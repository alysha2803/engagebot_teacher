import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../data/mock/mock_data_service.dart';
import '../../data/models/export_history_model.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'providers/reports_provider.dart';

/// Reports & Export — Tab 2.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _scrollController = ScrollController();
  final _historyKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll to history ────────────────────────────────────────────────────

  void _scrollToHistory() {
    final ctx = _historyKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
  }

  // ── Class picker ─────────────────────────────────────────────────────────

  void _showClassPicker() {
    final classes = MockDataService.getClasses();
    final current = ref.read(reportsProvider).selectedClass;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Select Class',
        child: Column(
          children: classes.map((cls) {
            final label = '${cls.code} : ${cls.subject}';
            final selected = label == current;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                label,
                style: TextStyle(
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? AppColors.primaryGreen
                      : AppColors.textPrimary,
                ),
              ),
              trailing: selected
                  ? const Icon(Icons.check,
                      color: AppColors.primaryGreen, size: 18)
                  : null,
              onTap: () {
                ref.read(reportsProvider.notifier).selectClass(label);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Date range picker ────────────────────────────────────────────────────

  void _showDateRangePicker() {
    const presets = [
      'Last 7 Days',
      'Last 14 Days',
      'Last 30 Days',
      'This Month',
      'Last 3 Months',
    ];
    final current = ref.read(reportsProvider).dateRange;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Select Date Range',
        child: Column(
          children: [
            ...presets.map((preset) {
              final selected = current.startsWith(preset);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  preset,
                  style: TextStyle(
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected
                        ? AppColors.primaryGreen
                        : AppColors.textPrimary,
                  ),
                ),
                trailing: selected
                    ? const Icon(Icons.check,
                        color: AppColors.primaryGreen, size: 18)
                    : null,
                onTap: () {
                  ref.read(reportsProvider.notifier).selectDateRange(preset);
                  Navigator.pop(context);
                },
              );
            }),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Custom Range…'),
              leading: const Icon(Icons.date_range,
                  size: 18, color: AppColors.textSecondary),
              onTap: () async {
                Navigator.pop(context);
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2023),
                  lastDate: DateTime.now(),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primaryGreen,
                        onPrimary: Colors.white,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null && mounted) {
                  final fmt = _fmtDate(picked.start);
                  final fmtEnd = _fmtDate(picked.end);
                  ref.read(reportsProvider.notifier).selectDateRange(
                      '$fmt – $fmtEnd');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${_month(d.month)} ${d.day}, ${d.year}';

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];

  // ── Generate export ──────────────────────────────────────────────────────

  Future<void> _generateExport(String type) async {
    // Show generating dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primaryGreen),
            ),
            const SizedBox(height: 20),
            Text(
              'Generating $type report…',
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              ref.read(reportsProvider).selectedClass,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );

    await ref.read(reportsProvider.notifier).generateExport(type);

    if (mounted) Navigator.of(context).pop(); // dismiss dialog
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('$type report generated and saved to History'),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ── Edit schedule ────────────────────────────────────────────────────────

  void _showEditSchedule() {
    final state = ref.read(reportsProvider);
    String selectedDay = state.scheduledDay;
    String selectedTime = state.scheduledTime;
    String selectedFormat = state.scheduledFormat;

    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
      'Sunday'
    ];
    const times = ['7:00 AM', '8:00 AM', '12:00 PM', '4:00 PM', '6:00 PM'];
    const formats = ['PDF', 'CSV'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => _BottomSheet(
          title: 'Edit Schedule',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day
              const _SheetLabel('Day'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: days.map((d) {
                  final sel = d == selectedDay;
                  return GestureDetector(
                    onTap: () => setSheet(() => selectedDay = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primaryGreen
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        d.substring(0, 3),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: sel ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Time
              const _SheetLabel('Time'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: times.map((t) {
                  final sel = t == selectedTime;
                  return GestureDetector(
                    onTap: () => setSheet(() => selectedTime = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primaryGreen
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: sel ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Format
              const _SheetLabel('Format'),
              const SizedBox(height: 8),
              Row(
                children: formats.map((f) {
                  final sel = f == selectedFormat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setSheet(() => selectedFormat = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primaryGreen
                              : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                sel ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(reportsProvider.notifier).updateSchedule(
                          day: selectedDay,
                          time: selectedTime,
                          format: selectedFormat,
                        );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Schedule updated: $selectedDay at $selectedTime ($selectedFormat)'),
                        backgroundColor: AppColors.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Schedule',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Share / download feedback ─────────────────────────────────────────────

  void _showShareSnackBar(ExportHistoryModel item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${item.name}.${item.type.toLowerCase()}…'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDownloadSnackBar(ExportHistoryModel item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download_done_outlined,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                  '${item.name}.${item.type.toLowerCase()} saved to Downloads'),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final notifier = ref.read(reportsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Reports & Export',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primaryGreen),
            tooltip: 'Jump to History',
            onPressed: _scrollToHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Report Filters Card ──────────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune,
                          size: 18, color: AppColors.primaryGreen),
                      SizedBox(width: 8),
                      Text(
                        'Report Filters',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select the parameters for your engagement data export.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Class selector
                  const Text(
                    'Active Class Session',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _FilterRow(
                    icon: Icons.group_outlined,
                    label: state.selectedClass,
                    onTap: _showClassPicker,
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 12),

                  // Date range
                  const Text(
                    'Date Range',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _FilterRow(
                    icon: Icons.calendar_today_outlined,
                    label: state.dateRange,
                    onTap: _showDateRangePicker,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Quick Export ─────────────────────────────────────────────
            const Text(
              'QUICK EXPORT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ExportCard(
                    iconBg: AppColors.primaryGreenDark,
                    icon: Icons.description_outlined,
                    title: 'PDF Summary',
                    description:
                        'Visual engagement charts and AI behaviour analysis',
                    onTap: () => _generateExport('PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExportCard(
                    iconBg: const Color(0xFF3D8B7F),
                    icon: Icons.table_chart_outlined,
                    title: 'CSV Data',
                    description:
                        'Raw student engagement logs for analysis',
                    onTap: () => _generateExport('CSV'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Scheduled Summaries ──────────────────────────────────────
            AppCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: notifier.toggleScheduled,
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.schedule,
                              size: 18,
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Scheduled Summaries',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                state.scheduledSummaryLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: state.scheduledExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),

                  // Expandable detail
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: state.scheduledExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(
                              height: 1, color: AppColors.borderLight),
                          const SizedBox(height: 12),
                          Text(
                            'Your scheduled ${state.scheduledFormat} summary is generated every ${state.scheduledDay} at ${state.scheduledTime} and sent to your registered email.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: _showEditSchedule,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.primaryGreen),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  foregroundColor: AppColors.primaryGreen,
                                ),
                                child: const Text('Edit Schedule',
                                    style: TextStyle(fontSize: 13)),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: () => _generateExport(
                                    state.scheduledFormat),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.borderLight),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  foregroundColor: AppColors.textSecondary,
                                ),
                                child: const Text('Run Now',
                                    style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── History ──────────────────────────────────────────────────
            SectionHeader(
              key: _historyKey,
              title: 'HISTORY',
              trailing: TextButton(
                onPressed: notifier.toggleShowAll,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: Text(
                  state.showAllHistory ? 'Show Less' : 'View All',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (state.allHistory.isEmpty)
              const Center(
                child: Text(
                  'No exports yet.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              )
            else
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: state.visibleHistory.asMap().entries.map((e) {
                    final isLast =
                        e.key == state.visibleHistory.length - 1;
                    return Column(
                      children: [
                        _HistoryRow(
                          item: e.value,
                          onShare: () => _showShareSnackBar(e.value),
                          onDownload: () =>
                              _showDownloadSnackBar(e.value),
                        ),
                        if (!isLast)
                          const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: AppColors.borderLight,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),

            if (!state.showAllHistory && state.allHistory.length > 3) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: notifier.toggleShowAll,
                  child: Text(
                    '+ ${state.allHistory.length - 3} more',
                    style: const TextStyle(
                        color: AppColors.primaryGreen, fontSize: 13),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Footer ───────────────────────────────────────────────────
            const Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: AppColors.textMuted, size: 22),
                  SizedBox(height: 6),
                  Text(
                    'EngageBot reports are verified by AI analysis\nfor accuracy in behavioural patterns.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable bottom sheet shell
// ─────────────────────────────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _BottomSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet label helper
// ─────────────────────────────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter row
// ─────────────────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FilterRow(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Export card
// ─────────────────────────────────────────────────────────────────────────────

class _ExportCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ExportCard({
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'Generate Now →',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History row
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  final ExportHistoryModel item;
  final VoidCallback onShare;
  final VoidCallback onDownload;

  const _HistoryRow({
    required this.item,
    required this.onShare,
    required this.onDownload,
  });

  Color get _badgeColor =>
      item.type == 'PDF'
          ? AppColors.primaryGreenDark
          : const Color(0xFF3D8B7F);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // File type badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                item.type,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _badgeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.date}  ·  ${item.size}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          IconButton(
            icon: const Icon(Icons.share_outlined,
                size: 18, color: AppColors.textMuted),
            onPressed: onShare,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 16,
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.download_outlined,
                size: 18, color: AppColors.textMuted),
            onPressed: onDownload,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 16,
          ),
        ],
      ),
    );
  }
}
