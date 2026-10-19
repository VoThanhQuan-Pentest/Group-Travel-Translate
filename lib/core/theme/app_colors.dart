import 'package:flutter/material.dart';

/// Bảng màu hiện đại theo phong cách Material 3
/// Tông màu chủ đạo: Xanh ngọc lục bảo (Emerald Green) & Chàm (Indigo),
/// kết hợp các màu trạng thái rõ ràng cho kế toán nhóm.
class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF0F766E); // Teal 700
  static const Color primaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color primaryDark = Color(0xFF115E59); // Teal 800
  static const Color primaryContainer = Color(0xFFCCFBF1); // Teal 100
  static const Color onPrimaryContainer = Color(0xFF134E4A);

  // Secondary palette
  static const Color secondary = Color(0xFF4338CA); // Indigo 700
  static const Color secondaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color secondaryContainer = Color(0xFFE0E7FF); // Indigo 100
  static const Color onSecondaryContainer = Color(0xFF312E81);

  // Neutral & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color outline = Color(0xFFCBD5E1); // Slate 300
  static const Color outlineVariant = Color(0xFFE2E8F0); // Slate 200

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Status & Financial indicators
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccessContainer = Color(0xFF065F46);

  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF92400E);

  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  static const Color info = Color(0xFF0284C7); // Sky 600
  static const Color infoContainer = Color(0xFFE0F2FE);
  static const Color onInfoContainer = Color(0xFF075985);

  // 3-state Cost Bearer colors
  static const Color bearerInherited = Color(0xFF0284C7); // Blue - Tự động
  static const Color bearerManualInclude = Color(0xFF059669); // Green - Ép chịu
  static const Color bearerManualExclude = Color(0xFFDC2626); // Red - Miễn trừ
}
