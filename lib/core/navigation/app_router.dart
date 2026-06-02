import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/animation_helpers.dart';

// Import shell views (Stubs to make GoRouter buildable and functional)
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/create_session/presentation/screens/create_session_screen.dart';
import '../../features/practice/presentation/screens/practice_screen.dart';
import '../../features/evaluation/presentation/screens/evaluation_screen.dart';
import '../../features/verify_answers/presentation/screens/verify_answers_screen.dart';
import '../../features/result/presentation/screens/result_screen.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String createSession = '/create-session';
  static const String practice = '/practice';
  static const String evaluation = '/evaluation';
  static const String verifyAnswers = '/verify-answers';
  static const String result = '/result';
  static const String history = '/history';
  static const String analytics = '/analytics';
  static const String settings = '/settings';

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: home,
    navigatorKey: _rootNavigatorKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Home / Workflow branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                pageBuilder: (context, state) => FadeSlideTransitionPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'create-session',
                    pageBuilder: (context, state) => FadeSlideTransitionPage(
                      key: state.pageKey,
                      child: const CreateSessionScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'practice',
                    pageBuilder: (context, state) => FadeSlideTransitionPage(
                      key: state.pageKey,
                      child: const PracticeScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'evaluation',
                    pageBuilder: (context, state) => FadeSlideTransitionPage(
                      key: state.pageKey,
                      child: const EvaluationScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'verify-answers',
                    pageBuilder: (context, state) => FadeSlideTransitionPage(
                      key: state.pageKey,
                      child: const VerifyAnswersScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'result',
                    pageBuilder: (context, state) => FadeSlideTransitionPage(
                      key: state.pageKey,
                      child: const ResultScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // History branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: history,
                pageBuilder: (context, state) => FadeSlideTransitionPage(
                  key: state.pageKey,
                  child: const HistoryScreen(),
                ),
              ),
            ],
          ),
          // Analytics branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: analytics,
                pageBuilder: (context, state) => FadeSlideTransitionPage(
                  key: state.pageKey,
                  child: const AnalyticsScreen(),
                ),
              ),
            ],
          ),
          // Settings branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: settings,
                pageBuilder: (context, state) => FadeSlideTransitionPage(
                  key: state.pageKey,
                  child: const SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// A shell widget displaying persistent bottom navigation bar.
class ScaffoldWithBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
