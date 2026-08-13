import 'package:flutter/foundation.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/pagination.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/presentation/models/load_failure.dart';
import 'package:xuro/utils/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/core/settings/app_settings_service.dart';

class SimilarWorksViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final AppSettingsService _settings;
  final Work work;
  List<Work> _works = [];
  bool _isLoading = false;
  LoadFailure? _failure;
  Pagination? _pagination;
  int _currentPage = 1;
  bool _filterPanelExpanded = false;

  SimilarWorksViewModel(this.work)
      : _apiService = GetIt.I<ApiService>(),
        _settings = GetIt.I<AppSettingsService>() {
    // 共享筛选值由 AppSettingsService 同步提供，构造即可直接首载。
    loadSimilarWorks();
  }

  // Getters
  List<Work> get works => _works;
  bool get isLoading => _isLoading;
  LoadFailure? get failure => _failure;
  int get currentPage => _currentPage;
  bool get hasSubtitle => _settings.hasSubtitleFilter;
  bool get filterPanelExpanded => _filterPanelExpanded;
  int? get totalPages =>
      _pagination?.totalCount != null && _pagination?.pageSize != null
          ? (_pagination!.totalCount! / _pagination!.pageSize!).ceil()
          : null;

  // 切换字幕筛选
  void toggleSubtitleFilter() {
    _settings.setHasSubtitleFilter(!_settings.hasSubtitleFilter);
    notifyListeners();
    loadSimilarWorks();
  }

  void toggleFilterPanel() {
    _filterPanelExpanded = !_filterPanelExpanded;
    notifyListeners();
  }

  void closeFilterPanel() {
    if (_filterPanelExpanded) {
      _filterPanelExpanded = false;
      notifyListeners();
    }
  }

  /// 加载指定页面的数据
  Future<void> loadPage(int page) async {
    if (_isLoading) return;
    if (page < 1 || (totalPages != null && page > totalPages!)) return;

    _isLoading = true;
    _failure = null;
    notifyListeners();

    try {
      final response = await _apiService.getItemNeighbors(
        itemId: work.id.toString(),
        page: page,
        hasSubtitle: hasSubtitle, // 添加字幕筛选参数
      );
      _works = response.works;
      _pagination = response.pagination;
      _currentPage = page;
      AppLogger.info('第$page页相关推荐加载成功: ${response.works.length}个作品');
    } catch (e) {
      AppLogger.error('加载相关推荐失败', e);
      _failure = LoadFailure.from(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载相关推荐(用于初始加载和刷新)
  Future<void> loadSimilarWorks() async {
    await loadPage(1);
  }
}
