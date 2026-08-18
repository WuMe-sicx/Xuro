import 'package:flutter/foundation.dart';
import 'package:xuro/data/models/works/works_response.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/presentation/viewmodels/base/paginated_works_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/core/settings/app_settings_service.dart';

class RecommendViewModel extends ChangeNotifier with PagedWorks {
  final ApiService _apiService;
  final AppSettingsService _settings;
  final AuthViewModel _authViewModel;
  bool _filterPanelExpanded = false;

  RecommendViewModel(this._authViewModel)
      : _apiService = GetIt.I<ApiService>(),
        _settings = GetIt.I<AppSettingsService>() {
    // 首载改由内容 widget 的 postFrameCallback 触发（见 recommend_content.dart），
    // 避免所有 tab 的 VM 在启动时一起并发发请求。鉴权尚未就绪时补挂监听，
    // 就绪后自动补一次首载，防止「先误报未登录再翻转」的闪烁。
    if (!_authViewModel.isAuthReady) {
      _authViewModel.addListener(_onAuthReady);
    }
  }

  void _onAuthReady() {
    if (!_authViewModel.isAuthReady) return;
    _authViewModel.removeListener(_onAuthReady);
    reloadAfterAuthReady();
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthReady);
    super.dispose();
  }

  @override
  String get pageName => '推荐列表';

  bool get hasSubtitle => _settings.hasSubtitleFilter;
  bool get filterPanelExpanded => _filterPanelExpanded;

  // 切换字幕筛选
  void toggleSubtitleFilter() {
    _settings.setHasSubtitleFilter(!_settings.hasSubtitleFilter);
    notifyListeners();
    loadRecommendations(); // 刷新列表
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
  Future<WorksResponse> fetchPage(int page) {
    // uuid 的登录门禁在 loadPage 里（为空要走 markLoginRequired 给「去登录」，
    // 不是给一个加载失败）。这里之所以还要再读一次，是因为 fetchPage 的签名固定，
    // 传不进来——不是在重复那道门禁。真读到 null 说明门禁被绕过了（例如有人直接
    // 调了 fetchPage），抛出去由 runFetch 兜成一次普通失败，好过崩在 `!` 上。
    final uuid = _authViewModel.recommenderUuid;
    if (uuid == null) {
      throw StateError('recommenderUuid 为空却走到了取数：loadPage 的登录门禁被绕过');
    }
    return _apiService.getRecommendations(
      uuid: uuid,
      page: page,
      hasSubtitle: hasSubtitle, // 添加字幕筛选参数
    );
  }

  @override
  Future<void> loadPage(int page) async {
    if (!canLoad(page)) return;

    // 鉴权状态尚未从本地存储恢复：保持 loading 而非误报未登录，
    // 等 AuthViewModel 就绪后由 _onAuthReady 补一次加载。
    if (!_authViewModel.isAuthReady) {
      markAuthPending();
      return;
    }

    // 检查是否已登录
    final uuid = _authViewModel.recommenderUuid;
    if (uuid == null) {
      markLoginRequired();
      return;
    }

    await runFetch(page);
  }

  /// 加载推荐列表(用于初始加载和刷新)
  Future<void> loadRecommendations() async {
    await loadPage(1);
  }
}
