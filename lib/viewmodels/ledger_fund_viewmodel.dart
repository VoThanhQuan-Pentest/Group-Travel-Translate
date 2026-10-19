import 'package:flutter/foundation.dart';
import '../domain/models/trip.dart';
import '../domain/models/expense.dart';
import '../domain/models/cash_transaction.dart';
import '../domain/services/trip_repository.dart';

class LedgerFundViewModel extends ChangeNotifier {
  final TripRepository _repository;

  Trip? _trip;
  bool _isLoading = false;
  String? _errorMessage;

  LedgerFundViewModel({required TripRepository repository})
      : _repository = repository;

  Trip? get trip => _trip;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLedgerInitialized => _trip?.isLedgerInitialized ?? false;
  List<Expense> get expenses => _trip?.expenses ?? [];
  List<CashTransaction> get transactions => _trip?.cashTransactions ?? [];

  int get fundCashBalance => _trip?.fundCashBalance ?? 0;

  int get totalEstimatedCost {
    if (_trip == null) return 0;
    return _trip!.expenses.fold<int>(
      0,
      (sum, e) => sum + (e.estimatedTotal > 0 ? e.estimatedTotal : e.unitPrice),
    );
  }

  int get totalActualCost {
    if (_trip == null) return 0;
    return _trip!.expenses.fold<int>(
      0,
      (sum, e) => sum + (e.actualPrice ?? 0),
    );
  }

  int get unenteredExpensesCount {
    if (_trip == null) return 0;
    return _trip!.expenses.where((e) => e.actualPrice == null).length;
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
      _errorMessage = 'Lỗi tải Sổ thực tế & Quỹ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeLedgerFromScenario(String scenarioId) async {
    if (_trip == null) return;
    try {
      final updated = _trip!.copyWith(
        isLedgerInitialized: true,
        ledgerScenarioId: scenarioId,
      );
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi khởi tạo sổ thực tế: $e';
      notifyListeners();
    }
  }

  Future<void> updateActualPrice(String expenseId, int? actualPrice) async {
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

      final updated = _trip!.copyWith(expenses: updatedExpenses);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật giá thực tế: $e';
      notifyListeners();
    }
  }

  Future<void> markExpenseZero(String expenseId) async {
    await updateActualPrice(expenseId, 0);
  }

  Future<void> addCashTransaction({
    required CashTransactionType type,
    required String payerMemberId,
    required String recipient,
    required int amount,
    required String note,
    String? expenseId,
  }) async {
    if (_trip == null) return;
    try {
      final newTx = CashTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        tripId: _trip!.id,
        expenseId: expenseId,
        type: type,
        payerMemberId: payerMemberId,
        recipient: recipient,
        amount: amount,
        note: note.trim(),
        timestamp: DateTime.now(),
      );

      final updatedTransactions = [newTx, ..._trip!.cashTransactions];
      final updated = _trip!.copyWith(cashTransactions: updatedTransactions);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi thêm giao dịch quỹ: $e';
      notifyListeners();
    }
  }

  Future<void> deleteCashTransaction(String transactionId) async {
    if (_trip == null) return;
    try {
      final updatedTransactions =
          _trip!.cashTransactions.where((t) => t.id != transactionId).toList();
      final updated = _trip!.copyWith(cashTransactions: updatedTransactions);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi xóa giao dịch: $e';
      notifyListeners();
    }
  }

  /// Tổng số tiền đã thanh toán cho một hóa đơn cụ thể (từ quỹ hoặc cá nhân ứng)
  int getPaidAmountForExpense(String expenseId) {
    if (_trip == null) return 0;
    return _trip!.cashTransactions
        .where((t) =>
            t.expenseId == expenseId &&
            (t.type == CashTransactionType.supplierPayment ||
                t.type == CashTransactionType.supplierDeposit ||
                t.type == CashTransactionType.outOfPocketPayment))
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Số tiền còn thiếu cần trả thêm cho hóa đơn
  int getRemainingAmountForExpense(Expense expense) {
    final target = expense.actualPrice ?? expense.estimatedTotal;
    final paid = getPaidAmountForExpense(expense.id);
    final remaining = target - paid;
    return remaining > 0 ? remaining : 0;
  }
}
