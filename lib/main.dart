import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: EngageBotApp()));
}

class EngageBotApp extends ConsumerStatefulWidget {
  const EngageBotApp({super.key});

  @override
  ConsumerState<EngageBotApp> createState() => _EngageBotAppState();
}

class _EngageBotAppState extends ConsumerState<EngageBotApp> {
  final _authNotifier = AppAuthNotifier();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter(
      _authNotifier,
      () => ref.read(authProvider).isAuthenticated,
    );
    ref.read(settingsProvider.notifier).loadFromStorage();
  }

  @override
  void dispose() {
    _authNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Notify GoRouter whenever auth state changes so the redirect guard fires.
    ref.listen<AuthState>(authProvider, (_, __) => _authNotifier.notify());

    final isDark = ref.watch(settingsProvider.select((s) => s.darkMode));
    return MaterialApp.router(
      title: 'EngageBot Teacher',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
    );
  }
}
