import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../data/mock/mock_data_service.dart';
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

    final options = isPeriods
        ? [
            ('All Classes', null),
            ('Online', 'online'),
            ('Offline', 'offline'),
          ]
        : [
            ('All Students', null),
            ('Flagged', 'flagged'),
            ('Distracted', 'distracted'),
            ('Engaged', 'engaged'),
          ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          String? current = ref.read(classesProvider).statusFilter;
          return Container(
            decoration: BoxDecoration(
              color: ctx.colorCard,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ctx.colorBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isPeriods ? 'Filter Classes' : 'Filter Students',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ctx.colorOnCard,
                  ),
                ),
                const SizedBox(height: 16),
                ...options.map((opt) {
                  final isSelected = current == opt.$2;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      opt.$1,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primaryGreen
                            : ctx.colorOnCard,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check,
                            color: AppColors.primaryGreen, size: 18)
                        : null,
                    onTap: () {
                      setSheetState(() => current = opt.$2);
                      notifier.setStatusFilter(opt.$2);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classesProvider);
    final notifier = ref.read(classesProvider.notifier);
    final insight = MockDataService.getDroidInsight();
    final isPeriods = state.activeTab == ClassesTab.periods;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: AppLogo(size: 32),
        ),
        title: const Text(
          'Classes & Students',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined,
                color: AppColors.primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
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

            // Active filter badge
            if (state.statusFilter != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colorIconBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Filter: ${state.statusFilter![0].toUpperCase()}${state.statusFilter!.substring(1)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => notifier.setStatusFilter(null),
                          child: const Icon(Icons.close,
                              size: 14, color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
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
              const SizedBox(height: 24),
              DroidInsightsSection(
                title: insight['title']!,
                description: insight['description']!,
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
