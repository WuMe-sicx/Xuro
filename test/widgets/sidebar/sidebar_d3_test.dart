import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/widgets/common/brand_wordmark.dart';

/// `BrandWordmark` 在抽屉的深色 scheme 下仍然可读：字标取 `onSurface`、
/// 句点取 `primary`——回归 CLAUDE.md 记录的「抽屉内 accent 不可见」陷阱。
Widget _darkHost(ColorScheme s, Widget child) => MaterialApp(
      theme: ThemeData(colorScheme: s, useMaterial3: true),
      home: Scaffold(body: child),
    );

/// 取出 `Text.rich` 的两个 span：字标与句点。
(TextSpan wordmark, TextSpan period) _spans(WidgetTester tester) {
  final text = tester.widget<Text>(
    find.descendant(
      of: find.byType(BrandWordmark),
      matching: find.byType(Text),
    ),
  );
  final children = (text.textSpan! as TextSpan).children!;
  return (children[0] as TextSpan, children[1] as TextSpan);
}

void main() {
  group('BrandWordmark 在抽屉深色 Theme 下可见', () {
    for (final v in ColorVariant.values) {
      testWidgets(v.name, (tester) async {
        final dark = AppColors.darkSchemeFor(v);
        await tester.pumpWidget(
          _darkHost(dark, const BrandWordmark(text: 'Xuro')),
        );
        final (wordmark, period) = _spans(tester);
        expect(wordmark.text, 'Xuro');
        expect(wordmark.style?.color, dark.onSurface);
        // 句点是品牌里唯一着色的字符，必须是该配色的 accent。
        expect(period.text, '.');
        expect(period.style?.color, dark.primary);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
