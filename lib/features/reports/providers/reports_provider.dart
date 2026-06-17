import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/export_history_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Report type enum
// ─────────────────────────────────────────────────────────────────────────────

enum ReportType { overall, classroom, subject }

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ReportsState {
  final ReportType reportType;
  final String selectedClass;   // used when reportType == classroom
  final String selectedSubject; // used when reportType == subject
  final String dateRange;
  final List<ExportHistoryModel> allHistory;
  final bool showAllHistory;
  final bool isGenerating;
  final bool isLoading;

  const ReportsState({
    this.reportType = ReportType.overall,
    this.selectedClass = '',
    this.selectedSubject = '',
    required this.dateRange,
    required this.allHistory,
    this.showAllHistory = false,
    this.isGenerating = false,
    this.isLoading = false,
  });

  /// Human-readable summary of the current scope selection.
  String get scopeLabel {
    switch (reportType) {
      case ReportType.overall:
        return 'Overall (All Classes)';
      case ReportType.classroom:
        return selectedClass.isEmpty ? 'Select classroom' : selectedClass;
      case ReportType.subject:
        return selectedSubject.isEmpty ? 'Select subject' : selectedSubject;
    }
  }

  /// Shows up to 3 items unless expanded.
  List<ExportHistoryModel> get visibleHistory =>
      showAllHistory ? allHistory : allHistory.take(3).toList();

  ReportsState copyWith({
    ReportType? reportType,
    String? selectedClass,
    String? selectedSubject,
    String? dateRange,
    List<ExportHistoryModel>? allHistory,
    bool? showAllHistory,
    bool? isGenerating,
    bool? isLoading,
  }) =>
      ReportsState(
        reportType: reportType ?? this.reportType,
        selectedClass: selectedClass ?? this.selectedClass,
        selectedSubject: selectedSubject ?? this.selectedSubject,
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
          dateRange: 'Last 7 Days',
          allHistory: [],
        ));

  void selectReportType(ReportType type) =>
      state = state.copyWith(reportType: type);

  void selectClass(String classDisplay) =>
      state = state.copyWith(selectedClass: classDisplay);

  void selectSubject(String subject) =>
      state = state.copyWith(selectedSubject: subject);

  void selectDateRange(String range) =>
      state = state.copyWith(dateRange: range);

  void toggleShowAll() =>
      state = state.copyWith(showAllHistory: !state.showAllHistory);

  /// Simulates generating and adds the result to the top of history.
  Future<void> generateExport(String type) async {
    state = state.copyWith(isGenerating: true);
    await Future.delayed(const Duration(milliseconds: 1800));

    final scopeSlug = switch (state.reportType) {
      ReportType.overall => 'Overall',
      ReportType.classroom => state.selectedClass.isEmpty
          ? 'Class'
          : state.selectedClass.replaceAll(' ', '_'),
      ReportType.subject => state.selectedSubject.isEmpty
          ? 'Subject'
          : state.selectedSubject.replaceAll(' ', '_'),
    };

    final newExport = ExportHistoryModel(
      type: type,
      name: '${scopeSlug}_${type}_Report',
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
