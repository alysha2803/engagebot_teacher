import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'providers/auth_provider.dart';

const _kSage = Color(0xFF9CAF88);
const _kTitleColor = Color(0xFF1A2214);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final topH = MediaQuery.of(context).size.height * 0.43;

    return Scaffold(
      backgroundColor: _kSage,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Top sage green section ──────────────────────────────────────
          SizedBox(
            height: topH,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'EngageBot',
                    style: GoogleFonts.pacifico(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const RobotMascot(color: Colors.white, size: 100),
                ],
              ),
            ),
          ),

          // ── White card section ─────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _kTitleColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Access your teacher dashboard.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Google button ──────────────────────────────────────
                    _GoogleSignInButton(
                      isLoading: isLoading,
                      onTap: () =>
                          ref.read(authProvider.notifier).signInWithGoogle(),
                    ),

                    const SizedBox(height: 20),
                    const _OrDivider(),
                    const SizedBox(height: 20),

                    // ── Email field ────────────────────────────────────────
                    _PillInputField(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 12),

                    // ── Password field ─────────────────────────────────────
                    _PillInputField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscure: !_showPassword,
                      enabled: !isLoading,
                      suffix: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Sign In button ─────────────────────────────────────
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: isLoading
                            ? null
                            : () => ref
                                .read(authProvider.notifier)
                                .signInWithEmailAndPassword(
                                  _emailCtrl.text,
                                  _passwordCtrl.text,
                                ),
                        style: FilledButton.styleFrom(
                          backgroundColor: _kSage,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              _kSage.withValues(alpha: 0.5),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    // ── Status banners ─────────────────────────────────────
                    if (authState.status == AuthStatus.notRegistered) ...[
                      const SizedBox(height: 16),
                      const _StatusBanner(
                        color: AppColors.liveRed,
                        icon: Icons.block_outlined,
                        message:
                            "Your account hasn't been registered by your school admin. "
                            "Please contact them to be added to EngageBot.",
                      ),
                    ] else if (authState.status == AuthStatus.error &&
                        authState.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _StatusBanner(
                        color: AppColors.warningAmber,
                        icon: Icons.warning_amber_outlined,
                        message: authState.errorMessage!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google Sign-In button
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _GoogleSignInButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD8E6CE), width: 1.5),
          shape: const StadiumBorder(),
          backgroundColor: const Color(0xFFF6FAF3),
          foregroundColor: _kTitleColor,
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CustomPaint(painter: _GPainter()),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _kTitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple 4-quadrant Google "G" painted without assets.
class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final paints = [
      Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill,
      Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill,
      Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill,
      Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill,
    ];
    final c = Offset(r, r);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), 3.14, 1.57, true, paints[1]);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), 4.71, 1.57, true, paints[0]);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), 0.00, 1.57, true, paints[3]);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), 1.57, 1.57, true, paints[2]);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// "or sign in with email" divider
// ─────────────────────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2EDD9))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or sign in with email',
            style: TextStyle(
                fontSize: 12, color: Colors.black.withValues(alpha: 0.38)),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2EDD9))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill-shaped input field
// ─────────────────────────────────────────────────────────────────────────────

class _PillInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final bool enabled;
  final TextInputType keyboardType;
  final Widget? suffix;

  const _PillInputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: _kTitleColor),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, size: 20, color: Colors.black.withValues(alpha: 0.38)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF0F4ED),
        labelStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.42), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: _kSage, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status banner (error / not-registered)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;

  const _StatusBanner({
    required this.color,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  fontSize: 13, color: _kTitleColor, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
