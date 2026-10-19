import '../models/trip.dart';
import '../models/scenario.dart';
import '../models/calculation_result.dart';
import '../models/settlement.dart';

abstract class CalculationService {
  /// Tính toán chi tiết chi phí cho một kịch bản của chuyến đi.
  /// Tuân thủ quy tắc làm tròn nguyên đồng VNĐ và thứ tự ưu tiên thành viên.
  ScenarioCalculationResult calculateScenario({
    required Trip trip,
    required Scenario scenario,
  });

  /// Tính toán chi phí thực tế cho chuyến đi dựa trên giá thực tế xác nhận (actualPrice)
  ScenarioCalculationResult calculateActual({
    required Trip trip,
    required Scenario scenario,
  });

  /// So sánh hai kịch bản (mốc so sánh [baseline] và kịch bản [target]).
  ScenarioComparison compareScenarios({
    required Trip trip,
    required Scenario baseline,
    required Scenario target,
  });

  /// Kiểm tra dữ liệu có đủ điều kiện chốt sổ quyết toán hay không.
  SettlementValidation validateSettlement({
    required Trip trip,
    required Scenario scenario,
  });

  /// Tính toán công nợ và các bước chuyển tiền quyết toán theo phương thức chỉ định.
  SettlementResult calculateSettlement({
    required Trip trip,
    required Scenario scenario,
    required SettlementMethod method,
  });
}
