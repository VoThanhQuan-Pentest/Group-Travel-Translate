import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StaleCalculationBanner extends StatelessWidget {
  final VoidCallback? onResetToFixture;

  const StaleCalculationBanner({
    super.key,
    this.onResetToFixture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.onWarningContainer,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chưa có kết quả tính toán mới / Kết quả cũ đã hết hiệu lực',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.onWarningContainer,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Dữ liệu đầu vào đã được chỉnh sửa khác với các kịch bản mẫu đối chiếu. Ở phiên bản Frontend giả lập này, kết quả tính toán tạm thời bị khóa cho đến khi kết nối lõi tài chính SQLite ở giai đoạn sau.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onWarningContainer,
                    height: 1.35,
                  ),
                ),
                if (onResetToFixture != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onResetToFixture,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Khôi phục về dữ liệu mẫu chuẩn'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onWarningContainer,
                      side: const BorderSide(color: AppColors.onWarningContainer),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
