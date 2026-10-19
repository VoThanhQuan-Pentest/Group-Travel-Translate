import 'package:flutter/material.dart';
import '../../domain/models/expense.dart';
import '../../core/theme/app_colors.dart';

class CostBearerCheckbox extends StatelessWidget {
  final String memberName;
  final bool isPresentInStage;
  final CostBearerStatus status;
  final ValueChanged<CostBearerStatus> onChanged;
  final VoidCallback? onResetToInherited;

  const CostBearerCheckbox({
    super.key,
    required this.memberName,
    required this.isPresentInStage,
    required this.status,
    required this.onChanged,
    this.onResetToInherited,
  });

  bool get isEffectiveBearer => status.isEffectiveBearer(isPresentInStage);

  void _cycleNextState() {
    switch (status) {
      case CostBearerStatus.inherited:
        // Nếu đang kế thừa và có mặt -> chuyển sang bỏ thủ công
        // Nếu đang kế thừa và vắng mặt -> chuyển sang chọn thủ công
        if (isPresentInStage) {
          onChanged(CostBearerStatus.manualExclude);
        } else {
          onChanged(CostBearerStatus.manualInclude);
        }
        break;
      case CostBearerStatus.manualInclude:
        onChanged(CostBearerStatus.manualExclude);
        break;
      case CostBearerStatus.manualExclude:
        onChanged(CostBearerStatus.inherited);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Widget icon;
    String statusLabel;
    Color statusLabelColor;

    switch (status) {
      case CostBearerStatus.inherited:
        borderColor = isPresentInStage ? AppColors.info : AppColors.outline;
        bgColor = isPresentInStage ? AppColors.infoContainer : Colors.transparent;
        icon = isPresentInStage
            ? const Icon(Icons.check, size: 16, color: AppColors.onInfoContainer)
            : const Icon(Icons.remove, size: 16, color: AppColors.textMuted);
        statusLabel = isPresentInStage ? 'Tự động (Có mặt)' : 'Tự động (Vắng)';
        statusLabelColor = isPresentInStage ? AppColors.info : AppColors.textMuted;
        break;

      case CostBearerStatus.manualInclude:
        borderColor = AppColors.success;
        bgColor = AppColors.successContainer;
        icon = const Icon(Icons.check_circle, size: 16, color: AppColors.onSuccessContainer);
        statusLabel = 'Ép chịu (Thủ công)';
        statusLabelColor = AppColors.success;
        break;

      case CostBearerStatus.manualExclude:
        borderColor = AppColors.error;
        bgColor = AppColors.errorContainer;
        icon = const Icon(Icons.cancel, size: 16, color: AppColors.onErrorContainer);
        statusLabel = 'Miễn trừ (Thủ công)';
        statusLabelColor = AppColors.error;
        break;
    }

    return InkWell(
      onTap: _cycleNextState,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: status != CostBearerStatus.inherited
                ? borderColor
                : AppColors.outlineVariant,
            width: status != CostBearerStatus.inherited ? 1.5 : 1.0,
          ),
          color: status != CostBearerStatus.inherited
              ? bgColor.withAlpha(80)
              : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ô hiển thị trạng thái tương tác
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borderColor, width: 1.5),
                color: bgColor,
              ),
              child: Center(child: icon),
            ),
            const SizedBox(width: 8),
            // Tên và nhãn trạng thái
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    memberName,
                    style: TextStyle(
                      fontWeight: isEffectiveBearer ? FontWeight.w600 : FontWeight.w400,
                      color: isEffectiveBearer ? AppColors.textPrimary : AppColors.textMuted,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: statusLabelColor,
                    ),
                  ),
                ],
              ),
            ),
            if (status != CostBearerStatus.inherited && onResetToInherited != null) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: 'Khôi phục về kế thừa theo chặng',
                child: IconButton(
                  icon: const Icon(Icons.restore, size: 16, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 14,
                  onPressed: onResetToInherited,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
