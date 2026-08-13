import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/data/models/mark_status.dart';
import 'package:xuro/widgets/detail/mark_selection_dialog.dart';

/// 回归 `fillColor.resolveWith` 手搓灰色的删除：选中态 radio 必须严格等于
/// colorScheme.primary，否则三配色轮换在这里失效（本文件唯一的可见破口）。
Widget _host(ColorScheme scheme, Widget child) => MaterialApp(
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      home: Scaffold(body: child),
    );

void main() {
  final variants = [
    ('blue', AppColors.lightSchemeFor(ColorVariant.blue)),
    ('green', AppColors.lightSchemeFor(ColorVariant.green)),
    ('mono', AppColors.lightSchemeFor(ColorVariant.mono)),
  ];

  for (final (name, scheme) in variants) {
    testWidgets('$name：选中态 radio 颜色 == colorScheme.primary',
        (tester) async {
      await tester.pumpWidget(
        _host(
          scheme,
          MarkSelectionDialog(
            currentStatus: MarkStatus.listening,
            onMarkSelected: (_) {},
          ),
        ),
      );

      final selectedRadio = find.byWidgetPredicate(
        (w) => w is Radio<MarkStatus> && w.value == MarkStatus.listening,
      );
      final customPaint = tester.widget<CustomPaint>(
        find.descendant(of: selectedRadio, matching: find.byType(CustomPaint))
            .first,
      );
      final painter = customPaint.painter as ToggleablePainter;
      expect(painter.activeColor, scheme.primary);
    });
  }
}
