import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/dashboard_screen.dart';
import 'screens/donation_list_screen.dart';
import 'screens/application_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/scaffold_with_navbar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _sectionANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionANav');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
      branches: <StatefulShellBranch>[
        // Dashboard
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) =>
                  const DashboardScreen(),
            ),
          ],
        ),
        // Donations
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/donations',
              builder: (BuildContext context, GoRouterState state) =>
                  const DonationListScreen(),
            ),
          ],
        ),
        // Applications
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/applications',
              builder: (BuildContext context, GoRouterState state) =>
                  const ApplicationScreen(),
            ),
          ],
        ),
        // Settings
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/settings',
              builder: (BuildContext context, GoRouterState state) =>
                  const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
