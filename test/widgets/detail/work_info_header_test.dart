import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/data/models/works/circle.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/work_info.dart' as model;
import 'package:xuro/data/models/works/work_va.dart';
import 'package:xuro/widgets/common/tag_chip.dart';
import 'package:xuro/widgets/detail/work_info_header.dart';

/// 挂载 [WorkInfoHeader]（而非孤立测 [TagChip]），断言三类标签的底色/边框色
/// 严格等于对应 [ColorScheme] token。之所以挂真实屏而不是原子本身：此前的
/// bug 正是「原子本身没错，是 5 个调用点各自塞了 Colors.orange/green/blue」，
/// 孤立测原子测不出调用点的字面色。
Widget _host(ColorScheme scheme, Widget child) => MaterialApp(
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      home: Scaffold(body: Center(child: child)),
    );

Work _workFixture() => Work(
      circle: Circle(name: '某社团'),
      hasSubtitle: true,
    );

model.WorkInfo _workInfoFixture() => model.WorkInfo(
      vas: [WorkVA(name: '某声优')],
    );

Container _tagChipContainer(WidgetTester tester, String text) {
  final chip = find.byWidgetPredicate((w) => w is TagChip && w.text == text);
  expect(chip, findsOneWidget);
  return tester.widget<Container>(
    find.descendant(of: chip, matching: find.byType(Container)),
  );
}

void main() {
  final variants = [
    ('blue', AppColors.lightSchemeFor(ColorVariant.blue)),
    ('green', AppColors.lightSchemeFor(ColorVariant.green)),
    ('mono', AppColors.lightSchemeFor(ColorVariant.mono)),
  ];

  for (final (name, scheme) in variants) {
    testWidgets('$name：社团 chip（TagTone.neutral）底色 == surfaceContainerHighest',
        (tester) async {
      await tester.pumpWidget(
        _host(scheme, WorkInfoHeader(work: _workFixture())),
      );
      final decoration =
          _tagChipContainer(tester, '某社团').decoration as BoxDecoration;
      expect(decoration.color, scheme.surfaceContainerHighest);
    });

    testWidgets('$name：字幕 chip（TagTone.primary）底色 == primaryContainer',
        (tester) async {
      await tester.pumpWidget(
        _host(scheme, WorkInfoHeader(work: _workFixture())),
      );
      final decoration = _tagChipContainer(tester, Strings.subtitleChip)
          .decoration as BoxDecoration;
      expect(decoration.color, scheme.primaryContainer);
    });

    testWidgets('$name：声优 chip（TagTone.outline）边框色 == outlineVariant',
        (tester) async {
      await tester.pumpWidget(
        _host(
          scheme,
          WorkInfoHeader(work: _workFixture(), workInfo: _workInfoFixture()),
        ),
      );
      final decoration =
          _tagChipContainer(tester, '某声优').decoration as BoxDecoration;
      // outline tone 故意透明底（没有对应的“描边容器”token），可辨识度靠边框。
      expect(decoration.color, Colors.transparent);
      expect(decoration.border!.top.color, scheme.outlineVariant);
    });
  }

  testWidgets('blue 与 green 的字幕 chip 底色确实不同（轮换有效）',
      (tester) async {
    final blue = AppColors.lightSchemeFor(ColorVariant.blue);
    final green = AppColors.lightSchemeFor(ColorVariant.green);
    expect(blue.primaryContainer, isNot(green.primaryContainer));
  });
}
