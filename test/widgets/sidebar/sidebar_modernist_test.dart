/// sidebar_modernist_test.dart：侧边栏 Modernist 视觉语言回归——分组头 accent
/// 色、选中/未选中行前景色，四配色（blue/mono/green/still）各验一次。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/widgets/sidebar/sidebar_group.dart';
import 'package:xuro/widgets/sidebar/sidebar_tile.dart';

Widget _host(ColorScheme scheme, Widget child) => MaterialApp(
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      home: Scaffold(body: child),
    );

void main() {
  group('SidebarGroup 分区头颜色 == colorScheme.primary', () {
    for (final v in ColorVariant.values) {
      testWidgets(v.name, (tester) async {
        final scheme = AppColors.lightSchemeFor(v);
        await tester.pumpWidget(_host(
          scheme,
          SidebarGroup(
            header: 'X',
            children: [
              SidebarTile(icon: Icons.star, title: 'A', onTap: () {}),
            ],
          ),
        ));
        final header = tester.widget<Text>(find.text('X'));
        expect(header.style?.color, scheme.primary);
      });
    }
  });

  group('SidebarTile 前景色随 selected 切换', () {
    for (final v in ColorVariant.values) {
      testWidgets(v.name, (tester) async {
        final scheme = AppColors.lightSchemeFor(v);

        await tester.pumpWidget(_host(
          scheme,
          SidebarTile(
            icon: Icons.star,
            title: 'Selected',
            selected: true,
            onTap: () {},
          ),
        ));
        final selectedMaterial = tester.widget<Material>(
          find.descendant(
            of: find.byType(SidebarTile),
            matching: find.byType(Material),
          ),
        );
        final selectedText = tester.widget<Text>(find.text('Selected'));
        // 选中态：整行实心 primary + onPrimary 文字。
        expect(selectedMaterial.color, scheme.primary);
        expect(selectedText.style?.color, scheme.onPrimary);

        await tester.pumpWidget(_host(
          scheme,
          SidebarTile(icon: Icons.star, title: 'Idle', onTap: () {}),
        ));
        final idleMaterial = tester.widget<Material>(
          find.descendant(
            of: find.byType(SidebarTile),
            matching: find.byType(Material),
          ),
        );
        final idleText = tester.widget<Text>(find.text('Idle'));
        // 未选中：透明底 + onSurface 文字。
        expect(idleMaterial.color, Colors.transparent);
        expect(idleText.style?.color, scheme.onSurface);
      });
    }
  });
}
