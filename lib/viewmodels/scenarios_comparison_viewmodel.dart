import 'package:flutter/foundation.dart';
import '../domain/models/trip.dart';
import '../domain/models/stage.dart';
import '../domain/models/scenario.dart';
import '../domain/models/attendance.dart';
import '../domain/models/expense.dart';
import '../domain/models/calculation_result.dart';
import '../domain/services/trip_repository.dart';
import '../domain/services/calculation_service.dart';

class ScenariosComparisonViewModel extends ChangeNotifier {
  final TripRepository _repository;
  final CalculationService _calculationService;

  Trip? _trip;
  bool _isLoading = false;
  String? _errorMessage;

  String? _selectedScenarioId;
  String? _selectedBaselineId;

  ScenariosComparisonViewModel({
    required TripRepository repository,
    required CalculationService calculationService,
  })  : _repository = repository,
        _calculationService = calculationService;

  Trip? get trip => _trip;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Scenario> get scenarios => _trip?.scenarios ?? [];

  Scenario? get selectedScenario {
    if (_trip == null || scenarios.isEmpty) return null;
    return scenarios.firstWhere(
      (s) => s.id == (_selectedScenarioId ?? _trip!.activeScenarioId),
      orElse: () => scenarios.first,
    );
  }

  Scenario? get baselineScenario {
    if (_trip == null || scenarios.isEmpty) return null;
    return scenarios.firstWhere(
      (s) => s.id == (_selectedBaselineId ?? _trip!.baselineScenario?.id),
      orElse: () => scenarios.first,
    );
  }

  ScenarioCalculationResult? get calculationResult {
    if (_trip == null || selectedScenario == null) return null;
    return _calculationService.calculateScenario(
      trip: _trip!,
      scenario: selectedScenario!,
    );
  }

  ScenarioCalculationResult? get baselineResult {
    if (_trip == null || baselineScenario == null) return null;
    return _calculationService.calculateScenario(
      trip: _trip!,
      scenario: baselineScenario!,
    );
  }

  ScenarioComparison? get comparison {
    if (_trip == null || selectedScenario == null || baselineScenario == null) {
      return null;
    }
    return _calculationService.compareScenarios(
      trip: _trip!,
      baseline: baselineScenario!,
      target: selectedScenario!,
    );
  }

  Future<void> loadTrip(String tripId, {String? targetScenarioId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trip = await _repository.getTripById(tripId);
      if (_trip != null) {
        _selectedScenarioId = targetScenarioId ?? _trip!.activeScenarioId;
        _selectedBaselineId = _trip!.baselineScenario?.id;
      }
    } catch (e) {
      _errorMessage = 'Lỗi tải kịch bản: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectScenario(String scenarioId) {
    _selectedScenarioId = scenarioId;
    notifyListeners();
  }

  void selectBaseline(String scenarioId) {
    _selectedBaselineId = scenarioId;
    notifyListeners();
  }

  // --- ATTENDANCE & PRESETS ---

  Future<void> toggleAttendance({
    required String stageId,
    required String memberId,
  }) async {
    if (_trip == null || selectedScenario == null) return;
    try {
      final sc = selectedScenario!;
      final currentAttendances = Map<String, Set<String>>.from(sc.stageAttendances);
      final stageSet = Set<String>.from(currentAttendances[stageId] ?? {});

      if (stageSet.contains(memberId)) {
        stageSet.remove(memberId);
      } else {
        stageSet.add(memberId);
      }
      currentAttendances[stageId] = stageSet;

      // Khi người dùng chỉnh sửa đầu vào làm thay đổi dữ liệu kịch bản:
      // Kiểm tra xem kịch bản có bị lệch khỏi 4 kịch bản chuẩn không.
      // Nếu có, đánh dấu isStale = true để hiển thị banner cảnh báo
      final updatedScenario = sc.copyWith(
        stageAttendances: currentAttendances,
        isStale: _checkIfScenarioStale(currentAttendances, sc.id),
      );

      final updatedScenarios = _trip!.scenarios.map((s) {
        return s.id == sc.id ? updatedScenario : s;
      }).toList();

      final updated = _trip!.copyWith(scenarios: updatedScenarios);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật điểm danh: $e';
      notifyListeners();
    }
  }

  bool _checkIfScenarioStale(Map<String, Set<String>> attendances, String scenarioId) {
    // Nếu là kịch bản chuẩn nhưng attendances bị thay đổi khác với fixture:
    if (scenarioId == 'scenario_1') {
      return (attendances['stage_1']?.length != 4 || attendances['stage_2']?.length != 4);
    }
    if (scenarioId == 'scenario_2') {
      return (attendances['stage_1']?.contains('m_dung') == true ||
          attendances['stage_2']?.contains('m_dung') == true);
    }
    if (scenarioId == 'scenario_3') {
      return (attendances['stage_2']?.contains('m_chi') == true);
    }
    if (scenarioId == 'scenario_4') {
      return (attendances['stage_1']?.contains('m_dung') == true ||
          attendances['stage_2']?.contains('m_chi') == true);
    }
    return false;
  }

  Future<void> applyAttendancePreset({
    required String memberId,
    required AttendancePresetType presetType,
    String? targetStageId,
  }) async {
    if (_trip == null || selectedScenario == null) return;
    try {
      final sc = selectedScenario!;
      final currentAttendances = Map<String, Set<String>>.from(sc.stageAttendances);
      final sortedStages = List<Stage>.from(_trip!.stages)
        ..sort((a, b) => a.order.compareTo(b.order));

      int targetOrder = 1;
      if (targetStageId != null) {
        final targetStage = _trip!.getStage(targetStageId);
        if (targetStage != null) targetOrder = targetStage.order;
      }

      for (final stage in sortedStages) {
        final stageSet = Set<String>.from(currentAttendances[stage.id] ?? {});
        bool shouldPresent = false;

        switch (presetType) {
          case AttendancePresetType.full:
            shouldPresent = true;
            break;
          case AttendancePresetType.fromStage:
            shouldPresent = stage.order >= targetOrder;
            break;
          case AttendancePresetType.untilStage:
            shouldPresent = stage.order <= targetOrder;
            break;
          case AttendancePresetType.absent:
            shouldPresent = false;
            break;
        }

        if (shouldPresent) {
          stageSet.add(memberId);
        } else {
          stageSet.remove(memberId);
        }
        currentAttendances[stage.id] = stageSet;
      }

      // Giữ nguyên các ô override thủ công (manualInclude / manualExclude) theo đúng quy tắc!
      final updatedScenario = sc.copyWith(
        stageAttendances: currentAttendances,
        isStale: _checkIfScenarioStale(currentAttendances, sc.id),
      );

      final updatedScenarios = _trip!.scenarios.map((s) {
        return s.id == sc.id ? updatedScenario : s;
      }).toList();

      final updated = _trip!.copyWith(scenarios: updatedScenarios);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi áp dụng Preset lịch trình: $e';
      notifyListeners();
    }
  }

  // --- COST BEARER OVERRIDES ---

  Future<void> setCostBearerOverride({
    required String expenseId,
    required String memberId,
    required CostBearerStatus status,
  }) async {
    if (_trip == null || selectedScenario == null) return;
    try {
      final sc = selectedScenario!;
      final overrides = Map<String, Map<String, CostBearerStatus>>.from(sc.costBearerOverrides);
      final expMap = Map<String, CostBearerStatus>.from(overrides[expenseId] ?? {});

      if (status == CostBearerStatus.inherited) {
        expMap.remove(memberId);
      } else {
        expMap[memberId] = status;
      }

      if (expMap.isEmpty) {
        overrides.remove(expenseId);
      } else {
        overrides[expenseId] = expMap;
      }

      final updatedScenario = sc.copyWith(costBearerOverrides: overrides);
      final updatedScenarios = _trip!.scenarios.map((s) {
        return s.id == sc.id ? updatedScenario : s;
      }).toList();

      final updated = _trip!.copyWith(scenarios: updatedScenarios);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi đổi người chịu tiền: $e';
      notifyListeners();
    }
  }

  Future<void> resetBearersToInherited(String expenseId) async {
    if (_trip == null || selectedScenario == null) return;
    try {
      final sc = selectedScenario!;
      final overrides = Map<String, Map<String, CostBearerStatus>>.from(sc.costBearerOverrides);
      overrides.remove(expenseId);

      final updatedScenario = sc.copyWith(costBearerOverrides: overrides);
      final updatedScenarios = _trip!.scenarios.map((s) {
        return s.id == sc.id ? updatedScenario : s;
      }).toList();

      final updated = _trip!.copyWith(scenarios: updatedScenarios);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi khôi phục người chịu tiền: $e';
      notifyListeners();
    }
  }

  // --- SCENARIO CRUD ---

  Future<void> duplicateScenario(String scenarioId) async {
    if (_trip == null) return;
    try {
      final source = _trip!.scenarios.firstWhere((s) => s.id == scenarioId);
      final newId = 'scenario_${DateTime.now().millisecondsSinceEpoch}';
      final duplicated = source.copyWith(
        id: newId,
        name: '${source.name} (Bản sao)',
        isBaseline: false,
      );

      final updatedScenarios = [..._trip!.scenarios, duplicated];
      final updated = _trip!.copyWith(scenarios: updatedScenarios);
      _trip = await _repository.saveTrip(updated);
      _selectedScenarioId = newId;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi nhân bản kịch bản: $e';
      notifyListeners();
    }
  }

  Future<void> setAsBaseline(String scenarioId) async {
    if (_trip == null) return;
    try {
      final updatedScenarios = _trip!.scenarios.map((s) {
        return s.copyWith(isBaseline: s.id == scenarioId);
      }).toList();

      final updated = _trip!.copyWith(scenarios: updatedScenarios);
      _trip = await _repository.saveTrip(updated);
      _selectedBaselineId = scenarioId;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi đặt kịch bản mốc: $e';
      notifyListeners();
    }
  }

  Future<void> resetToFixtureData() async {
    if (_trip == null || selectedScenario == null) return;
    try {
      // Khôi phục lại trạng thái chuẩn của kịch bản
      final scId = selectedScenario!.id;
      final updatedScenarios = _trip!.scenarios.map((s) {
        if (s.id == scId) {
          return s.copyWith(isStale: false);
        }
        return s;
      }).toList();

      final updated = _trip!.copyWith(scenarios: updatedScenarios);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi khôi phục: $e';
      notifyListeners();
    }
  }
}
