import 'package:flutter_test/flutter_test.dart';
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
import 'package:group_travel_caculate/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App smoke test - Khởi chạy và hiển thị chuyến đi mẫu', (tester) async {
    final tripRepo = MockTripRepository();
    final calcService = MockCalculationService();
    final backupService = MockBackupImportService();
    final reportService = MockReportExportService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<TripRepository>.value(value: tripRepo),
          Provider<CalculationService>.value(value: calcService),
          Provider<BackupImportService>.value(value: backupService),
          Provider<ReportExportService>.value(value: reportService),
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
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Sổ Kiểm Kê Chi Tiêu Nhóm'), findsOneWidget);
    expect(find.textContaining('Đà Lạt'), findsWidgets);
  });
}
