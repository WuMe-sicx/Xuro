import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/screens/settings/widgets/settings_group.dart';
import 'package:xuro/screens/settings/widgets/settings_tile.dart';

/// D1 参考图不变量回归：设置项 leading 图标必须中性（onSurfaceVariant），
/// accent 仅出现在分区头 / 选中态 / 开关。任一处把 leading 改回 accent 徽章、
/// 或分区头不再是 accent labelMedium，都会撞红这里。
Widget _host(ColorScheme s, Widget child) => MaterialApp(
      theme: ThemeData(colorScheme: s, useMaterial3: true),
      home: Scaffold(body: child),
    );

void main() {
  final blue = AppColors.lightSchemeFor(ColorVariant.blue);
  final green = AppColors.lightSchemeFor(ColorVariant.green);
  final mono = AppColors.lightSchemeFor(ColorVariant.mono);

  group('leading 图标中性（== onSurfaceVariant，非 accent）', () {
    for (final (name, s) in [('blue', blue), ('green', green), ('mono', mono)]) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(_host(
          s,
          const SettingsTile.navigation(
            title: '节点',
            leading: Icons.lan_outlined,
            value: 'v',
          ),
        ));
        final icon = tester.widget<Icon>(find.byIcon(Icons.lan_outlined));
        expect(icon.color, s.onSurfaceVariant);
        expect(icon.color, isNot(s.primary));
      });
    }
  });

  testWidgets('selection 选中态用 accent（check == primary）', (tester) async {
    await tester.pumpWidget(_host(
      blue,
      const SettingsTile.selection(
        title: '蓝',
        leading: Icons.circle,
        selected: true,
      ),
    ));
    final check = tester.widget<Icon>(find.byIcon(Icons.check));
    expect(check.color, blue.primary);
  });

  testWidgets('toggle 激活轨道用 accent', (tester) async {
    await tester.pumpWidget(_host(
      green,
      SettingsTile.toggle(
        title: '后台播放',
        leading: Icons.play_circle_outline,
        value: true,
        onChanged: (_) {},
      ),
    ));
    final sw = tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch));
    expect(sw.activeTrackColor, green.primary);
  });

  group('分区头 == accent + labelMedium(12/w500)', () {
    for (final (name, s) in [('blue', blue), ('green', green)]) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(_host(
          s,
          const SettingsGroup(
            header: '播放设置',
            children: [
              SettingsTile.navigation(
                  title: '定时关闭', leading: Icons.timer_outlined, value: '30分钟'),
            ],
          ),
        ));
        final t = tester.widget<Text>(find.text('播放设置'));
        expect(t.style?.color, s.primary);
        expect(t.style?.fontSize, 12);
        expect(t.style?.fontWeight, FontWeight.w500);
      });
    }
  });
}
