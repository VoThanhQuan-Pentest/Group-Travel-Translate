import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_travel_caculate/data/fixtures/golden_fixture.dart';
import 'package:group_travel_caculate/data/mock_services/mock_trip_repository.dart';
import 'package:group_travel_caculate/data/services/real_backup_import_service.dart';
import 'package:group_travel_caculate/domain/models/trip.dart';

void main() {
  group('RealBackupImportService Tests', () {
    late MockTripRepository repository;
    late RealBackupImportService service;
    late Trip goldenTrip;

    setUp(() async {
      repository = MockTripRepository();
      service = RealBackupImportService();
      goldenTrip = GoldenFixture.createGoldenTrip();
      await repository.saveTrip(goldenTrip);
    });

    test('Xuất file sao lưu đơn chuyến mang schema 2.0.0 và định dạng chuẩn', () async {
      final jsonStr = await service.exportBackupJson(trip: goldenTrip);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded['schemaVersion'], '2.0.0');
      expect(decoded['fileFormat'], '.grouptrip.json');
      expect(decoded['exportType'], 'single_trip');
      expect(decoded['trip'], isNotNull);
      expect((decoded['trip'] as Map<String, dynamic>)['name'], goldenTrip.name);
    });

    test('Xuất file sao lưu nhiều chuyến mang danh sách toàn bộ chuyến đi', () async {
      final secondTrip = goldenTrip.copyWith(
        id: 'trip_vung_tau',
        name: 'Vũng Tàu Cuối Tuần',
      );
      await repository.saveTrip(secondTrip);

      final trips = await repository.getTrips();
      final jsonStr = await service.exportBackupJson(
        trip: goldenTrip,
        allTrips: true,
        trips: trips,
      );
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded['schemaVersion'], '2.0.0');
      expect(decoded['exportType'], 'all_trips');
      expect(decoded['trips'], isA<List>());
      expect((decoded['trips'] as List).length, 2);
    });

    test('Xem trước (Preview) file nhiều chuyến hiển thị đầy đủ thông tin từng chuyến', () async {
      final secondTrip = goldenTrip.copyWith(
        id: 'trip_hagiang',
        name: 'Hà Giang Mùa Tam Giác Mạch',
      );
      final jsonStr = await service.exportBackupJson(
        trip: goldenTrip,
        allTrips: true,
        trips: [goldenTrip, secondTrip],
      );

      final trips = await service.previewAllTrips(jsonStr);
      expect(trips.length, 2);
      expect(trips.any((t) => t.name == 'Chuyến đi Đà Lạt 2 ngày 1 đêm (Bộ dữ liệu mẫu kiểm thử)'), isTrue);
      expect(trips.any((t) => t.name == 'Hà Giang Mùa Tam Giác Mạch'), isTrue);
    });

    test('Import file nhiều chuyến tái lập ID chuyến mới và cập nhật tham chiếu giao dịch', () async {
      final tripA = goldenTrip.copyWith(id: 'trip_orig_1', name: 'Chuyến A');
      final tripB = goldenTrip.copyWith(id: 'trip_orig_2', name: 'Chuyến B');
      final jsonStr = await service.exportBackupJson(
        trip: tripA,
        allTrips: true,
        trips: [tripA, tripB],
      );

      final imported = await service.commitImportAll(
        jsonString: jsonStr,
        repository: repository,
      );

      expect(imported.length, 2);
      expect(imported[0].id, isNot('trip_orig_1'));
      expect(imported[1].id, isNot('trip_orig_2'));

      // Kiểm tra tất cả giao dịch trong chuyến mới đều mang tripId mới tương ứng
      for (final importedTrip in imported) {
        for (final tx in importedTrip.cashTransactions) {
          expect(tx.tripId, importedTrip.id);
        }
      }
    });

    test('Từ chối import file không đúng cấu trúc json', () async {
      const invalidJson = '{"broken": true}';
      expect(() => service.previewAllTrips(invalidJson), throwsFormatException);
    });
  });
}
