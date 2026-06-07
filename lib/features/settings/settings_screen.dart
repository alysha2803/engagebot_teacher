import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/router/app_router.dart';
import '../../data/mock/mock_data_service.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'providers/settings_provider.dart';
import 'widgets/droid_illustration_painter.dart';

/// Settings & Droid — Tab 3.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final teacher = MockDataService.getTeacherProfile();
    final droid = MockDataService.getDroidStatus();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Settings & Droid',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryGreen),
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Teacher Profile Card ───────────────────────────────────────
            AppCard(
              child: Row(
                children: [
                  // Avatar with camera badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.sageLight,
                        child: Text(
                          teacher.name.isNotEmpty ? teacher.name[0] : 'T',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: -4,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.cardWhite, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Name + school + subject
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          teacher.school,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SageChip(label: teacher.subject),
                      ],
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Device Management ──────────────────────────────────────────
            AppCard(
              child: Column(
                children: [
                  // Droid illustration
                  const SizedBox(
                    height: 120,
                    child: CustomPaint(
                      painter: DroidIllustrationPainter(),
                      size: Size(100, 120),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    droid['droidId'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // TODO: Replace with droid pairing API
                    'Your companion droid is currently active in ${droid['activeClass']}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryGreen,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.link_off, size: 16),
                          label: const Text('Unpair'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(
                                color: AppColors.borderLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon:
                              const Icon(Icons.bluetooth, size: 16),
                          label: const Text('Pair New'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Preferences ────────────────────────────────────────────────
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _PreferenceRow(
                    icon: Icons.notifications_outlined,
                    title: 'Real-time Alerts',
                    subtitle: 'Notifications for significant engagement drops',
                    value: prefs.realtimeAlerts,
                    onChanged: notifier.setRealtimeAlerts,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16,
                      color: AppColors.borderLight),
                  _PreferenceRow(
                    icon: Icons.calendar_today_outlined,
                    title: 'Auto-Schedule',
                    subtitle: 'Start monitoring sessions at class bell times',
                    value: prefs.autoSchedule,
                    onChanged: notifier.setAutoSchedule,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16,
                      color: AppColors.borderLight),
                  _PreferenceRow(
                    icon: Icons.cloud_outlined,
                    title: 'Cloud Sync',
                    subtitle: 'Sync analytics across your teacher devices',
                    value: prefs.cloudSync,
                    onChanged: notifier.setCloudSync,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Support ────────────────────────────────────────────────────
            const Text(
              'Support',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SupportCard(
                    icon: Icons.menu_book_outlined,
                    label: 'User Guide',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SupportCard(
                    icon: Icons.help_outline,
                    label: 'Get Help',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Footer ─────────────────────────────────────────────────────
            const Center(
              child: Text(
                'ENGAGEBOT V2.4.0 — MADE FOR EDUCATORS',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preference Row
// ─────────────────────────────────────────────────────────────────────────────
class _PreferenceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon in rounded square
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.sageLighter,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Support Card
// ─────────────────────────────────────────────────────────────────────────────
class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SupportCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.sageLighter,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
