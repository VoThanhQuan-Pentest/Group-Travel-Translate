import 'package:flutter_test/flutter_test.dart';
import 'package:group_travel_caculate/domain/models/settlement.dart';
import 'package:group_travel_caculate/domain/services/real_calculation_service.dart';
import 'package:group_travel_caculate/data/fixtures/golden_fixture.dart';

void main() {
  late RealCalculationService service;
  final goldenTrip = GoldenFixture.createGoldenTrip();

  setUp(() {
    service = RealCalculationService();
  });

  group('RealCalculationService Golden Fixture Tests (Pure Math, No Mock)', () {
    test('Kịch bản 1: Đi đủ - Khớp 100% từng đồng', () {
      final res = service.calculateScenario(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario1,
      );

      expect(res.totalTripCost, 1150000);
      expect(res.getMemberCost('m_an'), 273333);
      expect(res.getMemberCost('m_binh'), 282778);
      expect(res.getMemberCost('m_chi'), 292222);
      expect(res.getMemberCost('m_dung'), 301667);

      final sum = res.getMemberCost('m_an') +
          res.getMemberCost('m_binh') +
          res.getMemberCost('m_chi') +
          res.getMemberCost('m_dung');
      expect(sum, 1150000);
    });

    test('Kịch bản 2: Dũng nghỉ, vẫn chịu xe - Khớp 100% từng đồng', () {
      final res = service.calculateScenario(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario2,
      );

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

    test('Kịch bản 3: Chi về sau trưa - Khớp 100% từng đồng', () {
      final res = service.calculateScenario(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario3,
      );

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

    test('Kịch bản 4: Dũng nghỉ + Chi về sớm - Khớp 100% từng đồng', () {
      final res = service.calculateScenario(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario4,
      );

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

    test('Tăng tiền ship 1.000đ thì tổng chi phí tăng đúng 1.000đ và từng người tăng tương ứng', () {
      // Modify milk tea expense by adding 1.000đ shipping fee (from 20k to 21k)
      final modifiedExpenses = goldenTrip.expenses.map((e) {
        if (e.id == 'exp_milktea') {
          return e.copyWith(shippingFee: e.shippingFee + 1000);
        }
        return e;
      }).toList();

      final dynamicTrip = goldenTrip.copyWith(expenses: modifiedExpenses);

      final originalRes = service.calculateScenario(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario1,
      );
      final dynamicRes = service.calculateScenario(
        trip: dynamicTrip,
        scenario: GoldenFixture.scenario1,
      );

      // Verify that total increased by exactly 1.000đ!
      expect(dynamicRes.totalTripCost, originalRes.totalTripCost + 1000);

      final dynamicSum = dynamicRes.getMemberCost('m_an') +
          dynamicRes.getMemberCost('m_binh') +
          dynamicRes.getMemberCost('m_chi') +
          dynamicRes.getMemberCost('m_dung');
      expect(dynamicSum, dynamicRes.totalTripCost);
    });

    test('Quyết toán qua Quỹ khớp đúng nghĩa vụ nợ của Kịch bản 4', () {
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

      expect(anDebt.costObligation, 275714);
      expect(anDebt.amountToReceive, 164286);

      expect(binhDebt.costObligation, 284286);
      expect(binhDebt.amountToPay, 84286);

      expect(chiDebt.costObligation, 160000);
      expect(chiDebt.amountToReceive, 40000);

      expect(dungDebt.costObligation, 100000);
      expect(dungDebt.amountToReceive, 100000);
    });

    test('Chuyển tiền chéo trực tiếp không chuyển cho chính mình', () {
      final directSettlement = service.calculateSettlement(
        trip: goldenTrip,
        scenario: GoldenFixture.scenario4,
        method: SettlementMethod.directTransfer,
      );

      for (final step in directSettlement.transferSteps) {
        expect(step.fromMemberId == step.toMemberId, false);
      }
    });

    test('Xóa giao dịch thanh toán sẽ chặn quyết toán', () {
      final noPaymentTrip = goldenTrip.copyWith(cashTransactions: []);
      final validation = service.validateSettlement(
        trip: noPaymentTrip,
        scenario: GoldenFixture.scenario4,
      );

      expect(validation.canSettle, false);
      expect(validation.blockingReasons.isNotEmpty, true);
    });
  });
}
