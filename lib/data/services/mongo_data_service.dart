import 'package:dio/dio.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../models/teacher_profile_model.dart';
import 'api_service.dart';

abstract final class MongoDataService {
  // ── Internal helper ────────────────────────────────────────────────────────

  /// Message from the most recent failed request, or null after a success.
  /// Screens show it instead of silently falling back to sample data.
  static String? lastError;

  static const _unreachable =
      "Can't reach the EngageBot server. Check that the phone is on the same "
      'network as the server and that the server is running.';

  /// Runs [fetch]. On failure, records [lastError] and returns [empty] —
  /// never sample data, so a connection problem can't look like real classes.
  /// 401/403 are rethrown so auth handling still sees them.
  static Future<T> _withFallback<T>(
    Future<T?> Function() fetch,
    T Function() empty,
  ) async {
    try {
      final result = await fetch();
      lastError = null;
      return result ?? empty();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        rethrow;
      }
      lastError = e.response == null ? _unreachable : (e.message ?? _unreachable);
      return empty();
    } catch (_) {
      lastError = _unreachable;
      return empty();
    }
  }

  // ── Teacher profile ────────────────────────────────────────────────────────

  static Future<TeacherProfileModel> getTeacherProfile(String teacherId) =>
      _withFallback(
        () async {
          final data = await ApiService.getMyProfile();
          final subjectsList = data['subjects'];
          final subject = (subjectsList is List && subjectsList.isNotEmpty)
              ? subjectsList.whereType<String>().join(', ')
              : (data['department'] as String? ?? '');
          return TeacherProfileModel.fromJson({
            'name': data['name'] ?? '',
            'school': data['school'] ?? '',
            'subject': subject,
            'avatarUrl': data['avatarUrl'] ?? '',
          });
        },
        () => const TeacherProfileModel(
              name: '', school: '', subject: '', avatarUrl: ''),
      );

  static Future<void> updateTeacherName(String name) async {
    await ApiService.updateMyProfile({'name': name.trim()});
  }

  // ── Raw schedule list (for weekly schedule view) ──────────────────────────

  static Future<List<Map<String, dynamic>>> getSchedules(String teacherId) =>
      _withFallback(
        () async {
          if (teacherId.isEmpty) return null;
          final raw = await ApiService.getSchedules(teacherId: teacherId);
          return raw.cast<Map<String, dynamic>>();
        },
        () => <Map<String, dynamic>>[],
      );

  // ── Class list ─────────────────────────────────────────────────────────────

  static Future<List<ClassModel>> getClasses(String teacherId) =>
      _withFallback(
        () async {
          if (teacherId.isEmpty) return null;
          final raw = await ApiService.getSchedules(teacherId: teacherId);

          final seen = <String>{};
          final classes = <ClassModel>[];
          for (final s in raw) {
            final code = s['classGroup'] as String? ?? '';
            if (code.isEmpty || seen.contains(code)) continue;
            seen.add(code);
            classes.add(ClassModel.fromJson({
              'code': code,
              'subject': s['subject'] ?? '',
              'students': 0,
              'status': s['status'] == 'ongoing' ? 'online' : 'offline',
            }));
          }
          classes.sort((a, b) => a.code.compareTo(b.code));
          return classes;
        },
        () => <ClassModel>[],
      );

  // ── Teacher check-in (clears the "late" alert on the admin dashboard) ─────

  /// Checks the teacher in to one of their scheduled lessons.
  /// Returns the updated schedule entry. Throws with a readable message on failure.
  static Future<Map<String, dynamic>> checkIn(String scheduleId) async {
    try {
      return await ApiService.checkInSchedule(scheduleId);
    } on DioException catch (e) {
      throw ApiException(e.response == null ? _unreachable : (e.message ?? 'Check-in failed'));
    }
  }

  // ── Write — update a student (name only) ──────────────────────────────────

  static Future<void> updateStudent(
    String studentId,
    StudentModel student,
  ) async {
    try {
      await ApiService.updateStudent(studentId, {'name': student.name});
    } catch (_) {
      // Fire-and-forget — the in-memory overlay already updated the UI.
    }
  }

  // ── All students for a teacher ─────────────────────────────────────────────

  static Future<List<StudentModel>> getAllStudentsForTeacher(String teacherId) =>
      _withFallback(
        () async {
          if (teacherId.isEmpty) return null;
          final schedules = await ApiService.getSchedules(teacherId: teacherId);
          final classCodes = schedules
              .map((s) => s['classGroup'] as String?)
              .whereType<String>()
              .toSet();
          if (classCodes.isEmpty) return [];

          final students = <StudentModel>[];
          for (final code in classCodes) {
            final raw = await ApiService.getStudents(classGroup: code);
            students.addAll(raw.map((d) => StudentModel.fromJson({
                  'id': (d['id'] ?? d['_id'] ?? '').toString(),
                  'name': d['name'] ?? '',
                  // engagementLevel is computed by the API from session reports.
                  // Falls back to 'engaged' when no droid data exists yet.
                  'status': (d['engagementLevel'] as String?) ?? 'engaged',
                  'statusNote': d['statusNote'],
                  'classCode': d['classGroup'] ?? code,
                })));
          }
          return students;
        },
        () => <StudentModel>[],
      );

  // ── Roster for a single class ──────────────────────────────────────────────

  static Future<List<StudentModel>> getRosterForClass(
    String classCode,
    String teacherId,
  ) =>
      _withFallback(
        () async {
          if (teacherId.isEmpty) return null;
          if (classCode.isEmpty) return [];
          final raw = await ApiService.getStudents(classGroup: classCode);
          return raw.map((d) => StudentModel.fromJson({
                'id': (d['id'] ?? d['_id'] ?? '').toString(),
                'name': d['name'] ?? '',
                'status': _mapEngagementLevel(d['engagementLevel'] as String?),
                'statusNote': d['statusNote'],
              })).toList();
        },
        () => <StudentModel>[],
      );

  // ── Live session (droid data) ──────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getLiveSession(String classGroup) async {
    try {
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final reports = await ApiService.getSessionReports(date);
      if (reports.isEmpty) return null;

      final forClass = classGroup.isEmpty
          ? reports
          : reports
              .where((r) => (r['classGroup'] as String?) == classGroup)
              .toList();

      if (forClass.isEmpty) return null;

      final inProgress = forClass
          .where((r) => (r['status'] as String?) == 'in_progress')
          .toList();
      return (inProgress.isNotEmpty ? inProgress.last : forClass.last)
          as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Historical reports for one student ────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getStudentReports(
      String studentId, {String? name}) =>
      _withFallback(
        () async {
          if (studentId.isEmpty) return null;
          final raw = await ApiService.getStudentReports(studentId, name: name);
          return raw.cast<Map<String, dynamic>>();
        },
        () => <Map<String, dynamic>>[],
      );

  // ── Class engagement summary ───────────────────────────────────────────────

  static Future<Map<String, dynamic>> getClassSummary(
    String classGroup, {
    String? date,
  }) =>
      _withFallback(
        () async {
          if (classGroup.isEmpty) return null;
          return await ApiService.getClassSummary(classGroup, date: date);
        },
        () => <String, dynamic>{},
      );

  // ── Per-student engagement from session report ─────────────────────────────

  static Future<List<StudentModel>> getRosterWithEngagement(
    String classCode,
    String teacherId,
  ) async {
    final roster = await getRosterForClass(classCode, teacherId);
    if (roster.isEmpty) return roster;

    try {
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final reports = await ApiService.getSessionReports(date);
      final sessionReport = reports
          .where((r) =>
              (r['classGroup'] as String?) == classCode &&
              (r['status'] as String?) == 'in_progress')
          .lastOrNull as Map<String, dynamic>?;

      if (sessionReport == null) return roster;

      final engagements = (sessionReport['studentEngagements'] as List?) ?? [];
      final engMap = <String, Map<String, dynamic>>{
        for (final e in engagements)
          (e['studentId'] as String? ?? ''): e as Map<String, dynamic>,
      };

      return roster.map((s) {
        final eng = engMap[s.id];
        if (eng == null) return s;
        return StudentModel.fromJson({
          'id': s.id,
          'name': s.name,
          'status': _mapEngagementLevel(eng['engagementLevel'] as String?),
          'statusNote': s.statusNote,
          'classCode': s.classCode,
        });
      }).toList();
    } catch (_) {
      return roster;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _mapEngagementLevel(String? level) => switch (level) {
        'high' => 'engaged',
        'medium' => 'engaged',
        'low' => 'distracted',
        'absent' => 'flagged',
        _ => 'engaged',
      };
}
