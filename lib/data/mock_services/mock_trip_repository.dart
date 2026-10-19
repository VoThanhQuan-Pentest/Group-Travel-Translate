import '../../domain/models/trip.dart';
import '../../domain/services/trip_repository.dart';
import '../fixtures/golden_fixture.dart';

class MockTripRepository implements TripRepository {
  final Map<String, Trip> _trips = {};

  MockTripRepository() {
    // Nạp sẵn chuyến đi mẫu Golden Fixture
    final goldenTrip = GoldenFixture.createGoldenTrip();
    _trips[goldenTrip.id] = goldenTrip;
  }

  @override
  Future<List<Trip>> getTrips() async {
    return _trips.values.toList();
  }

  @override
  Future<Trip?> getTripById(String id) async {
    return _trips[id];
  }

  @override
  Future<Trip> saveTrip(Trip trip, {int? expectedRevision}) async {
    if (expectedRevision != null && _trips.containsKey(trip.id)) {
      final currentRev = _trips[trip.id]!.revision;
      if (currentRev != expectedRevision) {
        throw StateError('Dữ liệu chuyến đi đã bị thay đổi bởi thao tác khác (revision: $currentRev != $expectedRevision)');
      }
    }
    final nextRev = trip.revision + 1;
    final updatedTrip = trip.copyWith(
      metadata: {
        ...trip.metadata,
        'revision': nextRev,
      },
    );
    _trips[trip.id] = updatedTrip;
    return updatedTrip;
  }

  @override
  Future<void> deleteTrip(String id) async {
    _trips.remove(id);
  }

  @override
  Future<Trip> duplicateTrip(String id, {String? newName}) async {
    final existing = _trips[id];
    if (existing == null) {
      throw ArgumentError('Không tìm thấy chuyến đi có ID: $id để nhân bản');
    }

    final newId = 'trip_${DateTime.now().millisecondsSinceEpoch}';
    final name = newName ?? '${existing.name} (Bản sao)';

    final duplicatedTrip = existing.copyWith(
      id: newId,
      name: name,
      metadata: {
        ...existing.metadata,
        'duplicatedFrom': id,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );

    _trips[newId] = duplicatedTrip;
    return duplicatedTrip;
  }
}
