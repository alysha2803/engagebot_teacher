import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/export_history_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ReportsState {
  final String selectedClass;
  final String dateRange;
  final List<ExportHistoryModel> allHistory;
  final bool showAllHistory;
  final bool isGenerating;
  final bool isLoading;

  const ReportsState({
    required this.selectedClass,
    required this.dateRange,
    required this.allHistory,
    this.showAllHistory = false,
    this.isGenerating = false,
    this.isLoading = false,
  });

  /// Shows up to 3 items unless expanded.
  List<ExportHistoryModel> get visibleHistory =>
      showAllHistory ? allHistory : allHistory.take(3).toList();

  ReportsState copyWith({
    String? selectedClass,
    String? dateRange,
    List<ExportHistoryModel>? allHistory,
    bool? showAllHistory,
    bool? isGenerating,
    bool? isLoading,
  }) =>
      ReportsState(
        selectedClass: selectedClass ?? this.selectedClass,
        dateRange: dateRange ?? this.dateRange,
        allHistory: allHistory ?? this.allHistory,
        showAllHistory: showAllHistory ?? this.showAllHistory,
        isGenerating: isGenerating ?? this.isGenerating,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier()
      : super(const ReportsState(
          selectedClass: '',
          dateRange: 'Last 7 Days',
          allHistory: [],
        ));

  void selectClass(String classDisplay) =>
      state = state.copyWith(selectedClass: classDisplay);

  void selectDateRange(String range) =>
      state = state.copyWith(dateRange: range);

  void toggleShowAll() =>
      state = state.copyWith(showAllHistory: !state.showAllHistory);

  /// Simulates generating and adds the result to the top of history.
  Future<void> generateExport(String type) async {
    state = state.copyWith(isGenerating: true);
    await Future.delayed(const Duration(milliseconds: 1800));

    final classCode = state.selectedClass.isEmpty
        ? 'Class'
        : state.selectedClass
            .split(' : ')
            .first
            .trim()
            .replaceAll(' ', '_');

    final newExport = ExportHistoryModel(
      type: type,
      name: '${classCode}_${type}_Report',
      date: 'Today',
      size: type == 'PDF' ? '1.8 MB' : '315 KB',
    );

    state = state.copyWith(
      isGenerating: false,
      allHistory: [newExport, ...state.allHistory],
      showAllHistory: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>(
  (ref) => ReportsNotifier(),
);
