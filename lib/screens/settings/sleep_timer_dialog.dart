import 'package:flutter/material.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/platform/sleep_timer_controller.dart';

/// 睡眠定时单选对话框：关闭 / 15 / 30 / 45 / 60 / 90 分钟。
/// 选择即写入 [SleepTimerController] 并关闭（无确认按钮，符合单选语义）。
class SleepTimerDialog extends StatelessWidget {
  final SleepTimerController controller;

  const SleepTimerDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current = controller.minutes;

    Widget option(String label, int? minutes) {
      final selected = current == minutes;
      return ListTile(
        title: Text(label),
        trailing: selected ? Icon(Icons.check, color: cs.primary) : null,
        onTap: () {
          controller.setMinutes(minutes);
          Navigator.pop(context);
        },
      );
    }

    return AlertDialog(
      title: const Text(Strings.sleepTimer),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            option(Strings.sleepTimerOff, null),
            for (final m in SleepTimerController.presetMinutes)
              option(Strings.sleepTimerMinutes(m), m),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(Strings.cancel),
        ),
      ],
    );
  }
}
