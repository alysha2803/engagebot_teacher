import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../data/mock/mock_data_service.dart';
import '../../data/models/analytics_models.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/live_session_card.dart';
import 'widgets/class_selector_row.dart';
import 'widgets/ai_recommendation_card.dart';
import 'widgets/class_roster_section.dart';

/// Dashboard (Live Monitoring) — Tab 0.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showTeachingRecommendations(BuildContext context) {
    final tips = MockDataService.getTeachingRecommendations();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeachingRecommendationsSheet(tips: tips),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: AppLogo(size: 32),
        ),
        title: const Text(
          'Live Monitoring',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
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
            // Tapping a class chip: selects it (updates roster preview) AND
            // navigates to the full Class Analytics page for that class.
            ClassSelectorRow(
              classes: state.classes,
              selectedIndex: state.selectedClassIndex,
              onSelect: (i) {
                notifier.selectClass(i);
                context.push(
                  '/class-detail/${Uri.encodeComponent(state.classes[i].code)}',
                );
              },
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
                  context.push('/students/${student.id}'),
              onStudentEdited: (updated) =>
                  notifier.editStudent(updated.id, updated),
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
                    onPressed: () => _showTeachingRecommendations(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: context.colorBorder),
                      foregroundColor: context.colorOnCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Teaching Tips',
                      style: TextStyle(fontWeight: FontWeight.w600),
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

// ─────────────────────────────────────────────────────────────────────────────
// Teaching Style Recommendations Sheet — UC-8
// ─────────────────────────────────────────────────────────────────────────────

class _TeachingRecommendationsSheet extends StatefulWidget {
  final List<TeachingRecommendation> tips;

  const _TeachingRecommendationsSheet({required this.tips});

  @override
  State<_TeachingRecommendationsSheet> createState() =>
      _TeachingRecommendationsSheetState();
}

class _TeachingRecommendationsSheetState
    extends State<_TeachingRecommendationsSheet> {
  late final List<TeachingRecommendation> _tips;

  @override
  void initState() {
    super.initState();
    _tips = List.of(widget.tips);
  }

  Color _priorityColor(String priority) => switch (priority) {
        'high' => AppColors.liveRed,
        'medium' => AppColors.warningAmber,
        _ => AppColors.successGreen,
      };

  Color _categoryColor(String category) => switch (category) {
        'Engagement' => AppColors.primaryGreen,
        'Behaviour' => AppColors.warningAmber,
        'Attention' => AppColors.liveRed,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.colorCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colorBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 17),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Teaching Style Recommendations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.colorOnCard,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Personalised for today\'s session · tap Apply to mark as used',
                    style: TextStyle(fontSize: 12, color: context.colorMuted),
                  ),
                ],
              ),
            ),

            Divider(height: 24, indent: 20, endIndent: 20, color: context.colorBorder),

            // Tips list
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: _tips.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final tip = _tips[i];
                  return _TipCard(
                    tip: tip,
                    categoryColor: _categoryColor(tip.category),
                    priorityColor: _priorityColor(tip.priority),
                    onApply: () => setState(() => tip.isApplied = !tip.isApplied),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final TeachingRecommendation tip;
  final Color categoryColor;
  final Color priorityColor;
  final VoidCallback onApply;

  const _TipCard({
    required this.tip,
    required this.categoryColor,
    required this.priorityColor,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tip.isApplied
            ? AppColors.primaryGreen.withValues(alpha: 0.07)
            : context.colorBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tip.isApplied
              ? AppColors.primaryGreen.withValues(alpha: 0.3)
              : context.colorBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tip.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${tip.priority[0].toUpperCase()}${tip.priority.substring(1)} priority',
                style: TextStyle(fontSize: 11, color: context.colorMuted),
              ),
              const Spacer(),
              if (tip.isApplied)
                const Icon(Icons.check_circle,
                    size: 16, color: AppColors.primaryGreen),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tip.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.colorOnCard,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tip.description,
            style: TextStyle(
              fontSize: 13,
              color: context.colorSubtle,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onApply,
            child: Text(
              tip.isApplied ? 'Mark as Not Applied' : 'Apply This Tip ›',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tip.isApplied
                    ? context.colorMuted
                    : AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
