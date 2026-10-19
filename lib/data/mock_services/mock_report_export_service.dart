import '../../domain/models/trip.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/settlement.dart';
import '../../domain/models/cash_transaction.dart';
import '../../domain/services/calculation_service.dart';
import '../../domain/services/report_export_service.dart';
import '../../core/utils/currency_formatter.dart';

class MockReportExportService implements ReportExportService {
  @override
  Future<ExcelReportPreview> generateExcelPreview({
    required Trip trip,
    required Scenario scenario,
    required CalculationService calculationService,
  }) async {
    final calcResult = calculationService.calculateScenario(trip: trip, scenario: scenario);
    final settlementResult = calculationService.calculateSettlement(
      trip: trip,
      scenario: scenario,
      method: SettlementMethod.viaFund,
    );

    // 1. Tab Thành viên
    final memberHeaders = ['Mã TV', 'Họ và tên', 'Vai trò'];
    final memberRows = trip.members
        .map((m) => [
              m.id,
              m.name,
              m.id == trip.treasurerId ? 'Thủ quỹ' : 'Thành viên',
            ])
        .toList();

    // 2. Tab Chặng
    final stageHeaders = ['Thứ tự', 'Mã chặng', 'Tên chặng', 'Mô tả'];
    final stageRows = trip.stages
        .map((s) => [
              s.order.toString(),
              s.id,
              s.name,
              s.description ?? '',
            ])
        .toList();

    // 3. Tab Khoản chi
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
              CurrencyFormatter.formatVnd(e.estimatedTotal > 0 ? e.estimatedTotal : e.unitPrice),
              CurrencyFormatter.formatVnd(e.actualPrice),
            ])
        .toList();

    // 4. Tab Phân bổ chi phí
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

    // 5. Tab Giao dịch dòng tiền
    final txHeaders = [
      'Mã GD',
      'Thời gian',
      'Loại giao dịch',
      'Người chi/góp',
      'Người nhận',
      'Số tiền',
      'Nội dung',
    ];
    final txRows = trip.cashTransactions
        .map((tx) => [
              tx.id,
              '${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
              tx.type.displayName,
              tx.payerMemberId == 'fund' ? 'Quỹ' : (trip.getMember(tx.payerMemberId)?.name ?? tx.payerMemberId),
              tx.recipient,
              CurrencyFormatter.formatVnd(tx.amount),
              tx.note,
            ])
        .toList();

    // 6. Tab So sánh
    final baseline = trip.baselineScenario ?? scenario;
    final comparison = calculationService.compareScenarios(
      trip: trip,
      baseline: baseline,
      target: scenario,
    );
    final compHeaders = [
      'Thành viên',
      'Kịch bản mốc (${baseline.name})',
      'Kịch bản đang xem (${scenario.name})',
      'Chênh lệch (+/-)',
    ];
    final baseRes = calculationService.calculateScenario(trip: trip, scenario: baseline);
    final compRows = trip.members
        .map((m) => [
              m.name,
              CurrencyFormatter.formatVnd(baseRes.getMemberCost(m.id)),
              CurrencyFormatter.formatVnd(calcResult.getMemberCost(m.id)),
              CurrencyFormatter.formatSignedVnd(comparison.memberDifferences[m.id] ?? 0),
            ])
        .toList();

    // 7. Tab Quyết toán
    final settleHeaders = [
      'Thành viên',
      'Phần phải chịu',
      'Đã góp quỹ',
      'Đã ứng trả hộ',
      'Đã nhận lại',
      'Kết quả quyết toán',
    ];
    final settleRows = settlementResult.debtSummaries
        .map((ds) => [
              ds.memberName,
              CurrencyFormatter.formatVnd(ds.costObligation),
              CurrencyFormatter.formatVnd(ds.fundContributed),
              CurrencyFormatter.formatVnd(ds.outOfPocketPaid),
              CurrencyFormatter.formatVnd(ds.refunded),
              ds.needsToPay
                  ? 'Còn phải đóng ${CurrencyFormatter.formatVnd(ds.amountToPay)}'
                  : (ds.getsRefund
                      ? 'Được nhận về ${CurrencyFormatter.formatVnd(ds.amountToReceive)}'
                      : 'Đã thanh toán đủ (0 đ)'),
            ])
        .toList();

    return ExcelReportPreview(
      fileName: 'BaoCao_ChiTieu_${trip.id}_${scenario.id}.xlsx',
      sheets: [
        ExcelSheetPreview(title: 'Thành viên', headers: memberHeaders, rows: memberRows),
        ExcelSheetPreview(title: 'Chặng', headers: stageHeaders, rows: stageRows),
        ExcelSheetPreview(title: 'Khoản chi', headers: expenseHeaders, rows: expenseRows),
        ExcelSheetPreview(title: 'Phân bổ', headers: allocationHeaders, rows: allocationRows),
        ExcelSheetPreview(title: 'Giao dịch', headers: txHeaders, rows: txRows),
        ExcelSheetPreview(title: 'So sánh', headers: compHeaders, rows: compRows),
        ExcelSheetPreview(title: 'Quyết toán', headers: settleHeaders, rows: settleRows),
      ],
    );
  }

  @override
  Future<PdfReportPreview> generatePdfPreview({
    required Trip trip,
    required Scenario scenario,
    required CalculationService calculationService,
  }) async {
    final calcResult = calculationService.calculateScenario(trip: trip, scenario: scenario);
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
      final ds = settlementResult.debtSummaries.firstWhere((e) => e.memberId == m.id);
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
}
