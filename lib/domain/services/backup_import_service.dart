import '../models/trip.dart';
import 'trip_repository.dart';

abstract class BackupImportService {
  /// Xuất dữ liệu chuyến đi ra chuỗi JSON định dạng `.grouptrip.json`.
  /// Chứa đầy đủ dữ liệu nền, món/phí, mọi kịch bản, sổ thực tế, giao dịch, metadata.
  Future<String> exportBackupJson({
    required Trip trip,
    bool allTrips = false,
    List<Trip>? trips,
  });

  /// Đọc và xác thực cấu trúc file JSON trước khi import.
  /// Trả về đối tượng Trip xem trước.
  Future<Trip> previewImportJson(String jsonString);

  /// Xác nhận import dữ liệu vào kho lưu trữ (tạo bản sao độc lập).
  Future<Trip> commitImport({
    required String jsonString,
    required TripRepository repository,
  });
}
