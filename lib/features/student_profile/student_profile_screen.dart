import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../data/mock/mock_data_service.dart';
import '../../data/models/analytics_models.dart';
import '../../data/models/observation_model.dart';
import 'providers/student_profile_provider.dart';
import 'widgets/student_profile_widgets.dart';

/// Student Profile detail screen — pushed from Classes or Dashboard.
/// No bottom nav visible on this screen (it's outside the ShellRoute).
class StudentProfileScreen extends ConsumerWidget {
  final String studentId;

  const StudentProfileScreen({super.key, required this.studentId});

  static const _filters = [
    'Participation',
    'Distraction',
    'Lateness',
    'Teamwork',
  ];

  void _showFullHistory(BuildContext context, String name) {
    final history = MockDataService.getStudentSessionHistory(studentId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StudentHistorySheet(history: history, studentName: name),
    );
  }

  void _showAddEditSheet(
    BuildContext context,
    WidgetRef ref, {
    ObservationModel? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditObservationSheet(
        existing: existing,
        onSave: (obs) {
          if (existing == null) {
            ref.read(studentProfileProvider(studentId).notifier).addObservation(obs);
          } else {
            ref.read(studentProfileProvider(studentId).notifier).updateObservation(obs);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentProfileProvider(studentId));
    final profile = state.profile;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Text(
          profile.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Profile Header ─────────────────────────────────────────────
            ProfileHeaderCard(profile: profile),

            const SizedBox(height: 16),

            // ── Engagement Timeline ────────────────────────────────────────
            EngagementTimelineCard(timeline: profile.timeline),

            const SizedBox(height: 16),

            // ── Metric Chips ───────────────────────────────────────────────
            MetricChipsRow(
              focusDepth: profile.focusDepth,
              collaboration: profile.collaboration,
            ),

            const SizedBox(height: 16),

            // ── Droid Insight ──────────────────────────────────────────────
            DroidInsightCard(
              insightText: profile.droidInsight,
              onApply: () {},
            ),

            const SizedBox(height: 24),

            // ── Observation Filters ────────────────────────────────────────
            ObservationFilterChips(
              filters: _filters,
              activeFilter: state.activeFilter,
              onSelect: (f) =>
                  ref.read(studentProfileProvider(studentId).notifier).setFilter(f),
            ),

            const SizedBox(height: 20),

            // ── Teacher Observations ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Teacher Observations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.colorOnCard,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddEditSheet(context, ref),
                  child: const Row(
                    children: [
                      Icon(Icons.add_circle_outline,
                          size: 16, color: AppColors.primaryGreen),
                      SizedBox(width: 4),
                      Text(
                        'Add Note',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Observation list
            if (state.observations.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No observations yet. Tap + Add Note to begin.',
                    style: TextStyle(color: context.colorMuted, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...state.observations.map(
                (obs) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ObservationCard(
                    observation: obs,
                    onEdit: () =>
                        _showAddEditSheet(context, ref, existing: obs),
                    onDelete: () => ref
                        .read(studentProfileProvider(studentId).notifier)
                        .deleteObservation(obs.id),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // View Full History button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showFullHistory(context, profile.name),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colorOnCard,
                  side: BorderSide(color: context.colorBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'View Full History',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
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
// Student Engagement History Sheet — UC-6.1
// ─────────────────────────────────────────────────────────────────────────────

class _StudentHistorySheet extends StatelessWidget {
  final List<SessionRecord> history;
  final String studentName;

  const _StudentHistorySheet({
    required this.history,
    required this.studentName,
  });

  Color _engagementColor(int pct) {
    if (pct >= 85) return AppColors.successGreen;
    if (pct >= 70) return AppColors.warningAmber;
    return AppColors.liveRed;
  }

  @override
  Widget build(BuildContext context) {
    final avg = history.isEmpty
        ? 0
        : (history.map((s) => s.avgEngagement).reduce((a, b) => a + b) /
                history.length)
            .round();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.92,
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Engagement History',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: context.colorOnCard,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          studentName,
                          style: TextStyle(
                              fontSize: 13, color: context.colorMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Avg $avg%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
                height: 24,
                indent: 20,
                endIndent: 20,
                color: context.colorBorder),

            // Session list
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final rec = history[i];
                  final col = _engagementColor(rec.avgEngagement);
                  return Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: context.colorBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border(
                          left: BorderSide(color: col, width: 4)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rec.date,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: context.colorOnCard,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 11,
                                      color: context.colorMuted),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${rec.durationMinutes} min',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: context.colorMuted),
                                  ),
                                  if (rec.flaggedCount > 0) ...[
                                    const SizedBox(width: 10),
                                    Icon(Icons.flag_outlined,
                                        size: 11,
                                        color: AppColors.liveRed
                                            .withValues(alpha: 0.7)),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${rec.flaggedCount} flagged',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.liveRed
                                              .withValues(alpha: 0.7)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rec.highlight,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: context.colorSubtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: col.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${rec.avgEngagement}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: col,
                            ),
                          ),
                        ),
                      ],
                    ),
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
