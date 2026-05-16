import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/widgets/player/circular_cover.dart';

/// D5：播放器封面由方形换圆形。锁定——圆形(ClipOval/BoxShape.circle)、
/// accent 细环随三配色轮换、无封面时音符回退。
Widget _host(ColorScheme s, Widget child) => MaterialApp(
      theme: ThemeData(colorScheme: s, useMaterial3: true),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('圆形 + accent 细环随三配色轮换', () {
    for (final v in ColorVariant.values) {
      testWidgets(v.name, (tester) async {
        final s = AppColors.lightSchemeFor(v);
        await tester.pumpWidget(_host(s, const CircularCover()));

        final box = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(CircularCover),
                matching: find.byType(Container),
              )
              .first,
        );
        final deco = box.decoration as BoxDecoration;
        expect(deco.shape, BoxShape.circle);
        expect(
          deco.border!.top.color,
          s.primary.withValues(alpha: 0.25),
        );
        expect(find.byType(ClipOval), findsOneWidget);
      });
    }
  });

  testWidgets('无封面 URL → 音符回退图标', (tester) async {
    await tester.pumpWidget(
      _host(AppColors.lightSchemeFor(ColorVariant.blue),
          const CircularCover()),
    );
    expect(find.byIcon(Icons.music_note), findsOneWidget);
  });
}
