import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: EngageBotApp()));
}

class EngageBotApp extends ConsumerStatefulWidget {
  const EngageBotApp({super.key});

  @override
  ConsumerState<EngageBotApp> createState() => _EngageBotAppState();
}

class _EngageBotAppState extends ConsumerState<EngageBotApp> {
  late final _router = buildAppRouter();

  @override
  void initState() {
    super.initState();
    // Restore persisted preferences (dark mode, toggles) from SharedPreferences.
    ref.read(settingsProvider.notifier).loadFromStorage();
  }

  @override
  Widget build(BuildContext context) {
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
