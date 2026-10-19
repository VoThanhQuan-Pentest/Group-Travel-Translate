import 'package:flutter/foundation.dart';
import '../domain/models/trip.dart';
import '../domain/models/stage.dart';
import '../domain/models/expense.dart';
import '../domain/services/trip_repository.dart';
import '../domain/services/calculation_service.dart';

class StagesExpensesViewModel extends ChangeNotifier {
  final TripRepository _repository;
  final CalculationService _calculationService;

  Trip? _trip;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasUnsavedChanges = false;

  StagesExpensesViewModel({
    required TripRepository repository,
    required CalculationService calculationService,
  })  : _repository = repository,
        _calculationService = calculationService;

  Trip? get trip => _trip;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  List<Stage> get stages => _trip?.stages ?? [];
  List<Expense> get expenses => _trip?.expenses ?? [];

  List<Expense> getExpensesForStage(String stageId) {
    if (_trip == null) return [];
    return _trip!.expenses.where((e) {
      if (e.calcMode == ExpenseCalcMode.fixedStageRatio && e.stageIds.isNotEmpty) {
        return e.stageIds.contains(stageId);
      }
      return e.stageId == stageId;
    }).toList();
  }

  void markDirty() {
    if (!_hasUnsavedChanges) {
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }

  void markClean() {
    if (_hasUnsavedChanges) {
      _hasUnsavedChanges = false;
      notifyListeners();
    }
  }

  Future<void> loadTrip(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trip = await _repository.getTripById(tripId);
      if (_trip == null) {
        _errorMessage = 'Không tìm thấy chuyến đi: $tripId';
      }
      _hasUnsavedChanges = false;
    } catch (e) {
      _errorMessage = 'Lỗi tải dữ liệu chặng & khoản chi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- STAGES OPERATIONS ---

  Future<void> addStage({
    required String name,
    String? description,
  }) async {
    if (_trip == null) return;
    try {
      final newStageId = 'stage_${DateTime.now().millisecondsSinceEpoch}';
      final newOrder = _trip!.stages.length + 1;
      final newStage = Stage(
        id: newStageId,
        name: name.trim(),
        order: newOrder,
        description: description?.trim(),
      );

      // Thêm chặng mới và cập nhật mặc định điểm danh cho các kịch bản
      final updatedStages = [..._trip!.stages, newStage];
      final allMemberIds = _trip!.members.map((m) => m.id).toSet();

      final updatedScenarios = _trip!.scenarios.map((sc) {
        final newAttendances = Map<String, Set<String>>.from(sc.stageAttendances);
        newAttendances[newStageId] = allMemberIds;
        return sc.copyWith(stageAttendances: newAttendances);
      }).toList();

      final updated = _trip!.copyWith(
        stages: updatedStages,
        scenarios: updatedScenarios,
      );

      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi thêm chặng: $e';
      notifyListeners();
    }
  }

  Future<void> updateStage(Stage updatedStage) async {
    if (_trip == null) return;
    try {
      final updatedStages = _trip!.stages.map((s) {
        return s.id == updatedStage.id ? updatedStage : s;
      }).toList();

      final updated = _trip!.copyWith(stages: updatedStages);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật chặng: $e';
      notifyListeners();
    }
  }

  Future<void> deleteStage(String stageId) async {
    if (_trip == null) return;
    try {
      final updatedStages =
          _trip!.stages.where((s) => s.id != stageId).toList();
      final updatedExpenses =
          _trip!.expenses.where((e) => e.stageId != stageId).toList();

      final updated = _trip!.copyWith(
        stages: updatedStages,
        expenses: updatedExpenses,
      );
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi xóa chặng: $e';
      notifyListeners();
    }
  }

  Future<void> reorderStages(int oldIndex, int newIndex) async {
    if (_trip == null) return;
    try {
      final list = List<Stage>.from(_trip!.stages);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);

      // Cập nhật lại số thứ tự order
      final reordered = <Stage>[];
      for (int i = 0; i < list.length; i++) {
        reordered.add(list[i].copyWith(order: i + 1));
      }

      final updated = _trip!.copyWith(stages: reordered);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi sắp xếp chặng: $e';
      notifyListeners();
    }
  }

  // --- EXPENSES OPERATIONS ---

  Future<bool> saveExpense(Expense expense) async {
    if (_trip == null) return false;
    try {
      final exists = _trip!.expenses.any((e) => e.id == expense.id);
      final List<Expense> updatedList;
      if (exists) {
        updatedList = _trip!.expenses.map((e) => e.id == expense.id ? expense : e).toList();
      } else {
        updatedList = [..._trip!.expenses, expense];
      }

      final updated = _trip!.copyWith(expenses: updatedList);
      _trip = await _repository.saveTrip(updated);
      _hasUnsavedChanges = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi lưu khoản chi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    if (_trip == null) return;
    try {
      final updatedList =
          _trip!.expenses.where((e) => e.id != expenseId).toList();
      final updated = _trip!.copyWith(expenses: updatedList);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi xóa khoản chi: $e';
      notifyListeners();
    }
  }

  /// Tính toán số người chịu tiền thực tế cho một khoản chi trong kịch bản hiện tại
  int getEffectiveBearersCount(Expense expense) {
    if (_trip == null || _trip!.activeScenario == null) return 0;
    final sc = _trip!.activeScenario!;
    int count = 0;
    for (final member in _trip!.members) {
      if (sc.isMemberCostBearer(expense, member.id) ||
          (expense.isCommitted &&
              sc.getEffectiveBearerStatus(expense, member.id) !=
                  CostBearerStatus.manualExclude)) {
        count++;
      }
    }
    return count;
  }

  /// Cảnh báo hợp lệ: Khoản chi có số tiền > 0 nhưng chưa có ai chịu
  bool hasNoBearersWarning(Expense expense) {
    final amount = expense.actualPrice ?? expense.estimatedTotal;
    if (amount <= 0) return false;
    return getEffectiveBearersCount(expense) == 0;
  }

  /// Tính toán số tiền tạm tính tức thời cho từng người của khoản chi đang chỉnh sửa
  Map<String, int> previewExpenseCost(Expense expense) {
    if (_trip == null || _trip!.activeScenario == null) return {};
    final tempTrip = _trip!.copyWith(expenses: [expense]);
    final res = _calculationService.calculateScenario(
      trip: tempTrip,
      scenario: _trip!.activeScenario!,
    );
    return {
      for (final m in _trip!.members) m.id: res.getMemberCost(m.id),
    };
  }
}
