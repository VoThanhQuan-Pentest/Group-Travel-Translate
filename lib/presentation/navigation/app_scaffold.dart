import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_layout.dart';
import '../../viewmodels/trip_overview_viewmodel.dart';
import '../controllers/trip_session_controller.dart';
import '../widgets/sample_data_banner.dart';
import '../widgets/scenario_picker_dialog.dart';

class AppScaffold extends StatelessWidget {
  final String tripId;
  final Widget child;

  const AppScaffold({
    super.key,
    required this.tripId,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains('/overview')) return 0;
    if (location.contains('/stages')) return 1;
    if (location.contains('/scenarios')) return 2;
    if (location.contains('/ledger')) return 3;
    if (location.contains('/settlement')) return 4;
    if (location.contains('/reports')) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/trips/$tripId/overview');
        break;
      case 1:
        context.go('/trips/$tripId/stages');
        break;
      case 2:
        context.go('/trips/$tripId/scenarios');
        break;
      case 3:
        context.go('/trips/$tripId/ledger');
        break;
      case 4:
        context.go('/trips/$tripId/settlement');
        break;
      case 5:
        context.go('/trips/$tripId/reports');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isDesktop = ResponsiveLayout.isExpanded(context);
    final isTablet = ResponsiveLayout.isMedium(context);
    final session = context.watch<TripSessionController>();
    final overviewVm = context.watch<TripOverviewViewModel>();
    final trip = session.trip ?? overviewVm.trip;

    // Ensure session is initialized for this trip
    if (session.trip?.id != tripId && !session.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        session.openTrip(tripId);
      });
    }

    final activeScenarioName = session.activeScenario?.name ?? trip?.activeScenario?.name ?? "Mặc định";
    final isActualMode = session.isActualMode;

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Tổng quan',
      ),
      const NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'Chặng & Chi',
      ),
      const NavigationDestination(
        icon: Icon(Icons.alt_route_outlined),
        selectedIcon: Icon(Icons.alt_route),
        label: 'Kịch bản',
      ),
      const NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet),
        label: 'Sổ & Quỹ',
      ),
      const NavigationDestination(
        icon: Icon(Icons.price_check_outlined),
        selectedIcon: Icon(Icons.price_check),
        label: 'Quyết toán',
      ),
    ];

    final railDestinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: Text('Tổng quan'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: Text('Chặng & Chi'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.alt_route_outlined),
        selectedIcon: Icon(Icons.alt_route),
        label: Text('Kịch bản'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet),
        label: Text('Sổ & Quỹ'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.price_check_outlined),
        selectedIcon: Icon(Icons.price_check),
        label: Text('Quyết toán'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.print_outlined),
        selectedIcon: Icon(Icons.print),
        label: Text('Báo cáo & Sao lưu'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Quay lại danh sách chuyến đi',
          onPressed: () => context.go('/trips'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip?.name ?? 'Đang tải chuyến đi...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (trip != null) ...[
              const SizedBox(height: 2),
              Wrap(
                spacing: 6,
                runSpacing: 2,
                children: [
                  // Clickable Badge Kịch bản đang xem
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      ScenarioPickerDialog.show(
                        context,
                        trip: trip,
                        initialSelectedId: session.selectedScenarioId ?? trip.activeScenarioId,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Kịch bản: $activeScenarioName',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSecondaryContainer,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 14,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Clickable Badge Chế độ (Dự toán / Thực tế)
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      session.setMode(isActual: !session.isActualMode);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isActualMode
                            ? AppColors.successContainer
                            : AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActualMode ? 'Sổ thực tế (Bấm để đổi)' : 'Dự toán (Bấm để đổi)',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isActualMode
                              ? AppColors.onSuccessContainer
                              : AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          if (trip != null)
            IconButton(
              icon: const Icon(Icons.alt_route),
              tooltip: 'Đổi kịch bản',
              onPressed: () {
                ScenarioPickerDialog.show(
                  context,
                  trip: trip,
                  initialSelectedId: session.selectedScenarioId ?? trip.activeScenarioId,
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Xem trước Báo cáo & Sao lưu',
            onPressed: () => context.go('/trips/$tripId/reports'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: SampleDataBanner(),
        ),
      ),
      body: Row(
        children: [
          if (isDesktop || isTablet)
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              labelType: NavigationRailLabelType.all,
              destinations: railDestinations,
              backgroundColor: Colors.white,
              indicatorColor: AppColors.primaryContainer,
              minWidth: 72,
            ),
          if (isDesktop || isTablet)
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.outlineVariant),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: (!isDesktop && !isTablet)
          ? NavigationBar(
              selectedIndex: selectedIndex > 4 ? 0 : selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              destinations: destinations,
              backgroundColor: Colors.white,
              indicatorColor: AppColors.primaryContainer,
            )
          : null,
    );
  }
}
