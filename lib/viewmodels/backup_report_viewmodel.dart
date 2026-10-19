import 'package:flutter/foundation.dart';
import '../domain/models/trip.dart';
import '../domain/models/scenario.dart';
import '../domain/services/trip_repository.dart';
import '../domain/services/calculation_service.dart';
import '../domain/services/backup_import_service.dart';
import '../domain/services/report_export_service.dart';

class BackupReportViewModel extends ChangeNotifier {
  final TripRepository _repository;
  final CalculationService _calculationService;
  final BackupImportService _backupImportService;
  final ReportExportService _reportExportService;

  Trip? _trip;
  bool _isLoading = false;
  String? _errorMessage;

  // Export state
  String? _exportedJson;
  bool _isExporting = false;

  // Import state
  Trip? _previewedTrip;
  bool _isImporting = false;
  String? _importError;

  // Report previews
  ExcelReportPreview? _excelPreview;
  PdfReportPreview? _pdfPreview;
  bool _isGeneratingReport = false;

  BackupReportViewModel({
    required TripRepository repository,
    required CalculationService calculationService,
    required BackupImportService backupImportService,
    required ReportExportService reportExportService,
  })  : _repository = repository,
        _calculationService = calculationService,
        _backupImportService = backupImportService,
        _reportExportService = reportExportService;

  Trip? get trip => _trip;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get exportedJson => _exportedJson;
  bool get isExporting => _isExporting;

  Trip? get previewedTrip => _previewedTrip;
  bool get isImporting => _isImporting;
  String? get importError => _importError;

  ExcelReportPreview? get excelPreview => _excelPreview;
  PdfReportPreview? get pdfPreview => _pdfPreview;
  bool get isGeneratingReport => _isGeneratingReport;

  Scenario? get activeScenario => _trip?.activeScenario;

  Future<void> loadTrip(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trip = await _repository.getTripById(tripId);
      if (_trip == null) {
        _errorMessage = 'Không tìm thấy chuyến đi: $tripId';
      } else {
        await generatePreviews();
      }
    } catch (e) {
      _errorMessage = 'Lỗi tải thông tin sao lưu & báo cáo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportSingleTrip() async {
    if (_trip == null) return;
    _isExporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _exportedJson = await _backupImportService.exportBackupJson(trip: _trip!);
    } catch (e) {
      _errorMessage = 'Lỗi xuất file sao lưu: $e';
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  Future<void> exportAllTrips() async {
    if (_trip == null) return;
    _isExporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final all = await _repository.getTrips();
      _exportedJson = await _backupImportService.exportBackupJson(
        trip: _trip!,
        allTrips: true,
        trips: all,
      );
    } catch (e) {
      _errorMessage = 'Lỗi xuất toàn bộ chuyến đi: $e';
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  Future<void> previewImport(String jsonString) async {
    _isImporting = true;
    _importError = null;
    _previewedTrip = null;
    notifyListeners();

    try {
      _previewedTrip = await _backupImportService.previewImportJson(jsonString);
    } catch (e) {
      _importError = e.toString();
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<Trip?> commitImport(String jsonString) async {
    _isImporting = true;
    _importError = null;
    notifyListeners();

    try {
      final importedTrip = await _backupImportService.commitImport(
        jsonString: jsonString,
        repository: _repository,
      );
      _previewedTrip = null;
      return importedTrip;
    } catch (e) {
      _importError = 'Lỗi lưu dữ liệu import: $e';
      return null;
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  void cancelImportPreview() {
    _previewedTrip = null;
    _importError = null;
    notifyListeners();
  }

  Future<void> generatePreviews() async {
    if (_trip == null || activeScenario == null) return;
    _isGeneratingReport = true;
    notifyListeners();

    try {
      _excelPreview = await _reportExportService.generateExcelPreview(
        trip: _trip!,
        scenario: activeScenario!,
        calculationService: _calculationService,
      );

      _pdfPreview = await _reportExportService.generatePdfPreview(
        trip: _trip!,
        scenario: activeScenario!,
        calculationService: _calculationService,
      );
    } catch (e) {
      _errorMessage = 'Lỗi sinh bản xem trước báo cáo: $e';
    } finally {
      _isGeneratingReport = false;
      notifyListeners();
    }
  }
}
