import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/student_model.dart';

// ---------------------------------------------------------------------------
// Live engagement state
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
  DashboardNotifier()
      : super(DashboardState(
          liveEngagement: MockDataService.getLiveEngagement(),
          classes: MockDataService.getClasses(),
          selectedClassIndex: 0,
          roster: MockDataService.getRosterForClass('1 USAHA'),
          aiRecommendation: MockDataService.getAIRecommendation(),
        ));

  void selectClass(int index) {
    final classCode = state.classes[index].code;
    state = state.copyWith(
      selectedClassIndex: index,
      roster: MockDataService.getRosterForClass(classCode),
    );
  }

  void editStudent(String studentId, StudentModel updated) {
    final roster =
        state.roster.map((s) => s.id == studentId ? updated : s).toList();
    state = state.copyWith(roster: roster);
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(),
);
