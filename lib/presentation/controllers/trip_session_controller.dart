import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/trip.dart';
import '../../domain/models/member.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/cash_transaction.dart';
import '../../domain/models/calculation_result.dart';
import '../../domain/models/settlement.dart';
import '../../domain/services/trip_repository.dart';
import '../../domain/services/calculation_service.dart';

class TripSessionController extends ChangeNotifier {
  final TripRepository _repository;
  final CalculationService _calculationService;
  final Uuid _uuid = const Uuid();

  Trip? _trip;
  String? _selectedScenarioId;
  String? _selectedBaselineId;
  bool _isActualMode = false;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isCalculating = false;
  String? _errorMessage;

  // Cached calculation results to avoid rebuilding loops
  ScenarioCalculationResult? _cachedCalculationResult;
  ScenarioComparison? _cachedComparison;
  SettlementResult? _cachedSettlement;
  SettlementMethod _settlementMethod = SettlementMethod.viaFund;

  TripSessionController({
    required TripRepository repository,
    required CalculationService calculationService,
  })  : _repository = repository,
        _calculationService = calculationService;

  Trip? get trip => _trip;
  String? get selectedScenarioId => _selectedScenarioId;
  String? get selectedBaselineId => _selectedBaselineId;
  bool get isActualMode => _isActualMode;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isCalculating => _isCalculating;
  String? get errorMessage => _errorMessage;
  SettlementMethod get settlementMethod => _settlementMethod;

  int get revision => _trip?.revision ?? 0;

  Scenario? get activeScenario {
    if (_trip == null) return null;
    if (_selectedScenarioId != null) {
      try {
        return _trip!.scenarios.firstWhere((s) => s.id == _selectedScenarioId);
      } catch (_) {}
    }
    return _trip!.activeScenario;
  }

  Scenario? get baselineScenario {
    if (_trip == null) return null;
    if (_selectedBaselineId != null) {
      try {
        return _trip!.scenarios.firstWhere((s) => s.id == _selectedBaselineId);
      } catch (_) {}
    }
    return _trip!.baselineScenario;
  }

  ScenarioCalculationResult? get calculationResult => _cachedCalculationResult;
  ScenarioComparison? get comparisonResult => _cachedComparison;
  SettlementResult? get settlementResult => _cachedSettlement;

  int get totalEstimatedCost => _cachedCalculationResult?.totalTripCost ?? 0;

  int get totalActualCost {
    if (_trip == null) return 0;
    int sum = 0;
    for (final exp in _trip!.expenses) {
      if (exp.actualPrice != null) {
        sum += exp.actualPrice!;
      }
    }
    return sum;
  }

  int get costVariance => totalActualCost - totalEstimatedCost;
  int get fundCashBalance => _trip?.fundCashBalance ?? 0;

  // ---------------------------------------------------------------------------
  // Session Lifecycle & Selection
  // ---------------------------------------------------------------------------

  Future<void> openTrip(String tripId, {String? targetScenarioId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trip = await _repository.getTripById(tripId);
      if (_trip == null) {
        _errorMessage = 'Không tìm thấy chuyến đi có ID: $tripId';
      } else {
        _selectedScenarioId = targetScenarioId ?? _trip!.activeScenarioId;
        _selectedBaselineId = _trip!.baselineScenario?.id;
        _isActualMode = _trip!.isLedgerInitialized;
        _recalculate();
      }
    } catch (e) {
      _errorMessage = 'Lỗi tải chuyến đi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectScenario(String scenarioId) {
    if (_selectedScenarioId != scenarioId) {
      _selectedScenarioId = scenarioId;
      if (_trip != null) {
        _trip = _trip!.copyWith(activeScenarioId: scenarioId);
        _repository.saveTrip(_trip!);
      }
      _recalculate();
      notifyListeners();
    }
  }

  void selectBaseline(String scenarioId) {
    if (_selectedBaselineId != scenarioId) {
      _selectedBaselineId = scenarioId;
      _recalculate();
      notifyListeners();
    }
  }

  void setMode({required bool isActual}) {
    if (_isActualMode != isActual) {
      _isActualMode = isActual;
      _recalculate();
      notifyListeners();
    }
  }

  void setSettlementMethod(SettlementMethod method) {
    if (_settlementMethod != method) {
      _settlementMethod = method;
      _recalculate();
      notifyListeners();
    }
  }

  void _recalculate() {
    if (_trip == null || activeScenario == null) {
      _cachedCalculationResult = null;
      _cachedComparison = null;
      _cachedSettlement = null;
      return;
    }

    _isCalculating = true;

    try {
      if (_isActualMode) {
        _cachedCalculationResult = _calculationService.calculateActual(
          trip: _trip!,
          scenario: activeScenario!,
        );
      } else {
        _cachedCalculationResult = _calculationService.calculateScenario(
          trip: _trip!,
          scenario: activeScenario!,
        );
      }

      if (baselineScenario != null) {
        _cachedComparison = _calculationService.compareScenarios(
          trip: _trip!,
          baseline: baselineScenario!,
          target: activeScenario!,
        );
      }

      _cachedSettlement = _calculationService.calculateSettlement(
        trip: _trip!,
        scenario: activeScenario!,
        method: _settlementMethod,
      );
    } finally {
      _isCalculating = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Member Management (Batch, Rename, Soft-delete)
  // ---------------------------------------------------------------------------

  Future<bool> addMembersBatch(
    List<String> rawNames, {
    bool addToActiveScenario = true,
  }) async {
    if (_trip == null) return false;

    // Normalize and filter
    final cleanNames = rawNames
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    if (cleanNames.isEmpty) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newMembers = cleanNames.map((name) {
        return Member(
          id: 'm_${_uuid.v4()}',
          name: name,
          isTreasurer: false,
          isActive: true,
        );
      }).toList();

      final updatedMembers = [..._trip!.members, ...newMembers];
      final newMemberIds = newMembers.map((m) => m.id).toSet();

      List<Scenario> updatedScenarios = _trip!.scenarios;
      if (addToActiveScenario && activeScenario != null) {
        final currentSc = activeScenario!;
        final newAttendances = Map<String, Set<String>>.from(
          currentSc.stageAttendances,
        );

        for (final stage in _trip!.stages) {
          final set = Set<String>.from(newAttendances[stage.id] ?? {});
          set.addAll(newMemberIds);
          newAttendances[stage.id] = set;
        }

        final updatedSc = currentSc.copyWith(stageAttendances: newAttendances);
        updatedScenarios = _trip!.scenarios.map((s) {
          return s.id == updatedSc.id ? updatedSc : s;
        }).toList();
      }

      final updatedTrip = _trip!.copyWith(
        members: updatedMembers,
        scenarios: updatedScenarios,
      );

      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _recalculate();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi lưu danh sách thành viên: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> renameMember(String memberId, String newName) async {
    if (_trip == null) return;
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    try {
      final updatedMembers = _trip!.members.map((m) {
        return m.id == memberId ? m.copyWith(name: trimmed) : m;
      }).toList();

      final updatedTrip = _trip!.copyWith(members: updatedMembers);
      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _recalculate();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi sửa tên thành viên: $e';
      notifyListeners();
    }
  }

  Future<void> setTreasurer(String memberId) async {
    if (_trip == null) return;
    try {
      final updatedMembers = _trip!.members.map((m) {
        return m.copyWith(isTreasurer: m.id == memberId);
      }).toList();

      final updatedTrip = _trip!.copyWith(
        treasurerId: memberId,
        members: updatedMembers,
      );
      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _recalculate();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi đổi thủ quỹ: $e';
      notifyListeners();
    }
  }

  Future<void> removeOrRetireMember(String memberId) async {
    if (_trip == null) return;
    if (memberId == _trip!.treasurerId) {
      _errorMessage = 'Không thể xóa Thủ quỹ. Vui lòng chỉ định thủ quỹ khác trước.';
      notifyListeners();
      return;
    }

    // Check if referenced in transactions or line items
    final hasTransactions = _trip!.cashTransactions.any(
      (tx) => tx.payerMemberId == memberId || tx.recipient == memberId,
    );
    final hasLineItems = _trip!.expenses.any(
      (e) => e.lineItems.any((li) => li.bearerMemberId == memberId),
    );

    try {
      final List<Member> updatedMembers;
      if (hasTransactions || hasLineItems) {
        // Soft-delete / Retire member so historical records remain valid
        updatedMembers = _trip!.members.map((m) {
          return m.id == memberId ? m.copyWith(isActive: false) : m;
        }).toList();
      } else {
        // Hard-delete member completely
        updatedMembers = _trip!.members.where((m) => m.id != memberId).toList();
      }

      final updatedTrip = _trip!.copyWith(members: updatedMembers);
      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _recalculate();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật thành viên: $e';
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Scenario Management (Create, Duplicate, Rename, Delete)
  // ---------------------------------------------------------------------------

  Future<Scenario?> duplicateScenario({
    required String sourceScenarioId,
    required String newName,
  }) async {
    if (_trip == null) return null;

    final source = _trip!.scenarios.firstWhere(
      (s) => s.id == sourceScenarioId,
      orElse: () => _trip!.scenarios.first,
    );

    final cleanName = newName.trim().isNotEmpty
        ? newName.trim()
        : '${source.name} (Bản sao)';

    _isSaving = true;
    notifyListeners();

    try {
      final newId = 'scenario_${_uuid.v4()}';

      // Deep clone collections
      final clonedAttendances = source.stageAttendances.map(
        (k, v) => MapEntry(k, Set<String>.from(v)),
      );
      final clonedOverrides = source.costBearerOverrides.map(
        (k, v) => MapEntry(k, Map<String, CostBearerStatus>.from(v)),
      );
      final clonedAmountOverrides =
          Map<String, int>.from(source.expenseAmountOverrides);

      final duplicated = Scenario(
        id: newId,
        name: cleanName,
        description: source.description != null ? '${source.description} (Bản sao)' : null,
        isBaseline: false,
        stageAttendances: clonedAttendances,
        costBearerOverrides: clonedOverrides,
        expenseAmountOverrides: clonedAmountOverrides,
        isStale: false,
      );

      final updatedScenarios = [..._trip!.scenarios, duplicated];
      final updatedTrip = _trip!.copyWith(scenarios: updatedScenarios);

      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _selectedScenarioId = newId;
      _recalculate();
      return duplicated;
    } catch (e) {
      _errorMessage = 'Lỗi nhân bản kịch bản: $e';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<Scenario?> createScenario({
    required String name,
    String? description,
  }) async {
    if (_trip == null) return null;
    final cleanName = name.trim();
    if (cleanName.isEmpty) return null;

    _isSaving = true;
    notifyListeners();

    try {
      final newId = 'scenario_${_uuid.v4()}';
      // Default: all active members present in all stages
      final activeMemberIds = _trip!.members
          .where((m) => m.isActive)
          .map((m) => m.id)
          .toSet();

      final defaultAttendances = <String, Set<String>>{
        for (final stage in _trip!.stages) stage.id: Set<String>.from(activeMemberIds),
      };

      final newScenario = Scenario(
        id: newId,
        name: cleanName,
        description: description?.trim(),
        isBaseline: false,
        stageAttendances: defaultAttendances,
      );

      final updatedScenarios = [..._trip!.scenarios, newScenario];
      final updatedTrip = _trip!.copyWith(scenarios: updatedScenarios);

      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _selectedScenarioId = newId;
      _recalculate();
      return newScenario;
    } catch (e) {
      _errorMessage = 'Lỗi tạo kịch bản mới: $e';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> renameScenario(String scenarioId, String newName) async {
    if (_trip == null) return;
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    try {
      final updatedScenarios = _trip!.scenarios.map((s) {
        return s.id == scenarioId ? s.copyWith(name: trimmed) : s;
      }).toList();

      final updatedTrip = _trip!.copyWith(scenarios: updatedScenarios);
      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _recalculate();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi đổi tên kịch bản: $e';
      notifyListeners();
    }
  }

  Future<bool> deleteScenario(String scenarioId) async {
    if (_trip == null) return false;
    if (_trip!.scenarios.length <= 1) {
      _errorMessage = 'Không thể xóa kịch bản duy nhất còn lại.';
      notifyListeners();
      return false;
    }

    try {
      final deleting = _trip!.scenarios.firstWhere((s) => s.id == scenarioId);
      final remaining = _trip!.scenarios.where((s) => s.id != scenarioId).toList();

      // If deleting baseline, make first remaining scenario the baseline
      List<Scenario> finalScenarios = remaining;
      if (deleting.isBaseline && remaining.isNotEmpty) {
        finalScenarios = remaining.map((s) {
          return s.id == remaining.first.id ? s.copyWith(isBaseline: true) : s;
        }).toList();
      }

      String newActiveId = _trip!.activeScenarioId;
      if (newActiveId == scenarioId) {
        newActiveId = finalScenarios.first.id;
      }
      if (_selectedScenarioId == scenarioId) {
        _selectedScenarioId = newActiveId;
      }

      final updatedTrip = _trip!.copyWith(
        scenarios: finalScenarios,
        activeScenarioId: newActiveId,
      );

      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _recalculate();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi xóa kịch bản: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleAttendance({
    required String stageId,
    required String memberId,
  }) async {
    if (_trip == null || activeScenario == null) return;

    try {
      final sc = activeScenario!;
      final currentAttendances =
          Map<String, Set<String>>.from(sc.stageAttendances);
      final stageSet = Set<String>.from(currentAttendances[stageId] ?? {});

      if (stageSet.contains(memberId)) {
        stageSet.remove(memberId);
      } else {
        stageSet.add(memberId);
      }
      currentAttendances[stageId] = stageSet;

      final updatedScenario = sc.copyWith(
        stageAttendances: currentAttendances,
      );

      final updatedScenarios = _trip!.scenarios.map((s) {
        return s.id == sc.id ? updatedScenario : s;
      }).toList();

      final updatedTrip = _trip!.copyWith(scenarios: updatedScenarios);
      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _recalculate();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật điểm danh: $e';
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Expense Management
  // ---------------------------------------------------------------------------

  Future<bool> saveExpense(Expense expense) async {
    if (_trip == null) return false;
    _isSaving = true;
    notifyListeners();

    try {
      final exists = _trip!.expenses.any((e) => e.id == expense.id);
      final List<Expense> updatedList;
      if (exists) {
        updatedList = _trip!.expenses
            .map((e) => e.id == expense.id ? expense : e)
            .toList();
      } else {
        updatedList = [..._trip!.expenses, expense];
      }

      final updatedTrip = _trip!.copyWith(expenses: updatedList);
      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _recalculate();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi lưu khoản chi: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    if (_trip == null) return;
    try {
      final updatedList =
          _trip!.expenses.where((e) => e.id != expenseId).toList();
      final updatedTrip = _trip!.copyWith(expenses: updatedList);
      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _recalculate();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi xóa khoản chi: $e';
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Cash Transactions & Settlement
  // ---------------------------------------------------------------------------

  Future<bool> recordCashTransaction(CashTransaction transaction) async {
    if (_trip == null) return false;
    try {
      final updatedTxs = [..._trip!.cashTransactions, transaction];
      final updatedTrip = _trip!.copyWith(cashTransactions: updatedTxs);
      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _recalculate();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi ghi nhận giao dịch: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmTransferStep(SettlementTransferStep step) async {
    if (_trip == null) return false;

    final businessKey = 'settlement_step_${step.id}';

    // Check duplicate
    final isDuplicate = _trip!.cashTransactions.any(
      (tx) => tx.businessKey == businessKey,
    );
    if (isDuplicate) return true;

    final txType = step.isViaFund
        ? (step.toMemberId == _trip!.treasurerId
            ? CashTransactionType.fundContribution
            : CashTransactionType.refund)
        : CashTransactionType.memberTransfer;

    final tx = CashTransaction(
      id: 'tx_${_uuid.v4()}',
      tripId: _trip!.id,
      type: txType,
      payerMemberId: step.fromMemberId,
      recipient: step.toMemberId,
      amount: step.amount,
      note: 'Quyết toán: ${step.fromMemberName} ➔ ${step.toMemberName}',
      timestamp: DateTime.now(),
      businessKey: businessKey,
    );

    return recordCashTransaction(tx);
  }

  Future<void> initializeActualBook(String scenarioId) async {
    if (_trip == null) return;
    try {
      final updatedTrip = _trip!.copyWith(
        isLedgerInitialized: true,
        ledgerScenarioId: scenarioId,
      );
      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _isActualMode = true;
      _recalculate();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi khởi tạo sổ thực tế: $e';
      notifyListeners();
    }
  }

  Future<void> updateActualExpensePrice(String expenseId, int? actualPrice) async {
    if (_trip == null) return;
    try {
      final updatedExpenses = _trip!.expenses.map((e) {
        if (e.id == expenseId) {
          return e.copyWith(
            actualPrice: actualPrice,
            clearActualPrice: actualPrice == null,
          );
        }
        return e;
      }).toList();

      final updatedTrip = _trip!.copyWith(expenses: updatedExpenses);
      _trip = await _repository.saveTrip(
        updatedTrip,
        expectedRevision: _trip!.revision,
      );
      _recalculate();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật giá thực tế: $e';
      notifyListeners();
    }
  }
}
