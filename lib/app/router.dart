import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/history/presentation/history_screen.dart';
import '../features/history/presentation/trip_detail_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/map/presentation/map_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/paywall/presentation/paywall_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/sos/presentation/sos_screen.dart';
import '../features/statistics/presentation/stats_screen.dart';
import '../features/tracking/presentation/tracking_screen.dart';
import 'shell.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellKey = GlobalKey<NavigatorState>();

abstract class AppRoute {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String map = '/map';
  static const String history = '/history';
  static const String stats = '/stats';
  static const String tripDetail = '/trip/:id';
  static const String tracking = '/tracking';
  static const String sos = '/sos';
  static const String settings = '/settings';
  static const String paywall = '/paywall';
}

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoute.home,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoute.onboarding,
        parentNavigatorKey: _rootKey,
        builder: (BuildContext context, GoRouterState state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.tracking,
        parentNavigatorKey: _rootKey,
        builder: (BuildContext context, GoRouterState state) => const TrackingScreen(),
      ),
      GoRoute(
        path: AppRoute.sos,
        parentNavigatorKey: _rootKey,
        builder: (BuildContext context, GoRouterState state) => const SosScreen(),
      ),
      GoRoute(
        path: AppRoute.paywall,
        parentNavigatorKey: _rootKey,
        builder: (BuildContext context, GoRouterState state) => const PaywallScreen(),
      ),
      GoRoute(
        path: AppRoute.settings,
        parentNavigatorKey: _rootKey,
        builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoute.tripDetail,
        parentNavigatorKey: _rootKey,
        builder: (BuildContext context, GoRouterState state) =>
            TripDetailScreen(tripId: state.pathParameters['id']!),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            AppShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: AppRoute.home,
            pageBuilder: (BuildContext c, GoRouterState s) =>
                const NoTransitionPage<void>(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoute.map,
            pageBuilder: (BuildContext c, GoRouterState s) =>
                const NoTransitionPage<void>(child: MapScreen()),
          ),
          GoRoute(
            path: AppRoute.history,
            pageBuilder: (BuildContext c, GoRouterState s) =>
                const NoTransitionPage<void>(child: HistoryScreen()),
          ),
          GoRoute(
            path: AppRoute.stats,
            pageBuilder: (BuildContext c, GoRouterState s) =>
                const NoTransitionPage<void>(child: StatsScreen()),
          ),
        ],
      ),
    ],
  );
});
