import '../models/trip.dart';
import '../models/scenario.dart';
import 'calculation_service.dart';

class ExcelSheetPreview {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;

  const ExcelSheetPreview({
    required this.title,
    required this.headers,
    required this.rows,
  });
}

class ExcelReportPreview {
  final String fileName;
  final List<ExcelSheetPreview> sheets;

  const ExcelReportPreview({
    required this.fileName,
    required this.sheets,
  });
}

enum ReportDocumentStatus {
  estimate, // Dự toán
  provisional, // Tạm tính
  settled, // Đã chốt
}

extension ReportDocumentStatusExt on ReportDocumentStatus {
  String get displayName {
    switch (this) {
      case ReportDocumentStatus.estimate:
        return 'Dự toán';
      case ReportDocumentStatus.provisional:
        return 'Tạm tính';
      case ReportDocumentStatus.settled:
        return 'Đã chốt';
    }
  }
}

class PdfReportPreview {
  final String title;
  final String subtitle;
  final ReportDocumentStatus status;
  final int totalAmount;
  final List<Map<String, String>> summaryCards;
  final List<Map<String, dynamic>> memberDetails;
  final List<String> settlementInstructions;
  final String generatedAt;

  const PdfReportPreview({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.totalAmount,
    required this.summaryCards,
    required this.memberDetails,
    required this.settlementInstructions,
    required this.generatedAt,
  });
}

abstract class ReportExportService {
  /// Sinh dữ liệu cấu trúc phục vụ Xem trước (Preview) bảng tính Excel
  /// với 7 tab: Thành viên, Chặng, Khoản chi, Phân bổ, Giao dịch, So sánh, Quyết toán.
  Future<ExcelReportPreview> generateExcelPreview({
    required Trip trip,
    required Scenario scenario,
    required CalculationService calculationService,
  });

  /// Sinh dữ liệu cấu trúc phục vụ Xem trước (Preview) tài liệu PDF
  /// gồm Tổng kết chuyến, Chi tiết từng người, Hướng dẫn quyết toán và nhãn trạng thái.
  Future<PdfReportPreview> generatePdfPreview({
    required Trip trip,
    required Scenario scenario,
    required CalculationService calculationService,
  });
}
