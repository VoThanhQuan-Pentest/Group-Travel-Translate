import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'domain/services/calculation_service.dart';
import 'domain/services/trip_repository.dart';
import 'domain/services/backup_import_service.dart';
import 'domain/services/report_export_service.dart';
import 'domain/services/real_calculation_service.dart';
import 'data/repositories/drift_trip_repository.dart';
import 'data/services/real_backup_import_service.dart';
import 'data/services/real_report_export_service.dart';
import 'presentation/controllers/trip_session_controller.dart';
import 'viewmodels/trip_list_viewmodel.dart';
import 'viewmodels/trip_overview_viewmodel.dart';
import 'viewmodels/stages_expenses_viewmodel.dart';
import 'viewmodels/scenarios_comparison_viewmodel.dart';
import 'viewmodels/ledger_fund_viewmodel.dart';
import 'viewmodels/settlement_viewmodel.dart';
import 'viewmodels/backup_report_viewmodel.dart';
import 'presentation/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo các Persistent Drift SQLite Repository & Real Pure Dart Services
  final TripRepository tripRepository = DriftTripRepository();
  final CalculationService calculationService = RealCalculationService();
  final BackupImportService backupImportService = RealBackupImportService();
  final ReportExportService reportExportService = RealReportExportService();

  runApp(
    MultiProvider(
      providers: [
        // Services injection
        Provider<TripRepository>.value(value: tripRepository),
        Provider<CalculationService>.value(value: calculationService),
        Provider<BackupImportService>.value(value: backupImportService),
        Provider<ReportExportService>.value(value: reportExportService),

        // Session Controller (Unified session state)
        ChangeNotifierProvider<TripSessionController>(
          create: (_) => TripSessionController(
            repository: tripRepository,
            calculationService: calculationService,
          ),
        ),

        // ViewModels
        ChangeNotifierProvider<TripListViewModel>(
          create: (_) => TripListViewModel(repository: tripRepository),
        ),
        ChangeNotifierProvider<TripOverviewViewModel>(
          create: (_) => TripOverviewViewModel(
            repository: tripRepository,
            calculationService: calculationService,
          ),
        ),
        ChangeNotifierProvider<StagesExpensesViewModel>(
          create: (_) => StagesExpensesViewModel(
            repository: tripRepository,
            calculationService: calculationService,
          ),
        ),
        ChangeNotifierProvider<ScenariosComparisonViewModel>(
          create: (_) => ScenariosComparisonViewModel(
            repository: tripRepository,
            calculationService: calculationService,
          ),
        ),
        ChangeNotifierProvider<LedgerFundViewModel>(
          create: (_) => LedgerFundViewModel(repository: tripRepository),
        ),
        ChangeNotifierProvider<SettlementViewModel>(
          create: (_) => SettlementViewModel(
            repository: tripRepository,
            calculationService: calculationService,
          ),
        ),
        ChangeNotifierProvider<BackupReportViewModel>(
          create: (_) => BackupReportViewModel(
            repository: tripRepository,
            calculationService: calculationService,
            backupImportService: backupImportService,
            reportExportService: reportExportService,
          ),
        ),
      ],
      child: const GroupTravelApp(),
    ),
  );
}

class GroupTravelApp extends StatelessWidget {
  const GroupTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kiểm kê chi tiêu & chia tiền nhóm theo chặng',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
