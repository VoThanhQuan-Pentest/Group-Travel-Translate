import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/settlement.dart';
import '../../viewmodels/settlement_viewmodel.dart';

class SettlementScreen extends StatefulWidget {
  final String tripId;

  const SettlementScreen({super.key, required this.tripId});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettlementViewModel>().loadTrip(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettlementViewModel>();
    final trip = vm.trip;

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (trip == null) {
      return Center(
        child: Text(
          vm.errorMessage ?? 'Không tìm thấy chuyến đi',
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    final settlement = vm.settlementResult;
    final validation = settlement?.validation ?? const SettlementValidation(canSettle: true);
    final canSettle = validation.canSettle;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quyết Toán Cuối Chuyến & Thu Chi Công Nợ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kịch bản áp dụng: ${vm.targetScenario?.name ?? "Mặc định"} • Thủ quỹ đại diện: ${trip.treasurer?.name ?? "Chưa chỉ định"}',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  // Phương thức quyết toán
                  SegmentedButton<SettlementMethod>(
                    segments: const [
                      ButtonSegment(
                        value: SettlementMethod.viaFund,
                        label: Text('Qua Quỹ'),
                        icon: Icon(Icons.account_balance, size: 16),
                      ),
                      ButtonSegment(
                        value: SettlementMethod.directTransfer,
                        label: Text('Gợi ý chuyển khoản gọn'),
                        icon: Icon(Icons.swap_horiz, size: 16),
                      ),
                    ],
                    selected: {vm.method},
                    onSelectionChanged: (val) {
                      vm.setMethod(val.first);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Safe settlement lock warning if validation fails
              if (!canSettle) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lock_outline, color: AppColors.onErrorContainer, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Khóa chốt sổ quyết toán: Dữ liệu chưa đủ điều kiện',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Để đảm bảo tính chính xác tuyệt đối từng đồng, bạn cần xử lý các vấn đề sau trước khi thực hiện chuyển tiền quyết toán:',
                        style: TextStyle(fontSize: 12.5, color: AppColors.onErrorContainer),
                      ),
                      const SizedBox(height: 8),
                      ...validation.blockingReasons.map(
                        (reason) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onErrorContainer)),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.onErrorContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Fund Cash Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.wallet, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lượng tiền mặt thực tế Thủ quỹ đang cầm trong quỹ:',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Thủ quỹ (${trip.treasurer?.name ?? "Thủ quỹ"}) có trách nhiệm chi trả số tiền này khi quyết toán qua quỹ.',
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatVnd(settlement?.fundCashOnHand ?? 0),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 1: Debt Summary Table
              const Text(
                'Bảng Tổng Hợp Công Nợ Từng Thành Viên',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                    columns: const [
                      DataColumn(label: Text('Thành viên', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Phần phải chịu', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Đã góp quỹ', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Đã ứng trả hộ', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Đã nhận lại', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Kết quả quyết toán', style: TextStyle(fontWeight: FontWeight.w700))),
                    ],
                    rows: (settlement?.debtSummaries ?? []).map((ds) {
                      final isZero = ds.netBalance == 0;
                      final isNeedToPay = ds.needsToPay;

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Text(ds.memberName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                if (ds.memberId == trip.treasurerId) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: const Text('Thủ quỹ',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          DataCell(Text(CurrencyFormatter.formatVnd(ds.costObligation))),
                          DataCell(Text(CurrencyFormatter.formatVnd(ds.fundContributed))),
                          DataCell(Text(CurrencyFormatter.formatVnd(ds.outOfPocketPaid))),
                          DataCell(Text(CurrencyFormatter.formatVnd(ds.refunded))),
                          DataCell(
                            isZero
                                ? const Text('Cân bằng (0 đ)', style: TextStyle(color: AppColors.textMuted))
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isNeedToPay
                                          ? AppColors.errorContainer
                                          : AppColors.successContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isNeedToPay
                                          ? 'Đóng thêm ${CurrencyFormatter.formatVnd(ds.amountToPay)}'
                                          : 'Nhận về ${CurrencyFormatter.formatVnd(ds.amountToReceive)}',
                                      style: TextStyle(
                                        color: isNeedToPay ? AppColors.error : AppColors.success,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Section 2: Transfer Steps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vm.method == SettlementMethod.viaFund
                              ? 'Các Lệnh Chuyển Tiền Qua Quỹ (Thủ Quỹ Điều Phối)'
                              : 'Gợi Ý Chuyển Khoản Gọn (Chuyển Chéo Giữa Các Thành Viên)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vm.method == SettlementMethod.viaFund
                              ? 'Người thiếu nộp cho Thủ quỹ, Thủ quỹ trả lại cho người thừa từ Quỹ.'
                              : 'Thuật toán kết hợp các dòng nợ lớn nhất để giảm thiểu số lệnh chuyển tiền (không cam kết tối ưu tuyệt đối).',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (settlement != null && settlement.transferSteps.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Tất cả thành viên đã quyết toán cân bằng hoàn toàn. Không cần thực hiện thêm lệnh chuyển khoản nào.',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: settlement?.transferSteps.length ?? 0,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final step = settlement!.transferSteps[index];
                    final isCompleted = step.status == TransferStatus.completed;

                    return Card(
                      color: isCompleted ? AppColors.surfaceVariant.withOpacity(0.5) : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isCompleted
                                  ? AppColors.successContainer
                                  : AppColors.warningContainer,
                              child: Icon(
                                isCompleted ? Icons.check : Icons.hourglass_top,
                                size: 18,
                                color: isCompleted
                                    ? AppColors.onSuccessContainer
                                    : AppColors.onWarningContainer,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        step.fromMemberName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          decoration:
                                              isCompleted ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        child: Icon(Icons.arrow_forward,
                                            size: 16, color: AppColors.textMuted),
                                      ),
                                      Text(
                                        step.toMemberName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          decoration:
                                              isCompleted ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Lệnh chuyển #${index + 1} • ${step.isViaFund ? "Giao dịch qua quỹ" : "Chuyển khoản trực tiếp"}',
                                    style: const TextStyle(
                                        fontSize: 11.5, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatVnd(step.amount),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isCompleted ? AppColors.textMuted : AppColors.primary,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCompleted
                                    ? AppColors.surfaceVariant
                                    : AppColors.primary,
                                foregroundColor: isCompleted
                                    ? AppColors.textSecondary
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              onPressed: () => vm.toggleStepStatus(step.id),
                              child: Text(isCompleted ? 'Đã chuyển' : 'Đánh dấu đã chuyển'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
