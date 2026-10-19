import '../models/trip.dart';

abstract class TripRepository {
  /// Lấy danh sách tất cả các chuyến đi
  Future<List<Trip>> getTrips();

  /// Lấy chi tiết một chuyến đi theo ID
  Future<Trip?> getTripById(String id);

  /// Lưu hoặc cập nhật một chuyến đi (hỗ trợ kiểm tra revision tránh ghi đè)
  Future<Trip> saveTrip(Trip trip, {int? expectedRevision});

  /// Xóa một chuyến đi
  Future<void> deleteTrip(String id);

  /// Nhân bản một chuyến đi thành bản sao độc lập
  Future<Trip> duplicateTrip(String id, {String? newName});
}
