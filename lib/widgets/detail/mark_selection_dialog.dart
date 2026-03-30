import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/mark_status.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      title: Text(
        '标记状态',
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: MarkStatus.values.map((status) {
          final isSelected = status == currentStatus;
          return ListTile(
            enabled: !loading,
            leading: Radio<MarkStatus>(
              value: status,
              groupValue: currentStatus,
              onChanged: loading ? null : (MarkStatus? value) {
                if (value != null) {
                  onMarkSelected(value);
                  Navigator.of(context).pop();
                }
              },
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return isDark ? Colors.white24 : Colors.black26;
                }
                if (states.contains(WidgetState.selected)) {
                  return isDark ? Colors.white70 : Colors.black87;
                }
                return isDark ? Colors.white38 : Colors.black45;
              }),
            ),
            title: Text(
              status.label,
              style: TextStyle(
                color: loading
                    ? (isDark ? Colors.white38 : Colors.black38)
                    : (isSelected
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white70 : Colors.black54)),
              ),
            ),
            onTap: loading ? null : () {
              onMarkSelected(status);
              Navigator.of(context).pop();
            },
            hoverColor: isDark 
                ? Colors.white.withOpacity(0.05) 
                : Colors.black.withOpacity(0.05),
          );
        }).toList(),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
} 