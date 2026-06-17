import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';

class WeeklyScheduleSection extends StatefulWidget {
  final List<Map<String, dynamic>> schedules;

  const WeeklyScheduleSection({super.key, required this.schedules});

  @override
  State<WeeklyScheduleSection> createState() => _WeeklyScheduleSectionState();
}

class _WeeklyScheduleSectionState extends State<WeeklyScheduleSection> {
  static const _allDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
  ];

  static const _dayOrder = {
    'monday': 0, 'tuesday': 1, 'wednesday': 2,
    'thursday': 3, 'friday': 4,
  };

  // null = "All"
  String? _dayFilter;
  String? _subjectFilter;
  String? _classroomFilter;

  @override
  void initState() {
    super.initState();
    // Default to today if a weekday.
    final weekday = DateTime.now().weekday; // 1=Mon … 5=Fri
    if (weekday >= 1 && weekday <= 5) {
      _dayFilter = _allDays[weekday - 1];
    }
  }

  List<Map<String, dynamic>> get _filtered {
    var list = List<Map<String, dynamic>>.from(widget.schedules);

    if (_dayFilter != null) {
      list = list.where((s) {
        return (s['day'] as String? ?? '').toLowerCase() ==
            _dayFilter!.toLowerCase();
      }).toList();
    }

    if (_subjectFilter != null) {
      list = list.where((s) => s['subject'] == _subjectFilter).toList();
    }

    if (_classroomFilter != null) {
      list = list.where((s) => s['classGroup'] == _classroomFilter).toList();
    }

    list.sort((a, b) {
      final aDay = _dayOrder[(a['day'] as String? ?? '').toLowerCase()] ?? 5;
      final bDay = _dayOrder[(b['day'] as String? ?? '').toLowerCase()] ?? 5;
      if (aDay != bDay) return aDay.compareTo(bDay);
      return (a['startTime'] as String? ?? '')
          .compareTo(b['startTime'] as String? ?? '');
    });

    return list;
  }

  List<String> get _subjects => widget.schedules
      .map((s) => s['subject'] as String? ?? '')
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<String> get _classrooms => widget.schedules
      .map((s) => s['classGroup'] as String? ?? '')
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final subjects = _subjects;
    final classrooms = _classrooms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Text(
          'Weekly Schedule',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.colorOnCard,
          ),
        ),
        const SizedBox(height: 12),

        // ── Dropdown filter row ──────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _ScheduleDropdown(
                hint: 'Day',
                value: _dayFilter,
                items: _allDays,
                onChanged: (v) => setState(() => _dayFilter = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ScheduleDropdown(
                hint: 'Subject',
                value: _subjectFilter,
                items: subjects,
                onChanged: (v) => setState(() => _subjectFilter = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ScheduleDropdown(
                hint: 'Classroom',
                value: _classroomFilter,
                items: classrooms,
                onChanged: (v) => setState(() => _classroomFilter = v),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Schedule list ────────────────────────────────────────────────────
        if (widget.schedules.isEmpty)
          _emptyCard(context, 'No schedule assigned yet.')
        else if (filtered.isEmpty)
          _emptyCard(context, 'No classes match the selected filters.')
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: filtered.asMap().entries.map((entry) {
                return _ScheduleTile(
                  schedule: entry.value,
                  isLast: entry.key == filtered.length - 1,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _emptyCard(BuildContext context, String message) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: context.colorMuted, fontSize: 13),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Styled dropdown for schedule filters
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _ScheduleDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value != null;
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryGreen.withValues(alpha: 0.08)
              : context.colorIconBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primaryGreen : context.colorBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isActive ? AppColors.primaryGreen : context.colorSubtle,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isActive ? Icons.close : Icons.arrow_drop_down,
              size: 16,
              color:
                  isActive ? AppColors.primaryGreen : context.colorMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    if (value != null) {
      // Tapping an active filter clears it.
      onChanged(null);
      return;
    }
    if (items.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DropdownSheet(
        title: hint,
        items: items,
        current: value,
        onSelect: (v) {
          onChanged(v);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Picker bottom sheet used by _ScheduleDropdown
// ─────────────────────────────────────────────────────────────────────────────

class _DropdownSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final String? current;
  final void Function(String) onSelect;

  const _DropdownSheet({
    required this.title,
    required this.items,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: context.colorBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.colorOnCard,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: items.map((item) {
                    final selected = item == current;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                          color: selected
                              ? AppColors.primaryGreen
                              : context.colorOnCard,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(Icons.check,
                              color: AppColors.primaryGreen, size: 18)
                          : null,
                      onTap: () => onSelect(item),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual schedule entry row
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleTile extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final bool isLast;

  const _ScheduleTile({required this.schedule, required this.isLast});

  Color _subjectColor(String subject) {
    const colors = {
      'Mathematics': Color(0xFF2563EB),
      'Add Maths': Color(0xFFD97706),
      'Bahasa Melayu': Color(0xFF854D0E),
      'English Language': Color(0xFF7C3AED),
      'Chemistry': Color(0xFF059669),
      'Physics': Color(0xFFDC2626),
      'Science': Color(0xFF0891B2),
      'Biology': Color(0xFF16A34A),
      'History': Color(0xFF4B5563),
      'P. Islam': Color(0xFF065F46),
    };
    return colors[subject] ?? AppColors.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    final subject = schedule['subject'] as String? ?? '';
    final classGroup = schedule['classGroup'] as String? ?? '';
    final startTime = schedule['startTime'] as String? ?? '';
    final endTime = schedule['endTime'] as String? ?? '';
    final day = schedule['day'] as String? ?? '';
    final status = schedule['status'] as String? ?? '';
    final color = _subjectColor(subject);
    final isOngoing = status == 'ongoing';

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: context.colorBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Subject colour bar
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Time
          SizedBox(
            width: 54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startTime,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.colorOnCard,
                  ),
                ),
                Text(
                  endTime,
                  style: TextStyle(fontSize: 11, color: context.colorMuted),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Subject + classroom + day
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colorOnCard,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.people_outline,
                        size: 12, color: context.colorMuted),
                    const SizedBox(width: 3),
                    Text(
                      classGroup,
                      style: TextStyle(
                          fontSize: 12, color: context.colorSubtle),
                    ),
                    if (day.isNotEmpty) ...[
                      Text('  ·  ',
                          style: TextStyle(
                              fontSize: 12, color: context.colorMuted)),
                      Text(
                        day,
                        style: TextStyle(
                            fontSize: 12, color: context.colorSubtle),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Ongoing badge
          if (isOngoing)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Ongoing',
                style: TextStyle(
                  fontSize: 11,
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
