import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../data/mock/mock_data_service.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/droid_illustration_painter.dart';

/// App-level settings sidebar — rendered inside the global Drawer.
class SettingsSidebar extends ConsumerStatefulWidget {
  const SettingsSidebar({super.key});

  @override
  ConsumerState<SettingsSidebar> createState() => _SettingsSidebarState();
}

class _SettingsSidebarState extends ConsumerState<SettingsSidebar> {
  void _showLogoutDialog() {
    // Capture stable references BEFORE the dialog opens — dialog callbacks
    // must not access `context` after dismiss because the sidebar may be
    // unmounted by then.
    final router = GoRouter.of(context);
    final authNotifier = ref.read(authProvider.notifier);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'You will be returned to the login screen. '
          'Your preferences and data will be preserved.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // dismiss dialog via its own context
              // GoRouter's _AuthStateNotifier redirects to /login when
              // Firebase auth changes; go() is a safety-net fallback.
              authNotifier.signOut().then((_) {
                router.go(AppRoutes.login);
              });
            },
            style:
                TextButton.styleFrom(foregroundColor: AppColors.liveRed),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showEditProfile() {
    final state = ref.read(settingsProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        initialName: state.teacherName,
        initialSchool: state.teacherSchool,
        onSaved: (name, school) => ref
            .read(settingsProvider.notifier)
            .updateProfile(name: name, school: school),
      ),
    );
  }

  void _showUserGuide() {
    Navigator.of(context).pop();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _UserGuideSheet(),
      );
    });
  }

  void _showGetHelp() {
    Navigator.of(context).pop();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email: support@engagebot.edu.my'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final droid = MockDataService.getDroidStatus();
    final th = Theme.of(context);
    final isDark = prefs.darkMode;
    final iconBg = isDark ? const Color(0xFF1E2B1A) : AppColors.sageLighter;

    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ─────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // ── Profile header ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _showEditProfile,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.sageLight,
                                child: Text(
                                  prefs.teacherName.isNotEmpty
                                      ? prefs.teacherName[0]
                                      : 'T',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: -2,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: th.colorScheme.surface, width: 2),
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prefs.teacherName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: th.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                prefs.teacherSchool,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: th.colorScheme.onSurface
                                      .withValues(alpha: 0.55),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: iconBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  MockDataService.getTeacherProfile().subject,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              size: 18,
                              color: th.colorScheme.onSurface
                                  .withValues(alpha: 0.4)),
                          onPressed: _showEditProfile,
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Divider(height: 1, color: th.dividerColor),
                  ),

                  // ── Droid ─────────────────────────────────────────────
                  _SectionLabel('DROID DEVICE'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: th.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: th.dividerColor),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            height: 44,
                            child: CustomPaint(
                                painter: DroidIllustrationPainter()),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  droid['droidId'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: th.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  droid['activeClass'] as String,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primaryGreen),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.successGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text('Active',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.successGreen,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Preferences ────────────────────────────────────────
                  _SectionLabel('PREFERENCES'),
                  const SizedBox(height: 4),
                  _SwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: prefs.darkMode,
                    onChanged: notifier.setDarkMode,
                    iconBg: iconBg,
                  ),
                  _SwitchTile(
                    icon: Icons.notifications_outlined,
                    title: 'Real-time Alerts',
                    value: prefs.realtimeAlerts,
                    onChanged: notifier.setRealtimeAlerts,
                    iconBg: iconBg,
                  ),
                  _SwitchTile(
                    icon: Icons.cloud_outlined,
                    title: 'Cloud Sync',
                    value: prefs.cloudSync,
                    onChanged: notifier.setCloudSync,
                    iconBg: iconBg,
                  ),
                  _SwitchTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'Auto-Schedule',
                    value: prefs.autoSchedule,
                    onChanged: notifier.setAutoSchedule,
                    iconBg: iconBg,
                  ),

                  const SizedBox(height: 12),

                  // ── Support ────────────────────────────────────────────
                  _SectionLabel('SUPPORT'),
                  const SizedBox(height: 4),
                  _LinkTile(
                    icon: Icons.menu_book_outlined,
                    title: 'User Guide',
                    iconBg: iconBg,
                    onTap: _showUserGuide,
                  ),
                  _LinkTile(
                    icon: Icons.help_outline,
                    title: 'Get Help',
                    iconBg: iconBg,
                    onTap: _showGetHelp,
                  ),
                  _LinkTile(
                    icon: Icons.info_outline,
                    title: 'About EngageBot',
                    iconBg: iconBg,
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'EngageBot Teacher',
                      applicationVersion: '2.4.0',
                      applicationLegalese:
                          '© 2024 EngageBot Systems\nAll rights reserved.',
                    ),
                  ),

                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: th.dividerColor),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'EngageBot Teacher  v2.4.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: th.colorScheme.onSurface.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Logout ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future.delayed(const Duration(milliseconds: 200),
                        _showLogoutDialog);
                  },
                  icon: const Icon(Icons.logout,
                      size: 16, color: AppColors.liveRed),
                  label: const Text('Log Out',
                      style: TextStyle(
                          color: AppColors.liveRed,
                          fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.liveRed),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
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
// Small reusable sidebar widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.45),
          ),
        ),
      );
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconBg;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 15, color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryGreen,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      );
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconBg;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.title,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Container(
        width: 32,
        height: 32,
        decoration:
            BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primaryGreen, size: 15),
      ),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: th.colorScheme.onSurface),
      ),
      trailing: Icon(Icons.chevron_right,
          size: 16, color: th.colorScheme.onSurface.withValues(alpha: 0.3)),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit profile sheet
// ─────────────────────────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final String initialName;
  final String initialSchool;
  final void Function(String name, String school) onSaved;

  const _EditProfileSheet({
    required this.initialName,
    required this.initialSchool,
    required this.onSaved,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _schoolCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _schoolCtrl = TextEditingController(text: widget.initialSchool);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
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
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Edit Profile',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: onSurface)),
          const SizedBox(height: 20),
          Text('Full Name',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: onSurface.withValues(alpha: 0.55))),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                hintText: 'e.g. Ms. Sarah Halim',
                prefixIcon: Icon(Icons.person_outline, size: 18)),
          ),
          const SizedBox(height: 16),
          Text('School',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: onSurface.withValues(alpha: 0.55))),
          const SizedBox(height: 6),
          TextField(
            controller: _schoolCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                hintText: 'e.g. SMK Bandar Kinrara',
                prefixIcon: Icon(Icons.school_outlined, size: 18)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final name = _nameCtrl.text.trim();
                final school = _schoolCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context);
                widget.onSaved(name, school);
              },
              child: const Text('Save Changes',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User Guide sheet
// ─────────────────────────────────────────────────────────────────────────────

class _UserGuideSheet extends StatelessWidget {
  const _UserGuideSheet();

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
            color: surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: AppColors.sageLighter,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.menu_book_outlined,
                            color: AppColors.primaryGreen, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text('User Guide',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: onSurface)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: const [
                  _GuideSection(
                    icon: Icons.rocket_launch_outlined,
                    title: 'Getting Started',
                    body:
                        'EngageBot Teacher pairs with your physical EngageBot droid to monitor classroom engagement in real-time. Power on the droid, open Settings (hamburger menu), and tap the Droid section to pair via Bluetooth.',
                  ),
                  _GuideSection(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    body:
                        'The Dashboard shows live class engagement. Select an active class from the chips, view the engagement percentage, AI recommendation, and the student roster.\n\n'
                        '• Tap a class chip → opens detailed analytics.\n'
                        '• Tap a student name → individual engagement profile.\n'
                        '• Tap "Manage" → edit names, statuses and add notes.',
                  ),
                  _GuideSection(
                    icon: Icons.auto_awesome_outlined,
                    title: 'AI Insights',
                    body:
                        'The AI Insights tab provides personalised teaching recommendations generated from your class engagement data.\n\n'
                        '• Filter by class or view overall recommendations.\n'
                        '• Tap "Save" to keep a recommendation for reference.\n'
                        '• Tap "Ignore" to dismiss recommendations you\'ve already applied.',
                  ),
                  _GuideSection(
                    icon: Icons.track_changes_outlined,
                    title: 'Engagement Status',
                    body:
                        'Each student shows one of three engagement levels:\n\n'
                        '🟢 Engaged — focused and participating\n'
                        '🟡 Distracted — attention drifting\n'
                        '🔴 Flagged — needs immediate attention\n\n'
                        'You can manually override a status from the Manage sheet.',
                  ),
                  _GuideSection(
                    icon: Icons.bar_chart_outlined,
                    title: 'Reports & Export',
                    body:
                        'Generate a PDF summary or CSV data file for any class and date range. Use Scheduled Summaries to automate weekly or monthly reports emailed to your address.',
                  ),
                  _GuideSection(
                    icon: Icons.tips_and_updates_outlined,
                    title: 'Tips & Best Practices',
                    body:
                        '• Apply AI recommendations at the start of the session.\n'
                        '• Use the Flagged filter in Classes → Students after class.\n'
                        '• Weekly PDF reports are great for parent-teacher meetings.\n'
                        '• Enable Dark Mode (sidebar) for evening planning sessions.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _GuideSection(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          Text(body,
              style: TextStyle(
                  fontSize: 13,
                  color: onSurface.withValues(alpha: 0.7),
                  height: 1.6)),
        ],
      ),
    );
  }
}
