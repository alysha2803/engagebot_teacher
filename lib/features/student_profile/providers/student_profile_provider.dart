import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/models/analytics_models.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/observation_model.dart';
import '../../../data/services/mongo_data_service.dart';
import '../../../data/models/class_model.dart';
import '../../classes/providers/classes_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Student Profile state
// ─────────────────────────────────────────────────────────────────────────────

class StudentProfileState {
  final StudentProfile profile;
  final List<ObservationModel> observations;
  final List<SessionRecord> sessionHistory;
  final String activeFilter;
  final bool isLoading;

  const StudentProfileState({
    required this.profile,
    required this.observations,
    this.sessionHistory = const [],
    this.activeFilter = 'Participation',
    this.isLoading = false,
  });

  StudentProfileState copyWith({
    StudentProfile? profile,
    List<ObservationModel>? observations,
    List<SessionRecord>? sessionHistory,
    String? activeFilter,
    bool? isLoading,
  }) =>
      StudentProfileState(
        profile: profile ?? this.profile,
        observations: observations ?? this.observations,
        sessionHistory: sessionHistory ?? this.sessionHistory,
        activeFilter: activeFilter ?? this.activeFilter,
        isLoading: isLoading ?? this.isLoading,
      );
}

class StudentProfileNotifier extends StateNotifier<StudentProfileState> {
  final String _studentId;

  StudentProfileNotifier(String studentId, Ref ref)
      : _studentId = studentId,
        super(_buildInitialState(
          studentId,
          ref.read(studentEditsProvider),
          ref.read(classesProvider).allStudents,
        )) {
    // Keep name in sync when teacher edits it from the dashboard roster.
    ref.listen<Map<String, StudentModel>>(
      studentEditsProvider,
      (_, edits) {
        final override = edits[studentId];
        if (override != null) {
          state = state.copyWith(
            profile: state.profile.copyWith(name: override.name),
          );
        }
      },
    );

    // When classesProvider loads real students from DB, update name + class + subject.
    ref.listen<List<StudentWithClass>>(
      classesProvider.select((s) => s.allStudents),
      (_, students) {
        final match = students
            .where((sw) => sw.student.id == _studentId)
            .firstOrNull;
        if (match == null) return;
        final edits = ref.read(studentEditsProvider);
        final name = edits[_studentId]?.name ?? match.student.name;
        final classSubject = ref.read(classesProvider).classes
            .where((c) => c.code == match.classCode)
            .firstOrNull?.subject;
        state = state.copyWith(
          profile: state.profile.copyWith(
            name: name,
            className: match.classCode,
            subject: (classSubject?.isNotEmpty == true) ? classSubject : null,
          ),
        );
      },
    );

    // Update subject if the classes list loads after the roster.
    ref.listen<List<ClassModel>>(
      classesProvider.select((s) => s.classes),
      (_, classes) {
        if (state.profile.className.isEmpty) return;
        final cls = classes
            .where((c) => c.code == state.profile.className)
            .firstOrNull;
        final sub = cls?.subject;
        if (sub == null || sub.isEmpty) return;
        state = state.copyWith(
          profile: state.profile.copyWith(subject: sub),
        );
      },
    );

    // Load real droid data from session reports.
    Future.microtask(() => _loadDroidData(studentId, state.profile.name));
  }

  static StudentProfileState _buildInitialState(
    String studentId,
    Map<String, StudentModel> edits,
    List<StudentWithClass> allStudents,
  ) {
    final realStudent = allStudents
        .where((sw) => sw.student.id == studentId)
        .firstOrNull;

    final name = edits[studentId]?.name ?? realStudent?.student.name;
    final classCode = realStudent?.classCode;

    final baseProfile = MockDataService.getStudentProfile(studentId);
    final profile = baseProfile.copyWith(
      name: name ?? baseProfile.name,
      className: classCode ?? baseProfile.className,
    );

    return StudentProfileState(
      profile: profile,
      observations: MockDataService.getObservations(),
    );
  }

  // ── Load real data from droid session reports ──────────────────────────────

  Future<void> _loadDroidData(String studentId, String studentName) async {
    final reports = await MongoDataService.getStudentReports(studentId, name: studentName);
    if (reports.isEmpty || !mounted) return;

    // Extract this student's engagement from each report.
    final entries = <Map<String, dynamic>>[];
    for (final report in reports) {
      final engList = (report['studentEngagements'] as List?) ?? [];
      for (final eng in engList) {
        if ((eng['studentId'] as String? ?? '') == studentId) {
          entries.add({
            'date': report['date'] as String? ?? '',
            'subject': report['subject'] as String? ?? '',
            'classGroup': report['classGroup'] as String? ?? '',
            'startTime': report['startTime'] as String? ?? '',
            'endTime': report['endTime'] as String? ?? '',
            'focusScore': (eng['focusScore'] as num?)?.toInt() ?? 0,
            'engagementLevel': eng['engagementLevel'] as String? ?? 'medium',
            'distractedCount': (eng['distractedCount'] as num?)?.toInt() ?? 0,
          });
        }
      }
    }

    if (entries.isEmpty || !mounted) return;

    // Sort entries oldest → newest.
    entries.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

    final latest = entries.last;
    final latestLevel = latest['engagementLevel'] as String;
    // Use the latest session's score — not a cross-session average.
    final avgFocus = (latest['focusScore'] as int?) ?? 0;
    final totalDistracted = entries.fold<int>(
        0, (sum, e) => sum + (e['distractedCount'] as int));

    // ── Timeline from per-sample data in the latest session ────────────────
    // Each sample is {t: seconds_from_start, score: 0-100}.
    final rawTimeline = (latest['timeline'] as List?) ?? [];
    List<EngagementPoint> timeline;
    if (rawTimeline.isNotEmpty) {
      timeline = rawTimeline.map((p) {
        final t = (p['t'] as num?)?.toInt() ?? 0;
        final s = (p['score'] as num?)?.toDouble() ?? 0.0;
        final mins = t ~/ 60;
        final secs = (t % 60).toString().padLeft(2, '0');
        final label = '$mins:$secs';
        return EngagementPoint(timeLabel: label, value: s);
      }).toList();
    } else {
      // Fallback: one point per session.
      timeline = entries.map((e) => EngagementPoint(
        timeLabel: _shortDate(e['date'] as String),
        value: (e['focusScore'] as int).toDouble(),
      )).toList();
    }

    // ── Analytics from latest session ──────────────────────────────────────
    Map<String, int> poseDist = {};
    Map<String, int> exprDist = {};
    double avgEAR = 0.0;
    double avgMAR = 0.0;

    final pd = latest['poseDistribution'];
    if (pd is Map) {
      poseDist = {
        for (final e in pd.entries)
          e.key.toString(): (e.value as num).toInt(),
      };
    }
    final ed = latest['expressionDistribution'];
    if (ed is Map) {
      exprDist = {
        for (final e in ed.entries)
          e.key.toString(): (e.value as num).toInt(),
      };
    }
    avgEAR = (latest['avgEAR'] as num?)?.toDouble() ?? 0.0;
    avgMAR = (latest['avgMAR'] as num?)?.toDouble() ?? 0.0;

    // ── Session history ────────────────────────────────────────────────────
    final history = entries.reversed.map((e) {
      final dateStr = e['date'] as String;
      final dur = _parseDuration(e['startTime'] as String, e['endTime'] as String);
      return SessionRecord(
        date: _longDate(dateStr),
        classCode: e['classGroup'] as String,
        subject: e['subject'] as String,
        avgEngagement: e['focusScore'] as int,
        durationMinutes: dur,
        studentCount: 1,
        flaggedCount: e['distractedCount'] as int,
        highlight: _sessionHighlight(e['focusScore'] as int),
      );
    }).toList();

    final latestSubject = (latest['subject'] as String?)?.trim() ?? '';

    if (!mounted) return;
    state = state.copyWith(
      profile: state.profile.copyWith(
        avgEngagement: avgFocus,
        focusDepth: avgFocus,
        flags: totalDistracted,
        engagementLabel: _levelLabel(latestLevel),
        droidInsight: _buildInsight(avgFocus, totalDistracted, entries.length),
        timeline: timeline,
        poseDistribution: poseDist,
        expressionDistribution: exprDist,
        avgEAR: avgEAR,
        avgMAR: avgMAR,
        subject: latestSubject.isNotEmpty ? latestSubject : null,
      ),
      sessionHistory: history,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _levelLabel(String level) => switch (level) {
        'high' => 'High Focus',
        'medium' => 'On Track',
        'low' => 'Needs Support',
        _ => 'On Track',
      };

  static String _shortDate(String iso) {
    // "2026-06-18" → "Jun 18"
    final parts = iso.split('-');
    if (parts.length < 3) return iso;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    final d = int.tryParse(parts[2]) ?? 0;
    return '${months[m]} $d';
  }

  static String _longDate(String iso) {
    // "2026-06-18" → "18 Jun 2026"
    final parts = iso.split('-');
    if (parts.length < 3) return iso;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${parts[2]} ${months[m]} ${parts[0]}';
  }

  static int _parseDuration(String start, String end) {
    try {
      final sp = start.split(':');
      final ep = end.split(':');
      if (sp.length < 2 || ep.length < 2) return 0;
      final sm = int.parse(sp[0]) * 60 + int.parse(sp[1]);
      final em = int.parse(ep[0]) * 60 + int.parse(ep[1]);
      final diff = em - sm;
      return diff > 0 ? diff : 0;
    } catch (_) {
      return 0;
    }
  }

  static String _sessionHighlight(int score) {
    if (score >= 75) return 'Strong focus throughout the session';
    if (score >= 55) return 'Moderate engagement with some off-task moments';
    return 'Low engagement — consider following up with this student';
  }

  static String _buildInsight(int avgFocus, int totalDistracted, int sessions) {
    final s = sessions == 1 ? '1 session' : '$sessions sessions';
    if (avgFocus >= 75) {
      return 'Strong engagement across $s — $avgFocus% average focus. '
          '${totalDistracted > 5 ? "Address $totalDistracted distraction events with short check-ins." : "Current activities are working well — keep it up."}';
    } else if (avgFocus >= 50) {
      return 'Moderate engagement across $s ($avgFocus% average). '
          '${totalDistracted > 10 ? "$totalDistracted distraction events detected — try shorter task intervals." : "Occasional off-task moments; targeted prompts may help."}';
    } else {
      return 'Low engagement across $s ($avgFocus% average focus). '
          '$totalDistracted distraction events logged. Consider a direct check-in or adjusted pacing.';
    }
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  void setFilter(String filter) => state = state.copyWith(activeFilter: filter);

  void addObservation(ObservationModel obs) {
    state = state.copyWith(observations: [...state.observations, obs]);
  }

  void updateObservation(ObservationModel updated) {
    state = state.copyWith(
      observations: state.observations
          .map((o) => o.id == updated.id ? updated : o)
          .toList(),
    );
  }

  void deleteObservation(String id) {
    state = state.copyWith(
      observations: state.observations.where((o) => o.id != id).toList(),
    );
  }
}

final studentProfileProvider = StateNotifierProvider.family<
    StudentProfileNotifier, StudentProfileState, String>(
  (ref, studentId) => StudentProfileNotifier(studentId, ref),
);
