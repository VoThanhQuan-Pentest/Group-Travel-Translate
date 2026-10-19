import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/trip.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/settlement.dart';
import '../../domain/models/cash_transaction.dart';
import '../../domain/services/calculation_service.dart';
import '../../domain/services/report_export_service.dart';

class RealReportExportService implements ReportExportService {
  @override
  Future<ExcelReportPreview> generateExcelPreview({
    required Trip trip,
    required Scenario scenario,
    required CalculationService calculationService,
  }) async {
    final calcResult = calculationService.calculateScenario(
      trip: trip,
      scenario: scenario,
    );
    final settlementResult = calculationService.calculateSettlement(
      trip: trip,
      scenario: scenario,
      method: SettlementMethod.viaFund,
    );

    // 1. Members
    final memberHeaders = ['Mã TV', 'Họ và tên', 'Vai trò', 'Trạng thái'];
    final memberRows = trip.members
        .map((m) => [
              m.id,
              m.name,
              m.id == trip.treasurerId ? 'Thủ quỹ' : 'Thành viên',
              m.isActive ? 'Đang tham gia' : 'Đã ngừng',
            ])
        .toList();

    // 2. Stages
    final stageHeaders = ['Thứ tự', 'Mã chặng', 'Tên chặng', 'Mô tả'];
    final stageRows = trip.stages
        .map((s) => [
              s.order.toString(),
              s.id,
              s.name,
              s.description ?? '',
            ])
        .toList();

    // 3. Expenses
    final expenseHeaders = [
      'Mã khoản chi',
      'Tên khoản chi',
      'Chặng gắn',
      'Phương thức tính',
      'Cam kết',
      'Giá dự tính',
      'Giá thực tế',
    ];
    final expenseRows = trip.expenses
        .map((e) => [
              e.id,
              e.title,
              trip.getStage(e.stageId)?.name ?? e.stageId,
              e.calcMode.displayName,
              e.isCommitted ? 'Có' : 'Không',
              CurrencyFormatter.formatVnd(
                e.estimatedTotal > 0 ? e.estimatedTotal : e.unitPrice,
              ),
              CurrencyFormatter.formatVnd(e.actualPrice),
            ])
        .toList();

    // 4. Allocations
    final allocationHeaders = [
      'Thành viên',
      'Khoản chi',
      'Tiền gốc/Món',
      'Phí Ship',
      'Giảm giá',
      'Số tiền chịu',
      'Ghi chú giải thích',
    ];
    final allocationRows = <List<String>>[];
    for (final member in trip.members) {
      final breakdowns = calcResult.getMemberBreakdowns(member.id);
      for (final bd in breakdowns) {
        allocationRows.add([
          member.name,
          bd.expenseTitle,
          CurrencyFormatter.formatVnd(bd.baseAmount),
          CurrencyFormatter.formatVnd(bd.shippingShare),
          CurrencyFormatter.formatVnd(bd.discountShare),
          CurrencyFormatter.formatVnd(bd.finalShare),
          bd.explanationNotes,
        ]);
      }
    }

    // 5. Cash Transactions
    final txHeaders = [
      'Mã GD',
      'Thời gian',
      'Loại giao dịch',
      'Người chi/góp',
      'Người nhận',
      'Số tiền',
      'Ghi chú',
    ];
    final txRows = trip.cashTransactions
        .map((tx) => [
              tx.id,
              '${tx.timestamp.hour}:${tx.timestamp.minute.toString().padLeft(2, '0')} ${tx.timestamp.day}/${tx.timestamp.month}',
              tx.type.displayName,
              tx.payerMemberId == 'fund'
                  ? 'Quỹ chung'
                  : (trip.getMember(tx.payerMemberId)?.name ?? tx.payerMemberId),
              tx.recipient,
              CurrencyFormatter.formatVnd(tx.amount),
              tx.note,
            ])
        .toList();

    // 6. Comparison
    final compHeaders = [
      'Thành viên',
      'Chi phí kịch bản hiện tại',
      'Chi phí kịch bản mốc',
      'Chênh lệch (+/-)',
    ];
    final compRows = <List<String>>[];
    final baseline = trip.baselineScenario ?? scenario;
    final baselineCalc = calculationService.calculateScenario(
      trip: trip,
      scenario: baseline,
    );

    for (final m in trip.members) {
      final targetCost = calcResult.getMemberCost(m.id);
      final baseCost = baselineCalc.getMemberCost(m.id);
      final diff = targetCost - baseCost;
      compRows.add([
        m.name,
        CurrencyFormatter.formatVnd(targetCost),
        CurrencyFormatter.formatVnd(baseCost),
        '${diff >= 0 ? "+" : ""}${CurrencyFormatter.formatVnd(diff)}',
      ]);
    }

    // 7. Settlement
    final settlementHeaders = [
      'Thành viên',
      'Phần phải chịu',
      'Đã góp quỹ',
      'Đã ứng tiền túi',
      'Đã nhận lại',
      'Số dư ròng',
      'Hành động quyết toán',
    ];
    final settlementRows = settlementResult.debtSummaries
        .map((ds) => [
              ds.memberName,
              CurrencyFormatter.formatVnd(ds.costObligation),
              CurrencyFormatter.formatVnd(ds.fundContributed),
              CurrencyFormatter.formatVnd(ds.outOfPocketPaid),
              CurrencyFormatter.formatVnd(ds.refunded),
              CurrencyFormatter.formatVnd(ds.netBalance),
              ds.needsToPay
                  ? 'Cần đóng: ${CurrencyFormatter.formatVnd(ds.amountToPay)}'
                  : (ds.getsRefund
                      ? 'Nhận về: ${CurrencyFormatter.formatVnd(ds.amountToReceive)}'
                      : 'Đã cân bằng'),
            ])
        .toList();

    final sheets = [
      ExcelSheetPreview(title: '1. Thành viên', headers: memberHeaders, rows: memberRows),
      ExcelSheetPreview(title: '2. Chặng', headers: stageHeaders, rows: stageRows),
      ExcelSheetPreview(title: '3. Khoản chi', headers: expenseHeaders, rows: expenseRows),
      ExcelSheetPreview(title: '4. Phân bổ', headers: allocationHeaders, rows: allocationRows),
      ExcelSheetPreview(title: '5. Sổ giao dịch', headers: txHeaders, rows: txRows),
      ExcelSheetPreview(title: '6. So sánh', headers: compHeaders, rows: compRows),
      ExcelSheetPreview(title: '7. Quyết toán', headers: settlementHeaders, rows: settlementRows),
    ];

    return ExcelReportPreview(
      fileName: 'BaoCao_${trip.name.replaceAll(RegExp(r'\s+'), '_')}_${scenario.name}.xlsx',
      sheets: sheets,
    );
  }

  Future<List<int>> generateExcelBytes({
    required Trip trip,
    required Scenario scenario,
    required CalculationService calculationService,
  }) async {
    final preview = await generateExcelPreview(
      trip: trip,
      scenario: scenario,
      calculationService: calculationService,
    );

    final excel = Excel.createExcel();

    for (final sheetPreview in preview.sheets) {
      final sheet = excel[sheetPreview.title];
      sheet.appendRow(sheetPreview.headers.map((h) => TextCellValue(h)).toList());
      for (final row in sheetPreview.rows) {
        sheet.appendRow(row.map((c) => TextCellValue(c)).toList());
      }
    }

    // Remove default sheet if not needed
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    return excel.encode() ?? <int>[];
  }

  @override
  Future<PdfReportPreview> generatePdfPreview({
    required Trip trip,
    required Scenario scenario,
    required CalculationService calculationService,
  }) async {
    final calcResult = calculationService.calculateScenario(
      trip: trip,
      scenario: scenario,
    );
    final settlementResult = calculationService.calculateSettlement(
      trip: trip,
      scenario: scenario,
      method: SettlementMethod.viaFund,
    );

    final status = trip.isLedgerInitialized
        ? (settlementResult.validation.canSettle
            ? ReportDocumentStatus.settled
            : ReportDocumentStatus.provisional)
        : ReportDocumentStatus.estimate;

    final summaryCards = [
      {'title': 'Tổng chi phí chuyến đi', 'value': CurrencyFormatter.formatVnd(calcResult.totalTripCost)},
      {'title': 'Số lượng thành viên', 'value': '${trip.members.length} người'},
      {'title': 'Thủ quỹ chịu trách nhiệm', 'value': trip.treasurer?.name ?? 'Chưa chỉ định'},
      {'title': 'Số dư tiền mặt tồn quỹ', 'value': CurrencyFormatter.formatVnd(trip.fundCashBalance)},
    ];

    final memberDetails = trip.members.map((m) {
      final summary = calcResult.memberSummaries[m.id];
      final ds = settlementResult.debtSummaries.firstWhere(
        (e) => e.memberId == m.id,
        orElse: () => MemberDebtSummary(
          memberId: m.id,
          memberName: m.name,
          costObligation: 0,
          fundContributed: 0,
          outOfPocketPaid: 0,
        ),
      );

      return {
        'name': m.name,
        'isTreasurer': m.id == trip.treasurerId,
        'cost': CurrencyFormatter.formatVnd(summary?.totalCost ?? 0),
        'fund': CurrencyFormatter.formatVnd(ds.fundContributed),
        'outOfPocket': CurrencyFormatter.formatVnd(ds.outOfPocketPaid),
        'netStatus': ds.needsToPay
            ? 'Cần đóng: ${CurrencyFormatter.formatVnd(ds.amountToPay)}'
            : (ds.getsRefund
                ? 'Nhận về: ${CurrencyFormatter.formatVnd(ds.amountToReceive)}'
                : 'Cân bằng (0 đ)'),
      };
    }).toList();

    final instructions = settlementResult.transferSteps
        .map((step) =>
            '${step.fromMemberName} ➔ Chuyển ${CurrencyFormatter.formatVnd(step.amount)} cho ${step.toMemberName} (${step.status.displayName})')
        .toList();

    return PdfReportPreview(
      title: 'BÁO CÁO TỔNG KẾT CHI TIÊU & CHIA TIỀN NHÓM',
      subtitle: '${trip.name} • Kịch bản: ${scenario.name}',
      status: status,
      totalAmount: calcResult.totalTripCost,
      summaryCards: summaryCards,
      memberDetails: memberDetails,
      settlementInstructions: instructions,
      generatedAt: 'Ngày lập: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );
  }

  Future<Uint8List> generatePdfBytes({
    required Trip trip,
    required Scenario scenario,
    required CalculationService calculationService,
  }) async {
    final preview = await generatePdfPreview(
      trip: trip,
      scenario: scenario,
      calculationService: calculationService,
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    preview.title,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(preview.subtitle),
                  pw.Text('Trạng thái: ${preview.status.displayName} • ${preview.generatedAt}'),
                  pw.Divider(),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '1. Tổng quan tài chính',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.Table.fromTextArray(
              headers: ['Chỉ số', 'Giá trị'],
              data: preview.summaryCards.map((c) => [c['title']!, c['value']!]).toList(),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              '2. Chi tiết phân bổ theo thành viên',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.Table.fromTextArray(
              headers: ['Thành viên', 'Nghĩa vụ chi phí', 'Đã góp quỹ', 'Ứng trả hộ', 'Quyết toán'],
              data: preview.memberDetails
                  .map((m) => [
                        m['name'] as String,
                        m['cost'] as String,
                        m['fund'] as String,
                        m['outOfPocket'] as String,
                        m['netStatus'] as String,
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              '3. Các bước chuyển khoản quyết toán',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.Bullet(
              text: preview.settlementInstructions.isNotEmpty
                  ? preview.settlementInstructions.join('\n')
                  : 'Không có giao dịch chuyển khoản nào cần thực hiện.',
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
