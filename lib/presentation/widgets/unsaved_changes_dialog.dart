import 'package:flutter/material.dart';

class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const UnsavedChangesDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rời khỏi biểu mẫu?'),
      content: const Text(
        'Bạn có những thay đổi chưa lưu. Nếu rời khỏi bây giờ, các thay đổi sẽ bị mất.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Ở lại tiếp tục sửa'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Rời khỏi và hủy thay đổi'),
        ),
      ],
    );
  }
}
