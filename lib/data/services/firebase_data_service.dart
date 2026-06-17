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

  // The API returns ClassSchedule records. We group them into ClassModel
  // by classGroup name so the existing UI keeps working unchanged.
  static Future<List<ClassModel>> getClasses(String teacherId) =>
      _withFallback(
        () async {
          if (teacherId.isEmpty) return null;
          final raw = await ApiService.getSchedules(teacherId: teacherId);
          if (raw.isEmpty) return null;

          // Deduplicate: one ClassModel per unique classGroup.
          final seen = <String>{};
          final classes = <ClassModel>[];
          for (final s in raw) {
            final code = s['classGroup'] as String? ?? '';
            if (seen.contains(code)) continue;
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
          // Get all classes for this teacher, then fetch students per class.
          final schedules = await ApiService.getSchedules(teacherId: teacherId);
          final classCodes = schedules
              .map((s) => s['classGroup'] as String?)
              .whereType<String>()
              .toSet();
          if (classCodes.isEmpty) return null;

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
          return students.isEmpty ? null : students;
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
          final raw = await ApiService.getStudents(classGroup: classCode);
          if (raw.isEmpty) return null;
          return raw.map((d) => StudentModel.fromJson({
                'id': (d['id'] ?? d['_id'] ?? '').toString(),
                'name': d['name'] ?? '',
                'status': d['status'] ?? 'engaged',
                'statusNote': d['statusNote'],
              })).toList();
        },
        () => MockDataService.getRosterForClassByTeacher(classCode, teacherId),
      );
}
