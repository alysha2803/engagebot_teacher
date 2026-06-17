import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/engagebot_scaffold.dart';
import 'providers/classes_provider.dart';
import 'widgets/classes_widgets.dart';

/// Classes & Students screen — Tab 1.
class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  // ── Filter bottom sheet ──────────────────────────────────────────────────

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final state = ref.read(classesProvider);
    final notifier = ref.read(classesProvider.notifier);
    final isPeriods = state.activeTab == ClassesTab.periods;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        if (isPeriods) {
          return _PeriodFilterSheet(
            current: state.statusFilter,
            onSelect: (v) {
              notifier.setStatusFilter(v);
              Navigator.of(context).pop();
            },
          );
        }
        return _StudentFilterSheet(
          currentStatus: state.statusFilter,
          currentSubject: state.subjectFilter,
          currentClassroom: state.classroomFilter,
          subjects: state.classes
              .map((c) => c.subject)
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList()
            ..sort(),
          classrooms: state.allStudents
              .map((sw) => sw.classCode)
              .toSet()
              .toList()
            ..sort(),
          onStatusSelect: notifier.setStatusFilter,
          onSubjectSelect: notifier.setSubjectFilter,
          onClassroomSelect: notifier.setClassroomFilter,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classesProvider);
    final notifier = ref.read(classesProvider.notifier);
    final isPeriods = state.activeTab == ClassesTab.periods;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () =>
              EngagebotDrawer.maybeOf(context)?.openDrawer(),
        ),
        title: const Text(
          'Classes & Students',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Search ─────────────────────────────────────────────────────
            ClassSearchBar(
              onChanged: notifier.search,
              onFilter: () => _showFilterSheet(context, ref),
            ),

            // Active filter badges
            if (state.statusFilter != null ||
                state.subjectFilter != null ||
                state.classroomFilter != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (state.statusFilter != null)
                    _ActiveFilterBadge(
                      label: state.statusFilter!,
                      onRemove: () => notifier.setStatusFilter(null),
                    ),
                  if (state.subjectFilter != null)
                    _ActiveFilterBadge(
                      label: state.subjectFilter!,
                      onRemove: () => notifier.setSubjectFilter(null),
                    ),
                  if (state.classroomFilter != null)
                    _ActiveFilterBadge(
                      label: state.classroomFilter!,
                      onRemove: () => notifier.setClassroomFilter(null),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // ── Period / Students Toggle ────────────────────────────────────
            PeriodRosterToggle(
              isPeriods: isPeriods,
              onToggle: (isPer) => notifier.setTab(
                isPer ? ClassesTab.periods : ClassesTab.students,
              ),
            ),

            const SizedBox(height: 20),

            // ── Content switches by tab ────────────────────────────────────
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (isPeriods) ...[
              // Periods — class grid
              ClassGrid(
                classes: state.filteredClasses,
                onTap: (cls) => context.push(
                  '/class-detail/${Uri.encodeComponent(cls.code)}',
                ),
              ),
            ] else ...[
              // Students — ranked attention list
              StudentAttentionList(
                students: state.filteredStudents,
                onTap: (sw) => context.push('/students/${sw.student.id}'),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active filter badge chip
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveFilterBadge extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterBadge({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final display = label[0].toUpperCase() + label.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorIconBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            display,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primaryGreen),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Periods filter sheet (simple: Online / Offline)
// ─────────────────────────────────────────────────────────────────────────────

class _PeriodFilterSheet extends StatefulWidget {
  final String? current;
  final void Function(String?) onSelect;

  const _PeriodFilterSheet({required this.current, required this.onSelect});

  @override
  State<_PeriodFilterSheet> createState() => _PeriodFilterSheetState();
}

class _PeriodFilterSheetState extends State<_PeriodFilterSheet> {
  static const _options = [
    ('All Classes', null),
    ('Online', 'online'),
    ('Offline', 'offline'),
  ];

  late String? _current;

  @override
  void initState() {
    super.initState();
    _current = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Filter Classes',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: context.colorOnCard,
            ),
          ),
          const SizedBox(height: 8),
          ..._options.map((opt) {
            final isSelected = _current == opt.$2;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                opt.$1,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primaryGreen : context.colorOnCard,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppColors.primaryGreen, size: 18)
                  : null,
              onTap: () {
                setState(() => _current = opt.$2);
                widget.onSelect(opt.$2);
              },
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Students filter sheet (engagement level + subject + classroom)
// ─────────────────────────────────────────────────────────────────────────────

class _StudentFilterSheet extends StatefulWidget {
  final String? currentStatus;
  final String? currentSubject;
  final String? currentClassroom;
  final List<String> subjects;
  final List<String> classrooms;
  final void Function(String?) onStatusSelect;
  final void Function(String?) onSubjectSelect;
  final void Function(String?) onClassroomSelect;

  const _StudentFilterSheet({
    required this.currentStatus,
    required this.currentSubject,
    required this.currentClassroom,
    required this.subjects,
    required this.classrooms,
    required this.onStatusSelect,
    required this.onSubjectSelect,
    required this.onClassroomSelect,
  });

  @override
  State<_StudentFilterSheet> createState() => _StudentFilterSheetState();
}

class _StudentFilterSheetState extends State<_StudentFilterSheet> {
  late String? _status;
  late String? _subject;
  late String? _classroom;

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
    _subject = widget.currentSubject;
    _classroom = widget.currentClassroom;
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colorSubtle,
          ),
        ),
      );

  Widget _optionTile(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primaryGreen : context.colorOnCard,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: AppColors.primaryGreen, size: 18)
            : null,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Filter Students',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: context.colorOnCard,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Engagement Level'),
                    _optionTile('All', _status == null,
                        () => setState(() { _status = null; widget.onStatusSelect(null); })),
                    _optionTile('Engaged', _status == 'engaged',
                        () => setState(() { _status = 'engaged'; widget.onStatusSelect('engaged'); })),
                    _optionTile('Distracted', _status == 'distracted',
                        () => setState(() { _status = 'distracted'; widget.onStatusSelect('distracted'); })),
                    _optionTile('Flagged', _status == 'flagged',
                        () => setState(() { _status = 'flagged'; widget.onStatusSelect('flagged'); })),

                    if (widget.subjects.isNotEmpty) ...[
                      _sectionLabel('Subject'),
                      _optionTile('All', _subject == null,
                          () => setState(() { _subject = null; widget.onSubjectSelect(null); })),
                      ...widget.subjects.map((s) => _optionTile(
                            s,
                            _subject == s,
                            () => setState(() { _subject = s; widget.onSubjectSelect(s); }),
                          )),
                    ],

                    if (widget.classrooms.isNotEmpty) ...[
                      _sectionLabel('Classroom'),
                      _optionTile('All', _classroom == null,
                          () => setState(() { _classroom = null; widget.onClassroomSelect(null); })),
                      ...widget.classrooms.map((c) => _optionTile(
                            c,
                            _classroom == c,
                            () => setState(() { _classroom = c; widget.onClassroomSelect(c); }),
                          )),
                    ],

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
