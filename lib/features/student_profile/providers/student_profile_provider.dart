import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/observation_model.dart';
import '../../classes/providers/classes_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Student Profile state
// ─────────────────────────────────────────────────────────────────────────────

class StudentProfileState {
  final StudentProfile profile;
  final List<ObservationModel> observations;
  final String activeFilter;
  final bool isLoading;

  const StudentProfileState({
    required this.profile,
    required this.observations,
    this.activeFilter = 'Participation',
    this.isLoading = false,
  });

  StudentProfileState copyWith({
    StudentProfile? profile,
    List<ObservationModel>? observations,
    String? activeFilter,
    bool? isLoading,
  }) =>
      StudentProfileState(
        profile: profile ?? this.profile,
        observations: observations ?? this.observations,
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

    // When classesProvider loads real students from DB, update name + class.
    ref.listen<List<StudentWithClass>>(
      classesProvider.select((s) => s.allStudents),
      (_, students) {
        final match = students
            .where((sw) => sw.student.id == _studentId)
            .firstOrNull;
        if (match == null) return;
        final edits = ref.read(studentEditsProvider);
        final name = edits[_studentId]?.name ?? match.student.name;
        state = state.copyWith(
          profile: state.profile.copyWith(
            name: name,
            className: match.classCode,
          ),
        );
      },
    );
  }

  static StudentProfileState _buildInitialState(
    String studentId,
    Map<String, StudentModel> edits,
    List<StudentWithClass> allStudents,
  ) {
    // Look up the real student from the DB-loaded class roster.
    final realStudent = allStudents
        .where((sw) => sw.student.id == studentId)
        .firstOrNull;

    // Prefer: explicit edit override → real DB name → mock fallback.
    final name = edits[studentId]?.name ?? realStudent?.student.name;
    final classCode = realStudent?.classCode;

    // Build mock profile template then overlay real name/class.
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
