import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.cardWhite,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left,
              color: AppColors.textPrimary, size: 28),
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
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
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
                const Text(
                  'Teacher Observations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No observations yet. Tap + Add Note to begin.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
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
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderLight),
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
