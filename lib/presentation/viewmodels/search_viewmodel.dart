import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/data/models/works/works_response.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/presentation/viewmodels/base/paginated_works_viewmodel.dart';
import 'package:xuro/utils/logger.dart';

class SearchViewModel extends ChangeNotifier with PagedWorks {
  final _apiService = GetIt.I<ApiService>();

  String _keyword = '';
  String get keyword => _keyword;

  bool _hasSubtitle = false;
  bool get hasSubtitle => _hasSubtitle;

  String _order = 'create_date'; // 默认按创建时间
  String get order => _order;

  String _sort = 'desc'; // 默认降序
  String get sort => _sort;

  @override
  String get pageName => '搜索结果';

  @override
  Future<WorksResponse> fetchPage(int page) => _apiService.searchWorks(
        keyword: _keyword,
        page: page,
        order: _order,
        sort: _sort,
        hasSubtitle: _hasSubtitle,
      );

  /// 与其余列表不同，这里回落 1 而不是 null：`grid_content.dart` 只在 totalPages
  /// 非空时渲染分页器，搜索页要在拿到 pagination 之前就把分页器摆在那里。
  @override
  int get totalPages => super.totalPages ?? 1;

  void toggleSubtitle() {
    _hasSubtitle = !_hasSubtitle;
    notifyListeners();
    if (_keyword.isNotEmpty) {
      search(_keyword);
    }
  }

  void setOrder(String order, String sort) {
    _order = order;
    _sort = sort;
    notifyListeners();
    if (_keyword.isNotEmpty) {
      search(_keyword);
    }
  }

  /// 执行搜索
  ///
  /// 故意不走 [loadPage]/`canLoad`：切换字幕筛选或排序时要能在请求途中立刻
  /// 重发一次，最后一次写入生效，而不是被 in-flight 守卫吞掉。
  Future<void> search(String keyword, {int page = 1}) async {
    if (keyword.isEmpty) return;
    _keyword = keyword;
    AppLogger.info('搜索关键词: $keyword'); // 页码由 runFetch 自己记
    await runFetch(page);
  }

  /// 加载指定页
  @override
  Future<void> loadPage(int page) async {
    if (_keyword.isEmpty) return;
    await search(_keyword, page: page);
  }

  /// 清空搜索结果
  void clear() {
    resetPagedState();
    _keyword = '';
    notifyListeners();
  }
}
