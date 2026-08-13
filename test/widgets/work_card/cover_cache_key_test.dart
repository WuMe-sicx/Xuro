/// cover_cache_key_test.dart：锁定「详情页低清 placeholder 与网格封面共用同一个
/// 解码缓存条目」这一不变量。
///
/// `CachedNetworkImage` 在 `memCacheWidth` 非空时把 provider 包进 `ResizeImage`，
/// 而 `ResizeImage` 把宽度算进相等性——宽度差 1px 就是另一个缓存条目，详情页的
/// 低清打底就命不中网格已解码的那份，进详情仍会空窗闪白，**且没有任何报错**。
/// 所以这里不复核公式本身，而是挂真实网格读出它实际用的宽度来对齐。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/presentation/layouts/work_layout_config.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';
import 'package:xuro/widgets/detail/work_cover.dart';
import 'package:xuro/widgets/work_grid.dart';

const _url = 'https://example.invalid/cover.jpg';

Work _work(int id) => Work(id: id, mainCoverUrl: _url, sourceId: 'RJ$id');

/// 复刻 `GridContent` 的真实外层：SliverPadding(getPadding) → WorkGrid。
Widget _grid(WorkLayoutStrategy strategy) => MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => CustomScrollView(
            slivers: [
              SliverPadding(
                padding: strategy.getPadding(context),
                sliver: WorkGrid(
                  works: [_work(1), _work(2)],
                  layoutStrategy: strategy,
                ),
              ),
            ],
          ),
        ),
      ),
    );

void main() {
  const strategy = WorkLayoutStrategy();

  /// 逐项覆盖三档设备宽度：内边距/间距按 DeviceType 变化，公式必须在每档都对。
  for (final scenario in const [
    (label: '手机 360pt', physical: Size(1080, 2400), dpr: 3.0),
    (label: '平板 900pt', physical: Size(1800, 2560), dpr: 2.0),
    (label: '桌面 1280pt', physical: Size(1280, 800), dpr: 1.0),
  ]) {
    testWidgets('${scenario.label}：网格封面实际解码宽度 == gridCoverCacheWidth',
        (tester) async {
      tester.view.physicalSize = scenario.physical;
      tester.view.devicePixelRatio = scenario.dpr;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_grid(strategy));
      await tester.pump();

      final actual = tester
          .widget<CachedNetworkImage>(find.byType(CachedNetworkImage).first)
          .memCacheWidth;

      final screenWidth = scenario.physical.width / scenario.dpr;
      final expected =
          WorkLayoutConfig.gridCoverCacheWidth(screenWidth, scenario.dpr);

      expect(
        actual,
        expected,
        reason: '公式与真实网格布局脱钩了。详情页的低清 placeholder 会因此命不中'
            '网格的缓存条目，进详情仍然空窗闪白——而且不会有任何报错。'
            '改了内边距/间距/Card margin/列数就要同步改 gridCoverCacheWidth。',
      );
    });
  }

  testWidgets('详情页封面在高清图就绪前用网格那份宽度打底，而不是留白', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WorkCover(imageUrl: _url, workId: 1, sourceId: 'RJ1'),
      ),
    ));
    await tester.pump();

    final widths = tester
        .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
        .map((w) => w.memCacheWidth)
        .toSet();

    final gridWidth = WorkLayoutConfig.gridCoverCacheWidth(360, 3.0);
    expect(
      widths,
      contains(gridWidth),
      reason: '详情页必须存在一份按网格宽度解码的图作为打底；'
          '否则高清图解码那段窗口里是空白，即用户报的「闪」',
    );
  });
}
