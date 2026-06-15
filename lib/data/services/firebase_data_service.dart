import 'package:cloud_firestore/cloud_firestore.dart';
import '../mock/mock_data_service.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../models/teacher_profile_model.dart';

// Firestore collection names — match whatever the admin app writes.
const _kTeachers = 'teachers';
const _kClasses = 'classes';
const _kStudents = 'students';

/// Reads data from Firestore.
/// Every method falls back to the corresponding MockDataService call when:
///   • the query returns 0 documents
///   • Firestore is unreachable (network error, permission error, etc.)
///   • the operation times out (> 6 s)
///
/// This means the app always has data to show, even before the admin has
/// populated the database or when running offline.
abstract final class FirebaseDataService {
  static final _db = FirebaseFirestore.instance;

  // ── Internal helper ────────────────────────────────────────────────────────

  static Future<T> _withFallback<T>(
    Future<T?> Function() fetch,
    T Function() fallback,
  ) async {
    try {
      final result = await fetch().timeout(const Duration(seconds: 6));
      return result ?? fallback();
    } catch (_) {
      return fallback();
    }
  }

  // ── Teacher profile ────────────────────────────────────────────────────────

  // Firestore document: teachers/{teacherId}
  //   name      : string
  //   school    : string   (optional — defaults to mock)
  //   subject   : string   (optional)
  //   avatarUrl : string   (optional)
  static Future<TeacherProfileModel> getTeacherProfile(String teacherId) =>
      _withFallback(
        () async {
          final doc =
              await _db.collection(_kTeachers).doc(teacherId).get();
          if (!doc.exists) return null;
          final d = doc.data()!;
          return TeacherProfileModel.fromJson({
            'name': d['name'] ?? '',
            'school': d['school'] ?? d['schoolName'] ?? '',
            'subject': d['subject'] ?? '',
            'avatarUrl': d['avatarUrl'] ?? '',
          });
        },
        MockDataService.getTeacherProfile,
      );

  // ── Class list ─────────────────────────────────────────────────────────────

  // Firestore documents: classes/{classId}
  //   code         : string   e.g. "1 USAHA"
  //   subject      : string
  //   teacherId    : string   (foreign key)
  //   studentCount : number
  //   status       : "online" | "offline"
  static Future<List<ClassModel>> getClasses(String teacherId) =>
      _withFallback(
        () async {
          final snap = await _db
              .collection(_kClasses)
              .where('teacherId', isEqualTo: teacherId)
              .orderBy('code')
              .get();
          if (snap.docs.isEmpty) return null;
          return snap.docs.map((doc) {
            final d = doc.data();
            return ClassModel.fromJson({
              'code': d['code'] ?? doc.id,
              'subject': d['subject'] ?? '',
              'students': d['studentCount'] ?? 0,
              'status': d['status'] ?? 'offline',
            });
          }).toList();
        },
        () => MockDataService.getClassesForTeacher(teacherId),
      );

  // ── Write — update a student document ────────────────────────────────────

  // Persists name/status/statusNote edits to Firestore.
  // Fire-and-forget: callers update the in-memory overlay immediately so the
  // UI never waits on this write.
  static Future<void> updateStudent(
      String studentId, StudentModel student) async {
    try {
      await _db.collection(_kStudents).doc(studentId).update({
        'name': student.name,
        'status': student.status,
        'statusNote': student.statusNote ?? '',
      }).timeout(const Duration(seconds: 10));
    } catch (_) {
      // Silently ignore — studentEditsProvider holds the in-session edit.
    }
  }

  // ── All students for a teacher (one query) ────────────────────────────────

  // Returns every student for the given teacher, each with `classCode` set.
  // Used by ClassesNotifier to populate the Students tab without N separate
  // per-class queries.
  static Future<List<StudentModel>> getAllStudentsForTeacher(
          String teacherId) =>
      _withFallback(
        () async {
          final snap = await _db
              .collection(_kStudents)
              .where('teacherId', isEqualTo: teacherId)
              .get();
          if (snap.docs.isEmpty) return null;
          return snap.docs.map((doc) {
            final d = doc.data();
            return StudentModel.fromJson({
              'id': doc.id,
              'name': d['name'] ?? '',
              'status': d['status'] ?? 'engaged',
              'statusNote': d['statusNote'],
              'classCode': d['classCode'],
            });
          }).toList();
        },
        () => MockDataService.getAllStudentsWithClassForTeacher(teacherId),
      );

  // ── Roster for a single class ──────────────────────────────────────────────

  // Firestore documents: students/{studentId}
  //   name      : string
  //   classCode : string   matches ClassModel.code
  //   teacherId : string   (foreign key)
  //   status    : "engaged" | "distracted" | "flagged"
  //   statusNote: string   (optional)
  static Future<List<StudentModel>> getRosterForClass(
    String classCode,
    String teacherId,
  ) =>
      _withFallback(
        () async {
          final snap = await _db
              .collection(_kStudents)
              .where('teacherId', isEqualTo: teacherId)
              .where('classCode', isEqualTo: classCode)
              .get();
          if (snap.docs.isEmpty) return null;
          return snap.docs.map((doc) {
            final d = doc.data();
            return StudentModel.fromJson({
              'id': doc.id,
              'name': d['name'] ?? '',
              'status': d['status'] ?? 'engaged',
              'statusNote': d['statusNote'],
            });
          }).toList();
        },
        () => MockDataService.getRosterForClassByTeacher(classCode, teacherId),
      );
}
