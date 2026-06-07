import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/observation_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Student Profile state
// ─────────────────────────────────────────────────────────────────────────────

class StudentProfileState {
  final StudentProfile profile;
  final List<ObservationModel> observations;
  final String activeFilter; // observation category filter
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
  StudentProfileNotifier(String studentId)
      : super(StudentProfileState(
          // TODO: Replace with droid student engagement API
          profile: MockDataService.getStudentProfile(studentId),
          observations: MockDataService.getObservations(),
        ));

  void setFilter(String filter) => state = state.copyWith(activeFilter: filter);

  /// Add a new observation note.
  void addObservation(ObservationModel obs) {
    state = state.copyWith(
      observations: [...state.observations, obs],
    );
  }

  /// Update an existing observation by id.
  void updateObservation(ObservationModel updated) {
    state = state.copyWith(
      observations: state.observations
          .map((o) => o.id == updated.id ? updated : o)
          .toList(),
    );
  }

  /// Delete an observation by id.
  void deleteObservation(String id) {
    state = state.copyWith(
      observations: state.observations.where((o) => o.id != id).toList(),
    );
  }
}

/// Family provider — keyed by studentId so each profile gets its own state.
final studentProfileProvider = StateNotifierProvider.family<
    StudentProfileNotifier, StudentProfileState, String>(
  (ref, studentId) => StudentProfileNotifier(studentId),
);
