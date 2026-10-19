import 'package:flutter_test/flutter_test.dart';
import 'package:group_travel_caculate/domain/models/attendance.dart';
import 'package:group_travel_caculate/domain/models/expense.dart';
import 'package:group_travel_caculate/data/fixtures/golden_fixture.dart';
import 'package:group_travel_caculate/data/mock_services/mock_calculation_service.dart';
import 'package:group_travel_caculate/data/mock_services/mock_trip_repository.dart';
import 'package:group_travel_caculate/viewmodels/scenarios_comparison_viewmodel.dart';

void main() {
  late MockTripRepository repository;
  late MockCalculationService calculationService;
  late ScenariosComparisonViewModel viewModel;

  setUp(() async {
    repository = MockTripRepository();
    calculationService = MockCalculationService();
    viewModel = ScenariosComparisonViewModel(
      repository: repository,
      calculationService: calculationService,
    );
    await viewModel.loadTrip(GoldenFixture.tripId);
  });

  test('Tải kịch bản mặc định và nạp đúng 4 kịch bản mẫu', () {
    expect(viewModel.scenarios.length, 4);
    expect(viewModel.selectedScenario?.id, 'scenario_4');
    expect(viewModel.calculationResult?.isStale, false);
    expect(viewModel.calculationResult?.totalTripCost, 820000);
  });

  test('Chuyển sang kịch bản 1 hiển thị đúng tổng 1.150.000 đ', () {
    viewModel.selectScenario('scenario_1');
    expect(viewModel.selectedScenario?.id, 'scenario_1');
    expect(viewModel.calculationResult?.totalTripCost, 1150000);
  });

  test('Đổi người chịu tiền thủ công và khôi phục về kế thừa', () async {
    viewModel.selectScenario('scenario_1');
    await viewModel.setCostBearerOverride(
      expenseId: 'exp_lunch',
      memberId: 'm_dung',
      status: CostBearerStatus.manualExclude,
    );

    expect(
      viewModel.selectedScenario?.costBearerOverrides['exp_lunch']?['m_dung'],
      CostBearerStatus.manualExclude,
    );

    // Khôi phục về kế thừa
    await viewModel.resetBearersToInherited('exp_lunch');
    expect(
      viewModel.selectedScenario?.costBearerOverrides.containsKey('exp_lunch'),
      false,
    );
  });

  test('Áp dụng preset lịch trình cập nhật đúng danh sách có mặt', () async {
    viewModel.selectScenario('scenario_1');
    // Áp dụng Dũng nghỉ
    await viewModel.applyAttendancePreset(
      memberId: 'm_dung',
      presetType: AttendancePresetType.absent,
    );

    final sc = viewModel.selectedScenario!;
    expect(sc.isMemberPresentInStage('stage_1', 'm_dung'), false);
    expect(sc.isMemberPresentInStage('stage_2', 'm_dung'), false);
  });

  test('Khi sửa đổi điểm danh làm lệch khỏi kịch bản mẫu thì đánh dấu isStale = true', () async {
    viewModel.selectScenario('scenario_1');
    expect(viewModel.selectedScenario?.isStale, false);

    // Bỏ An khỏi stage 1 ở scenario 1 (làm lệch khỏi fixture)
    await viewModel.toggleAttendance(
      stageId: 'stage_1',
      memberId: 'm_an',
    );

    expect(viewModel.selectedScenario?.isStale, true);
    expect(viewModel.calculationResult?.isStale, true);

    // Khôi phục lại
    await viewModel.resetToFixtureData();
    expect(viewModel.selectedScenario?.isStale, false);
  });
}
