import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_layout.dart';
import '../../viewmodels/trip_list_viewmodel.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/sample_data_banner.dart';
import '../controllers/trip_session_controller.dart';
import '../widgets/scenario_picker_dialog.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripListViewModel>().loadTrips();
    });
  }

  void _showCreateTripDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final treasurerCtrl = TextEditingController(text: 'An');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo chuyến đi mới'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên chuyến đi *',
                    hintText: 'Ví dụ: Dã ngoại Vũng Tàu 2N1Đ',
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Vui lòng nhập tên chuyến' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: treasurerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên Thủ quỹ đại diện *',
                    hintText: 'Ví dụ: An',
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Vui lòng nhập tên thủ quỹ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả ngắn (Tùy chọn)',
                    hintText: 'Ví dụ: Đi cùng hội bạn thân',
                  ),
                  maxLines: 2,
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
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final vm = context.read<TripListViewModel>();
                final created = await vm.createTrip(
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  defaultTreasurerName: treasurerCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (created != null && mounted) {
                  context.go('/trips/${created.id}/overview');
                }
              }
            },
            child: const Text('Tạo chuyến'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(String tripId, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi tên chuyến đi'),
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
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty) {
                context.read<TripListViewModel>().renameTrip(tripId, newName);
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
    final vm = context.watch<TripListViewModel>();
    final isDesktop = ResponsiveLayout.isExpanded(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ Kiểm Kê Chi Tiêu Nhóm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'Nhập file sao lưu (.grouptrip.json)',
            onPressed: () {
              if (vm.trips.isNotEmpty) {
                context.go('/trips/${vm.trips.first.id}/reports');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng tạo chuyến đi để truy cập phân hệ Backup & Báo cáo')),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: SampleDataBanner(),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.isEmpty
              ? EmptyStateView(
                  icon: Icons.luggage_outlined,
                  title: 'Chưa có chuyến đi nào',
                  description:
                      'Bắt đầu bằng cách tạo chuyến đi đầu tiên hoặc nhập dữ liệu từ file sao lưu.',
                  actionLabel: 'Tạo chuyến đi mới',
                  onAction: _showCreateTripDialog,
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Danh sách chuyến đi (${vm.trips.length})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _showCreateTripDialog,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Tạo chuyến đi'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isDesktop ? 2 : 1,
                                mainAxisExtent: 180,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: vm.trips.length,
                              itemBuilder: (context, index) {
                                final trip = vm.trips[index];
                                final isSample = trip.metadata['isSampleData'] == true;

                                return Card(
                                  elevation: 0,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      final session = context.read<TripSessionController>();
                                      await session.openTrip(trip.id);
                                      if (!context.mounted) return;
                                      final chosen = await ScenarioPickerDialog.show(
                                        context,
                                        trip: session.trip ?? trip,
                                        initialSelectedId: trip.activeScenarioId,
                                      );
                                      if (chosen != null && context.mounted) {
                                        context.go('/trips/${trip.id}/overview');
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  trip.name,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isSample) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryContainer,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'Dữ liệu mẫu',
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.onPrimaryContainer,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              PopupMenuButton<String>(
                                                icon: const Icon(Icons.more_vert, size: 20),
                                                onSelected: (val) {
                                                  if (val == 'rename') {
                                                    _showRenameDialog(trip.id, trip.name);
                                                  } else if (val == 'duplicate') {
                                                    vm.duplicateTrip(trip.id);
                                                  } else if (val == 'delete') {
                                                    vm.deleteTrip(trip.id);
                                                  }
                                                },
                                                itemBuilder: (ctx) => [
                                                  const PopupMenuItem(
                                                    value: 'rename',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit_outlined, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Đổi tên'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'duplicate',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.copy_outlined, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Nhân bản'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete_outline,
                                                            size: 18, color: Colors.red),
                                                        SizedBox(width: 8),
                                                        Text('Xóa',
                                                            style: TextStyle(color: Colors.red)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            trip.description ?? 'Không có mô tả bổ sung.',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: AppColors.textSecondary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          const Divider(height: 12),
                                          Wrap(
                                            alignment: WrapAlignment.spaceBetween,
                                            runSpacing: 4,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              Wrap(
                                                spacing: 12,
                                                children: [
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.group_outlined,
                                                          size: 16, color: AppColors.textSecondary),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${trip.members.length} người',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors.textSecondary),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.flag_outlined,
                                                          size: 16, color: AppColors.textSecondary),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${trip.stages.length} chặng',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors.textSecondary),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                'Thủ quỹ: ${trip.treasurer?.name ?? "Chưa có"}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
                ),
    );
  }
}
