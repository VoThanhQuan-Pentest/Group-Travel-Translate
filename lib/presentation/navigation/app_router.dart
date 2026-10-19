import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/trip_list_screen.dart';
import '../screens/trip_overview_screen.dart';
import '../screens/stages_expenses_screen.dart';
import '../screens/scenarios_screen.dart';
import '../screens/ledger_fund_screen.dart';
import '../screens/settlement_screen.dart';
import '../screens/backup_reports_screen.dart';
import 'app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/trips',
  routes: [
    GoRoute(
      path: '/trips',
      builder: (context, state) => const TripListScreen(),
    ),
    GoRoute(
      path: '/trips/:tripId',
      redirect: (context, state) {
        final tripId = state.pathParameters['tripId'];
        return '/trips/$tripId/overview';
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        final tripId = state.pathParameters['tripId'] ?? 'golden_trip_dalat';
        return AppScaffold(tripId: tripId, child: child);
      },
      routes: [
        GoRoute(
          path: '/trips/:tripId/overview',
          builder: (context, state) {
            final tripId = state.pathParameters['tripId']!;
            return TripOverviewScreen(tripId: tripId);
          },
        ),
        GoRoute(
          path: '/trips/:tripId/stages',
          builder: (context, state) {
            final tripId = state.pathParameters['tripId']!;
            return StagesExpensesScreen(tripId: tripId);
          },
        ),
        GoRoute(
          path: '/trips/:tripId/scenarios',
          builder: (context, state) {
            final tripId = state.pathParameters['tripId']!;
            return ScenariosScreen(tripId: tripId);
          },
        ),
        GoRoute(
          path: '/trips/:tripId/ledger',
          builder: (context, state) {
            final tripId = state.pathParameters['tripId']!;
            return LedgerFundScreen(tripId: tripId);
          },
        ),
        GoRoute(
          path: '/trips/:tripId/settlement',
          builder: (context, state) {
            final tripId = state.pathParameters['tripId']!;
            return SettlementScreen(tripId: tripId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/trips/:tripId/reports',
      builder: (context, state) {
        final tripId = state.pathParameters['tripId']!;
        return BackupReportsScreen(tripId: tripId);
      },
    ),
  ],
);
