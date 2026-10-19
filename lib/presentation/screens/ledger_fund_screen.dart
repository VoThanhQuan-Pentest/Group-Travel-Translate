import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/cash_transaction.dart';
import '../../domain/models/expense.dart';
import '../../viewmodels/ledger_fund_viewmodel.dart';

class LedgerFundScreen extends StatefulWidget {
  final String tripId;

  const LedgerFundScreen({super.key, required this.tripId});

  @override
  State<LedgerFundScreen> createState() => _LedgerFundScreenState();
}

class _LedgerFundScreenState extends State<LedgerFundScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LedgerFundViewModel>().loadTrip(widget.tripId);
    });
  }

  void _showInitializeLedgerDialog() {
    final vm = context.read<LedgerFundViewModel>();
    final trip = vm.trip!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Khởi tạo Sổ thực tế độc lập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn một kịch bản dự toán làm dữ liệu nền để khởi tạo Sổ thực tế. Cột giá dự tính sẽ được giữ nguyên bên cạnh để đối chiếu.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            ...trip.scenarios.map((sc) {
              return ListTile(
                title: Text(sc.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(sc.description ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  vm.initializeLedgerFromScenario(sc.id);
                  Navigator.of(ctx).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showEditActualPriceDialog(Expense expense) {
    final ctrl = TextEditingController(
      text: expense.actualPrice != null ? '${expense.actualPrice}' : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nhập giá thực tế: ${expense.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Giá dự tính: ${CurrencyFormatter.formatVnd(expense.estimatedTotal > 0 ? expense.estimatedTotal : expense.unitPrice)}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Số tiền thực tế (VNĐ)',
                hintText: 'Nhập số tiền hoặc chọn Không phát sinh bên dưới',
                suffixText: 'VNĐ',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Không phát sinh (0 đ)'),
                  onPressed: () {
                    context.read<LedgerFundViewModel>().markExpenseZero(expense.id);
                    Navigator.of(ctx).pop();
                  },
                ),
                ActionChip(
                  label: const Text('Đặt lại (Chưa nhập)'),
                  onPressed: () {
                    context.read<LedgerFundViewModel>().updateActualPrice(expense.id, null);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = CurrencyFormatter.parseVnd(ctrl.text);
              context.read<LedgerFundViewModel>().updateActualPrice(expense.id, parsed);
              Navigator.of(ctx).pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    final vm = context.read<LedgerFundViewModel>();
    final trip = vm.trip!;

    CashTransactionType type = CashTransactionType.fundContribution;
    String payerMemberId = trip.members.first.id;
    final recipientCtrl = TextEditingController(text: 'Quỹ chung');
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String? selectedExpenseId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ghi nhận dòng tiền mới'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<CashTransactionType>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Loại giao dịch *'),
                    items: CashTransactionType.values.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.displayName));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          type = val;
                          if (type == CashTransactionType.fundContribution) {
                            recipientCtrl.text = 'Quỹ chung';
                            payerMemberId = trip.members.first.id;
                          } else if (type == CashTransactionType.supplierPayment ||
                              type == CashTransactionType.supplierDeposit) {
                            payerMemberId = 'fund';
                            recipientCtrl.text = 'Nhà cung cấp';
                          } else if (type == CashTransactionType.outOfPocketPayment) {
                            payerMemberId = trip.members.first.id;
                            recipientCtrl.text = 'Nhà cung cấp';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (type.isPaidFromFund) ...[
                    const TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Nguồn tiền chi trả',
                        hintText: 'Quỹ chung (Thủ quỹ)',
                      ),
                    ),
                  ] else ...[
                    DropdownButtonFormField<String>(
                      value: payerMemberId == 'fund' ? trip.members.first.id : payerMemberId,
                      decoration: const InputDecoration(labelText: 'Thành viên thanh toán / góp *'),
                      items: trip.members.map((m) {
                        return DropdownMenuItem(value: m.id, child: Text(m.name));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => payerMemberId = val);
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: recipientCtrl,
                    decoration: const InputDecoration(labelText: 'Người nhận tiền / Nhà cung cấp *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền (VNĐ) *',
                      suffixText: 'VNĐ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    value: selectedExpenseId,
                    decoration: const InputDecoration(labelText: 'Gắn với hóa đơn (Tùy chọn)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Không gắn hóa đơn')),
                      ...trip.expenses.map((e) {
                        return DropdownMenuItem(
                          value: e.id,
                          child: Text(e.title, overflow: TextOverflow.ellipsis),
                        );
                      }),
                    ],
                    onChanged: (val) => setDialogState(() => selectedExpenseId = val),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(labelText: 'Ghi chú nội dung chi tiêu'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = CurrencyFormatter.parseVnd(amountCtrl.text);
                if (amount != null && amount > 0) {
                  vm.addCashTransaction(
                    type: type,
                    payerMemberId: payerMemberId,
                    recipient: recipientCtrl.text.trim(),
                    amount: amount,
                    note: noteCtrl.text.trim().isEmpty ? type.displayName : noteCtrl.text.trim(),
                    expenseId: selectedExpenseId,
                  );
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Ghi nhận'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LedgerFundViewModel>();
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card & Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sổ Thực Tế & Quản Lý Dòng Tiền',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trip.isLedgerInitialized
                            ? 'Sổ thực tế độc lập đã khởi tạo (gắn với kịch bản: ${trip.ledgerScenarioId ?? "Mặc định"})'
                            : 'Chưa khởi tạo sổ thực tế độc lập.',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (!trip.isLedgerInitialized)
                    ElevatedButton.icon(
                      onPressed: _showInitializeLedgerDialog,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Khởi tạo Sổ thực tế'),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Metric Highlights
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildFundHighlight(
                    title: 'Tiền mặt thực tế tồn Quỹ',
                    value: CurrencyFormatter.formatVnd(vm.fundCashBalance),
                    subtitle: 'Thủ quỹ đang trực tiếp quản lý',
                    color: AppColors.success,
                    icon: Icons.savings_outlined,
                  ),
                  _buildFundHighlight(
                    title: 'Tổng chi phí thực tế',
                    value: CurrencyFormatter.formatVnd(vm.totalActualCost),
                    subtitle: '${vm.unenteredExpensesCount} hóa đơn chưa nhập giá',
                    color: AppColors.primary,
                    icon: Icons.receipt_long_outlined,
                  ),
                  _buildFundHighlight(
                    title: 'Tổng chi dự tính mốc',
                    value: CurrencyFormatter.formatVnd(vm.totalEstimatedCost),
                    subtitle: 'Đối chiếu chênh lệch song song',
                    color: AppColors.secondary,
                    icon: Icons.analytics_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 1: Invoices & Actual Price Table
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bảng Kê Hóa Đơn & Giá Thực Tế',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  if (vm.unenteredExpensesCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warningContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Còn ${vm.unenteredExpensesCount} khoản chưa nhập giá thực tế',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onWarningContainer,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                    columns: const [
                      DataColumn(label: Text('Khoản chi', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Chặng', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Giá dự tính', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Giá thực tế', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Đã chi trả', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Còn thiếu', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.w700))),
                    ],
                    rows: trip.expenses.map((exp) {
                      final paid = vm.getPaidAmountForExpense(exp.id);
                      final remaining = vm.getRemainingAmountForExpense(exp);
                      final isNullPrice = exp.actualPrice == null;
                      final isZeroPrice = exp.actualPrice == 0;

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Text(exp.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                if (exp.isCommitted) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.warningContainer,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: const Text('Cam kết',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          DataCell(Text(trip.getStage(exp.stageId)?.name ?? exp.stageId)),
                          DataCell(Text(CurrencyFormatter.formatVnd(
                              exp.estimatedTotal > 0 ? exp.estimatedTotal : exp.unitPrice))),
                          DataCell(
                            isNullPrice
                                ? const Text('Chưa nhập',
                                    style: TextStyle(
                                        color: AppColors.warning, fontWeight: FontWeight.w600))
                                : (isZeroPrice
                                    ? const Text('0 đ (Không phát sinh)',
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontStyle: FontStyle.italic))
                                    : Text(CurrencyFormatter.formatVnd(exp.actualPrice),
                                        style: const TextStyle(fontWeight: FontWeight.w700))),
                          ),
                          DataCell(Text(CurrencyFormatter.formatVnd(paid))),
                          DataCell(
                            remaining > 0
                                ? Text(CurrencyFormatter.formatVnd(remaining),
                                    style: const TextStyle(
                                        color: AppColors.error, fontWeight: FontWeight.w600))
                                : const Text('Đã đủ (0 đ)',
                                    style: TextStyle(color: AppColors.success)),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit_note, size: 20, color: AppColors.primary),
                              tooltip: 'Nhập giá thực tế',
                              onPressed: () => _showEditActualPriceDialog(exp),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Section 2: Cash Flow Transactions
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  const Text(
                    'Lịch Sử Dòng Tiền (Thu / Chi Quỹ & Ứng Tiền)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddTransactionDialog,
                    icon: const Icon(Icons.add_card, size: 16),
                    label: const Text('Ghi nhận giao dịch'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Card(
                child: vm.transactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Chưa có giao dịch quỹ nào được ghi nhận.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vm.transactions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tx = vm.transactions[index];
                          final payerName = tx.payerMemberId == 'fund'
                              ? 'Quỹ chung'
                              : (trip.getMember(tx.payerMemberId)?.name ?? tx.payerMemberId);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: tx.type == CashTransactionType.fundContribution
                                  ? AppColors.successContainer
                                  : (tx.type == CashTransactionType.outOfPocketPayment
                                      ? AppColors.secondaryContainer
                                      : AppColors.primaryContainer),
                              child: Icon(
                                tx.type == CashTransactionType.fundContribution
                                    ? Icons.arrow_downward
                                    : (tx.type == CashTransactionType.outOfPocketPayment
                                        ? Icons.person_pin
                                        : Icons.arrow_upward),
                                size: 18,
                                color: tx.type == CashTransactionType.fundContribution
                                    ? AppColors.success
                                    : (tx.type == CashTransactionType.outOfPocketPayment
                                        ? AppColors.secondary
                                        : AppColors.primary),
                              ),
                            ),
                            title: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  tx.type.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '$payerName ➔ ${tx.recipient}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${tx.note} • ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  CurrencyFormatter.formatVnd(tx.amount),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  tooltip: 'Xóa giao dịch',
                                  onPressed: () => vm.deleteCashTransaction(tx.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFundHighlight({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
