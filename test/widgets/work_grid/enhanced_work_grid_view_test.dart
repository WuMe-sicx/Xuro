import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/widgets/work_grid/components/grid_content.dart';
import 'package:xuro/widgets/work_grid/components/grid_empty.dart';
import 'package:xuro/widgets/work_grid/components/grid_error.dart';
import 'package:xuro/widgets/work_grid/components/grid_loading.dart';
import 'package:xuro/widgets/work_grid/enhanced_work_grid_view.dart';

/// EnhancedWorkGridView 是 legacy WorkGridView 的严格超集，迁移后成为
/// search/favorites/similar_works 三屏的唯一 grid 实现，这里补上此前 0 覆盖的
/// 状态机测试：四态互斥、两处迁移前的行为差异（翻页不闪白、错误不盖过陈旧内容）、
/// 登录态分支、空态兜底文案。
Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

List<Work> _works(int n) =>
    List.generate(n, (i) => Work(id: i, title: 'work$i'));

void main() {
  group('四态互斥', () {
    testWidgets('isLoading + 无数据 → GridLoading', (tester) async {
      await tester.pumpWidget(_host(const EnhancedWorkGridView(
        works: [],
        isLoading: true,
      )));
      expect(find.byType(GridLoading), findsOneWidget);
      expect(find.byType(GridError), findsNothing);
      expect(find.byType(GridEmpty), findsNothing);
      expect(find.byType(GridContent), findsNothing);
    });

    testWidgets('error 非空且无数据 → GridError', (tester) async {
      await tester.pumpWidget(_host(const EnhancedWorkGridView(
        works: [],
        isLoading: false,
        error: '网络错误',
      )));
      expect(find.byType(GridError), findsOneWidget);
      expect(find.byType(GridLoading), findsNothing);
      expect(find.byType(GridEmpty), findsNothing);
      expect(find.byType(GridContent), findsNothing);
    });

    testWidgets('works 为空且无错误 → GridEmpty', (tester) async {
      await tester.pumpWidget(_host(const EnhancedWorkGridView(
        works: [],
        isLoading: false,
      )));
      expect(find.byType(GridEmpty), findsOneWidget);
      expect(find.byType(GridLoading), findsNothing);
      expect(find.byType(GridError), findsNothing);
      expect(find.byType(GridContent), findsNothing);
    });

    testWidgets('works 非空 → GridContent', (tester) async {
      await tester.pumpWidget(_host(EnhancedWorkGridView(
        works: _works(1),
        isLoading: false,
      )));
      expect(find.byType(GridContent), findsOneWidget);
      expect(find.byType(GridLoading), findsNothing);
      expect(find.byType(GridError), findsNothing);
      expect(find.byType(GridEmpty), findsNothing);
    });
  });

  group('翻页不闪白（迁移前 legacy 的 if(isLoading) 会把整屏换成裸转圈）', () {
    testWidgets('isLoading + 已有数据 → 内容仍在树上，loading 不在', (tester) async {
      await tester.pumpWidget(_host(EnhancedWorkGridView(
        works: _works(1),
        isLoading: true,
      )));
      expect(find.byType(GridContent), findsOneWidget);
      expect(find.byType(GridLoading), findsNothing);
    });
  });

  group('T1：陈旧内容优先于错误页', () {
    testWidgets('works 非空 + error 非空 → 渲染内容不渲染错误页', (tester) async {
      await tester.pumpWidget(_host(EnhancedWorkGridView(
        works: _works(1),
        isLoading: false,
        error: '翻页失败',
      )));
      expect(find.byType(GridContent), findsOneWidget);
      expect(find.byType(GridError), findsNothing);
    });
  });

  group('登录态分支', () {
    testWidgets('isLoginError + onLogin 非空 → 出现"去登录"，不出现"重试"',
        (tester) async {
      await tester.pumpWidget(_host(EnhancedWorkGridView(
        works: const [],
        isLoading: false,
        error: Strings.loginRequired,
        isLoginError: true,
        onLogin: () {},
        onRetry: () {},
      )));
      expect(find.text(Strings.goLogin), findsOneWidget);
      expect(find.text(Strings.retry), findsNothing);
    });

    testWidgets('onLogin 为空 → 回退"重试"', (tester) async {
      await tester.pumpWidget(_host(EnhancedWorkGridView(
        works: const [],
        isLoading: false,
        error: Strings.loginRequired,
        isLoginError: true,
        onRetry: () {},
      )));
      expect(find.text(Strings.retry), findsOneWidget);
      expect(find.text(Strings.goLogin), findsNothing);
    });
  });

  group('空态不白屏', () {
    testWidgets('works 为空 + emptyMessage 为空 → 有可见默认文案，不是纯 shrink',
        (tester) async {
      await tester.pumpWidget(_host(const EnhancedWorkGridView(
        works: [],
        isLoading: false,
      )));
      expect(find.text(Strings.gridEmpty), findsOneWidget);
    });
  });
}
