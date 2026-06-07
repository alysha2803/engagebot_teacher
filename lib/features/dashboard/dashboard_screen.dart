import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/live_session_card.dart';
import 'widgets/class_selector_row.dart';
import 'widgets/ai_recommendation_card.dart';
import 'widgets/class_roster_section.dart';

/// Dashboard (Live Monitoring) — Tab 0.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.cardWhite,
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: AppLogo(size: 32),
        ),
        title: const Text(
          'Live Monitoring',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Live Session Card ──────────────────────────────────────────
            LiveSessionCard(
              percentage: state.liveEngagement['percentage'] as int,
              trend: state.liveEngagement['trend'] as String,
              sessionMinutes: state.liveEngagement['sessionMinutes'] as int,
              droidStatus: state.liveEngagement['droidStatus'] as String,
            ),

            const SizedBox(height: 24),

            // ── Select Class ───────────────────────────────────────────────
            SectionHeader(
              title: 'Select Class',
              trailing: TextButton(
                onPressed: () => context.go('/classes'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ClassSelectorRow(
              classes: state.classes,
              selectedIndex: state.selectedClassIndex,
              onSelect: (i) =>
                  ref.read(dashboardProvider.notifier).selectClass(i),
            ),

            const SizedBox(height: 20),

            // ── AI Recommendation ──────────────────────────────────────────
            AIRecommendationCard(
              text: state.aiRecommendation['text'] as String,
              highlightWord: state.aiRecommendation['highlightWord'] as String,
              actionLabel: state.aiRecommendation['action'] as String,
              onApply: () {},
            ),

            const SizedBox(height: 24),

            // ── Class Roster ───────────────────────────────────────────────
            ClassRosterSection(
              students: state.roster,
              onlineCount: state.roster
                  .where((s) => s.status == 'engaged')
                  .length,
              onStudentTap: (student) =>
                  context.go('/classes/students/${student.id}'),
              onManageTap: () => context.go('/classes'),
            ),

            const SizedBox(height: 20),

            // ── Bottom Action Row ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/reports'),
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text('Generate Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Details',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
