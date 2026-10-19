import 'package:flutter/foundation.dart';
import '../domain/models/trip.dart';
import '../domain/models/member.dart';
import '../domain/models/scenario.dart';
import '../domain/models/stage.dart';
import '../domain/services/trip_repository.dart';

class TripListViewModel extends ChangeNotifier {
  final TripRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Trip> _trips = [];

  TripListViewModel({required TripRepository repository})
      : _repository = repository {
    loadTrips();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Trip> get trips => _trips;
  bool get isEmpty => !_isLoading && _trips.isEmpty;

  Future<void> loadTrips() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trips = await _repository.getTrips();
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách chuyến đi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Trip?> createTrip({
    required String name,
    String? description,
    required String defaultTreasurerName,
  }) async {
    try {
      final tripId = 'trip_${DateTime.now().millisecondsSinceEpoch}';
      final treasurerId = 'm_${DateTime.now().millisecondsSinceEpoch}';
      final defaultStageId = 'stage_${DateTime.now().millisecondsSinceEpoch}';

      final initialTrip = Trip(
        id: tripId,
        name: name,
        description: description,
        treasurerId: treasurerId,
        members: [
          Member(
            id: treasurerId,
            name: defaultTreasurerName,
            isTreasurer: true,
          ),
        ],
        stages: [
          Stage(
            id: defaultStageId,
            name: 'Chặng 1',
            order: 1,
          ),
        ],
        scenarios: [
          Scenario(
            id: 'scenario_1',
            name: 'Kịch bản 1',
            isBaseline: true,
            stageAttendances: {
              defaultStageId: {treasurerId},
            },
          ),
        ],
        activeScenarioId: 'scenario_1',
      );

      final saved = await _repository.saveTrip(initialTrip);
      await loadTrips();
      return saved;
    } catch (e) {
      _errorMessage = 'Lỗi tạo chuyến đi: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> renameTrip(String tripId, String newName) async {
    try {
      final trip = await _repository.getTripById(tripId);
      if (trip != null) {
        final updated = trip.copyWith(name: newName);
        await _repository.saveTrip(updated);
        await loadTrips();
      }
    } catch (e) {
      _errorMessage = 'Lỗi đổi tên: $e';
      notifyListeners();
    }
  }

  Future<Trip?> duplicateTrip(String tripId, {String? customName}) async {
    try {
      final duplicated =
          await _repository.duplicateTrip(tripId, newName: customName);
      await loadTrips();
      return duplicated;
    } catch (e) {
      _errorMessage = 'Lỗi nhân bản chuyến đi: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _repository.deleteTrip(tripId);
      await loadTrips();
    } catch (e) {
      _errorMessage = 'Lỗi xóa chuyến đi: $e';
      notifyListeners();
    }
  }
}
