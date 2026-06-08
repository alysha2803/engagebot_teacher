import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_router.dart';
import '../../features/settings/settings_sidebar.dart';

/// Exposes the outer Scaffold's [openDrawer] to any descendant widget.
/// Screens retrieve it with [EngagebotDrawer.maybeOf(context)?.openDrawer()].
class EngagebotDrawer extends InheritedWidget {
  final VoidCallback openDrawer;

  const EngagebotDrawer({
    super.key,
    required this.openDrawer,
    required super.child,
  });

  static EngagebotDrawer? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EngagebotDrawer>();

  @override
  bool updateShouldNotify(EngagebotDrawer old) => false;
}

/// Shell scaffold: persistent bottom nav + app-level settings sidebar drawer.
class EngagebotScaffold extends StatefulWidget {
  final Widget child;
  const EngagebotScaffold({super.key, required this.child});

  @override
  State<EngagebotScaffold> createState() => _EngagebotScaffoldState();
}

class _EngagebotScaffoldState extends State<EngagebotScaffold> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _tabs = [
    AppRoutes.dashboard,
    AppRoutes.classes,
    AppRoutes.reports,
    AppRoutes.recommendations,
  ];

  int _currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _tabs.length; i++) {
      if (path.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return EngagebotDrawer(
      openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const SettingsSidebar(),
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => context.go(_tabs[i]),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              label: 'AI Insights',
            ),
          ],
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}
