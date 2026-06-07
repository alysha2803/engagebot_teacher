import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/student_model.dart';
import '../../dashboard/providers/dashboard_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab enum
// ─────────────────────────────────────────────────────────────────────────────

enum ClassesTab { periods, students }

// ─────────────────────────────────────────────────────────────────────────────
// StudentWithClass — student model + which class they belong to
// ─────────────────────────────────────────────────────────────────────────────

class StudentWithClass {
  final StudentModel student;
  final String classCode;

  const StudentWithClass({required this.student, required this.classCode});
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ClassesState {
  final List<ClassModel> classes;
  final List<StudentWithClass> allStudents;
  final ClassesTab activeTab;
  final String searchQuery;
  final String? statusFilter; // null = show all
  final bool isLoading;

  const ClassesState({
    required this.classes,
    required this.allStudents,
    this.activeTab = ClassesTab.periods,
    this.searchQuery = '',
    this.statusFilter,
    this.isLoading = false,
  });

  // ── Periods tab ────────────────────────────────────────────────────────────

  List<ClassModel> get filteredClasses {
    var list = searchQuery.isEmpty
        ? classes
        : classes
            .where((c) =>
                c.code.toLowerCase().contains(searchQuery.toLowerCase()) ||
                c.subject.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
    if (statusFilter != null) {
      list = list.where((c) => c.status == statusFilter).toList();
    }
    return list;
  }

  // ── Students tab ───────────────────────────────────────────────────────────

  // Priority: flagged (0) → distracted (1) → engaged (2)
  static const _attentionOrder = {'flagged': 0, 'distracted': 1, 'engaged': 2};

  List<StudentWithClass> get filteredStudents {
    var list = allStudents;

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where((sw) =>
              sw.student.name.toLowerCase().contains(q) ||
              sw.classCode.toLowerCase().contains(q))
          .toList();
    }

    if (statusFilter != null) {
      list = list.where((sw) => sw.student.status == statusFilter).toList();
    }

    return List.of(list)
      ..sort((a, b) =>
          (_attentionOrder[a.student.status] ?? 3)
              .compareTo(_attentionOrder[b.student.status] ?? 3));
  }

  ClassesState copyWith({
    List<ClassModel>? classes,
    List<StudentWithClass>? allStudents,
    ClassesTab? activeTab,
    String? searchQuery,
    String? statusFilter,
    bool clearStatusFilter = false,
    bool? isLoading,
  }) =>
      ClassesState(
        classes: classes ?? this.classes,
        allStudents: allStudents ?? this.allStudents,
        activeTab: activeTab ?? this.activeTab,
        searchQuery: searchQuery ?? this.searchQuery,
        statusFilter:
            clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ClassesNotifier extends StateNotifier<ClassesState> {
  final Ref _ref;

  ClassesNotifier(this._ref)
      : super(ClassesState(
          classes: MockDataService.getClasses(),
          allStudents: [],
        )) {
    // Build initial student list
    state = state.copyWith(allStudents: _buildAllStudents());

    // Keep the student list in sync whenever a name/status is edited from
    // the Dashboard (both screens share studentEditsProvider).
    _ref.listen<Map<String, StudentModel>>(
      studentEditsProvider,
      (_, __) => state = state.copyWith(allStudents: _buildAllStudents()),
    );
  }

  List<StudentWithClass> _buildAllStudents() {
    final edits = _ref.read(studentEditsProvider);
    return MockDataService.getAllClassRosters()
        .expand((entry) => entry.value.map((baseStudent) => StudentWithClass(
              student: edits[baseStudent.id] ?? baseStudent,
              classCode: entry.key,
            )))
        .toList();
  }

  void setTab(ClassesTab tab) =>
      state = state.copyWith(activeTab: tab, clearStatusFilter: true);

  void search(String query) => state = state.copyWith(searchQuery: query);

  void setStatusFilter(String? filter) =>
      state = state.copyWith(clearStatusFilter: filter == null, statusFilter: filter);
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final classesProvider =
    StateNotifierProvider<ClassesNotifier, ClassesState>(
  (ref) => ClassesNotifier(ref),
);
