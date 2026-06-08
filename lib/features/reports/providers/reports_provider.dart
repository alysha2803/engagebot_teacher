import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/models/export_history_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ReportsState {
  final String selectedClass;
  final String dateRange;
  final List<ExportHistoryModel> allHistory;
  final bool showAllHistory;
  final bool scheduledExpanded;
  final String scheduledDay;
  final String scheduledTime;
  final String scheduledFormat;
  final bool isGenerating;
  final bool isLoading;

  const ReportsState({
    required this.selectedClass,
    required this.dateRange,
    required this.allHistory,
    this.showAllHistory = false,
    this.scheduledExpanded = false,
    this.scheduledDay = 'Monday',
    this.scheduledTime = '8:00 AM',
    this.scheduledFormat = 'PDF',
    this.isGenerating = false,
    this.isLoading = false,
  });

  /// Shows up to 3 items unless expanded.
  List<ExportHistoryModel> get visibleHistory =>
      showAllHistory ? allHistory : allHistory.take(3).toList();

  /// "Next: Monday at 8:00 AM" label shown in the card.
  String get scheduledSummaryLabel => 'Next: $scheduledDay at $scheduledTime';

  ReportsState copyWith({
    String? selectedClass,
    String? dateRange,
    List<ExportHistoryModel>? allHistory,
    bool? showAllHistory,
    bool? scheduledExpanded,
    String? scheduledDay,
    String? scheduledTime,
    String? scheduledFormat,
    bool? isGenerating,
    bool? isLoading,
  }) =>
      ReportsState(
        selectedClass: selectedClass ?? this.selectedClass,
        dateRange: dateRange ?? this.dateRange,
        allHistory: allHistory ?? this.allHistory,
        showAllHistory: showAllHistory ?? this.showAllHistory,
        scheduledExpanded: scheduledExpanded ?? this.scheduledExpanded,
        scheduledDay: scheduledDay ?? this.scheduledDay,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        scheduledFormat: scheduledFormat ?? this.scheduledFormat,
        isGenerating: isGenerating ?? this.isGenerating,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier()
      : super(ReportsState(
          selectedClass: '4 GIGIH : Add Maths',
          dateRange: 'Last 7 Days (Oct 12 – Oct 19)',
          // TODO: Replace with export history API
          allHistory: MockDataService.getExportHistory(),
        ));

  void selectClass(String classDisplay) =>
      state = state.copyWith(selectedClass: classDisplay);

  void selectDateRange(String range) =>
      state = state.copyWith(dateRange: range);

  void toggleScheduled() =>
      state = state.copyWith(scheduledExpanded: !state.scheduledExpanded);

  void toggleShowAll() =>
      state = state.copyWith(showAllHistory: !state.showAllHistory);

  void updateSchedule({
    required String day,
    required String time,
    required String format,
  }) =>
      state = state.copyWith(
        scheduledDay: day,
        scheduledTime: time,
        scheduledFormat: format,
      );

  /// Simulates generating and adds the result to the top of history.
  Future<void> generateExport(String type) async {
    state = state.copyWith(isGenerating: true);
    await Future.delayed(const Duration(milliseconds: 1800));

    final classCode = state.selectedClass
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
      showAllHistory: false, // collapse so the new item is visible at top
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
