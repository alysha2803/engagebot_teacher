import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/services/mongo_data_service.dart';
import '../../auth/providers/auth_provider.dart';
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
          classes: MockDataService.getClassesForTeacher(
              _ref.read(currentTeacherIdProvider) ?? ''),
          allStudents: [],
        )) {
    // Build initial student list from mock immediately (no wait).
    state = state.copyWith(allStudents: _buildAllStudents());

    // Re-initialise when the teacher signs in or changes account.
    _ref.listen<String?>(currentTeacherIdProvider, (_, next) {
      final teacherId = next ?? '';
      state = state.copyWith(
        classes: MockDataService.getClassesForTeacher(teacherId),
        allStudents: _buildAllStudents(teacherId: teacherId),
      );
      if (teacherId.isNotEmpty) refreshFromFirebase(teacherId);
    });

    // Apply edits on top of the current (real or mock) student list.
    _ref.listen<Map<String, StudentModel>>(
      studentEditsProvider,
      (_, edits) {
        final updated = state.allStudents.map((sw) {
          final edit = edits[sw.student.id];
          return edit != null
              ? StudentWithClass(student: edit, classCode: sw.classCode)
              : sw;
        }).toList();
        state = state.copyWith(allStudents: updated);
      },
    );

    // Kick off a Firebase refresh if the teacher is already signed in.
    Future.microtask(() {
      final id = _ref.read(currentTeacherIdProvider) ?? '';
      if (id.isNotEmpty) refreshFromFirebase(id);
    });

    // Re-sync whenever dashboardProvider refreshes its class list (e.g. every
    // 60 s or after the admin edits the schedule).
    _ref.listen<List<ClassModel>>(
      dashboardProvider.select((s) => s.classes),
      (prev, next) {
        if (next == prev) return;
        final id = _ref.read(currentTeacherIdProvider) ?? '';
        if (id.isNotEmpty) refreshFromFirebase(id);
      },
    );
  }

  /// Loads the real class list and full student roster from the API.
  Future<void> refreshFromFirebase(String teacherId) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);

    final classes = await MongoDataService.getClasses(teacherId);
    if (!mounted) return;

    final allFromFirebase =
        await MongoDataService.getAllStudentsForTeacher(teacherId);
    if (!mounted) return;

    // Count students per class code so ClassCard shows real numbers.
    final countByClass = <String, int>{};
    for (final s in allFromFirebase) {
      if (s.classCode != null && s.classCode!.isNotEmpty) {
        countByClass[s.classCode!] = (countByClass[s.classCode!] ?? 0) + 1;
      }
    }

    final updatedClasses = classes
        .map((c) => ClassModel(
              code: c.code,
              subject: c.subject,
              studentCount: countByClass[c.code] ?? 0,
              status: c.status,
            ))
        .toList();

    final edits = _ref.read(studentEditsProvider);
    final allStudents = allFromFirebase
        .where((s) => s.classCode != null)
        .map((s) => StudentWithClass(
              student: edits[s.id] ?? s,
              classCode: s.classCode!,
            ))
        .toList();

    state = state.copyWith(
      classes: updatedClasses,
      allStudents: allStudents,
      isLoading: false,
    );
  }

  List<StudentWithClass> _buildAllStudents({String? teacherId}) {
    final id = teacherId ?? _ref.read(currentTeacherIdProvider) ?? '';
    final edits = _ref.read(studentEditsProvider);
    return MockDataService.getAllClassRostersForTeacher(id)
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
