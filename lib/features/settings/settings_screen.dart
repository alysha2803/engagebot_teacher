import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../data/mock/mock_data_service.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/droid_illustration_painter.dart';

/// Settings & Droid — Tab 3.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // ── Edit Profile ─────────────────────────────────────────────────────────

  void _showEditProfile() {
    final state = ref.read(settingsProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        initialName: state.teacherName,
        initialSchool: state.teacherSchool,
        onSaved: (name, school) {
          ref
              .read(settingsProvider.notifier)
              .updateProfile(name: name, school: school);
          _snack('Profile updated');
        },
      ),
    );
  }

  // ── Droid actions ─────────────────────────────────────────────────────────

  void _showUnpairDialog() {
    final droid = MockDataService.getDroidStatus();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Unpair Droid?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'This will disconnect ${droid['droidId']} from your account. '
          'You can pair again at any time.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _snack('${droid['droidId']} unpaired');
            },
            style: TextButton.styleFrom(
                foregroundColor: AppColors.liveRed),
            child: const Text('Unpair'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPairNewDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation(AppColors.primaryGreen),
            ),
            SizedBox(height: 20),
            Text(
              'Scanning for EngageBot droids…',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Make sure the droid is powered on\nand within Bluetooth range.',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) Navigator.of(context).pop();
    if (mounted) {
      _snack('EngageBot-07 paired successfully', success: true);
    }
  }

  // ── User Guide ────────────────────────────────────────────────────────────

  void _showUserGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UserGuideSheet(),
    );
  }

  // ── Get Help ──────────────────────────────────────────────────────────────

  void _showGetHelp() {
    final th = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThemedSheet(
        title: 'Get Help',
        child: Column(
          children: [
            _HelpOption(
              icon: Icons.question_answer_outlined,
              title: 'FAQ',
              subtitle: 'Browse common questions and answers',
              onTap: () {
                Navigator.pop(_);
                _snack('Opening FAQ…');
              },
            ),
            const SizedBox(height: 8),
            _HelpOption(
              icon: Icons.mail_outline,
              title: 'Email Support',
              subtitle: 'support@engagebot.edu.my',
              onTap: () {
                Navigator.pop(_);
                _snack('Opening email client…');
              },
            ),
            const SizedBox(height: 8),
            _HelpOption(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Help us improve EngageBot',
              onTap: () {
                Navigator.pop(_);
                _showFeedbackSheet();
              },
            ),
            const SizedBox(height: 8),
            _HelpOption(
              icon: Icons.info_outline,
              title: 'About EngageBot',
              subtitle: 'Version 2.4.0 · Built for educators',
              onTap: () {
                Navigator.pop(_);
                showAboutDialog(
                  context: context,
                  applicationName: 'EngageBot Teacher',
                  applicationVersion: '2.4.0',
                  applicationLegalese:
                      '© 2024 EngageBot Systems\nAll rights reserved.',
                );
              },
            ),
            SizedBox(
                height: MediaQuery.of(th.platform == TargetPlatform.iOS
                        ? context
                        : context)
                    .padding
                    .bottom),
          ],
        ),
      ),
    );
  }

  void _showFeedbackSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FeedbackSheet(
        onSubmitted: () => _snack('Thank you for your feedback!',
            success: true),
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  void _showLogoutDialog() {
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).signOut();
              // GoRouter redirect handles navigation to /login automatically.
            },
            style: TextButton.styleFrom(
                foregroundColor: AppColors.liveRed),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            success ? AppColors.primaryGreen : null,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final droid = MockDataService.getDroidStatus();
    final th = Theme.of(context);
    final isDark = prefs.darkMode;

    return Scaffold(
      // Let theme control background so dark mode works here
      appBar: AppBar(
        title: const Text(
          'Settings & Droid',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryGreen),
            tooltip: 'Log out',
            onPressed: _showLogoutDialog,
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
            _Card(
              child: Row(
                children: [
                  // Avatar with camera badge
                  GestureDetector(
                    onTap: () =>
                        _snack('Photo picker coming in v3.0'),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.sageLight,
                          child: Text(
                            prefs.teacherName.isNotEmpty
                                ? prefs.teacherName[0]
                                : 'T',
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
                                  color: th.colorScheme.surface,
                                  width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name + school
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prefs.teacherName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: th.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prefs.teacherSchool,
                          style: TextStyle(
                            fontSize: 12,
                            color: th.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2B1A)
                                : AppColors.sageLighter,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            MockDataService.getTeacherProfile().subject,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  TextButton(
                    onPressed: _showEditProfile,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Edit',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Droid Device Card ──────────────────────────────────────────
            _Card(
              child: Column(
                children: [
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: th.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Active in ${droid['activeClass']}',
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
                          onPressed: _showUnpairDialog,
                          icon: const Icon(Icons.link_off, size: 16),
                          label: const Text('Unpair'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showPairNewDialog,
                          icon: const Icon(Icons.bluetooth, size: 16),
                          label: const Text('Pair New'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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

            const SizedBox(height: 24),

            // ── Preferences ────────────────────────────────────────────────
            const _SectionLabel('PREFERENCES'),
            const SizedBox(height: 12),

            _Card(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _PrefRow(
                    icon: Icons.notifications_outlined,
                    title: 'Real-time Alerts',
                    subtitle:
                        'Notifications for significant engagement drops',
                    value: prefs.realtimeAlerts,
                    onChanged: notifier.setRealtimeAlerts,
                    isDark: isDark,
                  ),
                  _divider(),
                  _PrefRow(
                    icon: Icons.calendar_today_outlined,
                    title: 'Auto-Schedule',
                    subtitle:
                        'Start monitoring sessions at class bell times',
                    value: prefs.autoSchedule,
                    onChanged: notifier.setAutoSchedule,
                    isDark: isDark,
                  ),
                  _divider(),
                  _PrefRow(
                    icon: Icons.cloud_outlined,
                    title: 'Cloud Sync',
                    subtitle:
                        'Sync analytics across your teacher devices',
                    value: prefs.cloudSync,
                    onChanged: notifier.setCloudSync,
                    isDark: isDark,
                  ),
                  _divider(),
                  _PrefRow(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Switch to a darker interface theme',
                    value: prefs.darkMode,
                    onChanged: notifier.setDarkMode,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Support ────────────────────────────────────────────────────
            const _SectionLabel('SUPPORT'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SupportCard(
                    icon: Icons.menu_book_outlined,
                    label: 'User Guide',
                    onTap: _showUserGuide,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SupportCard(
                    icon: Icons.help_outline,
                    label: 'Get Help',
                    onTap: _showGetHelp,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Footer ─────────────────────────────────────────────────────
            Center(
              child: Text(
                'ENGAGEBOT V2.4.0 — MADE FOR EDUCATORS',
                style: TextStyle(
                  fontSize: 10,
                  color: th.colorScheme.onSurface.withValues(alpha: 0.35),
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

  Widget _divider() => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: Theme.of(context).dividerColor,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme-aware card
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preference Row
// ─────────────────────────────────────────────────────────────────────────────

class _PrefRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _PrefRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final iconBg = isDark
        ? const Color(0xFF1E2B1A)
        : AppColors.sageLighter;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: th.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: th.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
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
  final bool isDark;

  const _SupportCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final iconBg = isDark
        ? const Color(0xFF1E2B1A)
        : AppColors.sageLighter;

    return GestureDetector(
      onTap: onTap,
      child: _Card(
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(icon, color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: th.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable themed sheet wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _ThemedSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _ThemedSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Profile Sheet
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
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 20),

          // Name field
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
              prefixIcon:
                  Icon(Icons.person_outline, size: 18),
            ),
          ),
          const SizedBox(height: 16),

          // School field
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
              prefixIcon: Icon(Icons.school_outlined, size: 18),
            ),
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
// User Guide Sheet
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
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle + title
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
                        borderRadius: BorderRadius.circular(2),
                      ),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_book_outlined,
                            color: AppColors.primaryGreen, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'User Guide',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor),
                ],
              ),
            ),

            // Scrollable guide content
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: const [
                  _GuideSection(
                    icon: Icons.rocket_launch_outlined,
                    title: 'Getting Started',
                    body:
                        'EngageBot Teacher pairs with your physical EngageBot droid to monitor classroom engagement in real-time. Power on the droid, open Settings, and tap "Pair New" to connect via Bluetooth. Once paired, head to the Dashboard to start your first session.',
                  ),
                  _GuideSection(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    body:
                        'The Dashboard shows your live class engagement at a glance. Select an active class from the chips at the top, then view the engagement percentage, AI recommendation, and the full student roster below.\n\n'
                        '• Tap any class chip to open its detailed analytics page.\n'
                        '• Tap a student\'s name to view their individual engagement profile.\n'
                        '• Tap "Manage" to edit student names, statuses, and add notes.',
                  ),
                  _GuideSection(
                    icon: Icons.track_changes_outlined,
                    title: 'Engagement Status',
                    body:
                        'Each student displays one of three engagement levels, updated every 30 seconds by the droid\'s AI:\n\n'
                        '🟢 Engaged — focused and participating\n'
                        '🟡 Distracted — attention drifting; consider a re-engagement prompt\n'
                        '🔴 Flagged — needs immediate attention; the AI has detected a significant drop\n\n'
                        'You can manually override a student\'s status from the Manage sheet and add a private note explaining your reasoning.',
                  ),
                  _GuideSection(
                    icon: Icons.groups_outlined,
                    title: 'Classes & Students',
                    body:
                        'Switch between the Periods tab (your full timetable in a grid view) and the Students tab (all students ranked by who needs the most attention first).\n\n'
                        'Use the search bar to find any class or student by name, and tap the filter icon to narrow results by status (Flagged, Distracted, Engaged) or class connectivity (Online, Offline).',
                  ),
                  _GuideSection(
                    icon: Icons.bar_chart_outlined,
                    title: 'Reports & Export',
                    body:
                        'Generate a PDF summary or raw CSV data file for any class and date range. Select your filters at the top of the Reports screen, then tap "Generate Now" on the export type you need.\n\n'
                        'To automate reporting, expand the Scheduled Summaries section and tap "Edit Schedule" to choose a day, time, and format. Reports are emailed to your registered address automatically.',
                  ),
                  _GuideSection(
                    icon: Icons.smart_toy_outlined,
                    title: 'EngageBot Droid',
                    body:
                        'Your EngageBot droid is a compact AI-powered device that sits at the front of the classroom and monitors student facial cues, posture, and activity using on-device vision processing. No video is stored or transmitted.\n\n'
                        'If you move classrooms, tap "Pair New" in Settings to reconnect. Tap "Unpair" to remove the droid from your account entirely.',
                  ),
                  _GuideSection(
                    icon: Icons.tips_and_updates_outlined,
                    title: 'Tips & Best Practices',
                    body:
                        '• Apply the AI Recommendation at the start of the session for best engagement results.\n'
                        '• Use the Flagged filter in the Students tab at the end of class to identify students who may need a follow-up.\n'
                        '• Weekly PDF reports are great for parent-teacher meetings — generate one from Reports.\n'
                        '• Dark Mode (in Preferences) is easier on the eyes during evening planning sessions.',
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

  const _GuideSection({
    required this.icon,
    required this.title,
    required this.body,
  });

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
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              color: onSurface.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Get Help — option row
// ─────────────────────────────────────────────────────────────────────────────

class _HelpOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: th.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.sageLighter,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, size: 18, color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: th.colorScheme.onSurface)),
                  const SizedBox(height: 1),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: th.colorScheme.onSurface
                              .withValues(alpha: 0.5))),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18,
                color: th.colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feedback Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FeedbackSheet extends StatefulWidget {
  final VoidCallback onSubmitted;
  const _FeedbackSheet({required this.onSubmitted});

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _ctrl = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Send Feedback',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: onSurface)),
          const SizedBox(height: 16),

          // Star rating
          Text('How would you rate your experience?',
              style: TextStyle(
                  fontSize: 13,
                  color: onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: i < _rating
                        ? const Color(0xFFF59E0B)
                        : onSurface.withValues(alpha: 0.3),
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Message field
          TextField(
            controller: _ctrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'Tell us what you love or what we can improve…',
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onSubmitted();
              },
              child: const Text('Submit Feedback',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
