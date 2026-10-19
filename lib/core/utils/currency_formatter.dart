import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  /// Định dạng số nguyên VNĐ (Ví dụ: 273.333 đ, -84.286 đ)
  /// Nếu [amount] là null, hiển thị [nullPlaceholder] (mặc định "Chưa nhập")
  static String formatVnd(
    int? amount, {
    bool showSuffix = true,
    String nullPlaceholder = 'Chưa nhập',
  }) {
    if (amount == null) return nullPlaceholder;
    final formatted = _formatter.format(amount).replaceAll(',', '.');
    return showSuffix ? '$formatted đ' : formatted;
  }

  /// Định dạng số nguyên kèm dấu cộng/trừ rõ ràng (Ví dụ: +164.286 đ, -84.286 đ, 0 đ)
  static String formatSignedVnd(
    int? amount, {
    bool showSuffix = true,
  }) {
    if (amount == null) return 'Chưa nhập';
    if (amount > 0) {
      return '+${formatVnd(amount, showSuffix: showSuffix)}';
    }
    return formatVnd(amount, showSuffix: showSuffix);
  }

  /// Chuyển chuỗi người dùng nhập (có thể có dấu chấm/phẩy) thành int hợp lệ
  static int? parseVnd(String? text) {
    if (text == null) return null;
    final cleaned = text.trim().replaceAll('.', '').replaceAll(',', '').replaceAll('đ', '').replaceAll(' ', '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }
}
