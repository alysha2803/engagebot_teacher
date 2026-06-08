import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/router/app_router.dart';
import 'providers/auth_provider.dart';

const _kSage = Color(0xFF9CAF88);

/// Welcome splash screen shown when the app first launches.
/// Background: classroom photo with dark gradients at top and bottom.
/// User taps Continue to proceed to login (or dashboard if already signed in).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    // Short delay so the image has a frame to render before fading in
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) { _ctrl.forward(); }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    final status = ref.read(authProvider).status;
    context.go(
      status == AuthStatus.authenticated ? AppRoutes.dashboard : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background classroom photo ────────────────────────────────
          // Add assets/images/classroom.jpg to your project to show the photo.
          Image.asset(
            'assets/images/classroom.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2E4720), Color(0xFF0E1B0A)],
                ),
              ),
            ),
          ),

          // ── Top dark gradient ─────────────────────────────────────────
          const _TopGradient(),

          // ── Bottom dark gradient ──────────────────────────────────────
          const _BottomGradient(),

          // ── Foreground content ────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // EngageBot title — top center
                    Center(
                      child: Text(
                        'EngageBot',
                        style: GoogleFonts.pacifico(
                          fontSize: 38,
                          color: _kSage,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Expanded(child: SizedBox()),

                    // Tagline — bottom left
                    const Text(
                      'Your Classroom\nEngagement\nAssistant',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.18,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _onContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: _kSage.withValues(alpha: 0.82),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
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
// Gradient overlays
// ─────────────────────────────────────────────────────────────────────────────

class _TopGradient extends StatelessWidget {
  const _TopGradient();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: h * 0.38,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xCC000000), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: h * 0.62,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xEE000000),
              Color(0xBB000000),
              Color(0x55000000),
              Colors.transparent,
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
      ),
    );
  }
}
