import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/student_model.dart';

// ---------------------------------------------------------------------------
// Global student edits store
// Persists name/status/note edits across class switches and provider rebuilds.
// ---------------------------------------------------------------------------

final studentEditsProvider = StateProvider<Map<String, StudentModel>>(
  (ref) => {},
);

// ---------------------------------------------------------------------------
// Dashboard state
// ---------------------------------------------------------------------------

class DashboardState {
  final Map<String, dynamic> liveEngagement;
  final List<ClassModel> classes;
  final int selectedClassIndex;
  final List<StudentModel> roster;
  final Map<String, dynamic> aiRecommendation;
  final bool isLoading;

  const DashboardState({
    required this.liveEngagement,
    required this.classes,
    required this.selectedClassIndex,
    required this.roster,
    required this.aiRecommendation,
    this.isLoading = false,
  });

  DashboardState copyWith({
    Map<String, dynamic>? liveEngagement,
    List<ClassModel>? classes,
    int? selectedClassIndex,
    List<StudentModel>? roster,
    Map<String, dynamic>? aiRecommendation,
    bool? isLoading,
  }) =>
      DashboardState(
        liveEngagement: liveEngagement ?? this.liveEngagement,
        classes: classes ?? this.classes,
        selectedClassIndex: selectedClassIndex ?? this.selectedClassIndex,
        roster: roster ?? this.roster,
        aiRecommendation: aiRecommendation ?? this.aiRecommendation,
        isLoading: isLoading ?? this.isLoading,
      );
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref _ref;

  DashboardNotifier(this._ref)
      : super(DashboardState(
          liveEngagement: MockDataService.getLiveEngagement(),
          classes: MockDataService.getClasses(),
          selectedClassIndex: 0,
          roster: MockDataService.getRosterForClass('1 USAHA'),
          aiRecommendation: MockDataService.getAIRecommendation(),
        ));

  /// Merge a freshly-loaded roster with any persisted edits from the global store.
  List<StudentModel> _applyEdits(List<StudentModel> baseRoster) {
    final edits = _ref.read(studentEditsProvider);
    return baseRoster.map((s) => edits[s.id] ?? s).toList();
  }

  void selectClass(int index) {
    final classCode = state.classes[index].code;
    final baseRoster = MockDataService.getRosterForClass(classCode);
    state = state.copyWith(
      selectedClassIndex: index,
      // Always re-apply edits so changes survive class switching.
      roster: _applyEdits(baseRoster),
    );
  }

  void editStudent(String studentId, StudentModel updated) {
    // Persist to global store so other screens and future selectClass calls
    // pick up the change without hitting MockDataService again.
    _ref.read(studentEditsProvider.notifier).update(
      (map) => {...map, studentId: updated},
    );
    // Refresh the visible roster immediately.
    final roster =
        state.roster.map((s) => s.id == studentId ? updated : s).toList();
    state = state.copyWith(roster: roster);
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(ref),
);
