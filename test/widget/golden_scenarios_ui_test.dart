import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:group_travel_caculate/domain/services/calculation_service.dart';
import 'package:group_travel_caculate/domain/services/trip_repository.dart';
import 'package:group_travel_caculate/domain/services/backup_import_service.dart';
import 'package:group_travel_caculate/domain/services/report_export_service.dart';
import 'package:group_travel_caculate/data/mock_services/mock_calculation_service.dart';
import 'package:group_travel_caculate/data/mock_services/mock_trip_repository.dart';
import 'package:group_travel_caculate/data/mock_services/mock_backup_import_service.dart';
import 'package:group_travel_caculate/data/mock_services/mock_report_export_service.dart';
import 'package:group_travel_caculate/viewmodels/trip_list_viewmodel.dart';
import 'package:group_travel_caculate/viewmodels/trip_overview_viewmodel.dart';
import 'package:group_travel_caculate/viewmodels/stages_expenses_viewmodel.dart';
import 'package:group_travel_caculate/viewmodels/scenarios_comparison_viewmodel.dart';
import 'package:group_travel_caculate/viewmodels/ledger_fund_viewmodel.dart';
import 'package:group_travel_caculate/viewmodels/settlement_viewmodel.dart';
import 'package:group_travel_caculate/viewmodels/backup_report_viewmodel.dart';
import 'package:group_travel_caculate/presentation/navigation/app_router.dart';
import 'package:group_travel_caculate/presentation/controllers/trip_session_controller.dart';
import 'package:group_travel_caculate/main.dart';

Widget createTestApp() {
  final tripRepo = MockTripRepository();
  final calcService = MockCalculationService();
  final backupService = MockBackupImportService();
  final reportService = MockReportExportService();

  return MultiProvider(
    providers: [
      Provider<TripRepository>.value(value: tripRepo),
      Provider<CalculationService>.value(value: calcService),
      Provider<BackupImportService>.value(value: backupService),
      Provider<ReportExportService>.value(value: reportService),
      ChangeNotifierProvider<TripSessionController>(
        create: (_) => TripSessionController(
          repository: tripRepo,
          calculationService: calcService,
        ),
      ),
      ChangeNotifierProvider<TripListViewModel>(
        create: (_) => TripListViewModel(repository: tripRepo),
      ),
      ChangeNotifierProvider<TripOverviewViewModel>(
        create: (_) => TripOverviewViewModel(
          repository: tripRepo,
          calculationService: calcService,
        ),
      ),
      ChangeNotifierProvider<StagesExpensesViewModel>(
        create: (_) => StagesExpensesViewModel(
          repository: tripRepo,
          calculationService: calcService,
        ),
      ),
      ChangeNotifierProvider<ScenariosComparisonViewModel>(
        create: (_) => ScenariosComparisonViewModel(
          repository: tripRepo,
          calculationService: calcService,
        ),
      ),
      ChangeNotifierProvider<LedgerFundViewModel>(
        create: (_) => LedgerFundViewModel(repository: tripRepo),
      ),
      ChangeNotifierProvider<SettlementViewModel>(
        create: (_) => SettlementViewModel(
          repository: tripRepo,
          calculationService: calcService,
        ),
      ),
      ChangeNotifierProvider<BackupReportViewModel>(
        create: (_) => BackupReportViewModel(
          repository: tripRepo,
          calculationService: calcService,
          backupImportService: backupService,
          reportExportService: reportService,
        ),
      ),
    ],
    child: const GroupTravelApp(),
  );
}

void main() {
  setUp(() {
    appRouter.go('/trips');
  });

  testWidgets('App renders correctly without overflow on 360px (Mobile)', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Khảo sát Trip List
    expect(find.text('Sổ Kiểm Kê Chi Tiêu Nhóm'), findsOneWidget);
    expect(find.textContaining('Đà Lạt'), findsWidgets);
    expect(find.text('Dữ liệu mẫu'), findsOneWidget);

    // Mở chuyến đi mẫu & chọn kịch bản
    await tester.tap(find.textContaining('Đà Lạt').first);
    await tester.pumpAndSettle();

    if (find.text('Mở kịch bản này').evaluate().isNotEmpty) {
      await tester.tap(find.text('Mở kịch bản này'));
      await tester.pumpAndSettle();
    }

    // Màn hình Overview
    expect(find.textContaining('Đà Lạt'), findsWidgets);
    expect(find.text('An', skipOffstage: false), findsWidgets);
    expect(find.text('Bình', skipOffstage: false), findsWidgets);
    expect(find.text('Chi', skipOffstage: false), findsWidgets);
    expect(find.text('Dũng', skipOffstage: false), findsWidgets);
  });

  testWidgets('App renders correctly without overflow on 600px (Tablet)', (tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Sổ Kiểm Kê Chi Tiêu Nhóm'), findsOneWidget);
    expect(find.textContaining('Đà Lạt'), findsWidgets);

    // Mở chuyến đi mẫu & chọn kịch bản
    await tester.tap(find.textContaining('Đà Lạt').first);
    await tester.pumpAndSettle();

    if (find.text('Mở kịch bản này').evaluate().isNotEmpty) {
      await tester.tap(find.text('Mở kịch bản này'));
      await tester.pumpAndSettle();
    }

    // Màn hình Overview
    expect(find.textContaining('Đà Lạt'), findsWidgets);
  });

  testWidgets('App renders correctly without overflow on 1280px (Desktop)', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Sổ Kiểm Kê Chi Tiêu Nhóm'), findsOneWidget);
    expect(find.textContaining('Đà Lạt'), findsWidgets);

    // Mở chuyến đi mẫu & chọn kịch bản
    await tester.tap(find.textContaining('Đà Lạt').first);
    await tester.pumpAndSettle();

    if (find.text('Mở kịch bản này').evaluate().isNotEmpty) {
      await tester.tap(find.text('Mở kịch bản này'));
      await tester.pumpAndSettle();
    }

    // Kiểm tra NavigationRail hiển thị trên Desktop
    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
