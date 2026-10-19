import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/trip.dart';
import '../controllers/trip_session_controller.dart';

class ScenarioPickerDialog extends StatefulWidget {
  final Trip trip;
  final String? initialSelectedId;
  final ValueChanged<String>? onScenarioSelected;

  const ScenarioPickerDialog({
    super.key,
    required this.trip,
    this.initialSelectedId,
    this.onScenarioSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    required Trip trip,
    String? initialSelectedId,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ScenarioPickerDialog(
        trip: trip,
        initialSelectedId: initialSelectedId,
      ),
    );
  }

  @override
  State<ScenarioPickerDialog> createState() => _ScenarioPickerDialogState();
}

class _ScenarioPickerDialogState extends State<ScenarioPickerDialog> {
  late String _selectedScenarioId;

  @override
  void initState() {
    super.initState();
    _selectedScenarioId = widget.initialSelectedId ??
        widget.trip.activeScenarioId;
    if (!widget.trip.scenarios.any((s) => s.id == _selectedScenarioId)) {
      _selectedScenarioId = widget.trip.scenarios.isNotEmpty
          ? widget.trip.scenarios.first.id
          : '';
    }
  }

  void _showCreateScenarioDialog(TripSessionController session) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo kịch bản dự toán mới'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Tên kịch bản *',
            hintText: 'Ví dụ: Kịch bản đi xe riêng, Kịch bản không ăn trưa...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                final created = await session.createScenario(name: name);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (created != null && mounted) {
                  setState(() {
                    _selectedScenarioId = created.id;
                  });
                }
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showDuplicateScenarioDialog(
    TripSessionController session,
    Scenario scenario,
  ) {
    final ctrl = TextEditingController(text: '${scenario.name} (Bản sao)');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sao chép thành kịch bản độc lập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bản sao sẽ giữ toàn bộ phân bổ chi phí, danh sách món và điểm danh hiện tại mà không bị ảnh hưởng khi bản gốc thay đổi:',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Tên kịch bản sao chép *',
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
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                final copy = await session.duplicateScenario(
                  sourceScenarioId: scenario.id,
                  newName: name,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (copy != null && mounted) {
                  setState(() {
                    _selectedScenarioId = copy.id;
                  });
                }
              }
            },
            child: const Text('Sao chép độc lập'),
          ),
        ],
      ),
    );
  }

  void _showRenameScenarioDialog(
    TripSessionController session,
    Scenario scenario,
  ) {
    final ctrl = TextEditingController(text: scenario.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi tên kịch bản'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Tên kịch bản mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                await session.renameScenario(scenario.id, name);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) setState(() {});
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteScenarioDialog(
    TripSessionController session,
    Scenario scenario,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa kịch bản'),
        content: Text(
          'Bạn có chắc muốn xóa kịch bản "${scenario.name}" không? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final success = await session.deleteScenario(scenario.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (success && mounted) {
                setState(() {
                  _selectedScenarioId = session.selectedScenarioId ??
                      (session.trip?.scenarios.first.id ?? '');
                });
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<TripSessionController>();
    final trip = session.trip ?? widget.trip;
    final scenarios = trip.scenarios;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Icons.alt_route, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Chọn kịch bản',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Tạo mới', style: TextStyle(fontSize: 11)),
              onPressed: () => _showCreateScenarioDialog(session),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chuyến đi: ${trip.name}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                'Chọn một kịch bản để xem toàn bộ Tổng quan, Chặng & Chi, Sổ Quỹ và Báo cáo theo đúng kịch bản này:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...scenarios.map((sc) {
                final isSelected = sc.id == _selectedScenarioId;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: isSelected ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _selectedScenarioId = sc.id;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: sc.id,
                            groupValue: _selectedScenarioId,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedScenarioId = val;
                                });
                              }
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        sc.name,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          fontSize: 14,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (sc.isBaseline)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        margin: const EdgeInsets.only(right: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Mốc chuẩn',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.onSecondaryContainer,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (sc.description != null &&
                                    sc.description!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    sc.description!,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (val) {
                              if (val == 'dup') {
                                _showDuplicateScenarioDialog(session, sc);
                              } else if (val == 'rename') {
                                _showRenameScenarioDialog(session, sc);
                              } else if (val == 'delete') {
                                _showDeleteScenarioDialog(session, sc);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'dup',
                                child: Text('Sao chép độc lập'),
                              ),
                              const PopupMenuItem(
                                value: 'rename',
                                child: Text('Đổi tên'),
                              ),
                              if (scenarios.length > 1)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa kịch bản',
                                      style: TextStyle(color: AppColors.error)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Mở kịch bản này'),
          onPressed: () {
            session.selectScenario(_selectedScenarioId);
            widget.onScenarioSelected?.call(_selectedScenarioId);
            Navigator.of(context).pop(_selectedScenarioId);
          },
        ),
      ],
    );
  }
}
