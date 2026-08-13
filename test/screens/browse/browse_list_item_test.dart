/// browse_list_item_test.dart：分类三屏共用编号列表行 [BrowseListItem] 的回归测试。
/// 三屏（标签/社团/声优）复用同一组件，故只写一套骨架即可覆盖三屏渲染契约。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/screens/browse/widgets/browse_list_item.dart';

Widget _host(ColorScheme scheme, Widget child) => MaterialApp(
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      home: Scaffold(body: child),
    );

void main() {
  group('编号按下标生成两位数', () {
    for (final (i, expected) in [(1, '01'), (2, '02'), (10, '10')]) {
      testWidgets('index=$i -> $expected', (tester) async {
        await tester.pumpWidget(_host(
          AppColors.lightSchemeFor(ColorVariant.blue),
          BrowseListItem(index: i, name: '耳かき', count: 12),
        ));
        expect(find.text(expected), findsOneWidget);
      });
    }
  });

  testWidgets('渲染真实名称与计数文案', (tester) async {
    await tester.pumpWidget(_host(
      AppColors.lightSchemeFor(ColorVariant.blue),
      const BrowseListItem(index: 1, name: 'バイノーラル', count: 28),
    ));
    expect(find.text('バイノーラル'), findsOneWidget);
    expect(find.text('28 条'), findsOneWidget);
  });

  testWidgets('接口未返回计数（count=null）时只显示箭头，不编数字', (tester) async {
    await tester.pumpWidget(_host(
      AppColors.lightSchemeFor(ColorVariant.blue),
      const BrowseListItem(index: 1, name: '无计数标签', count: null),
    ));
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    expect(find.textContaining('条'), findsNothing);
  });

  // 设计稿此行是纯中性视觉（编号/名称/计数均取 onSurface 的不同透明度），
  // 不含 accent。三配色不变量在这里的体现是「颜色恒等于 onSurface 系、
  // 不随 primary 漂移」——同 settings_d1_test 对中性 leading 图标的验证方式。
  group('多配色下行内颜色恒为中性（非 accent），blue/still 两档', () {
    for (final variant in [ColorVariant.blue, ColorVariant.still]) {
      testWidgets(variant.name, (tester) async {
        final scheme = AppColors.lightSchemeFor(variant);
        await tester.pumpWidget(_host(
          scheme,
          const BrowseListItem(index: 1, name: '标签', count: 5),
        ));

        final nameText = tester.widget<Text>(find.text('标签'));
        expect(nameText.style?.color, scheme.onSurface);
        expect(nameText.style?.color, isNot(scheme.primary));

        final countText = tester.widget<Text>(find.text('5 条'));
        expect(countText.style?.color, scheme.onSurface.withValues(alpha: 0.55));
        expect(countText.style?.color, isNot(scheme.primary));

        final arrow = tester.widget<Icon>(find.byIcon(Icons.arrow_forward));
        expect(arrow.color, scheme.onSurface.withValues(alpha: 0.55));
        expect(arrow.color, isNot(scheme.primary));
      });
    }
  });

  testWidgets('点击行触发 onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_host(
      AppColors.lightSchemeFor(ColorVariant.blue),
      BrowseListItem(
        index: 1,
        name: '标签',
        count: 1,
        onTap: () => tapped = true,
      ),
    ));
    await tester.tap(find.byType(BrowseListItem));
    expect(tapped, isTrue);
  });
}
