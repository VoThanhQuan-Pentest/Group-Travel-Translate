import 'package:flutter_test/flutter_test.dart';
import 'package:group_travel_caculate/data/fixtures/golden_fixture.dart';
import 'package:group_travel_caculate/data/mock_services/mock_trip_repository.dart';
import 'package:group_travel_caculate/domain/models/settlement.dart';
import 'package:group_travel_caculate/domain/services/real_calculation_service.dart';
import 'package:group_travel_caculate/presentation/controllers/trip_session_controller.dart';

void main() {
  group('TripSessionController Tests', () {
    late MockTripRepository repository;
    late RealCalculationService calculationService;
    late TripSessionController controller;

    setUp(() async {
      repository = MockTripRepository();
      calculationService = RealCalculationService();
      final goldenTrip = GoldenFixture.createGoldenTrip();
      await repository.saveTrip(goldenTrip);

      controller = TripSessionController(
        repository: repository,
        calculationService: calculationService,
      );
      await controller.openTrip(goldenTrip.id);
    });

    test('Thêm thành viên hàng loạt: Bỏ dòng trống, chuẩn hóa khoảng trắng và thêm vào kịch bản', () async {
      final initialMemberCount = controller.trip!.members.length;
      final rawNames = [
        '  Hoàng Nam  ',
        '',
        '   ',
        'Thúy Vi',
      ];

      final success = await controller.addMembersBatch(rawNames, addToActiveScenario: true);
      expect(success, isTrue);
      expect(controller.trip!.members.length, initialMemberCount + 2);

      final addedNames = controller.trip!.members.map((m) => m.name).toList();
      expect(addedNames, contains('Hoàng Nam'));
      expect(addedNames, contains('Thúy Vi'));

      // Kiểm tra thành viên mới đã được thêm vào điểm danh từng chặng của kịch bản đang mở
      final activeSc = controller.activeScenario!;
      final newMemberIds = controller.trip!.members
          .where((m) => m.name == 'Hoàng Nam' || m.name == 'Thúy Vi')
          .map((m) => m.id);
      for (final stage in controller.trip!.stages) {
        final attendances = activeSc.stageAttendances[stage.id] ?? {};
        for (final newId in newMemberIds) {
          expect(attendances.contains(newId), isTrue);
        }
      }
    });

    test('Sao chép kịch bản thành bản độc lập: Sửa bản sao không ảnh hưởng bản gốc', () async {
      final initialScenarioCount = controller.trip!.scenarios.length;
      final sourceScenario = controller.activeScenario!;

      final copy = await controller.duplicateScenario(
        sourceScenarioId: sourceScenario.id,
        newName: 'Kịch bản Thử Nghiệm Riêng',
      );

      expect(copy, isNotNull);
      expect(controller.trip!.scenarios.length, initialScenarioCount + 1);
      expect(copy!.name, 'Kịch bản Thử Nghiệm Riêng');

      // Đổi điểm danh trên bản sao
      final stageId = controller.trip!.stages.first.id;
      final memberId = controller.trip!.members.first.id;
      await controller.toggleAttendance(stageId: stageId, memberId: memberId);

      // Kiểm tra bản sao đổi nhưng bản gốc không đổi
      final refreshedTrip = controller.trip!;
      final originalSc = refreshedTrip.scenarios.firstWhere((s) => s.id == sourceScenario.id);
      final clonedSc = refreshedTrip.scenarios.firstWhere((s) => s.id == copy.id);

      final origHasMember = originalSc.stageAttendances[stageId]?.contains(memberId);
      final cloneHasMember = clonedSc.stageAttendances[stageId]?.contains(memberId);
      expect(origHasMember, isNot(cloneHasMember));
    });

    test('Xóa kịch bản mốc chuẩn sẽ tự động chỉ định kịch bản còn lại làm mốc chuẩn', () async {
      final baselineSc = controller.trip!.scenarios.firstWhere((s) => s.isBaseline);
      final success = await controller.deleteScenario(baselineSc.id);

      expect(success, isTrue);
      expect(controller.trip!.scenarios.any((s) => s.id == baselineSc.id), isFalse);
      expect(controller.trip!.scenarios.any((s) => s.isBaseline), isTrue);
    });

    test('Không cho phép xóa kịch bản duy nhất còn lại', () async {
      while (controller.trip!.scenarios.length > 1) {
        await controller.deleteScenario(controller.trip!.scenarios.last.id);
      }

      final lastId = controller.trip!.scenarios.first.id;
      final success = await controller.deleteScenario(lastId);
      expect(success, isFalse);
      expect(controller.errorMessage, contains('duy nhất'));
    });

    test('Xóa thành viên đã có giao dịch chuyển thành Ngừng tham gia (Soft-delete)', () async {
      // Dũng đã có giao dịch đóng tiền quỹ trong GoldenFixture
      final dung = controller.trip!.members.firstWhere((m) => m.name == 'Dũng');
      await controller.removeOrRetireMember(dung.id);

      final refreshedDung = controller.trip!.members.firstWhere((m) => m.id == dung.id);
      expect(refreshedDung.isActive, isFalse);
    });

    test('Xác nhận bước chuyển tiền quyết toán chống ghi trùng nhờ businessKey', () async {
      final step = SettlementTransferStep(
        id: 'step_1',
        fromMemberId: 'm_binh',
        fromMemberName: 'Bình',
        toMemberId: 'm_an',
        toMemberName: 'An',
        amount: 84286,
        isViaFund: false,
      );

      final success1 = await controller.confirmTransferStep(step);
      expect(success1, isTrue);
      final txCount1 = controller.trip!.cashTransactions.length;

      // Xác nhận lần 2 cùng bước
      final success2 = await controller.confirmTransferStep(step);
      expect(success2, isTrue);
      final txCount2 = controller.trip!.cashTransactions.length;

      // Không tăng thêm giao dịch
      expect(txCount2, txCount1);
    });
  });
}
