/// work_cover_download_badge_test.dart：封面左上角在线/本地角标——按
/// [WorkCoverImage.isDownloaded] 三态（未接入判定/在线/本地）正确显隐与取词，
/// 且随三配色轮换的 surface 实底取色正确。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/widgets/work_card/components/work_cover_image.dart';

Widget _host(ColorScheme scheme, Widget child) => MaterialApp(
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      home: Scaffold(body: SizedBox(width: 200, child: child)),
    );

void main() {
  testWidgets('isDownloaded 为 null（未接入判定的网格）→ 不显示角标', (tester) async {
    await tester.pumpWidget(_host(
      AppColors.lightSchemeFor(ColorVariant.blue),
      const WorkCoverImage(
        imageUrl: '',
        workId: 1,
        sourceId: 'RJ1',
      ),
    ));
    expect(find.text(Strings.playerOnline), findsNothing);
    expect(find.text(Strings.playerLocal), findsNothing);
  });

  testWidgets('isDownloaded=false → 显示"在线"', (tester) async {
    await tester.pumpWidget(_host(
      AppColors.lightSchemeFor(ColorVariant.blue),
      const WorkCoverImage(
        imageUrl: '',
        workId: 2,
        sourceId: 'RJ2',
        isDownloaded: false,
      ),
    ));
    expect(find.text(Strings.playerOnline), findsOneWidget);
    expect(find.text(Strings.playerLocal), findsNothing);
  });

  testWidgets('isDownloaded=true → 显示"本地"', (tester) async {
    await tester.pumpWidget(_host(
      AppColors.lightSchemeFor(ColorVariant.blue),
      const WorkCoverImage(
        imageUrl: '',
        workId: 3,
        sourceId: 'RJ3',
        isDownloaded: true,
      ),
    ));
    expect(find.text(Strings.playerLocal), findsOneWidget);
    expect(find.text(Strings.playerOnline), findsNothing);
  });

  group('角标 surface 实底随三配色轮换（blue / still）', () {
    for (final v in [ColorVariant.blue, ColorVariant.still]) {
      testWidgets(v.name, (tester) async {
        final scheme = AppColors.lightSchemeFor(v);
        await tester.pumpWidget(_host(
          scheme,
          const WorkCoverImage(
            imageUrl: '',
            workId: 4,
            sourceId: 'RJ4',
            isDownloaded: true,
          ),
        ));
        final badge = tester.widget<Container>(
          find
              .ancestor(
                of: find.text(Strings.playerLocal),
                matching: find.byType(Container),
              )
              .first,
        );
        // 角标 solid=true 时用 colorScheme.surface 实底——本身是中性色、
        // 不随 variant 轮换，锁住的是「取自 scheme 而非写死颜色」这条不变量。
        expect(badge.color, scheme.surface);
      });
    }
  });
}
