import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SampleDataBanner extends StatelessWidget {
  const SampleDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.infoContainer.withOpacity(0.7),
        border: const Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 16, color: AppColors.info),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Môi trường dữ liệu mẫu (Golden Fixtures) • Ứng dụng chạy Local • Giai đoạn Frontend',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onInfoContainer,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
