import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'providers/auth_provider.dart';

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
    final isLoading = authState.status == AuthStatus.loading ||
        authState.status == AuthStatus.initial;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // ── Branding ──────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.smart_toy_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'EngageBot',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnCard,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Smart Classroom System',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colorSubtle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const SageChip(label: 'Teacher Portal'),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Sign-in card ───────────────────────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnCard,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Access your teacher dashboard.',
                      style: TextStyle(fontSize: 14, color: context.colorSubtle),
                    ),
                    const SizedBox(height: 24),

                    // ── Google button ────────────────────────────────────────
                    _GoogleSignInButton(
                      isLoading: isLoading,
                      onTap: () =>
                          ref.read(authProvider.notifier).signInWithGoogle(),
                    ),

                    const SizedBox(height: 20),
                    const _Divider(label: 'or sign in with email'),
                    const SizedBox(height: 20),

                    // ── Email field ──────────────────────────────────────────
                    _InputField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'teacher@school.edu.my',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 12),

                    // ── Password field ───────────────────────────────────────
                    _InputField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: !_showPassword,
                      enabled: !isLoading,
                      suffix: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: context.colorSubtle,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Email sign-in button ─────────────────────────────────
                    SizedBox(
                      height: 50,
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
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),

                    // ── Status banners ───────────────────────────────────────
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

              const SizedBox(height: 28),

              // ── Footer ─────────────────────────────────────────────────────
              const Center(
                child: Text(
                  'ENGAGEBOT V2.4.0 — FOR EDUCATORS',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
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
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.colorBorder, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          backgroundColor: context.colorBg,
          foregroundColor: context.colorOnCard,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(painter: _GPainter()),
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.colorOnCard,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple 4-quadrant Google "G" icon painted without any assets.
class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFFEA4335),
      const Color(0xFFFBBC05),
      const Color(0xFF34A853),
    ];
    final paints = colors
        .map((c) => Paint()
          ..color = c
          ..style = PaintingStyle.fill)
        .toList();
    canvas.drawArc(Rect.fromCircle(center: Offset(r, r), radius: r),
        3.14, 1.57, true, paints[1]);
    canvas.drawArc(Rect.fromCircle(center: Offset(r, r), radius: r),
        4.71, 1.57, true, paints[0]);
    canvas.drawArc(Rect.fromCircle(center: Offset(r, r), radius: r),
        0, 1.57, true, paints[3]);
    canvas.drawArc(Rect.fromCircle(center: Offset(r, r), radius: r),
        1.57, 1.57, true, paints[2]);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Divider with centred label
// ─────────────────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  final String label;
  const _Divider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.colorBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: context.colorMuted),
          ),
        ),
        Expanded(child: Divider(color: context.colorBorder)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable input field
// ─────────────────────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final bool enabled;
  final TextInputType keyboardType;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
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
      style: TextStyle(fontSize: 14, color: context.colorOnCard),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: context.colorSubtle),
        suffixIcon: suffix,
        filled: true,
        fillColor: context.colorInputFill,
        labelStyle: TextStyle(color: context.colorSubtle, fontSize: 13),
        hintStyle: TextStyle(color: context.colorMuted, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colorBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderRadius: BorderRadius.circular(12),
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
              style: TextStyle(
                  fontSize: 13, color: context.colorOnCard, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
