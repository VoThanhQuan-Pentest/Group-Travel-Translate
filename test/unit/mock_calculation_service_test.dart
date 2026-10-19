import 'package:flutter_test/flutter_test.dart';
import 'package:group_travel_caculate/domain/models/settlement.dart';
import 'package:group_travel_caculate/data/fixtures/golden_fixture.dart';
import 'package:group_travel_caculate/data/mock_services/mock_calculation_service.dart';

void main() {
  late MockCalculationService service;
  final goldenTrip = GoldenFixture.createGoldenTrip();

  setUp(() {
    service = MockCalculationService();
  });

  group('Golden Fixtures Calculation Tests', () {
    test('Kịch bản 1: Đi đủ - Khớp tuyệt đối bảng đối chiếu', () {
      final res = service.calculateScenario(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario1,
      );

      expect(res.isStale, false);
      expect(res.totalTripCost, 1150000);
      expect(res.getMemberCost('m_an'), 273333);
      expect(res.getMemberCost('m_binh'), 282778);
      expect(res.getMemberCost('m_chi'), 292222);
      expect(res.getMemberCost('m_dung'), 301667);

      // Kiểm tra tổng từng người cộng lại khớp tổng chuyến
      final sum = res.getMemberCost('m_an') +
          res.getMemberCost('m_binh') +
          res.getMemberCost('m_chi') +
          res.getMemberCost('m_dung');
      expect(sum, 1150000);
    });

    test('Kịch bản 2: Dũng nghỉ, vẫn chịu xe - Khớp tuyệt đối bảng đối chiếu', () {
      final res = service.calculateScenario(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario2,
      );

      expect(res.isStale, false);
      expect(res.totalTripCost, 950000);
      expect(res.getMemberCost('m_an'), 274167);
      expect(res.getMemberCost('m_binh'), 283334);
      expect(res.getMemberCost('m_chi'), 292499);
      expect(res.getMemberCost('m_dung'), 100000);

      final sum = res.getMemberCost('m_an') +
          res.getMemberCost('m_binh') +
          res.getMemberCost('m_chi') +
          res.getMemberCost('m_dung');
      expect(sum, 950000);
    });

    test('Kịch bản 3: Chi về sau trưa - Khớp tuyệt đối bảng đối chiếu', () {
      final res = service.calculateScenario(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario3,
      );

      expect(res.isStale, false);
      expect(res.totalTripCost, 1020000);
      expect(res.getMemberCost('m_an'), 274359);
      expect(res.getMemberCost('m_binh'), 283590);
      expect(res.getMemberCost('m_chi'), 160000);
      expect(res.getMemberCost('m_dung'), 302051);

      final sum = res.getMemberCost('m_an') +
          res.getMemberCost('m_binh') +
          res.getMemberCost('m_chi') +
          res.getMemberCost('m_dung');
      expect(sum, 1020000);
    });

    test('Kịch bản 4: Dũng nghỉ + Chi về sớm - Khớp tuyệt đối bảng đối chiếu', () {
      final res = service.calculateScenario(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario4,
      );

      expect(res.isStale, false);
      expect(res.totalTripCost, 820000);
      expect(res.getMemberCost('m_an'), 275714);
      expect(res.getMemberCost('m_binh'), 284286);
      expect(res.getMemberCost('m_chi'), 160000);
      expect(res.getMemberCost('m_dung'), 100000);

      final sum = res.getMemberCost('m_an') +
          res.getMemberCost('m_binh') +
          res.getMemberCost('m_chi') +
          res.getMemberCost('m_dung');
      expect(sum, 820000);
    });
  });

  group('Golden Settlement Tests (Kịch bản 4)', () {
    test('Số dư quỹ và công nợ từng người khớp 100% tài liệu', () {
      expect(goldenTrip.fundCashBalance, 220000);

      final settlement = service.calculateSettlement(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario4,
        method: SettlementMethod.viaFund,
      );

      expect(settlement.validation.canSettle, true);

      final anDebt = settlement.debtSummaries.firstWhere((e) => e.memberId == 'm_an');
      final binhDebt = settlement.debtSummaries.firstWhere((e) => e.memberId == 'm_binh');
      final chiDebt = settlement.debtSummaries.firstWhere((e) => e.memberId == 'm_chi');
      final dungDebt = settlement.debtSummaries.firstWhere((e) => e.memberId == 'm_dung');

      // An: Góp quỹ 200k + Ứng 240k = 440k. Chịu 275.714k => Nhận về 164.286đ
      expect(anDebt.costObligation, 275714);
      expect(anDebt.totalPaid, 440000);
      expect(anDebt.getsRefund, true);
      expect(anDebt.amountToReceive, 164286);

      // Bình: Góp 200k. Chịu 284.286đ => Đóng thêm 84.286đ
      expect(binhDebt.costObligation, 284286);
      expect(binhDebt.totalPaid, 200000);
      expect(binhDebt.needsToPay, true);
      expect(binhDebt.amountToPay, 84286);

      // Chi: Góp 200k. Chịu 160.000đ => Nhận về 40.000đ
      expect(chiDebt.costObligation, 160000);
      expect(chiDebt.totalPaid, 200000);
      expect(chiDebt.getsRefund, true);
      expect(chiDebt.amountToReceive, 40000);

      // Dũng: Góp 200k. Chịu 100.000đ => Nhận về 100.000đ
      expect(dungDebt.costObligation, 100000);
      expect(dungDebt.totalPaid, 200000);
      expect(dungDebt.getsRefund, true);
      expect(dungDebt.amountToReceive, 100000);

      // Cân đối hoàn hảo:
      final totalInflow = binhDebt.amountToPay + settlement.fundCashOnHand;
      final totalOutflow = anDebt.amountToReceive + chiDebt.amountToReceive + dungDebt.amountToReceive;
      expect(totalInflow, totalOutflow);
    });

    test('Chuyển tiền chéo không bao giờ chuyển cho chính mình', () {
      final directSettlement = service.calculateSettlement(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario4,
        method: SettlementMethod.directTransfer,
      );

      for (final step in directSettlement.transferSteps) {
        expect(step.fromMemberId == step.toMemberId, false);
      }
    });

    test('Đánh dấu trạng thái stale khi kịch bản bị sửa đổi ngoài fixture', () {
      final modifiedScenario = GoldenFixture.scenario1.copyWith(
        id: 'scenario_custom_unknown',
        name: 'Kịch bản tùy chỉnh người dùng',
        isStale: true,
      );

      final res = service.calculateScenario(
        trip: goldenTrip,
        scenario: modifiedScenario,
      );

      expect(res.isStale, true);
    });
  });
}
