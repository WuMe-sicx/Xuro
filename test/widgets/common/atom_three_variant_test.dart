import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/widgets/common/brand_wordmark.dart';

/// 三配色不变量回归：同一原子在不同 [ColorVariant] 下，accent 元素颜色
/// 必须严格等于该 scheme 的 primary/primaryContainer——证明组件从 Theme 取色、
/// 未写死任何配色。任一原子改成硬编码色都会撞红这里。
Widget _host(ColorScheme scheme, Widget child) => MaterialApp(
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  final blue = AppColors.lightSchemeFor(ColorVariant.blue);
  final green = AppColors.lightSchemeFor(ColorVariant.green);
  final mono = AppColors.lightSchemeFor(ColorVariant.mono);

  // 品牌是纯排版：字标 onSurface + 句点 accent。句点是唯一着色的字符，
  // 这条断言同时守住「多配色只轮换 accent」和「品牌不用图标」两件事。
  group('BrandWordmark 句点 == colorScheme.primary，字标 == onSurface', () {
    for (final (name, scheme) in [
      ('blue', blue),
      ('green', green),
      ('mono', mono),
    ]) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(_host(scheme, const BrandWordmark()));
        expect(
          find.descendant(
            of: find.byType(BrandWordmark),
            matching: find.byType(Icon),
          ),
          findsNothing,
        );
        final text = tester.widget<Text>(
          find.descendant(
            of: find.byType(BrandWordmark),
            matching: find.byType(Text),
          ),
        );
        final spans = (text.textSpan! as TextSpan).children!;
        expect((spans[0] as TextSpan).style?.color, scheme.onSurface);
        expect((spans[1] as TextSpan).text, '.');
        expect((spans[1] as TextSpan).style?.color, scheme.primary);
      });
    }
  });
}
