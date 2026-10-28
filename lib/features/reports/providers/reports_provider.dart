import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/models/export_history_model.dart';
import '../../../data/services/mongo_data_service.dart';

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

  /// Returns today's date as ISO string (e.g. "2026-06-18").
  static String _todayIso() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// True when the classroom+Today combination allows a real PDF download.
  bool get canDownloadPdf =>
      state.reportType == ReportType.classroom &&
      state.selectedClass.isNotEmpty &&
      state.dateRange == 'Today';

  /// Generates and shares a real PDF for classroom+Today; falls back to mock otherwise.
  Future<void> generateExport(String type) async {
    state = state.copyWith(isGenerating: true);

    if (type == 'PDF' && canDownloadPdf) {
      await _downloadClassroomPdf();
      state = state.copyWith(isGenerating: false);
      return;
    }

    // Mock path for all other combinations.
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

  Future<void> _downloadClassroomPdf() async {
    final classGroup = state.selectedClass;
    final today = _todayIso();

    // Fetch today's session data for this class.
    final summary = await MongoDataService.getClassSummary(classGroup, date: today);
    final breakdown = (summary['studentBreakdown'] as List?) ?? [];

    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (ctx) => [
        // Header
        pw.Text('EngageBot Engagement Report',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Classroom: $classGroup   |   Date: $today',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.Divider(height: 24),

        // Summary
        pw.Text('Session Summary',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (breakdown.isEmpty)
          pw.Text('No session data recorded for today.',
              style: const pw.TextStyle(color: PdfColors.grey600))
        else ...[
          _pdfSummaryRow(ctx, 'Total Students', '${breakdown.length}'),
          () {
            int eng = 0, dis = 0, flg = 0;
            int totalScore = 0;
            for (final s in breakdown) {
              final score = (s['latestFocusScore'] as num?)?.toInt() ??
                  (s['avgFocusScore'] as num?)?.toInt() ?? 0;
              totalScore += score;
              if (score >= 65) { eng++; }
              else if (score >= 35) { dis++; }
              else { flg++; }
            }
            final avg = breakdown.isEmpty ? 0 : (totalScore / breakdown.length).round();
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _pdfSummaryRow(ctx, 'Overall Engagement', '$avg%'),
                _pdfSummaryRow(ctx, 'Engaged (≥65%)', '$eng students'),
                _pdfSummaryRow(ctx, 'Distracted (35–64%)', '$dis students'),
                _pdfSummaryRow(ctx, 'Flagged (<35%)', '$flg students'),
              ],
            );
          }(),
        ],

        pw.SizedBox(height: 20),

        // Student breakdown table
        pw.Text('Student Breakdown',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (breakdown.isEmpty)
          pw.Text('No student data available.',
              style: const pw.TextStyle(color: PdfColors.grey600))
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('Student Name', bold: true),
                  _cell('Score', bold: true),
                  _cell('Category', bold: true),
                ],
              ),
              ...breakdown.map((s) {
                final name = s['studentName'] as String? ?? '—';
                final score = (s['latestFocusScore'] as num?)?.toInt() ??
                    (s['avgFocusScore'] as num?)?.toInt() ?? 0;
                final cat = score >= 65
                    ? 'Engaged'
                    : score >= 35
                        ? 'Distracted'
                        : 'Flagged';
                return pw.TableRow(children: [
                  _cell(name),
                  _cell('$score%'),
                  _cell(cat),
                ]);
              }),
            ],
          ),

        pw.SizedBox(height: 24),
        pw.Text('Generated by EngageBot Teacher App',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
      ],
    ));

    final bytes = await pdf.save();
    final filename = '${classGroup.replaceAll(' ', '_')}_$today.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  static pw.Widget _pdfSummaryRow(pw.Context ctx, String label, String value) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(children: [
          pw.Expanded(child: pw.Text(label,
              style: const pw.TextStyle(color: PdfColors.grey800))),
          pw.Text(value,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ]),
      );

  static pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(text,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            )),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>(
  (ref) => ReportsNotifier(),
);
