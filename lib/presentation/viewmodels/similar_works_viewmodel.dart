import 'package:flutter/foundation.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/works_response.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/presentation/viewmodels/base/paginated_works_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/core/settings/app_settings_service.dart';

class SimilarWorksViewModel extends ChangeNotifier with PagedWorks {
  final ApiService _apiService;
  final AppSettingsService _settings;
  final Work work;
  bool _filterPanelExpanded = false;

  SimilarWorksViewModel(this.work)
      : _apiService = GetIt.I<ApiService>(),
        _settings = GetIt.I<AppSettingsService>() {
    // 共享筛选值由 AppSettingsService 同步提供，构造即可直接首载。
    loadSimilarWorks();
  }

  @override
  String get pageName => '相关推荐';

  @override
  Future<WorksResponse> fetchPage(int page) => _apiService.getItemNeighbors(
        itemId: work.id.toString(),
        page: page,
        hasSubtitle: hasSubtitle,
      );

  bool get hasSubtitle => _settings.hasSubtitleFilter;
  bool get filterPanelExpanded => _filterPanelExpanded;

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

  /// 加载相关推荐(用于初始加载和刷新)
  Future<void> loadSimilarWorks() async {
    await loadPage(1);
  }
}
