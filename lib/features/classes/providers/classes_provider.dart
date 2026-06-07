import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/models/class_model.dart';

enum ClassesTab { periods, roster }

class ClassesState {
  final List<ClassModel> classes;
  final ClassesTab activeTab;
  final String searchQuery;
  final bool isLoading;

  const ClassesState({
    required this.classes,
    this.activeTab = ClassesTab.periods,
    this.searchQuery = '',
    this.isLoading = false,
  });

  List<ClassModel> get filtered => searchQuery.isEmpty
      ? classes
      : classes
          .where((c) =>
              c.code.toLowerCase().contains(searchQuery.toLowerCase()) ||
              c.subject.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

  ClassesState copyWith({
    List<ClassModel>? classes,
    ClassesTab? activeTab,
    String? searchQuery,
    bool? isLoading,
  }) =>
      ClassesState(
        classes: classes ?? this.classes,
        activeTab: activeTab ?? this.activeTab,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
      );
}

class ClassesNotifier extends StateNotifier<ClassesState> {
  ClassesNotifier()
      : super(ClassesState(classes: MockDataService.getClasses()));

  void setTab(ClassesTab tab) => state = state.copyWith(activeTab: tab);

  void search(String query) => state = state.copyWith(searchQuery: query);
}

final classesProvider =
    StateNotifierProvider<ClassesNotifier, ClassesState>(
  (ref) => ClassesNotifier(),
);
