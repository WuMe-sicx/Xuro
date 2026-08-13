import 'package:flutter/material.dart';
import 'package:xuro/data/models/mark_status.dart';

class MarkSelectionDialog extends StatelessWidget {
  final MarkStatus? currentStatus;
  final Function(MarkStatus) onMarkSelected;
  final bool loading;

  const MarkSelectionDialog({
    super.key,
    this.currentStatus,
    required this.onMarkSelected,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('标记状态'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: MarkStatus.values.map((status) {
          return ListTile(
            enabled: !loading,
            // 不覆盖 fillColor：M3 默认选中态即 colorScheme.primary，
            // 手动指定灰色会让三配色轮换在这里失效。
            leading: Radio<MarkStatus>(
              value: status,
              groupValue: currentStatus,
              onChanged: loading
                  ? null
                  : (MarkStatus? value) {
                      if (value != null) {
                        onMarkSelected(value);
                        Navigator.of(context).pop();
                      }
                    },
            ),
            title: Text(status.label),
            onTap: loading
                ? null
                : () {
                    onMarkSelected(status);
                    Navigator.of(context).pop();
                  },
          );
        }).toList(),
      ),
    );
  }
}
