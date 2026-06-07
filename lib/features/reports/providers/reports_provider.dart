import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock/mock_data_service.dart';
import '../../../data/models/export_history_model.dart';

class ReportsState {
  final String selectedClass;
  final String dateRange;
  final List<ExportHistoryModel> history;
  final bool scheduledExpanded;
  final bool isLoading;

  const ReportsState({
    required this.selectedClass,
    required this.dateRange,
    required this.history,
    this.scheduledExpanded = false,
    this.isLoading = false,
  });

  ReportsState copyWith({
    String? selectedClass,
    String? dateRange,
    List<ExportHistoryModel>? history,
    bool? scheduledExpanded,
    bool? isLoading,
  }) =>
      ReportsState(
        selectedClass: selectedClass ?? this.selectedClass,
        dateRange: dateRange ?? this.dateRange,
        history: history ?? this.history,
        scheduledExpanded: scheduledExpanded ?? this.scheduledExpanded,
        isLoading: isLoading ?? this.isLoading,
      );
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier()
      : super(ReportsState(
          selectedClass: '4 GIGIH : Add Maths',
          dateRange: 'Last 7 Days (Oct 12 – Oct 19)',
          // TODO: Replace with export history API
          history: MockDataService.getExportHistory(),
        ));

  void toggleScheduled() => state =
      state.copyWith(scheduledExpanded: !state.scheduledExpanded);
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>(
  (ref) => ReportsNotifier(),
);
