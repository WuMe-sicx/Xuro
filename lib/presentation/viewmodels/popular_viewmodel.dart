import 'package:xuro/presentation/viewmodels/base/paginated_works_viewmodel.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/data/models/works/works_response.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/core/settings/app_settings_service.dart';

class PopularViewModel extends PaginatedWorksViewModel {
  final AppSettingsService _settings = GetIt.I<AppSettingsService>();
  bool _filterPanelExpanded = false;

  PopularViewModel() : super(GetIt.I<ApiService>());

  bool get hasSubtitle => _settings.hasSubtitleFilter;
  bool get filterPanelExpanded => _filterPanelExpanded;

  void toggleSubtitleFilter() {
    _settings.setHasSubtitleFilter(!_settings.hasSubtitleFilter);
    notifyListeners();
    refresh(); // 刷新列表
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

  @override
  String get pageName => '热门列表';

  @override
  Future<WorksResponse> fetchPage(int page) {
    return apiService.getPopular(
      page: page,
      hasSubtitle: hasSubtitle,
    );
  }
}
