/// paginated_works_viewmodel.dart：分页作品列表的共用状态机（mixin）与首载协议（基类）。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2024-12-16
library;

import 'package:flutter/foundation.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/pagination.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/data/models/works/works_response.dart';
import 'package:xuro/presentation/models/load_failure.dart';
import 'package:xuro/utils/logger.dart';

/// 分页作品列表的状态机：谁在加载、失败是什么、现在第几页。
///
/// 存在的理由是一次已经付过的代价：候选 D 给 11 个列表换上 `LoadFailure` 时，
/// 这 25 行状态机在 5 个 VM 里各有一份手抄件，**8 屏抄错**（错误页给出了错误的
/// 恢复动作）。收敛之后，下一次横切改动只需要改这里。
///
/// **故意留在外面的三样东西**——它们才是各 VM 真正不同的地方，不要为它们开钩子：
/// - **前置条件**：收藏查 `isLoggedIn`，推荐查 `recommenderUuid`。这两个覆写
///   [loadPage]，先过 [canLoad] 再判自己的条件，最后调 [runFetch]。
///   **搜索页不属于这一类**：它的「关键词非空」不是加在 [canLoad] 之前的一道额外
///   门，而是**整个绕开 [canLoad]**——见 `SearchViewModel.search` 的注释。不要为了
///   「统一」把它接回 [loadPage]，那会让筛选/排序在请求途中静默失效。
/// - **空闲态**：只有搜索页有「什么都没搜过」这个状态（[resetPagedState]）。
/// - **构造形状**：相关推荐构造即加载，主页/热门走 [PaginatedWorksViewModel.ensureFirstLoad]。
///
/// 五个状态字段是库级私有，子类够不着——这是要的。四个状态迁移
/// （[markAuthPending] / [reloadAfterAuthReady] / [markLoginRequired] /
/// [resetPagedState]）只能走这里提供的方法，抄错的机会由语言堵死。
mixin PagedWorks on ChangeNotifier {
  List<Work> _works = [];
  bool _isLoading = false;
  LoadFailure? _failure;
  Pagination? _pagination;
  int _currentPage = 1;
  bool _disposed = false;

  List<Work> get works => _works;
  bool get isLoading => _isLoading;
  LoadFailure? get failure => _failure;
  int get currentPage => _currentPage;
  Pagination? get pagination => _pagination;

  /// `null` = 还不知道总页数。`grid_content.dart` 只在 `totalPages != null` 时渲染
  /// 分页器，所以「不知道」必须能表达出来，不能回落 1——否则首屏会先闪一个 `1/1`
  /// 的分页器。搜索页故意覆写成非空，理由见 `SearchViewModel.totalPages`。
  int? get totalPages =>
      _pagination?.totalCount != null && _pagination?.pageSize != null
          ? (_pagination!.totalCount! / _pagination!.pageSize!).ceil()
          : null;

  /// 日志用的列表名，也是错误日志里唯一能区分调用方的东西。
  String get pageName;

  /// 一次取数。这是唯一需要子类实现的东西。
  /// 只该由 [runFetch] 调用——它的前置条件（例如推荐页的 uuid 非空）由各 VM 的
  /// [loadPage] 覆写把关，绕开那道关直接调它是未定义行为。
  @protected
  Future<WorksResponse> fetchPage(int page);

  /// 请求飞在半空时页面被弹掉：`dispose()` 之后再 `notifyListeners()` 会踩
  /// `ChangeNotifier` 的 assert。相关推荐是构造即发请求的（`SimilarWorksViewModel`），
  /// 进去马上返回就能撞上。仓库为这件事已经付过一次代价——见 `UpdateViewModel`
  /// 的 `_disposed` 守卫，那里是对话框中途被关掉。
  ///
  /// 这里是全部 6 个列表 VM 唯一的 `notifyListeners()` 出口，守卫装一处就够了。
  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// [loadPage] 的两道通用守卫。
  ///
  /// 有前置条件的 VM 要在**自己的条件之前**先过这一关，顺序不能换：鉴权分支会写
  /// `_isLoading`，排到 in-flight 守卫之前，会在已经在加载时重复发通知。
  @protected
  bool canLoad(int page) =>
      !_isLoading && page >= 1 && (totalPages == null || page <= totalPages!);

  /// 带守卫的加载。有前置条件的 VM 覆写它：`canLoad` → 自己的条件 → [runFetch]。
  Future<void> loadPage(int page) async {
    if (!canLoad(page)) return;
    await runFetch(page);
  }

  /// 不带守卫的取数主体。
  ///
  /// 与 [loadPage] 分成两个入口，是因为搜索页要跳过守卫：它没有 in-flight 守卫是
  /// **行为不是疏漏**——筛选/排序在请求途中被点击时要能立刻重发，最后一次写入生效。
  @protected
  Future<void> runFetch(int page) async {
    _isLoading = true;
    _failure = null;
    _safeNotify();

    try {
      AppLogger.info('加载$pageName: 第$page页');
      final response = await fetchPage(page);
      _works = response.works;
      _pagination = response.pagination;
      _currentPage = page;
      AppLogger.info('第$page页$pageName加载成功: ${response.works.length}个作品');
    } catch (e) {
      // 故意不清空 _works：翻页失败时旧内容要留在屏幕上，由
      // EnhancedWorkGridView 的 works.isEmpty 守卫决定是否让位给错误页。
      // 清掉它会让「第 2 页失败」抹掉第 1 页，整屏变错误页。
      AppLogger.error('加载$pageName失败', e);
      _failure = LoadFailure.from(e);
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// 鉴权状态还没从本地存储恢复：停在 loading，不要先误报未登录再翻转。
  ///
  /// 这个 loading 标志**不会在本路径上被清掉**，必须由 [reloadAfterAuthReady]
  /// 接手——两者成对使用。
  @protected
  void markAuthPending() {
    _isLoading = true;
    _safeNotify();
  }

  /// [markAuthPending] 之后的补载。
  ///
  /// 先放掉那个 loading 标志，否则 [canLoad] 会把这次补载吞掉、页面永远转圈。
  /// 回到 [currentPage] 而不是第 1 页：鉴权补载要停在用户原来那一页。
  @protected
  Future<void> reloadAfterAuthReady() async {
    _isLoading = false;
    await loadPage(_currentPage);
  }

  /// 请求还没发就知道要登录。
  ///
  /// **必须清空列表**：`EnhancedWorkGridView` 只在 `works.isEmpty` 时让错误页出来，
  /// 留着旧列表会把「去登录」按钮藏在它后面。
  @protected
  void markLoginRequired() {
    _failure = const LoadFailure.loginRequired();
    _works = [];
    _pagination = null;
    _safeNotify();
  }

  /// 回到「什么都还没加载过」的初始态。目前只有搜索页的 `clear()` 需要。
  /// 不发通知——调用方通常还要清自己的字段，由它统一发一次。
  @protected
  void resetPagedState() {
    _works = [];
    _failure = null;
    _pagination = null;
    _currentPage = 1;
  }
}

/// 首载协议：主页与热门共用。
///
/// 只装「什么时候发第一次请求」这一件事——收藏/推荐/相关推荐/搜索各有各的首载
/// 形状，并不需要它。把它并进 [PagedWorks] 会让那 4 个 VM 白拿一个永不调用的
/// `ensureFirstLoad`。
abstract class PaginatedWorksViewModel extends ChangeNotifier with PagedWorks {
  final ApiService _apiService;
  bool _firstLoadTriggered = false;

  PaginatedWorksViewModel(this._apiService);

  /// 首载入口：由内容 widget 在挂载后的 postFrameCallback 中调用，而非
  /// 构造函数——构造即请求会让所有 tab 的 VM 在启动时一起并发发请求。
  /// 幂等：重复调用不重复请求（keep-alive 的 tab 回切不会重新触发）。
  Future<void> ensureFirstLoad() async {
    if (_firstLoadTriggered) return;
    _firstLoadTriggered = true;
    await onInit();
    loadPage(1);
  }

  /// 首载前的准备钩子（主页用它读回持久化的排序）。
  Future<void> onInit() async {}

  /// 获取 ApiService 实例，供子类使用
  ApiService get apiService => _apiService;

  Future<void> refresh() async {
    AppLogger.info('刷新$pageName');
    await loadPage(1);
  }

  @override
  void dispose() {
    AppLogger.info('销毁$pageName ViewModel');
    super.dispose();
  }
}
