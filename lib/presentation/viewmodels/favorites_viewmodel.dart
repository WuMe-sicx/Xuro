import 'package:flutter/foundation.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/pagination.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/data/services/exceptions/network_exception.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/utils/logger.dart';
import 'package:get_it/get_it.dart';

class FavoritesViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final AuthViewModel _authViewModel;
  List<Work> _works = [];
  bool _isLoading = false;
  String? _error;
  bool _isLoginError = false;
  Pagination? _pagination;
  int _currentPage = 1;

  FavoritesViewModel(this._authViewModel)
      : _apiService = GetIt.I<ApiService>() {
    // 鉴权尚未从本地存储恢复时补挂监听，就绪后补一次加载——防止「先误报
    // 未登录再翻转」的闪烁（同 recommend_viewmodel.dart 的处理）。
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

  List<Work> get works => _works;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// True when [error] is a "not logged in" / auth failure, so the UI can
  /// offer a login action instead of a (useless) retry.
  bool get isLoginError => _isLoginError;
  int get currentPage => _currentPage;
  int? get totalCount => _pagination?.totalCount;
  int? get totalPages =>
      _pagination?.totalCount != null && _pagination?.pageSize != null
          ? (_pagination!.totalCount! / _pagination!.pageSize!).ceil()
          : null;

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

    if (!_authViewModel.isLoggedIn) {
      _error = Strings.loginRequired;
      _isLoginError = true;
      _works = [];
      _pagination = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _isLoginError = false;
    notifyListeners();

    try {
      final response = await _apiService.getFavorites(page: page);
      _works = response.works;
      _pagination = response.pagination;
      _currentPage = page;
      AppLogger.info('第$page页收藏列表加载成功: ${response.works.length}个作品');
    } catch (e) {
      AppLogger.error('加载收藏列表失败', e);
      _error = userMessageOf(e);
      _isLoginError = isAuthErrorOf(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载收藏列表(用于初始加载和刷新)
  Future<void> loadFavorites({bool refresh = false}) async {
    await loadPage(1);
  }
}
