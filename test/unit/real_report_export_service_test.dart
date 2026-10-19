import 'package:flutter_test/flutter_test.dart';
import 'package:group_travel_caculate/data/fixtures/golden_fixture.dart';
import 'package:group_travel_caculate/data/services/real_report_export_service.dart';
import 'package:group_travel_caculate/domain/services/real_calculation_service.dart';

void main() {
  group('RealReportExportService Tests', () {
    late RealReportExportService service;
    late RealCalculationService calcService;
    final goldenTrip = GoldenFixture.createGoldenTrip();
    final scenario = goldenTrip.scenarios.firstWhere((s) => s.id == 'scenario_4');

    setUp(() {
      service = RealReportExportService();
      calcService = RealCalculationService();
    });

    test('Sinh cấu trúc Excel Preview đầy đủ 7 tab với dữ liệu chuẩn xác', () async {
      final preview = await service.generateExcelPreview(
        trip: goldenTrip,
        scenario: scenario,
        calculationService: calcService,
      );

      expect(preview.sheets.length, 7);
      final sheetTitles = preview.sheets.map((s) => s.title).toList();
      expect(sheetTitles, contains('1. Thành viên'));
      expect(sheetTitles, contains('2. Chặng'));
      expect(sheetTitles, contains('3. Khoản chi'));
      expect(sheetTitles, contains('4. Phân bổ'));
      expect(sheetTitles, contains('5. Sổ giao dịch'));
      expect(sheetTitles, contains('6. So sánh'));
      expect(sheetTitles, contains('7. Quyết toán'));

      // Kiểm tra sheet thành viên
      final memberSheet = preview.sheets.firstWhere((s) => s.title == '1. Thành viên');
      expect(memberSheet.rows.length, goldenTrip.members.length);

      // Kiểm tra sheet quyết toán
      final settleSheet = preview.sheets.firstWhere((s) => s.title == '7. Quyết toán');
      expect(settleSheet.rows.length, goldenTrip.members.length);
    });

    test('Xuất file nhị phân Excel (.xlsx) không rỗng', () async {
      final bytes = await service.generateExcelBytes(
        trip: goldenTrip,
        scenario: scenario,
        calculationService: calcService,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
    });

    test('Sinh cấu trúc PDF Preview với tóm tắt và chi tiết từng thành viên', () async {
      final preview = await service.generatePdfPreview(
        trip: goldenTrip,
        scenario: scenario,
        calculationService: calcService,
      );

      expect(preview.title, isNotEmpty);
      expect(preview.subtitle, contains(goldenTrip.name));
      expect(preview.summaryCards, isNotEmpty);
      expect(preview.memberDetails.length, goldenTrip.members.length);
      expect(preview.settlementInstructions, isNotEmpty);
    });

    test('Xuất file nhị phân PDF (.pdf) không rỗng', () async {
      final bytes = await service.generatePdfBytes(
        trip: goldenTrip,
        scenario: scenario,
        calculationService: calcService,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(500));
    });
  });
}
