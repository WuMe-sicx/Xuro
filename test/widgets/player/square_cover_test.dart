import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/widgets/player/square_cover.dart';

/// Phase 3：播放器封面由圆形改回方形（Modernist 零圆角）。锁定——
/// 零圆角矩形（非 BoxShape.circle/ClipOval）、无封面时的回退图标染 accent
/// 并随三配色轮换、无封面时音符回退图标仍在。
Widget _host(ColorScheme s, Widget child) => MaterialApp(
      theme: ThemeData(colorScheme: s, useMaterial3: true),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('零圆角方形 + accent 回退图标随三配色轮换', () {
    for (final v in [ColorVariant.blue, ColorVariant.still]) {
      testWidgets(v.name, (tester) async {
        final s = AppColors.lightSchemeFor(v);
        await tester.pumpWidget(_host(s, const SquareCover()));

        final box = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(SquareCover),
                matching: find.byType(Container),
              )
              .first,
        );
        final deco = box.decoration as BoxDecoration;
        expect(deco.shape, isNot(BoxShape.circle));
        expect(deco.borderRadius, AppRadius.mdAll);
        expect(find.byType(ClipOval), findsNothing);
        expect(find.byType(ClipRRect), findsOneWidget);

        final icon = tester.widget<Icon>(find.byIcon(Icons.music_note));
        expect(icon.color, s.primary);
      });
    }
  });

  testWidgets('无封面 URL → 音符回退图标', (tester) async {
    await tester.pumpWidget(
      _host(AppColors.lightSchemeFor(ColorVariant.blue),
          const SquareCover()),
    );
    expect(find.byIcon(Icons.music_note), findsOneWidget);
  });
}
