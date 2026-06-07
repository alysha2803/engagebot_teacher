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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classesProvider);
    final notifier = ref.read(classesProvider.notifier);
    final insight = MockDataService.getDroidInsight();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
            color: AppColors.textPrimary,
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
            ClassSearchBar(onChanged: notifier.search),

            const SizedBox(height: 16),

            // ── Period / Roster Toggle ──────────────────────────────────────
            PeriodRosterToggle(
              isPeriods: state.activeTab == ClassesTab.periods,
              onToggle: (isPeriods) => notifier.setTab(
                isPeriods ? ClassesTab.periods : ClassesTab.roster,
              ),
            ),

            const SizedBox(height: 20),

            // ── Class Grid ─────────────────────────────────────────────────
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ClassGrid(
                classes: state.filtered,
                onTap: (cls) {
                  // Navigate to the first student in the class as a demo
                  // TODO: show class-specific student list
                  context.go('/classes/students/${cls.code.toLowerCase().replaceAll(' ', '_')}');
                },
              ),

            const SizedBox(height: 24),

            // ── Droid Insights ─────────────────────────────────────────────
            DroidInsightsSection(
              title: insight['title']!,
              description: insight['description']!,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
