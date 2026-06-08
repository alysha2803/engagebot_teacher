import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/classes/classes_screen.dart';
import '../../features/class_analytics/class_analytics_screen.dart';
import '../../features/student_profile/student_profile_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/ai_recommendation/ai_recommendation_screen.dart';
import '../../shared/widgets/engagebot_scaffold.dart';

/// Named route constants — use these everywhere instead of raw strings.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const classes = '/classes';
  static const classDetail = '/class-detail/:classCode';
  static const studentProfile = '/students/:studentId';
  static const reports = '/reports';
  static const recommendations = '/recommendations';
}

/// Builds and returns the GoRouter for the app.
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,

    // Re-evaluate redirect whenever Firebase auth state changes.
    refreshListenable: _AuthStateNotifier(),

    // Auth guard: redirect unauthenticated users to /login,
    // and skip /login for already-authenticated users.
    // /splash is exempt — it reads auth state itself and navigates when ready.
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == AppRoutes.splash) return null;
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      if (!isLoggedIn && loc != AppRoutes.login) return AppRoutes.login;
      if (isLoggedIn && loc == AppRoutes.login) return AppRoutes.dashboard;
      return null;
    },

    routes: [
      // ── Splash — shown once on app launch ──────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth — standalone, no shell ────────────────────────────────────
      // Slides up from the bottom when navigated from splash.
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      ),

      // ── Class Analytics — no bottom nav ────────────────────────────────
      GoRoute(
        path: AppRoutes.classDetail,
        name: 'classDetail',
        builder: (context, state) {
          final classCode =
              Uri.decodeComponent(state.pathParameters['classCode'] ?? '');
          return ClassAnalyticsScreen(classCode: classCode);
        },
      ),

      // ── Student Profile — no bottom nav ────────────────────────────────
      GoRoute(
        path: AppRoutes.studentProfile,
        name: 'studentProfile',
        builder: (context, state) {
          final studentId = state.pathParameters['studentId'] ?? '';
          return StudentProfileScreen(studentId: studentId);
        },
      ),

      // ── Main shell with bottom navigation ──────────────────────────────
      ShellRoute(
        builder: (context, state, child) => EngagebotScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.classes,
            name: 'classes',
            builder: (context, state) => const ClassesScreen(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: AppRoutes.recommendations,
            name: 'recommendations',
            builder: (context, state) => const AIRecommendationScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Notifies GoRouter whenever the Firebase auth state changes so the
/// redirect function is re-evaluated (sign-in → goes to /dashboard,
/// sign-out → goes to /login).
class _AuthStateNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _sub;

  _AuthStateNotifier() {
    _sub = FirebaseAuth.instance
        .authStateChanges()
        .listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
