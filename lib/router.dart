import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/donation.dart';
import 'screens/dashboard_screen.dart';
import 'screens/donation_list_screen.dart';
import 'screens/application_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_donation_screen.dart';
import 'widgets/scaffold_with_navbar.dart';

import 'services/auth_service.dart';
import 'screens/login_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _sectionANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionANav');

final authService = AuthService();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: authService,
  redirect: (context, state) {
    final isLoggedIn = authService.isAuthenticated;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }

    if (isLoggedIn && isLoggingIn) {
      return '/';
    }

    return null;
  },
  routes: <RouteBase>[
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
              routes: [
                GoRoute(
                  path: 'add',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) =>
                      const AddDonationScreen(),
                ),
                GoRoute(
                  path: 'edit',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    final donation = state.extra as Donation;
                    return AddDonationScreen(donation: donation);
                  },
                ),
              ],
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
