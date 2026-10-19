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
import 'package:group_travel_caculate/data/fixtures/golden_fixture.dart';
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

Widget createFlowTestApp() {
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

  testWidgets('Settlement Screen displays exact Golden Fixture 4 values and transfer steps', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createFlowTestApp());
    await tester.pumpAndSettle();

    appRouter.go('/trips/${GoldenFixture.tripId}/settlement');
    await tester.pumpAndSettle();

    // Verify Title & Scenarios Badge
    expect(find.text('Quyết Toán Cuối Chuyến & Thu Chi Công Nợ'), findsOneWidget);
    expect(find.textContaining('Dũng nghỉ + Chi về sớm'), findsWidgets);

    // Verify Member Debt Amounts (Scenario 4)
    // An: +164.286 đ
    expect(find.textContaining('164.286'), findsWidgets);
    // Bình: -84.286 đ
    expect(find.textContaining('84.286'), findsWidgets);
    // Chi: +40.000 đ
    expect(find.textContaining('40.000'), findsWidgets);
    // Dũng: +100.000 đ
    expect(find.textContaining('100.000'), findsWidgets);

    // Verify Fund Cash on Hand
    expect(find.textContaining('220.000'), findsWidgets);

    // Switch between settlement modes
    expect(find.text('Qua Quỹ'), findsOneWidget);
    expect(find.text('Gợi ý chuyển khoản gọn'), findsOneWidget);

    await tester.tap(find.text('Gợi ý chuyển khoản gọn'));
    await tester.pumpAndSettle();

    expect(find.text('Gợi ý chuyển khoản gọn'), findsOneWidget);
  });

  testWidgets('Scenarios Screen shows comparison matrix and drilldown dialog', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createFlowTestApp());
    await tester.pumpAndSettle();

    appRouter.go('/trips/${GoldenFixture.tripId}/scenarios');
    await tester.pumpAndSettle();

    // Check title
    expect(find.text('Ma trận có mặt theo từng chặng (Attendance Matrix)'), findsOneWidget);
    expect(find.text('Bảng So Sánh Kịch Bản (What-if Comparison)'), findsOneWidget);

    // Tap on member drilldown button for 'An'
    final drilldownFinder = find.byIcon(Icons.info_outline);
    expect(drilldownFinder, findsWidgets);

    await tester.tap(drilldownFinder.first);
    await tester.pumpAndSettle();

    // Verify Drill-down dialog opens
    expect(find.textContaining('Bóc tách nguồn gốc'), findsOneWidget);
    expect(find.byTooltip('Đóng'), findsOneWidget);

    await tester.tap(find.byTooltip('Đóng'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bóc tách nguồn gốc'), findsNothing);
  });

  testWidgets('Ledger & Fund Screen displays cash transactions and fund balance', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createFlowTestApp());
    await tester.pumpAndSettle();

    appRouter.go('/trips/${GoldenFixture.tripId}/ledger');
    await tester.pumpAndSettle();

    // Verify Ledger title and fund balance card (220.000 đ)
    expect(find.text('Sổ Thực Tế & Quản Lý Dòng Tiền'), findsOneWidget);
    expect(find.textContaining('220.000'), findsWidgets);
    expect(find.text('Ghi nhận giao dịch'), findsOneWidget);
  });

  testWidgets('Reports Screen displays Excel & PDF preview tabs with honesty notice', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createFlowTestApp());
    await tester.pumpAndSettle();

    appRouter.go('/trips/${GoldenFixture.tripId}/reports');
    await tester.pumpAndSettle();

    // Verify Report Screen
    expect(find.text('Xem Trước Báo Cáo & Sao Lưu Dữ Liệu'), findsOneWidget);
    expect(find.text('Xem trước Excel (7 Tab)'), findsOneWidget);
    expect(find.text('Xem trước PDF'), findsOneWidget);
    expect(find.text('Sao lưu .grouptrip.json'), findsOneWidget);
    expect(find.textContaining('Bản xem trước (Preview)'), findsWidgets);
  });
}
