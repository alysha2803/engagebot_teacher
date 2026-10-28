import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/student_model.dart';
import '../dashboard/providers/dashboard_provider.dart';
import 'providers/student_profile_provider.dart';
import 'widgets/student_profile_widgets.dart';

class StudentProfileScreen extends ConsumerWidget {
  final String studentId;

  const StudentProfileScreen({super.key, required this.studentId});

  void _showOptionsMenu(BuildContext context, WidgetRef ref, String currentName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EditNameSheet(
        currentName: currentName,
        onSave: (newName) {
          final updated = StudentModel(
            id: studentId,
            name: newName,
            status: 'engaged',
            classCode: ref
                .read(studentProfileProvider(studentId))
                .profile
                .className,
          );
          ref.read(dashboardProvider.notifier).editStudent(studentId, updated);
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
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showOptionsMenu(context, ref, profile.name),
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

            // ── Engagement Level % ─────────────────────────────────────────
            EngagementLevelCard(
              avgEngagement: profile.avgEngagement,
              engagementLabel: profile.engagementLabel,
            ),

            const SizedBox(height: 16),

            // ── Session Analytics (pose / expression / EAR / MAR) ──────────
            if (profile.poseDistribution.isNotEmpty)
              SessionAnalyticsCard(
                poseDistribution: profile.poseDistribution,
                expressionDistribution: profile.expressionDistribution,
                avgEAR: profile.avgEAR,
                avgMAR: profile.avgMAR,
              ),

            if (profile.poseDistribution.isNotEmpty) const SizedBox(height: 16),

            // ── Droid Insight ──────────────────────────────────────────────
            DroidInsightCard(insightText: profile.droidInsight),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Name bottom sheet — opened from 3-dots menu
// ─────────────────────────────────────────────────────────────────────────────

class _EditNameSheet extends StatefulWidget {
  final String currentName;
  final void Function(String name) onSave;

  const _EditNameSheet({required this.currentName, required this.onSave});

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onSave(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
              'Edit Student Name',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.colorOnCard,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryGreen),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
