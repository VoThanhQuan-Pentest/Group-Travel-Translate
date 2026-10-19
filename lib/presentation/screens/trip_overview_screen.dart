import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/responsive_layout.dart';
import '../../viewmodels/trip_overview_viewmodel.dart';
import '../controllers/trip_session_controller.dart';
import '../widgets/batch_member_dialog.dart';

class TripOverviewScreen extends StatefulWidget {
  final String tripId;

  const TripOverviewScreen({super.key, required this.tripId});

  @override
  State<TripOverviewScreen> createState() => _TripOverviewScreenState();
}

class _TripOverviewScreenState extends State<TripOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripSessionController>().openTrip(widget.tripId);
      context.read<TripOverviewViewModel>().loadTrip(widget.tripId);
    });
  }

  void _showAddMemberDialog() {
    BatchMemberDialog.show(context, tripId: widget.tripId);
  }

  void _showRenameMemberDialog(String memberId, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa tên thành viên'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Tên mới'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                context.read<TripSessionController>().renameMember(memberId, name);
                context.read<TripOverviewViewModel>().renameMember(memberId, name);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<TripSessionController>();
    final vm = context.watch<TripOverviewViewModel>();
    final trip = session.trip ?? vm.trip;

    if (session.isLoading && trip == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (trip == null) {
      return Center(
        child: Text(
          session.errorMessage ?? vm.errorMessage ?? 'Không tìm thấy thông tin chuyến đi.',
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    final isDesktop = ResponsiveLayout.isExpanded(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Header & Scenario Selector
              Wrap(
                spacing: 16,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (trip.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          trip.description!,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Dropdown chọn kịch bản hoạt động
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: trip.activeScenarioId,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                          onChanged: (scId) {
                            if (scId != null) {
                              vm.setActiveScenario(scId);
                            }
                          },
                          items: trip.scenarios.map((sc) {
                            return DropdownMenuItem(
                              value: sc.id,
                              child: Text(
                                'Kịch bản: ${sc.name}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Cards (Tổng dự tính, Tổng thực tế, Độ lệch)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 600;
                  final cardWidth = isDesktop
                      ? (constraints.maxWidth - 32) / 3
                      : (isCompact ? constraints.maxWidth : (constraints.maxWidth - 16) / 2);

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildMetricCard(
                        title: 'Tổng dự tính (Kịch bản)',
                        value: CurrencyFormatter.formatVnd(vm.totalEstimatedCost),
                        subtitle: 'Theo kịch bản: ${trip.activeScenario?.name ?? "Mặc định"}',
                        icon: Icons.calculate_outlined,
                        color: AppColors.primary,
                        width: cardWidth,
                      ),
                      _buildMetricCard(
                        title: 'Tổng thực tế (Đã nhập)',
                        value: CurrencyFormatter.formatVnd(vm.totalActualCost),
                        subtitle: trip.isLedgerInitialized
                            ? 'Từ sổ thực tế đã kích hoạt'
                            : 'Chưa kích hoạt sổ thực tế',
                        icon: Icons.receipt_long_outlined,
                        color: AppColors.secondary,
                        width: cardWidth,
                      ),
                      _buildMetricCard(
                        title: 'Độ lệch (Chênh lệch)',
                        value: CurrencyFormatter.formatSignedVnd(vm.costVariance),
                        subtitle: vm.costVariance == 0
                            ? 'Khớp hoàn toàn với dự toán'
                            : (vm.costVariance > 0
                                ? 'Vượt dự toán ${CurrencyFormatter.formatVnd(vm.costVariance)}'
                                : 'Tiết kiệm ${CurrencyFormatter.formatVnd(-vm.costVariance)}'),
                        icon: Icons.compare_arrows_outlined,
                        color: vm.costVariance > 0
                            ? AppColors.error
                            : (vm.costVariance < 0 ? AppColors.success : AppColors.info),
                        width: cardWidth,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Quick Actions Bar (Điều hướng 5 phân hệ)
              const Text(
                'Phân hệ chức năng chính',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildQuickNavButton(
                    title: 'Chặng & Khoản chi',
                    desc: '${trip.stages.length} chặng • ${trip.expenses.length} khoản chi',
                    icon: Icons.receipt_long,
                    route: '/trips/${widget.tripId}/stages',
                  ),
                  _buildQuickNavButton(
                    title: 'Kịch bản & So sánh',
                    desc: '${trip.scenarios.length} kịch bản • So sánh chi phí',
                    icon: Icons.alt_route,
                    route: '/trips/${widget.tripId}/scenarios',
                  ),
                  _buildQuickNavButton(
                    title: 'Sổ thực tế & Quỹ',
                    desc: 'Tồn quỹ: ${CurrencyFormatter.formatVnd(vm.fundCashBalance)}',
                    icon: Icons.account_balance_wallet,
                    route: '/trips/${widget.tripId}/ledger',
                  ),
                  _buildQuickNavButton(
                    title: 'Quyết toán cuối chuyến',
                    desc: 'Công nợ & Chuyển khoản gọn',
                    icon: Icons.price_check,
                    route: '/trips/${widget.tripId}/settlement',
                  ),
                  _buildQuickNavButton(
                    title: 'Xem trước Báo cáo & Sao lưu',
                    desc: 'Excel, PDF & Export JSON',
                    icon: Icons.print,
                    route: '/trips/${widget.tripId}/reports',
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Member Management Section
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      const Text(
                        'Danh sách thành viên',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${trip.members.length} người',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: _showAddMemberDialog,
                    icon: const Icon(Icons.person_add_alt_1, size: 16),
                    label: const Text('Thêm thành viên'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trip.members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final member = trip.members[index];
                    final isTreasurer = member.id == trip.treasurerId;

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: isTreasurer
                            ? AppColors.primaryContainer
                            : AppColors.surfaceVariant,
                        child: Text(
                          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isTreasurer
                                ? AppColors.onPrimaryContainer
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isTreasurer) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Thủ quỹ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                          if (!member.isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Đã ngừng',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        'Thứ tự ưu tiên xử lý đồng lẻ: Hạng ${index + 1}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        tooltip: 'Tùy chọn',
                        onSelected: (action) {
                          if (action == 'treasurer') {
                            session.setTreasurer(member.id);
                            vm.setTreasurer(member.id);
                          } else if (action == 'rename') {
                            _showRenameMemberDialog(member.id, member.name);
                          } else if (action == 'delete') {
                            session.removeOrRetireMember(member.id);
                            vm.removeMember(member.id);
                          }
                        },
                        itemBuilder: (context) => [
                          if (!isTreasurer)
                            const PopupMenuItem(
                              value: 'treasurer',
                              child: Row(
                                children: [
                                  Icon(Icons.account_balance_wallet_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Đặt làm Thủ quỹ'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Sửa tên'),
                              ],
                            ),
                          ),
                          if (!isTreasurer && trip.members.length > 2)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Xóa thành viên', style: TextStyle(color: Colors.red)),
                                ],
                              ),
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 20, color: color),
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
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavButton({
    required String title,
    required String desc,
    required IconData icon,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
