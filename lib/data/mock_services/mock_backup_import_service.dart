import 'dart:convert';
import '../../domain/models/trip.dart';
import '../../domain/services/trip_repository.dart';
import '../../domain/services/backup_import_service.dart';

class MockBackupImportService implements BackupImportService {
  @override
  Future<String> exportBackupJson({
    required Trip trip,
    bool allTrips = false,
    List<Trip>? trips,
  }) async {
    final Map<String, dynamic> exportData;

    if (allTrips && trips != null) {
      exportData = {
        'exportType': 'all_trips',
        'exportedAt': DateTime.now().toIso8601String(),
        'fileFormat': '.grouptrip.json',
        'schemaVersion': '1.0.0',
        'algorithmVersion': 'v1-greedy-fair-remainder',
        'trips': trips.map((t) => t.toJson()).toList(),
      };
    } else {
      exportData = {
        'exportType': 'single_trip',
        'exportedAt': DateTime.now().toIso8601String(),
        'fileFormat': '.grouptrip.json',
        'schemaVersion': '1.0.0',
        'algorithmVersion': 'v1-greedy-fair-remainder',
        'trip': trip.toJson(),
      };
    }

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(exportData);
  }

  @override
  Future<Trip> previewImportJson(String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Định dạng file không hợp lệ (không phải JSON object)');
      }

      final schemaVersion = decoded['schemaVersion'] as String?;
      if (schemaVersion == null) {
        throw const FormatException('Thiếu metadata phiên bản cấu trúc (schemaVersion)');
      }

      final Map<String, dynamic> tripJson;
      if (decoded.containsKey('trip')) {
        tripJson = decoded['trip'] as Map<String, dynamic>;
      } else if (decoded.containsKey('trips')) {
        final list = decoded['trips'] as List<dynamic>;
        if (list.isEmpty) throw const FormatException('Danh sách chuyến đi trong file rỗng');
        tripJson = list.first as Map<String, dynamic>;
      } else if (decoded.containsKey('id') && decoded.containsKey('name')) {
        tripJson = decoded;
      } else {
        throw const FormatException('Không tìm thấy dữ liệu chuyến đi hợp lệ trong file');
      }

      return Trip.fromJson(tripJson);
    } catch (e) {
      throw FormatException('Không thể đọc file sao lưu: ${e.toString()}');
    }
  }

  @override
  Future<Trip> commitImport({
    required String jsonString,
    required TripRepository repository,
  }) async {
    final parsedTrip = await previewImportJson(jsonString);

    // Luôn nhập thành bản sao độc lập với ID mới để bảo toàn dữ liệu hiện có
    final newId = 'trip_imported_${DateTime.now().millisecondsSinceEpoch}';
    final independentCopy = parsedTrip.copyWith(
      id: newId,
      name: '${parsedTrip.name} (Bản sao nhập)',
      metadata: {
        ...parsedTrip.metadata,
        'importedAt': DateTime.now().toIso8601String(),
        'originalTripId': parsedTrip.id,
      },
    );

    await repository.saveTrip(independentCopy);
    return independentCopy;
  }
}
