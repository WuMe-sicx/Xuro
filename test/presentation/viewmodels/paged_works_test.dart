/// paged_works_test.dart：给 PagedWorks 补上此前 0 覆盖率的状态机测试——
/// 它是 5 个列表 ViewModel 共用的分页守卫/失败态/鉴权补载逻辑，此前每个坑
/// 都只靠人肉读代码保证。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-17
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/data/models/works/pagination.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/works_response.dart';
import 'package:xuro/presentation/viewmodels/base/paginated_works_viewmodel.dart';

/// 直接 mixin PagedWorks 的最小宿主：不接 ApiService，不接 DI，
/// fetchPage 完全由测试通过 [onFetch] 控制返回值/异常/是否挂起。
///
/// [markAuthPending]/[reloadAfterAuthReady]/[markLoginRequired] 在 mixin 里标了
/// `@protected`，只能从子类内部调用——这里包一层同名 public 方法转发，
/// 避免测试代码直接摸 protected 成员触发 `flutter analyze` 的
/// invalid_use_of_protected_member。
class _FakePagedWorks extends ChangeNotifier with PagedWorks {
  _FakePagedWorks(this.onFetch);

  final Future<WorksResponse> Function(int page) onFetch;

  /// 记录每次 fetchPage 实际被调用时传入的页码，顺序即调用顺序。
  final List<int> calledPages = [];

  @override
  String get pageName => 'fake';

  @override
  Future<WorksResponse> fetchPage(int page) {
    calledPages.add(page);
    return onFetch(page);
  }

  void triggerAuthPending() => markAuthPending();
  Future<void> triggerReloadAfterAuthReady() => reloadAfterAuthReady();
  void triggerLoginRequired() => markLoginRequired();
}

Work _work(int id) => Work(id: id, title: 'work$id');

WorksResponse _response(
  List<Work> works, {
  int? totalCount,
  int? pageSize,
}) =>
    WorksResponse(
      works: works,
      pagination: Pagination(totalCount: totalCount, pageSize: pageSize),
    );

void main() {
  test('in-flight guard：请求在途时第二次 loadPage 不会重复触发 fetchPage', () async {
    // 后果：去掉这道守卫，用户快速二连点翻页会打两次请求，先发出的响应落地后
    // 立刻被后一次覆盖，界面跳动且语义错乱。
    final completer = Completer<WorksResponse>();
    final fake = _FakePagedWorks((page) => completer.future);

    // runFetch 是 async 函数，同步执行到第一个 await（即调用 fetchPage）为止，
    // 所以这里不 await 也已经完成了"进入在途态"这一步，不需要额外等一个事件循环。
    final first = fake.loadPage(1);
    final second = fake.loadPage(1);

    completer.complete(_response([_work(1)], totalCount: 10, pageSize: 10));
    await first;
    await second;

    expect(fake.calledPages, [1]);
  });

  test('boundary guard：page=0 从不请求；totalPages=N 已知后 page=N+1 从不请求，page=N 会请求',
      () async {
    // 后果：下界漏了会拿第 0 页去打服务端；上界差一错了会让最后一页翻不动，
    // 或者反过来把请求打到服务端根本不存在的页。
    final fake = _FakePagedWorks(
      (page) async => _response([_work(page)], totalCount: 20, pageSize: 10),
    );

    await fake.loadPage(0);
    expect(fake.calledPages, isEmpty, reason: 'page=0 不是合法页码，不该发请求');

    await fake.loadPage(1); // 建立 totalPages = 20/10 = 2
    expect(fake.totalPages, 2);

    await fake.loadPage(3); // N+1，必须被拦
    expect(fake.calledPages, [1], reason: '超出 totalPages 的翻页请求必须被拦下');

    await fake.loadPage(2); // ==N，必须放行——否则说明守卫写成了 page < totalPages 的差一错
    expect(fake.calledPages, [1, 2]);
  });

  test('success path：加载成功更新 works/pagination/currentPage、清空 failure，整轮恰好两次通知',
      () async {
    // 后果：通知次数一旦不是"进入一次 + finally 一次"，要么 UI 漏刷新，
    // 要么退化成每次内部状态变化都广播一轮，白白多重建。
    final fake = _FakePagedWorks(
      (page) async =>
          _response([_work(1), _work(2)], totalCount: 20, pageSize: 10),
    );
    var notifyCount = 0;
    fake.addListener(() => notifyCount++);

    await fake.loadPage(1);

    expect(fake.works.length, 2);
    expect(fake.pagination?.totalCount, 20);
    expect(fake.currentPage, 1);
    expect(fake.failure, isNull);
    expect(notifyCount, 2);
  });

  test('failure path：第2页失败保留第1页内容不清空，并记录 failure', () async {
    // 后果：翻页失败若清空 works，EnhancedWorkGridView 的 works.isEmpty 守卫
    // 会让整屏从"有内容"变成"错误页"，用户刚看到的第 1 页内容凭空消失。
    final fake = _FakePagedWorks((page) async {
      if (page == 1) return _response([_work(1)], totalCount: 30, pageSize: 10);
      throw Exception('boom');
    });

    await fake.loadPage(1);
    expect(fake.works, isNotEmpty);

    await fake.loadPage(2);

    expect(fake.works, isNotEmpty, reason: '失败不应清空已有内容');
    expect(fake.works.single.id, 1, reason: '仍是第1页的旧内容，没有被第2页的失败覆盖或清空');
    expect(fake.failure, isNotNull);
    // 若把 `_currentPage = page` 挪到 `await fetchPage(page)` 之前（在真正
    // 拿到响应前就认定翻页成功），这里会变成 2——尽管第 2 页请求实际失败了。
    expect(fake.currentPage, 1, reason: '第2页请求失败，currentPage 不应被推进');
  });

  test('markLoginRequired：清空 works/pagination，并给出 needsLogin=true 的 failure',
      () async {
    // 后果：不清空 works 的话，EnhancedWorkGridView 只在 works.isEmpty 时才
    // 露出错误页，"去登录"按钮会被藏在旧列表后面，用户点不到登录入口。
    final fake = _FakePagedWorks(
      (page) async => _response([_work(1)], totalCount: 10, pageSize: 10),
    );
    await fake.loadPage(1);
    expect(fake.works, isNotEmpty);

    fake.triggerLoginRequired();

    expect(fake.works, isEmpty);
    expect(fake.pagination, isNull);
    expect(fake.failure?.needsLogin, isTrue);
  });

  test('markAuthPending + reloadAfterAuthReady：先清掉 pending 标志，再按 currentPage（非第1页）补载',
      () async {
    // 后果：若 pending 标志不先清掉，canLoad 的 in-flight 守卫会把补载请求
    // 直接吞掉，收藏/推荐页会在鉴权信息恢复后永远停在转圈；若补载回落到
    // 第1页而不是 currentPage，用户会在鉴权恢复后被无声地拽回第一页。
    final fake = _FakePagedWorks(
      (page) async => _response([_work(page)], totalCount: 30, pageSize: 10),
    );
    await fake.loadPage(2); // 让 currentPage=2，与"第1页"区分开
    expect(fake.currentPage, 2);

    fake.triggerAuthPending();
    expect(fake.isLoading, isTrue);

    await fake.triggerReloadAfterAuthReady();

    expect(fake.calledPages, [2, 2], reason: '补载必须真的发出了第二次请求，且页码是2不是1');
    expect(fake.isLoading, isFalse);
  });

  test('dispose：请求在途时销毁，响应之后落地不应抛出（_safeNotify 的守卫）', () async {
    // 背景：SimilarWorksViewModel 构造即发请求，用户在响应回来之前就把页面
    // 弹掉——dispose() 后 finally 里的 notifyListeners() 会踩 ChangeNotifier
    // 的 `_debugAssertNotDisposed`，这是 debug-only 断言，`flutter test` 默认
    // 跑在 debug 模式，是活的：会同步抛出 FlutterError，让 runFetch 返回的
    // Future 带错误完成。所以「completes 不抛错」是一条真断言，不是空判断——
    // 去掉 `_safeNotify` 里的 `if (_disposed) return;` 这行，这个测试就会红。
    final completer = Completer<WorksResponse>();
    final fake = _FakePagedWorks((page) => completer.future);

    // 同步跑到 fetchPage 的 await 为止，进入在途态，再销毁。
    final future = fake.loadPage(1);
    fake.dispose();
    completer.complete(_response([_work(1)], totalCount: 10, pageSize: 10));

    await expectLater(future, completes);
  });

  test('totalPages：分页信息缺失或不完整时必须是 null，不能回落成 1', () async {
    // 后果：一旦回落成 1，每个列表页在真实分页数据到达前都会先闪一个假的
    // "1/1" 分页器，数据到达后再跳成真实值。
    final neverLoaded = _FakePagedWorks(
      (page) async => _response([], totalCount: null, pageSize: null),
    );
    expect(neverLoaded.totalPages, isNull, reason: '还没加载过任何一页，分页信息本就缺失');

    final missingTotalCount = _FakePagedWorks(
      (page) async => _response([_work(1)], totalCount: null, pageSize: 10),
    );
    await missingTotalCount.loadPage(1);
    expect(missingTotalCount.totalPages, isNull);

    final missingPageSize = _FakePagedWorks(
      (page) async => _response([_work(1)], totalCount: 100, pageSize: null),
    );
    await missingPageSize.loadPage(1);
    expect(missingPageSize.totalPages, isNull);
  });
}
