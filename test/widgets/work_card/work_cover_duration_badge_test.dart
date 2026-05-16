import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/widgets/work_card/components/work_cover_image.dart';

/// D4：封面左下时长角标（对齐参考图）。验证存在性 + 格式 + 缺省不显示。
Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: SizedBox(width: 200, child: child)));

void main() {
  testWidgets('有时长 → 显示 m:ss 角标', (tester) async {
    await tester.pumpWidget(_host(const WorkCoverImage(
      imageUrl: '',
      workId: 1,
      sourceId: 'RJ1',
      durationSeconds: 1845, // 30:45
    )));
    expect(find.text('30:45'), findsOneWidget);
  });

  testWidgets('超 1 小时 → H:MM:SS', (tester) async {
    await tester.pumpWidget(_host(const WorkCoverImage(
      imageUrl: '',
      workId: 2,
      sourceId: 'RJ2',
      durationSeconds: 3661, // 1:01:01
    )));
    expect(find.text('1:01:01'), findsOneWidget);
  });

  testWidgets('个位秒补零', (tester) async {
    await tester.pumpWidget(_host(const WorkCoverImage(
      imageUrl: '',
      workId: 3,
      sourceId: 'RJ3',
      durationSeconds: 65, // 1:05
    )));
    expect(find.text('1:05'), findsOneWidget);
  });

  testWidgets('无时长 / 0 → 不显示角标（仅 sourceId）', (tester) async {
    await tester.pumpWidget(_host(const WorkCoverImage(
      imageUrl: '',
      workId: 4,
      sourceId: 'RJ4',
    )));
    expect(find.text('RJ4'), findsOneWidget);
    // 没有任何 m:ss 文本
    expect(find.textContaining(':'), findsNothing);
  });
}
