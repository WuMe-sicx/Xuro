import 'package:flutter/foundation.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/pagination.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/presentation/models/load_failure.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/utils/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/core/settings/app_settings_service.dart';

class RecommendViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final AppSettingsService _settings;
  final AuthViewModel _authViewModel;
  List<Work> _works = [];
  bool _isLoading = false;
  LoadFailure? _failure;
  Pagination? _pagination;
  int _currentPage = 1;
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
    _isLoading = false;
    loadPage(_currentPage);
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthReady);
    super.dispose();
  }

  // Getters
  List<Work> get works => _works;
  bool get isLoading => _isLoading;
  LoadFailure? get failure => _failure;
  int get currentPage => _currentPage;
  int? get totalPages =>
      _pagination?.totalCount != null && _pagination?.pageSize != null
          ? (_pagination!.totalCount! / _pagination!.pageSize!).ceil()
          : null;
  bool get hasSubtitle => _settings.hasSubtitleFilter;
  bool get filterPanelExpanded => _filterPanelExpanded;

  Pagination? get pagination => _pagination;

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

  /// 加载指定页面的数据
  Future<void> loadPage(int page) async {
    if (_isLoading) return;
    if (page < 1 || (totalPages != null && page > totalPages!)) return;

    // 鉴权状态尚未从本地存储恢复：保持 loading 而非误报未登录，
    // 等 AuthViewModel 就绪后由 _onAuthReady 补一次加载。
    if (!_authViewModel.isAuthReady) {
      _isLoading = true;
      notifyListeners();
      return;
    }

    // 检查是否已登录
    final uuid = _authViewModel.recommenderUuid;
    if (uuid == null) {
      _failure = const LoadFailure.loginRequired();
      _works = [];
      _pagination = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _failure = null;
    notifyListeners();

    try {
      final response = await _apiService.getRecommendations(
        uuid: uuid,
        page: page,
        hasSubtitle: hasSubtitle, // 添加字幕筛选参数
      );
      _works = response.works;
      _pagination = response.pagination;
      _currentPage = page;
      AppLogger.info('第$page页推荐列表加载成功: ${response.works.length}个作品');
    } catch (e) {
      AppLogger.error('加载推荐列表失败', e);
      _failure = LoadFailure.from(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载推荐列表(用于初始加载和刷新)
  Future<void> loadRecommendations() async {
    await loadPage(1);
  }
}
