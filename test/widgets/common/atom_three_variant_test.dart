import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/widgets/common/accent_pill.dart';
import 'package:xuro/widgets/common/brand_wordmark.dart';
import 'package:xuro/widgets/common/category_chip.dart';

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

  group('AccentPill 底色 == colorScheme.primary（随配色轮换）', () {
    for (final (name, scheme) in [
      ('blue', blue),
      ('green', green),
      ('mono', mono),
    ]) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(
          _host(scheme, const AccentPill(label: '关注')),
        );
        final m = tester.widget<Material>(
          find.descendant(
            of: find.byType(AccentPill),
            matching: find.byType(Material),
          ),
        );
        expect(m.color, scheme.primary);
      });
    }

    testWidgets('blue 与 green primary 确实不同（轮换有效）', (tester) async {
      expect(blue.primary, isNot(green.primary));
    });
  });

  group('CategoryChip 软底 == colorScheme.primaryContainer', () {
    for (final (name, scheme) in [
      ('blue', blue),
      ('green', green),
      ('mono', mono),
    ]) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(
          _host(
            scheme,
            const CategoryChip(icon: Icons.spa, label: '助眠'),
          ),
        );
        final m = tester.widget<Material>(
          find.descendant(
            of: find.byType(CategoryChip),
            matching: find.byType(Material),
          ),
        );
        expect(m.color, scheme.primaryContainer);
      });
    }
  });

  group('BrandWordmark 图标 == colorScheme.primary', () {
    for (final (name, scheme) in [
      ('blue', blue),
      ('green', green),
      ('mono', mono),
    ]) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(_host(scheme, const BrandWordmark()));
        final icon = tester.widget<Icon>(
          find.descendant(
            of: find.byType(BrandWordmark),
            matching: find.byType(Icon),
          ),
        );
        expect(icon.color, scheme.primary);
      });
    }
  });
}
