import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_travel_caculate/data/database/app_database.dart';
import 'package:group_travel_caculate/data/repositories/drift_trip_repository.dart';
import 'package:group_travel_caculate/domain/models/member.dart';

void main() {
  late AppDatabase db;
  late DriftTripRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftTripRepository(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftTripRepository Persistence Tests', () {
    test('Thêm người thứ năm rồi mở lại bằng repository mới: Danh sách giữ nguyên 5 người', () async {
      final trips = await repo.getTrips();
      expect(trips.isNotEmpty, true);
      final trip = trips.first;
      expect(trip.members.length, 4);

      // Thêm người thứ 5
      final newMember = const Member(
        id: 'm_em_ut',
        name: 'Em Út',
        isTreasurer: false,
      );
      final updatedTrip = trip.copyWith(
        members: [...trip.members, newMember],
      );

      await repo.saveTrip(updatedTrip);

      // Tạo instance repository MỚI dùng chung database
      final newRepoInstance = DriftTripRepository(database: db);
      final reloaded = await newRepoInstance.getTripById(trip.id);

      expect(reloaded, isNotNull);
      expect(reloaded!.members.length, 5);
      expect(reloaded.members.any((m) => m.name == 'Em Út'), true);
      expect(reloaded.members.last.id, 'm_em_ut');
    });

    test('Kiểm tra revision: Phát hiện xung đột phiên bản khi lưu đè', () async {
      final trips = await repo.getTrips();
      final trip = trips.first;
      final currentRev = trip.revision;

      // Lưu lần đầu thành công
      await repo.saveTrip(trip, expectedRevision: currentRev);

      // Phiên bản cũ cố lưu với expectedRevision cũ phải ném lỗi
      expect(
        () async => await repo.saveTrip(trip, expectedRevision: currentRev),
        throwsA(isA<StateError>()),
      );
    });

    test('Nhân bản chuyến đi tạo ID và thực thể độc lập hoàn toàn', () async {
      final trips = await repo.getTrips();
      final original = trips.first;

      final duplicated = await repo.duplicateTrip(original.id, newName: 'Chuyến bản sao độc lập');
      expect(duplicated.id != original.id, true);
      expect(duplicated.name, 'Chuyến bản sao độc lập');

      // Member IDs, Stage IDs, Expense IDs must be remapped
      expect(duplicated.members.first.id != original.members.first.id, true);
      expect(duplicated.stages.first.id != original.stages.first.id, true);
      expect(duplicated.expenses.first.id != original.expenses.first.id, true);
      expect(duplicated.scenarios.first.id != original.scenarios.first.id, true);

      // Both trips exist in database
      final all = await repo.getTrips();
      expect(all.length, 2);
    });
  });
}
