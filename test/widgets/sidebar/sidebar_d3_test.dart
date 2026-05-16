import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/widgets/common/brand_wordmark.dart';
import 'package:xuro/widgets/sidebar/sidebar_decoration.dart';

/// D3：侧边栏装饰水印三配色（暗色 scheme，抽屉强制深色）正常渲染；
/// BrandWordmark 在抽屉局部深色 Theme 下文字=onSurface(白)、图标=primary
/// (该配色暗色 accent)——回归 CLAUDE.md 关切的「抽屉内 accent 不可见」陷阱。
Widget _darkHost(ColorScheme s, Widget child) => MaterialApp(
      theme: ThemeData(colorScheme: s, useMaterial3: true),
      home: Scaffold(body: child),
    );

void main() {
  group('SidebarDecoration 三配色暗色 scheme 渲染 smoke', () {
    for (final v in ColorVariant.values) {
      testWidgets(v.name, (tester) async {
        final scheme = AppColors.darkSchemeFor(v);
        await tester.pumpWidget(
          _darkHost(scheme, SidebarDecoration(variant: v)),
        );
        expect(find.byType(CustomPaint), findsWidgets);
        final deco = tester.widget<SidebarDecoration>(
          find.byType(SidebarDecoration),
        );
        expect(deco.variant, v);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('BrandWordmark 在抽屉深色 Theme 下可见', () {
    for (final v in ColorVariant.values) {
      testWidgets(v.name, (tester) async {
        final dark = AppColors.darkSchemeFor(v);
        await tester.pumpWidget(
          _darkHost(dark, const BrandWordmark(text: 'Xuro')),
        );
        final icon = tester.widget<Icon>(
          find.descendant(
            of: find.byType(BrandWordmark),
            matching: find.byType(Icon),
          ),
        );
        final text = tester.widget<Text>(
          find.descendant(
            of: find.byType(BrandWordmark),
            matching: find.byType(Text),
          ),
        );
        expect(icon.color, dark.primary); // accent，随配色轮换
        expect(text.style?.color, dark.onSurface); // 白，玻璃拟态可读
      });
    }
  });
}
