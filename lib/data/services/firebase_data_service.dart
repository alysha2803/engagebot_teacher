import 'package:dio/dio.dart';
import '../mock/mock_data_service.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../models/teacher_profile_model.dart';
import 'api_service.dart';

// Renamed from FirebaseDataService — keeps the same public API so all callers
// work without changes. Data now comes from the REST API instead of Firestore.
abstract final class FirebaseDataService {
  // ── Internal helper ────────────────────────────────────────────────────────

  static Future<T> _withFallback<T>(
    Future<T?> Function() fetch,
    T Function() fallback,
  ) async {
    try {
      final result = await fetch();
      return result ?? fallback();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        rethrow; // Auth errors should propagate, not silently fall back.
      }
      return fallback();
    } catch (_) {
      return fallback();
    }
  }

  // ── Teacher profile ────────────────────────────────────────────────────────

  static Future<TeacherProfileModel> getTeacherProfile(String teacherId) =>
      _withFallback(
        () async {
          final data = await ApiService.getMyProfile();
          return TeacherProfileModel.fromJson({
            'name': data['name'] ?? '',
            'school': data['school'] ?? '',
            'subject': data['department'] ?? data['subject'] ?? '',
            'avatarUrl': data['avatarUrl'] ?? '',
          });
        },
        MockDataService.getTeacherProfile,
      );

  // ── Class list ─────────────────────────────────────────────────────────────

  static Future<List<ClassModel>> getClasses(String teacherId) =>
      _withFallback(
        () async {
          // Empty teacherId means no auth — use mock so dev mode still works.
          if (teacherId.isEmpty) return null;
          final raw = await ApiService.getSchedules(teacherId: teacherId);

          // Deduplicate: one ClassModel per unique classGroup.
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
          // Return the list even if empty — shows "no classes" instead of mock.
          return classes;
        },
        () => MockDataService.getClassesForTeacher(teacherId),
      );

  // ── Write — update a student ───────────────────────────────────────────────

  static Future<void> updateStudent(
    String studentId,
    StudentModel student,
  ) async {
    try {
      await ApiService.updateStudent(studentId, {
        'name': student.name,
        'status': student.status,
        'statusNote': student.statusNote ?? '',
      });
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
                  'status': d['status'] ?? 'engaged',
                  'statusNote': d['statusNote'],
                  'classCode': d['classGroup'] ?? code,
                })));
          }
          return students; // empty list = no students in DB yet
        },
        () => MockDataService.getAllStudentsWithClassForTeacher(teacherId),
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
          // Returns empty list if no students — no mock fallback.
        },
        () => MockDataService.getRosterForClassByTeacher(classCode, teacherId),
      );

  // ── Live session (droid data) ──────────────────────────────────────────────

  // Returns the active or most recent session report for today.
  // Returns null when no droid has reported yet (UI keeps mock placeholder).
  static Future<Map<String, dynamic>?> getLiveSession(String classGroup) async {
    try {
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final reports = await ApiService.getSessionReports(date);
      if (reports.isEmpty) return null;

      // Prefer an in-progress session for this class; fall back to latest.
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

  // ── Per-student engagement from session report ─────────────────────────────

  // Overlays droid engagement levels onto a roster fetched from the students API.
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

  // Maps droid engagementLevel → app student status string.
  static String _mapEngagementLevel(String? level) => switch (level) {
        'high' => 'engaged',
        'medium' => 'engaged',
        'low' => 'distracted',
        'absent' => 'flagged',
        _ => 'engaged',
      };
}
