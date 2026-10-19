import 'package:flutter/foundation.dart';
import '../domain/models/trip.dart';
import '../domain/models/scenario.dart';
import '../domain/models/settlement.dart';
import '../domain/models/cash_transaction.dart';
import '../domain/services/trip_repository.dart';
import '../domain/services/calculation_service.dart';

class SettlementViewModel extends ChangeNotifier {
  final TripRepository _repository;
  final CalculationService _calculationService;

  Trip? _trip;
  bool _isLoading = false;
  String? _errorMessage;

  SettlementMethod _method = SettlementMethod.viaFund;
  final Map<String, TransferStatus> _stepStatuses = {};

  SettlementViewModel({
    required TripRepository repository,
    required CalculationService calculationService,
  })  : _repository = repository,
        _calculationService = calculationService;

  Trip? get trip => _trip;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SettlementMethod get method => _method;

  Scenario? get targetScenario {
    if (_trip == null) return null;
    // Nếu sổ thực tế đã khởi tạo và gắn với kịch bản nào, ưu tiên kịch bản đó
    if (_trip!.ledgerScenarioId != null) {
      try {
        return _trip!.scenarios.firstWhere((s) => s.id == _trip!.ledgerScenarioId);
      } catch (_) {}
    }
    return _trip!.activeScenario;
  }

  SettlementResult? get settlementResult {
    if (_trip == null || targetScenario == null) return null;
    final res = _calculationService.calculateSettlement(
      trip: _trip!,
      scenario: targetScenario!,
      method: _method,
    );

    // Ghép trạng thái tùy chỉnh của các bước chuyển tiền
    final updatedSteps = res.transferSteps.map((step) {
      final overrideStatus = _stepStatuses[step.id];
      if (overrideStatus != null) {
        return step.copyWith(status: overrideStatus);
      }
      return step;
    }).toList();

    return SettlementResult(
      validation: res.validation,
      method: res.method,
      debtSummaries: res.debtSummaries,
      transferSteps: updatedSteps,
      fundCashOnHand: res.fundCashOnHand,
    );
  }

  void setMethod(SettlementMethod method) {
    if (_method != method) {
      _method = method;
      notifyListeners();
    }
  }

  Future<void> toggleStepStatus(String stepId) async {
    final current = _stepStatuses[stepId] ?? TransferStatus.pending;
    final newStatus = current == TransferStatus.pending
        ? TransferStatus.completed
        : TransferStatus.pending;
    _stepStatuses[stepId] = newStatus;

    if (_trip != null && targetScenario != null) {
      try {
        final res = _calculationService.calculateSettlement(
          trip: _trip!,
          scenario: targetScenario!,
          method: _method,
        );
        final step = res.transferSteps.where((s) => s.id == stepId).firstOrNull;
        if (step != null) {
          if (newStatus == TransferStatus.completed) {
            final txType = step.isViaFund
                ? (step.toMemberId == _trip!.treasurerId
                    ? CashTransactionType.fundContribution
                    : CashTransactionType.refund)
                : CashTransactionType.memberTransfer;

            final tx = CashTransaction(
              id: 'tx_settle_${step.id}_${DateTime.now().millisecondsSinceEpoch}',
              tripId: _trip!.id,
              type: txType,
              payerMemberId: step.fromMemberId,
              recipient: step.toMemberId,
              amount: step.amount,
              note: 'Quyết toán: ${step.fromMemberName} ➔ ${step.toMemberName}',
              timestamp: DateTime.now(),
              businessKey: 'step_${step.id}',
            );

            // Chống ghi trùng
            if (!_trip!.cashTransactions.any((t) => t.businessKey == 'step_${step.id}')) {
              final updatedTxs = [..._trip!.cashTransactions, tx];
              final updated = _trip!.copyWith(cashTransactions: updatedTxs);
              _trip = await _repository.saveTrip(updated);
            }
          } else {
            // Hoàn tác: loại bỏ giao dịch quyết toán này
            final updatedTxs = _trip!.cashTransactions
                .where((t) => t.businessKey != 'step_${step.id}')
                .toList();
            final updated = _trip!.copyWith(cashTransactions: updatedTxs);
            _trip = await _repository.saveTrip(updated);
          }
        }
      } catch (e) {
        _errorMessage = 'Lỗi lưu giao dịch quyết toán: $e';
      }
    }

    notifyListeners();
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
    } catch (e) {
      _errorMessage = 'Lỗi tải quyết toán: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
