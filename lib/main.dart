import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';

void main() {
  runApp(
    // Wrap entire app in ProviderScope so Riverpod providers are accessible everywhere
    const ProviderScope(child: EngageBotApp()),
  );
}

class EngageBotApp extends StatefulWidget {
  const EngageBotApp({super.key});

  @override
  State<EngageBotApp> createState() => _EngageBotAppState();
}

class _EngageBotAppState extends State<EngageBotApp> {
  // Router instance is kept in state so it survives rebuilds
  late final _router = buildAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EngageBot Teacher',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
