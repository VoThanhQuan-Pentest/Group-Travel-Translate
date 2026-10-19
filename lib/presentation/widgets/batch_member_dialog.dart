import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/trip_session_controller.dart';

class BatchMemberDialog extends StatefulWidget {
  final String tripId;

  const BatchMemberDialog({super.key, required this.tripId});

  static Future<void> show(BuildContext context, {required String tripId}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BatchMemberDialog(tripId: tripId),
    );
  }

  @override
  State<BatchMemberDialog> createState() => _BatchMemberDialogState();
}

class _BatchMemberDialogState extends State<BatchMemberDialog> {
  final TextEditingController _inputCtrl = TextEditingController();
  final List<String> _parsedNames = [];
  bool _addToActiveScenario = true;
  bool _allowDuplicatesConfirmed = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _inputCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _inputCtrl.removeListener(_onTextChanged);
    _inputCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _inputCtrl.text;
    final tokens = text
        .split(RegExp(r'[\n,;]+'))
        .map((s) => s.trim().replaceAll(RegExp(r'\s+'), ' '))
        .where((s) => s.isNotEmpty)
        .toList();

    setState(() {
      _parsedNames.clear();
      _parsedNames.addAll(tokens);
      _localError = null;
    });
  }

  void _removeNameAt(int index) {
    setState(() {
      _parsedNames.removeAt(index);
      _inputCtrl.text = _parsedNames.join('\n');
    });
  }

  void _editNameAt(int index) {
    final editCtrl = TextEditingController(text: _parsedNames[index]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa tên', style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: editCtrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Tên thành viên'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = editCtrl.text.trim().replaceAll(RegExp(r'\s+'), ' ');
              if (newName.isNotEmpty) {
                setState(() {
                  _parsedNames[index] = newName;
                  _inputCtrl.text = _parsedNames.join('\n');
                });
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
    final existingMembers = session.trip?.members ?? [];
    final existingNames = existingMembers.map((m) => m.name.toLowerCase()).toSet();

    // Check for duplicates
    final seen = <String>{};
    final duplicatesInBatch = <String>{};
    final conflictsWithExisting = <String>{};

    for (final name in _parsedNames) {
      final lower = name.toLowerCase();
      if (seen.contains(lower)) {
        duplicatesInBatch.add(name);
      } else {
        seen.add(lower);
      }
      if (existingNames.contains(lower)) {
        conflictsWithExisting.add(name);
      }
    }

    final hasDuplicateIssues =
        duplicatesInBatch.isNotEmpty || conflictsWithExisting.isNotEmpty;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.group_add, color: AppColors.primary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Thêm danh sách thành viên theo lô',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nhập danh sách tên thành viên (mỗi dòng một người, hoặc phân cách bằng dấu phẩy, chấm phẩy):',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _inputCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ:\nNguyễn Văn A\nTrần Thị B, Lê Văn C; Hoàng D',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),

              // Summary Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _parsedNames.isNotEmpty
                          ? AppColors.primaryContainer
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sẽ thêm: ${_parsedNames.length} người',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _parsedNames.isNotEmpty
                            ? AppColors.onPrimaryContainer
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  if (_parsedNames.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Xóa hết', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        setState(() {
                          _inputCtrl.clear();
                          _parsedNames.clear();
                        });
                      },
                    ),
                ],
              ),

              // Duplicate Warning
              if (hasDuplicateIssues) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded,
                              size: 18, color: AppColors.warning),
                          SizedBox(width: 6),
                          Text(
                            'Phát hiện tên trùng lặp:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (conflictsWithExisting.isNotEmpty)
                        Text(
                          '• Trùng với thành viên đã có trong chuyến: ${conflictsWithExisting.join(", ")}',
                          style: const TextStyle(fontSize: 11.5),
                        ),
                      if (duplicatesInBatch.isNotEmpty)
                        Text(
                          '• Xuất hiện nhiều lần trong danh sách nhập: ${duplicatesInBatch.join(", ")}',
                          style: const TextStyle(fontSize: 11.5),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Checkbox(
                            value: _allowDuplicatesConfirmed,
                            onChanged: (val) {
                              setState(() {
                                _allowDuplicatesConfirmed = val ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Xác nhận đây là những người khác nhau (trùng tên)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Preview Table
              if (_parsedNames.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Xem trước và chỉnh sửa từng tên:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _parsedNames.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      final name = _parsedNames[idx];
                      final isDup = conflictsWithExisting.contains(name) ||
                          duplicatesInBatch.contains(name);

                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 12,
                          backgroundColor: isDup
                              ? AppColors.warningContainer
                              : AppColors.primaryContainer,
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDup
                                  ? AppColors.warning
                                  : AppColors.onPrimaryContainer,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: isDup ? FontWeight.bold : FontWeight.normal,
                            color: isDup ? AppColors.warning : AppColors.textPrimary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              tooltip: 'Sửa tên',
                              onPressed: () => _editNameAt(idx),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 16, color: AppColors.error),
                              tooltip: 'Xóa khỏi danh sách',
                              onPressed: () => _removeNameAt(idx),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 12),
              // Option: Add to active scenario
              Row(
                children: [
                  Checkbox(
                    value: _addToActiveScenario,
                    onChanged: (val) {
                      setState(() {
                        _addToActiveScenario = val ?? true;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Bổ sung vào kịch bản đang mở (${session.activeScenario?.name ?? "Mặc định"})',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),

              if (_localError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _localError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: session.isSaving || _parsedNames.isEmpty
              ? null
              : () async {
                  if (hasDuplicateIssues && !_allowDuplicatesConfirmed) {
                    setState(() {
                      _localError =
                          'Vui lòng đánh dấu xác nhận người khác nhau trùng tên hoặc sửa lại tên.';
                    });
                    return;
                  }

                  final success = await session.addMembersBatch(
                    _parsedNames,
                    addToActiveScenario: _addToActiveScenario,
                  );

                  if (success && mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm thành công ${_parsedNames.length} thành viên!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else if (mounted) {
                    setState(() {
                      _localError = session.errorMessage ?? 'Lưu thất bại';
                    });
                  }
                },
          child: session.isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu toàn bộ vào chuyến'),
        ),
      ],
    );
  }
}
