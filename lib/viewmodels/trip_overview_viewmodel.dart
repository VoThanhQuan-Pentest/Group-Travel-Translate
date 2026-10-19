import 'package:flutter/foundation.dart';
import '../domain/models/trip.dart';
import '../domain/models/member.dart';
import '../domain/models/scenario.dart';
import '../domain/services/trip_repository.dart';
import '../domain/services/calculation_service.dart';

class TripOverviewViewModel extends ChangeNotifier {
  final TripRepository _repository;
  final CalculationService _calculationService;

  Trip? _trip;
  bool _isLoading = false;
  String? _errorMessage;

  TripOverviewViewModel({
    required TripRepository repository,
    required CalculationService calculationService,
  })  : _repository = repository,
        _calculationService = calculationService;

  Trip? get trip => _trip;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isSampleData => _trip?.metadata['isSampleData'] == true;
  bool get isLedgerInitialized => _trip?.isLedgerInitialized ?? false;
  Scenario? get activeScenario => _trip?.activeScenario;

  /// Tổng chi phí dự tính theo kịch bản đang chọn
  int get totalEstimatedCost {
    if (_trip == null || activeScenario == null) return 0;
    final res = _calculationService.calculateScenario(
      trip: _trip!,
      scenario: activeScenario!,
    );
    return res.totalTripCost;
  }

  /// Tổng chi phí thực tế (từ các hóa đơn đã nhập thực tế)
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

  /// Độ lệch giữa thực tế và dự tính (Thực tế - Dự tính)
  int get costVariance => totalActualCost - totalEstimatedCost;

  /// Số dư tiền mặt tồn quỹ
  int get fundCashBalance => _trip?.fundCashBalance ?? 0;

  Future<void> loadTrip(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trip = await _repository.getTripById(tripId);
      if (_trip == null) {
        _errorMessage = 'Không tìm thấy chuyến đi có ID: $tripId';
      }
    } catch (e) {
      _errorMessage = 'Lỗi tải chuyến đi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTripInfo({
    required String name,
    String? description,
    required String treasurerId,
  }) async {
    if (_trip == null) return;
    try {
      final updated = _trip!.copyWith(
        name: name,
        description: description,
        treasurerId: treasurerId,
      );
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật thông tin chuyến đi: $e';
      notifyListeners();
    }
  }

  Future<void> setActiveScenario(String scenarioId) async {
    if (_trip == null) return;
    try {
      final updated = _trip!.copyWith(activeScenarioId: scenarioId);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi đổi kịch bản: $e';
      notifyListeners();
    }
  }

  Future<void> addMember(String name) async {
    if (_trip == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    try {
      final newMember = Member(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        name: trimmed,
        isTreasurer: false,
      );

      final updatedMembers = [..._trip!.members, newMember];
      final updated = _trip!.copyWith(members: updatedMembers);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi thêm thành viên: $e';
      notifyListeners();
    }
  }

  Future<void> renameMember(String memberId, String newName) async {
    if (_trip == null) return;
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    try {
      final updatedMembers = _trip!.members.map((m) {
        if (m.id == memberId) {
          return m.copyWith(name: trimmed);
        }
        return m;
      }).toList();

      final updated = _trip!.copyWith(members: updatedMembers);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi đổi tên thành viên: $e';
      notifyListeners();
    }
  }

  Future<void> setTreasurer(String memberId) async {
    if (_trip == null) return;
    try {
      final updatedMembers = _trip!.members.map((m) {
        return m.copyWith(isTreasurer: m.id == memberId);
      }).toList();

      final updated = _trip!.copyWith(
        treasurerId: memberId,
        members: updatedMembers,
      );
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi chỉ định thủ quỹ: $e';
      notifyListeners();
    }
  }

  Future<void> removeMember(String memberId) async {
    if (_trip == null) return;
    if (memberId == _trip!.treasurerId) {
      _errorMessage = 'Không thể xóa Thủ quỹ. Vui lòng chỉ định thủ quỹ khác trước.';
      notifyListeners();
      return;
    }

    try {
      final updatedMembers =
          _trip!.members.where((m) => m.id != memberId).toList();
      final updated = _trip!.copyWith(members: updatedMembers);
      _trip = await _repository.saveTrip(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi xóa thành viên: $e';
      notifyListeners();
    }
  }
}
