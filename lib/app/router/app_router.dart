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
/// [refreshNotifier] is notified whenever the auth state changes so the
/// redirect guard re-evaluates. [isLoggedIn] is a callback that reads the
/// current auth state from Riverpod without needing a BuildContext here.
GoRouter buildAppRouter(
  ChangeNotifier refreshNotifier,
  bool Function() isLoggedIn,
) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == AppRoutes.splash) return null;
      final loggedIn = isLoggedIn();
      if (!loggedIn && loc != AppRoutes.login) return AppRoutes.login;
      if (loggedIn && loc == AppRoutes.login) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, _, child) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.classDetail,
        name: 'classDetail',
        builder: (context, state) {
          final classCode = Uri.decodeComponent(state.pathParameters['classCode'] ?? '');
          return ClassAnalyticsScreen(classCode: classCode);
        },
      ),
      GoRoute(
        path: AppRoutes.studentProfile,
        name: 'studentProfile',
        builder: (context, state) {
          final studentId = state.pathParameters['studentId'] ?? '';
          return StudentProfileScreen(studentId: studentId);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => EngagebotScaffold(child: child),
        routes: [
          GoRoute(path: AppRoutes.dashboard, name: 'dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: AppRoutes.classes, name: 'classes', builder: (_, __) => const ClassesScreen()),
          GoRoute(path: AppRoutes.reports, name: 'reports', builder: (_, __) => const ReportsScreen()),
          GoRoute(path: AppRoutes.recommendations, name: 'recommendations', builder: (_, __) => const AIRecommendationScreen()),
        ],
      ),
    ],
  );
}

/// Wraps a simple notify() so Riverpod can tell GoRouter when auth state changes.
class AppAuthNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
