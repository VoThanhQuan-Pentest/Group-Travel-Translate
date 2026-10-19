import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/trip.dart';
import '../../domain/models/expense.dart';
import '../../viewmodels/stages_expenses_viewmodel.dart';
import '../widgets/cost_bearer_checkbox.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/unsaved_changes_dialog.dart';
import 'package:uuid/uuid.dart';

class StagesExpensesScreen extends StatefulWidget {
  final String tripId;

  const StagesExpensesScreen({super.key, required this.tripId});

  @override
  State<StagesExpensesScreen> createState() => _StagesExpensesScreenState();
}

class _StagesExpensesScreenState extends State<StagesExpensesScreen> {
  String? _selectedStageId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StagesExpensesViewModel>().loadTrip(widget.tripId);
    });
  }

  void _showAddStageDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm chặng / buổi mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên chặng *',
                hintText: 'Ví dụ: Buổi tối (Ăn tối & Dạo chợ)',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Mô tả (Tùy chọn)',
                hintText: 'Ví dụ: Ăn lẩu gà lá é và cà phê',
              ),
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
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                context.read<StagesExpensesViewModel>().addStage(
                      name: name,
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _openExpenseFormDialog({Expense? initialExpense, required String stageId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ExpenseFormDialog(
        tripId: widget.tripId,
        defaultStageId: stageId,
        initialExpense: initialExpense,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StagesExpensesViewModel>();
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

    final stages = vm.stages;
    final activeStageId = _selectedStageId ?? (stages.isNotEmpty ? stages.first.id : null);
    final activeExpenses = activeStageId != null ? vm.getExpensesForStage(activeStageId) : [];

    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar: Stages list with Reorder
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: AppColors.outlineVariant)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Các chặng / Buổi',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        tooltip: 'Thêm chặng mới',
                        onPressed: _showAddStageDialog,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: stages.isEmpty
                      ? const Center(
                          child: Text(
                            'Chưa có chặng nào.\nBấm + để thêm.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        )
                      : ReorderableListView.builder(
                          itemCount: stages.length,
                          onReorder: (oldIndex, newIndex) =>
                              vm.reorderStages(oldIndex, newIndex),
                          itemBuilder: (context, index) {
                            final stage = stages[index];
                            final isSelected = stage.id == activeStageId;
                            final expenseCount = vm.getExpensesForStage(stage.id).length;

                            return ListTile(
                              key: ValueKey(stage.id),
                              selected: isSelected,
                              selectedTileColor: AppColors.primaryContainer.withOpacity(0.5),
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                                child: Text(
                                  '${stage.order}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              title: Text(
                                stage.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 13.5,
                                  color: isSelected
                                      ? AppColors.primaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                '$expenseCount khoản chi',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                              trailing: const Icon(Icons.drag_handle,
                                  size: 18, color: AppColors.textMuted),
                              onTap: () {
                                setState(() {
                                  _selectedStageId = stage.id;
                                });
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Right Content: Expenses for the selected stage
          Expanded(
            child: activeStageId == null
                ? EmptyStateView(
                    icon: Icons.flag_outlined,
                    title: 'Chưa có chặng nào được chọn',
                    description: 'Vui lòng thêm hoặc chọn một chặng ở thanh bên trái.',
                    actionLabel: 'Thêm chặng',
                    onAction: _showAddStageDialog,
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stage header & Add Expense action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.getStage(activeStageId)?.name ?? 'Chặng',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (trip.getStage(activeStageId)?.description != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    trip.getStage(activeStageId)!.description!,
                                    style: const TextStyle(
                                        fontSize: 12.5, color: AppColors.textSecondary),
                                  ),
                                ],
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _openExpenseFormDialog(stageId: activeStageId),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Thêm khoản chi'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Expenses List
                        Expanded(
                          child: activeExpenses.isEmpty
                              ? EmptyStateView(
                                  icon: Icons.receipt_long_outlined,
                                  title: 'Chặng này chưa có khoản chi nào',
                                  description:
                                      'Nhấn nút "Thêm khoản chi" để bắt đầu ghi nhận các chi phí của chặng.',
                                  actionLabel: 'Thêm khoản chi ngay',
                                  onAction: () =>
                                      _openExpenseFormDialog(stageId: activeStageId),
                                )
                              : ListView.separated(
                                  itemCount: activeExpenses.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final exp = activeExpenses[index];
                                    final bearersCount = vm.getEffectiveBearersCount(exp);
                                    final hasWarning = vm.hasNoBearersWarning(exp);

                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        exp.title,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w700,
                                                          color: AppColors.textPrimary,
                                                        ),
                                                      ),
                                                      if (exp.isCommitted) ...[
                                                        const SizedBox(width: 8),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.warningContainer,
                                                            borderRadius:
                                                                BorderRadius.circular(4),
                                                          ),
                                                          child: const Text(
                                                            'Cam kết',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w700,
                                                              color: AppColors.onWarningContainer,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  exp.calcMode == ExpenseCalcMode.perPersonUnitPrice
                                                      ? '${CurrencyFormatter.formatVnd(exp.unitPrice)} / người'
                                                      : CurrencyFormatter.formatVnd(
                                                          exp.estimatedTotal),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  icon: const Icon(Icons.edit_outlined,
                                                      size: 18),
                                                  tooltip: 'Chỉnh sửa khoản chi',
                                                  onPressed: () => _openExpenseFormDialog(
                                                    initialExpense: exp,
                                                    stageId: activeStageId,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline,
                                                      size: 18, color: Colors.red),
                                                  tooltip: 'Xóa khoản chi',
                                                  onPressed: () =>
                                                      vm.deleteExpense(exp.id),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.surfaceVariant,
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    exp.calcMode.displayName,
                                                    style: const TextStyle(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Người chịu tiền: $bearersCount thành viên',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: hasWarning
                                                        ? AppColors.error
                                                        : AppColors.textSecondary,
                                                    fontWeight: hasWarning
                                                        ? FontWeight.w700
                                                        : FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (hasWarning) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.errorContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.error_outline,
                                                        size: 16,
                                                        color: AppColors.onErrorContainer),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      'Cảnh báo: Khoản chi có số tiền > 0 nhưng chưa có ai chịu tiền!',
                                                      style: TextStyle(
                                                        fontSize: 11.5,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.onErrorContainer,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            if (exp.calcMode == ExpenseCalcMode.itemized &&
                                                exp.lineItems.isNotEmpty) ...[
                                              const SizedBox(height: 10),
                                              const Divider(height: 1),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 4,
                                                children: exp.lineItems.map((item) {
                                                  final bearer =
                                                      trip.getMember(item.bearerMemberId);
                                                  return Chip(
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    label: Text(
                                                      '${item.name} (${CurrencyFormatter.formatVnd(item.unitPrice)}) - ${bearer?.name ?? "?"}',
                                                      style: const TextStyle(
                                                          fontSize: 11),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic Form Dialog for adding/editing an expense supporting all 4 calculation modes
class _ExpenseFormDialog extends StatefulWidget {
  final String tripId;
  final String defaultStageId;
  final Expense? initialExpense;

  const _ExpenseFormDialog({
    required this.tripId,
    required this.defaultStageId,
    this.initialExpense,
  });

  @override
  State<_ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<_ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isDirty = false;

  late String _title;
  String? _description;
  late String _stageId;
  late List<String> _stageIds;
  late ExpenseCalcMode _calcMode;
  late int _estimatedTotal;
  late int _unitPrice;
  late bool _isCommitted;

  late Map<String, CostBearerStatus> _costBearers;
  late List<LineItem> _lineItems;
  late int _shippingFee;
  late int _discountFee;
  late ModifierAllocationRule _shippingRule;
  late ModifierAllocationRule _discountRule;

  @override
  void initState() {
    super.initState();
    final init = widget.initialExpense;
    _title = init?.title ?? '';
    _description = init?.description;
    _stageId = init?.stageId ?? widget.defaultStageId;
    _stageIds = List<String>.from(
      init?.stageIds.isNotEmpty == true
          ? init!.stageIds
          : (init?.stageId != null ? [init!.stageId] : [widget.defaultStageId]),
    );
    _calcMode = init?.calcMode ?? ExpenseCalcMode.fixedEqual;
    _estimatedTotal = init?.estimatedTotal ?? 0;
    _unitPrice = init?.unitPrice ?? 0;
    _isCommitted = init?.isCommitted ?? false;
    _costBearers = Map<String, CostBearerStatus>.from(init?.costBearers ?? {});
    _lineItems = List<LineItem>.from(init?.lineItems ?? []);
    _shippingFee = init?.shippingFee ?? 0;
    _discountFee = init?.discountFee ?? 0;
    _shippingRule = init?.shippingRule ?? ModifierAllocationRule.equalSplit;
    _discountRule = init?.discountRule ?? ModifierAllocationRule.proportionalToSubtotal;
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<void> _handleClose() async {
    if (_isDirty) {
      final shouldLeave = await UnsavedChangesDialog.show(context);
      if (!shouldLeave) return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  Expense _buildCurrentExpense() {
    return Expense(
      id: widget.initialExpense?.id ?? 'exp_${const Uuid().v4()}',
      stageId: _stageId,
      stageIds: _stageIds,
      title: _title.trim(),
      description: _description?.trim(),
      calcMode: _calcMode,
      estimatedTotal: _estimatedTotal,
      unitPrice: _unitPrice,
      isCommitted: _isCommitted,
      costBearers: _costBearers,
      lineItems: _lineItems,
      shippingFee: _shippingFee,
      discountFee: _discountFee,
      shippingRule: _shippingRule,
      discountRule: _discountRule,
      actualPrice: widget.initialExpense?.actualPrice,
    );
  }

  void _resetBearersToInherited() {
    setState(() {
      _costBearers.clear();
      _markDirty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StagesExpensesViewModel>();
    final trip = vm.trip!;
    final previewCosts = vm.previewExpenseCost(_buildCurrentExpense());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialExpense == null
                        ? 'Thêm khoản chi mới'
                        : 'Chỉnh sửa khoản chi',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _handleClose,
                  ),
                ],
              ),
              const Divider(height: 16),

              // Form content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Stage
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: _title,
                                decoration: const InputDecoration(
                                  labelText: 'Tên khoản chi *',
                                  hintText: 'Ví dụ: Thuê xe, Ăn trưa...',
                                ),
                                onChanged: (val) {
                                  _title = val;
                                  _markDirty();
                                },
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? 'Vui lòng nhập tên'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: _stageId,
                                decoration: const InputDecoration(labelText: 'Chặng gắn'),
                                items: trip.stages.map((s) {
                                  return DropdownMenuItem(
                                    value: s.id,
                                    child: Text(s.name, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _stageId = val);
                                    _markDirty();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Calculation Mode Selector (4 modes)
                        const Text(
                          'Phương thức tính chi phí:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ExpenseCalcMode.values.map((mode) {
                            final isSelected = _calcMode == mode;
                            return ChoiceChip(
                              label: Text(mode.displayName),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _calcMode = mode);
                                  _markDirty();
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Dynamic inputs depending on mode
                        if (_calcMode == ExpenseCalcMode.fixedEqual ||
                            _calcMode == ExpenseCalcMode.fixedStageRatio) ...[
                          TextFormField(
                            initialValue: _estimatedTotal > 0 ? '$_estimatedTotal' : '',
                            decoration: const InputDecoration(
                              labelText: 'Tổng số tiền dự tính (VNĐ) *',
                              hintText: 'Ví dụ: 400000',
                              suffixText: 'VNĐ',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              _estimatedTotal = CurrencyFormatter.parseVnd(val) ?? 0;
                              _markDirty();
                            },
                            validator: (val) {
                              final p = CurrencyFormatter.parseVnd(val);
                              if (p == null || p <= 0) return 'Vui lòng nhập số tiền > 0';
                              return null;
                            },
                          ),
                          if (_calcMode == ExpenseCalcMode.fixedStageRatio) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Chọn các chặng áp dụng phân bổ (chia theo tỷ lệ số chặng tham gia):',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: trip.stages.map((stg) {
                                final isSelected = _stageIds.contains(stg.id);
                                return FilterChip(
                                  label: Text(stg.name),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    setState(() {
                                      if (val) {
                                        if (!_stageIds.contains(stg.id)) _stageIds.add(stg.id);
                                      } else {
                                        if (_stageIds.length > 1) _stageIds.remove(stg.id);
                                      }
                                      _markDirty();
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ] else if (_calcMode == ExpenseCalcMode.perPersonUnitPrice) ...[
                          TextFormField(
                            initialValue: _unitPrice > 0 ? '$_unitPrice' : '',
                            decoration: const InputDecoration(
                              labelText: 'Đơn giá / người (VNĐ) *',
                              hintText: 'Ví dụ: 60000',
                              suffixText: 'VNĐ/người',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              _unitPrice = CurrencyFormatter.parseVnd(val) ?? 0;
                              _markDirty();
                            },
                            validator: (val) {
                              final p = CurrencyFormatter.parseVnd(val);
                              if (p == null || p <= 0) return 'Vui lòng nhập đơn giá > 0';
                              return null;
                            },
                          ),
                        ] else if (_calcMode == ExpenseCalcMode.itemized) ...[
                          _buildItemizedSection(trip),
                        ],
                        const SizedBox(height: 16),

                        // Committed Expense Checkbox
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Khoản chi đã cam kết trước (Committed Expense)',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Thành viên chuyển sang Nghỉ hoặc Về sớm vẫn phải chịu khoản này (trừ khi được miễn thủ công).',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                          value: _isCommitted,
                          onChanged: (val) {
                            setState(() => _isCommitted = val ?? false);
                            _markDirty();
                          },
                        ),
                        const SizedBox(height: 14),

                        // Cost Bearers Selection (3-state Checkbox)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Người chịu tiền:',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            TextButton.icon(
                              onPressed: _resetBearersToInherited,
                              icon: const Icon(Icons.restore, size: 14),
                              label: const Text('Khôi phục về kế thừa',
                                  style: TextStyle(fontSize: 11.5)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: trip.members.map((member) {
                            final status = _costBearers[member.id] ?? CostBearerStatus.inherited;
                            final sc = trip.activeScenario;
                            final isPresent = sc?.isMemberPresentInStage(_stageId, member.id) ?? true;

                            return CostBearerCheckbox(
                              memberName: member.name,
                              isPresentInStage: isPresent,
                              status: status,
                              onChanged: (newStatus) {
                                setState(() {
                                  _costBearers[member.id] = newStatus;
                                  _markDirty();
                                });
                              },
                              onResetToInherited: () {
                                setState(() {
                                  _costBearers.remove(member.id);
                                  _markDirty();
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Instant preview per member
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tạm tính chi phí từng người trong khoản này (Kịch bản hiện tại):',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: trip.members.map((m) {
                                  final amount = previewCosts[m.id] ?? 0;
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${m.name}: ',
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        CurrencyFormatter.formatVnd(amount),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: amount > 0
                                              ? AppColors.primary
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleClose,
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final exp = _buildCurrentExpense();
                        final success = await vm.saveExpense(exp);
                        if (success && mounted) {
                          Navigator.of(context).pop();
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(vm.errorMessage ?? 'Lưu khoản chi thất bại'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Lưu khoản chi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemizedSection(Trip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Danh sách món ăn / đồ uống:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: () => _showAddLineItemDialog(trip),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Thêm món'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (_lineItems.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Chưa có món nào. Nhấn + Thêm món để tạo.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _lineItems.length,
            itemBuilder: (ctx, i) {
              final item = _lineItems[i];
              final bearer = trip.getMember(item.bearerMemberId);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${item.name} (${item.quantity}x)'),
                subtitle: Text('Người mua: ${bearer?.name ?? "Chưa rõ"}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.formatVnd(item.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _lineItems.removeAt(i);
                          _markDirty();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _shippingFee > 0 ? '$_shippingFee' : '',
                decoration: const InputDecoration(
                  labelText: 'Phí Ship (VNĐ)',
                  hintText: 'Ví dụ: 20000',
                  suffixText: 'VNĐ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  _shippingFee = CurrencyFormatter.parseVnd(val) ?? 0;
                  _markDirty();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<ModifierAllocationRule>(
                value: _shippingRule,
                decoration: const InputDecoration(labelText: 'Chia ship'),
                items: ModifierAllocationRule.values.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r.displayName, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _shippingRule = val);
                    _markDirty();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _discountFee > 0 ? '$_discountFee' : '',
                decoration: const InputDecoration(
                  labelText: 'Giảm giá (VNĐ)',
                  hintText: 'Ví dụ: 10000',
                  suffixText: 'VNĐ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  _discountFee = CurrencyFormatter.parseVnd(val) ?? 0;
                  _markDirty();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<ModifierAllocationRule>(
                value: _discountRule,
                decoration: const InputDecoration(labelText: 'Chia giảm giá'),
                items: ModifierAllocationRule.values.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r.displayName, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _discountRule = val);
                    _markDirty();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddLineItemDialog(Trip trip) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    String bearerId = trip.members.first.id;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm món mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Tên món *'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: 'Đơn giá *'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: qtyCtrl,
                    decoration: const InputDecoration(labelText: 'Số lượng'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: bearerId,
              decoration: const InputDecoration(labelText: 'Người đặt món'),
              items: trip.members.map((m) {
                return DropdownMenuItem(value: m.id, child: Text(m.name));
              }).toList(),
              onChanged: (val) {
                if (val != null) bearerId = val;
              },
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
              final name = nameCtrl.text.trim();
              final price = CurrencyFormatter.parseVnd(priceCtrl.text) ?? 0;
              final qty = int.tryParse(qtyCtrl.text) ?? 1;

              if (name.isNotEmpty && price > 0) {
                setState(() {
                  _lineItems.add(LineItem(
                    id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    quantity: qty,
                    unitPrice: price,
                    bearerMemberId: bearerId,
                  ));
                  _markDirty();
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}
