import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/widgets/work_grid/components/grid_loading.dart';

/// 骨架列数须跟随真实 [WorkLayoutStrategy]，不能写死 2 列——否则平板/桌面上会出现
/// 「2 列骨架 → 3/4 列内容」的加载态跳变（回归闸门）。
void main() {
  testWidgets('移动端宽度 → 2 列骨架', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GridLoading())));
    final delegate = tester
        .widget<GridView>(find.byType(GridView))
        .gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
  });

  testWidgets('桌面宽度 → 4 列骨架', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GridLoading())));
    final delegate = tester
        .widget<GridView>(find.byType(GridView))
        .gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);
  });
}
