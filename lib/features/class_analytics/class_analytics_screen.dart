import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../data/mock/mock_data_service.dart';
import '../../data/models/analytics_models.dart';
import '../../data/models/class_model.dart';
import '../../data/models/student_model.dart';
import '../../data/services/mongo_data_service.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../auth/providers/auth_provider.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../dashboard/widgets/ai_recommendation_card.dart';

/// Class Analytics screen — pushed from Dashboard or Classes.
/// Tabs: Overview (UC-6.3) | Behaviour (UC-6.2) | History (UC-6.4)
class ClassAnalyticsScreen extends ConsumerStatefulWidget {
  final String classCode;

  const ClassAnalyticsScreen({super.key, required this.classCode});

  @override
  ConsumerState<ClassAnalyticsScreen> createState() =>
      _ClassAnalyticsScreenState();
}

class _ClassAnalyticsScreenState extends ConsumerState<ClassAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late ClassModel _cls;
  // Base roster from Firebase/mock — edits overlay is applied in build().
  List<StudentModel> _baseRoster = [];
  late Map<String, dynamic> _engagement;
  // Base behaviour data — edit names/status applied in build().
  List<StudentBehaviourRecord> _baseBehaviourData = [];
  late final List<WeeklyDataPoint> _weeklyTrend;
  late final List<SessionRecord> _sessionHistory;
  // studentId → latestFocusScore from droid (null = no droid data yet)
  Map<String, int> _droidScores = {};
  // The class's real, backend-computed average (SessionReport.avgFocusScore,
  // aggregated server-side) -- NOT recomputed client-side, so it always
  // matches what's actually stored, including sessions where every
  // recognized face is still unlabeled (see studentBreakdown below).
  int? _droidOverallScore;
  // Raw per-identity breakdown from the backend -- covers BOTH named
  // students and not-yet-labeled ("Unlabeled-XXXX") faces. Split into
  // identified/unidentified reactively in build() against the live roster,
  // rather than here, since the roster can still be loading when this
  // resolves.
  List<Map<String, dynamic>> _studentBreakdown = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);

    // Prefer Firebase-aware class list from dashboardProvider; fall back to
    // teacher-scoped mock so Rahman's classes are found correctly.
    final teacherId = ref.read(currentTeacherIdProvider) ?? '';
    final fbClasses = ref.read(dashboardProvider).classes;
    final allClasses = fbClasses.isNotEmpty
        ? fbClasses
        : MockDataService.getClassesForTeacher(teacherId);
    _cls = allClasses.firstWhere(
      (c) => c.code == widget.classCode,
      orElse: () => allClasses.isNotEmpty ? allClasses.first
          : MockDataService.getClasses().first,
    );

    _baseRoster = MockDataService.getRosterForClass(_cls.code);
    _engagement = MockDataService.getClassEngagement(_cls.code);
    _baseBehaviourData = MockDataService.getBehaviourData(_cls.code);
    _weeklyTrend = MockDataService.getWeeklyTrend(_cls.code);
    _sessionHistory = MockDataService.getSessionHistory(_cls.code);

    // Replace mock roster with live Firebase data + droid scores.
    _loadRosterFromFirebase();
    _loadDroidScores();
  }

  Future<void> _loadDroidScores() async {
    final summary = await MongoDataService.getClassSummary(widget.classCode);
    final breakdown = (summary['studentBreakdown'] as List?) ?? [];
    if (!mounted) return;
    final scores = {
      for (final s in breakdown)
        (s['studentId'] as String? ?? ''):
            (s['latestFocusScore'] as num?)?.toInt() ??
            (s['avgFocusScore'] as num?)?.toInt() ?? 0,
    };
    setState(() {
      _droidScores = scores;
      // latestAvgFocusScore is that ONE most-recent session's own stored
      // MongoDB value -- what the card should show. summary['avgFocusScore']
      // is an average ACROSS every session ever held for this class, which
      // is a different (and, for "what's happening right now", wrong) number.
      _droidOverallScore = (summary['latestAvgFocusScore'] as num?)?.toInt();
      _studentBreakdown = breakdown.cast<Map<String, dynamic>>();
    });
  }

  Future<void> _loadRosterFromFirebase() async {
    final teacherId = ref.read(currentTeacherIdProvider) ?? '';
    if (teacherId.isEmpty || !mounted) return;
    final fbRoster = await MongoDataService.getRosterForClass(
        widget.classCode, teacherId);
    if (!mounted) return;
    setState(() {
      _baseRoster = fbRoster;
      // Derive behaviour records from the real roster. Engagement metrics
      // (score, attention minutes, off-task count) will come from the droid
      // once it is available; until then use neutral placeholders.
      _baseBehaviourData = fbRoster
          .map((s) => StudentBehaviourRecord(
                studentId: s.id,
                studentName: s.name,
                engagementScore: 75,
                attentionMinutes: 30,
                offTaskCount: 0,
                dominantStatus: s.status,
              ))
          .toList();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reactively apply in-session edits (name/status/note changes from Manage).
    final edits = ref.watch(studentEditsProvider);
    final roster = _baseRoster.map((s) => edits[s.id] ?? s).toList();

    // A droid-tracked identity with no matching real roster entry is a face
    // the droid has seen and scored but nobody's labeled yet ("Unlabeled-XXXX").
    // Computed here (not in _loadDroidScores) so it's always correct against
    // whichever roster is currently loaded, regardless of which async call
    // (roster vs droid scores) happens to resolve first.
    final rosterIds = roster.map((s) => s.id).toSet();
    final unidentified = _studentBreakdown
        .where((s) => !rosterIds.contains(s['studentId'] as String? ?? ''))
        .toList();
    final behaviourData = _baseBehaviourData.map((r) {
      final edit = edits[r.studentId];
      if (edit == null) return r;
      return StudentBehaviourRecord(
        studentId: r.studentId,
        studentName: edit.name,
        engagementScore: r.engagementScore,
        attentionMinutes: r.attentionMinutes,
        offTaskCount: r.offTaskCount,
        dominantStatus: edit.status,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _cls.code,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Text(
              _cls.subject,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: context.colorOnCard,
          unselectedLabelColor: context.colorMuted,
          indicatorColor: AppColors.primaryGreen,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Behaviour'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _OverviewTab(
            cls: _cls,
            roster: roster,
            engagement: _engagement,
            droidScores: _droidScores,
            droidOverallScore: _droidOverallScore,
            unidentified: unidentified,
            aiRec: MockDataService.getAIRecommendation(),
          ),
          _BehaviourTab(behaviourData: behaviourData, droidScores: _droidScores),
          _HistoryTab(
            weeklyTrend: _weeklyTrend,
            sessionHistory: _sessionHistory,
          ),
        ],
      ),
    );
  }
}

// Shared helper: derive engaged/distracted/flagged from droid score.
// Falls back to roster status when no droid data is available for the student.
String _engagementCategory(String studentId, String fallbackStatus, Map<String, int> scores) {
  final score = scores[studentId];
  if (score == null) return fallbackStatus;
  if (score >= 65) return 'engaged';
  if (score >= 35) return 'distracted';
  return 'flagged';
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — Overview  (UC-6.3)
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final ClassModel cls;
  final List<StudentModel> roster;
  final Map<String, dynamic> engagement;
  final Map<String, int> droidScores;
  final int? droidOverallScore;
  final List<Map<String, dynamic>> unidentified;
  final Map<String, dynamic> aiRec;

  const _OverviewTab({
    required this.cls,
    required this.roster,
    required this.engagement,
    required this.droidScores,
    required this.unidentified,
    required this.aiRec,
    this.droidOverallScore,
  });

  @override
  Widget build(BuildContext context) {
    final onlineCount = roster.where((s) => _engagementCategory(s.id, s.status, droidScores) == 'engaged').length;
    final distractedCount = roster.where((s) => _engagementCategory(s.id, s.status, droidScores) == 'distracted').length;
    final flaggedCount = roster.where((s) => _engagementCategory(s.id, s.status, droidScores) == 'flagged').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Engagement card
          _ClassEngagementCard(
            percentage: droidOverallScore ?? engagement['percentage'] as int,
            trend: engagement['trend'] as String,
            sessionMinutes: engagement['sessionMinutes'] as int,
            studentCount: cls.studentCount,
            onlineCount: onlineCount,
            isOnline: cls.isOnline,
          ),
          const SizedBox(height: 16),

          // Live class snapshot (UC-6.3)
          _ClassSnapshotCard(
            engagedCount: onlineCount,
            distractedCount: distractedCount,
            flaggedCount: flaggedCount,
          ),
          const SizedBox(height: 16),

          // AI Recommendation
          AIRecommendationCard(
            text: aiRec['text'] as String,
            highlightWord: aiRec['highlightWord'] as String,
            actionLabel: aiRec['action'] as String,
            onApply: () {},
          ),
          const SizedBox(height: 24),

          // Class Roster
          SectionHeader(
            title: 'Class Roster',
            trailing: Text(
              '$onlineCount Online',
              style: TextStyle(fontSize: 13, color: context.colorMuted),
            ),
          ),
          const SizedBox(height: 12),

          AppCard(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              itemCount: roster.length,
              itemBuilder: (context, index) {
                final student = roster[index];
                return _StudentTile(
                  student: student,
                  onTap: () => context.push('/students/${student.id}'),
                );
              },
            ),
          ),

          if (unidentified.isNotEmpty) ...[
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Unidentified Students',
              trailing: Text(
                '${unidentified.length}',
                style: TextStyle(fontSize: 13, color: context.colorMuted),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'The droid has tracked these faces but nobody\'s labeled them '
              'yet -- open Identify Students to assign a name.',
              style: TextStyle(fontSize: 12, color: context.colorSubtle),
            ),
            const SizedBox(height: 12),
            for (final s in unidentified)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _UnidentifiedStudentTile(data: s),
              ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — Behaviour  (UC-6.2)
// ─────────────────────────────────────────────────────────────────────────────

class _BehaviourTab extends StatelessWidget {
  final List<StudentBehaviourRecord> behaviourData;
  final Map<String, int> droidScores;

  const _BehaviourTab({
    required this.behaviourData,
    this.droidScores = const {},
  });

  @override
  Widget build(BuildContext context) {
    final engagedList = behaviourData
        .where((r) => _engagementCategory(r.studentId, r.dominantStatus, droidScores) == 'engaged')
        .toList();
    final distractedList = behaviourData
        .where((r) => _engagementCategory(r.studentId, r.dominantStatus, droidScores) == 'distracted')
        .toList();
    final flaggedList = behaviourData
        .where((r) => _engagementCategory(r.studentId, r.dominantStatus, droidScores) == 'flagged')
        .toList();

    final total = behaviourData.length;
    final avgScore = total == 0
        ? 0
        : (behaviourData.map((r) => r.engagementScore).reduce((a, b) => a + b) /
                total)
            .round();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Behaviour summary card
          _BehaviourSummaryCard(
            engagedCount: engagedList.length,
            distractedCount: distractedList.length,
            flaggedCount: flaggedList.length,
            avgScore: avgScore,
            total: total,
          ),
          const SizedBox(height: 24),

          Text(
            'Student Behaviour Detail',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.colorOnCard,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sorted by concern level · tap a student for full profile',
            style: TextStyle(fontSize: 12, color: context.colorMuted),
          ),
          const SizedBox(height: 12),

          ...behaviourData.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BehaviourStudentRow(record: record),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — History  (UC-6.4)
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final List<WeeklyDataPoint> weeklyTrend;
  final List<SessionRecord> sessionHistory;

  const _HistoryTab({
    required this.weeklyTrend,
    required this.sessionHistory,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyAvg = weeklyTrend.isEmpty
        ? 0
        : (weeklyTrend.map((p) => p.engagement).reduce((a, b) => a + b) /
                weeklyTrend.length)
            .round();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          _WeeklyTrendCard(
            weeklyTrend: weeklyTrend,
            weeklyAvg: weeklyAvg,
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              const Icon(Icons.history, size: 16, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text(
                'Past Sessions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.colorOnCard,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...sessionHistory.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SessionRecordCard(record: record),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets — Overview
// ─────────────────────────────────────────────────────────────────────────────

class _ClassEngagementCard extends StatelessWidget {
  final int percentage;
  final String trend;
  final int sessionMinutes;
  final int studentCount;
  final int onlineCount;
  final bool isOnline;

  const _ClassEngagementCard({
    required this.percentage,
    required this.trend,
    required this.sessionMinutes,
    required this.studentCount,
    required this.onlineCount,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final trendUp = trend.startsWith('+');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.liveRed : Colors.white54,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isOnline ? 'LIVE SESSION' : 'OFFLINE',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: trendUp ? Colors.greenAccent : Colors.redAccent,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 14,
                        color: trendUp ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Overall Engagement',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '$onlineCount / $studentCount students online',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '${sessionMinutes}m session',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClassSnapshotCard extends StatelessWidget {
  final int engagedCount;
  final int distractedCount;
  final int flaggedCount;

  const _ClassSnapshotCard({
    required this.engagedCount,
    required this.distractedCount,
    required this.flaggedCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = engagedCount + distractedCount + flaggedCount;
    if (total == 0) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Class Snapshot',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.colorOnCard,
            ),
          ),
          const SizedBox(height: 12),

          // Distribution bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                if (engagedCount > 0)
                  Expanded(
                    flex: engagedCount,
                    child: Container(
                        height: 10, color: AppColors.successGreen),
                  ),
                if (distractedCount > 0) ...[
                  const SizedBox(width: 2),
                  Expanded(
                    flex: distractedCount,
                    child: Container(
                        height: 10, color: AppColors.warningAmber),
                  ),
                ],
                if (flaggedCount > 0) ...[
                  const SizedBox(width: 2),
                  Expanded(
                    flex: flaggedCount,
                    child: Container(height: 10, color: AppColors.liveRed),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _SnapStat(
                count: engagedCount,
                label: 'Engaged',
                color: AppColors.successGreen,
              ),
              const SizedBox(width: 16),
              _SnapStat(
                count: distractedCount,
                label: 'Distracted',
                color: AppColors.warningAmber,
              ),
              const SizedBox(width: 16),
              _SnapStat(
                count: flaggedCount,
                label: 'Flagged',
                color: AppColors.liveRed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnapStat extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SnapStat({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$count $label',
          style: TextStyle(
            fontSize: 12,
            color: context.colorSubtle,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StudentTile extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;

  const _StudentTile({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: context.colorAvatarBg,
                child: Text(
                  student.name.isNotEmpty ? student.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: -2,
                child: StatusDot(status: student.status, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            student.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: context.colorOnCard,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// A droid-tracked face with no matching real roster entry -- taps open to
// show its per-individual focus/distraction/participation numbers, taken
// straight from the backend's class-summary breakdown (itself sourced from
// the student's latest SessionReport entry in MongoDB).
class _UnidentifiedStudentTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const _UnidentifiedStudentTile({required this.data});

  Color _levelColor(String level) => switch (level) {
        'high' => AppColors.successGreen,
        'medium' => AppColors.warningAmber,
        _ => AppColors.liveRed,
      };

  @override
  Widget build(BuildContext context) {
    final name = data['studentName'] as String? ?? 'Unidentified';
    final focus = (data['latestFocusScore'] as num?)?.toInt() ?? 0;
    final participation = (data['latestParticipationScore'] as num?)?.toInt() ?? 0;
    final distracted = (data['distractedCount'] as num?)?.toInt() ?? 0;
    final level = data['latestEngagementLevel'] as String? ?? 'medium';
    final sessions = (data['sessions'] as num?)?.toInt() ?? 1;
    final col = _levelColor(level);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: context.colorAvatarBg,
            child: Icon(Icons.person_outline, color: context.colorMuted, size: 20),
          ),
          title: Text(
            name,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colorOnCard),
          ),
          subtitle: Text(
            'Not yet labeled · $sessions session${sessions == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 12, color: context.colorSubtle),
          ),
          trailing: SageChip(label: level, fontSize: 10),
          children: [
            Row(
              children: [
                Expanded(child: _MiniStat(label: 'Focus', value: '$focus%', color: col)),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat(label: 'Participation', value: '$participation%', color: AppColors.primaryGreen)),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat(label: 'Distractions', value: '$distracted', color: AppColors.liveRed)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: context.colorMuted)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets — Behaviour
// ─────────────────────────────────────────────────────────────────────────────

class _BehaviourSummaryCard extends StatelessWidget {
  final int engagedCount;
  final int distractedCount;
  final int flaggedCount;
  final int avgScore;
  final int total;

  const _BehaviourSummaryCard({
    required this.engagedCount,
    required this.distractedCount,
    required this.flaggedCount,
    required this.avgScore,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class Behaviour Overview',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnCard,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Current session · $total students',
                      style: TextStyle(fontSize: 12, color: context.colorMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Avg $avgScore%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _BehaviourMetricTile(
                  count: engagedCount,
                  label: 'Engaged',
                  color: AppColors.successGreen,
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BehaviourMetricTile(
                  count: distractedCount,
                  label: 'Distracted',
                  color: AppColors.warningAmber,
                  icon: Icons.remove_circle_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BehaviourMetricTile(
                  count: flaggedCount,
                  label: 'Flagged',
                  color: AppColors.liveRed,
                  icon: Icons.flag_outlined,
                ),
              ),
            ],
          ),

          if (flaggedCount + distractedCount > 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 13, color: AppColors.warningAmber),
                const SizedBox(width: 6),
                Text(
                  '${flaggedCount + distractedCount} student${(flaggedCount + distractedCount) > 1 ? 's' : ''} may need attention',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colorSubtle,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BehaviourMetricTile extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const _BehaviourMetricTile({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: context.colorMuted),
          ),
        ],
      ),
    );
  }
}

class _BehaviourStudentRow extends StatelessWidget {
  final StudentBehaviourRecord record;

  const _BehaviourStudentRow({required this.record});

  Color get _statusColor => switch (record.dominantStatus) {
        'flagged' => AppColors.liveRed,
        'distracted' => AppColors.warningAmber,
        _ => AppColors.successGreen,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/students/${record.studentId}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.colorCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.cardShadow,
          border: Border(
            left: BorderSide(color: _statusColor, width: 4),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: context.colorAvatarBg,
              child: Text(
                record.studentName.isNotEmpty ? record.studentName[0] : '?',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.studentName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colorOnCard,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 11, color: context.colorMuted),
                      const SizedBox(width: 3),
                      Text(
                        '${record.attentionMinutes}m on-task',
                        style:
                            TextStyle(fontSize: 11, color: context.colorMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Engagement score badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${record.engagementScore}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _statusColor,
                ),
              ),
            ),

            if (record.offTaskCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.liveRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${record.offTaskCount}×',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.liveRed,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: context.colorMuted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets — History
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklyTrendCard extends StatelessWidget {
  final List<WeeklyDataPoint> weeklyTrend;
  final int weeklyAvg;

  const _WeeklyTrendCard({
    required this.weeklyTrend,
    required this.weeklyAvg,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = context.colorBorder;
    final mutedColor = context.colorMuted;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Engagement Trend',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnCard,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last 7 days',
                      style: TextStyle(
                          fontSize: 12, color: context.colorMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Avg $weeklyAvg%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: 100,
                minY: 0,
                barGroups: weeklyTrend.asMap().entries.map((e) {
                  final isToday = e.key == 6;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.engagement.toDouble(),
                        color: isToday
                            ? AppColors.primaryGreen
                            : AppColors.primaryGreen.withValues(alpha: 0.4),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: borderColor,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= weeklyTrend.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          weeklyTrend[idx].dayLabel,
                          style: TextStyle(fontSize: 10, color: mutedColor),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10, color: mutedColor),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionRecordCard extends StatelessWidget {
  final SessionRecord record;

  const _SessionRecordCard({required this.record});

  Color get _engagementColor {
    if (record.avgEngagement >= 85) return AppColors.successGreen;
    if (record.avgEngagement >= 70) return AppColors.warningAmber;
    return AppColors.liveRed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
        border: Border(
          left: BorderSide(color: _engagementColor, width: 4),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.date,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.colorOnCard,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _engagementColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${record.avgEngagement}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _engagementColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: context.colorMuted),
              const SizedBox(width: 4),
              Text(
                '${record.durationMinutes} min',
                style: TextStyle(fontSize: 12, color: context.colorMuted),
              ),
              const SizedBox(width: 12),
              Icon(Icons.people_outline, size: 12, color: context.colorMuted),
              const SizedBox(width: 4),
              Text(
                '${record.studentCount} students',
                style: TextStyle(fontSize: 12, color: context.colorMuted),
              ),
              if (record.flaggedCount > 0) ...[
                const SizedBox(width: 12),
                Icon(Icons.flag_outlined,
                    size: 12, color: AppColors.liveRed.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Text(
                  '${record.flaggedCount} flagged',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.liveRed.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),

          Text(
            record.highlight,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: context.colorSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
