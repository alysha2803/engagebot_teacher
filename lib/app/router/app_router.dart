// ignore: unused_import — needed for Widget type in builder closures via go_router
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/classes/classes_screen.dart';
import '../../features/student_profile/student_profile_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/engagebot_scaffold.dart';

/// Named route constants — use these everywhere instead of raw strings.
abstract final class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const classes = '/classes';
  static const studentProfile = '/students/:studentId';
  static const reports = '/reports';
  static const settings = '/settings';
}

/// Builds and returns the GoRouter for the app.
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      // Auth — standalone, no shell
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main shell with bottom navigation
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
            routes: [
              // Student profile is a sub-route pushed from Classes (or Dashboard)
              GoRoute(
                path: 'students/:studentId',
                name: 'studentProfile',
                builder: (context, state) {
                  final studentId = state.pathParameters['studentId'] ?? '';
                  return StudentProfileScreen(studentId: studentId);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
