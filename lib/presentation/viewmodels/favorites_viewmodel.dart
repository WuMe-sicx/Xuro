import 'package:flutter/foundation.dart';
import 'package:xuro/data/models/works/works_response.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/presentation/viewmodels/base/paginated_works_viewmodel.dart';
import 'package:get_it/get_it.dart';

class FavoritesViewModel extends ChangeNotifier with PagedWorks {
  final ApiService _apiService;
  final AuthViewModel _authViewModel;

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
    reloadAfterAuthReady();
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthReady);
    super.dispose();
  }

  @override
  String get pageName => '收藏列表';

  /// `main_screen.dart` 用它渲染收藏 Tab 的 AppBar 标题。
  int? get totalCount => pagination?.totalCount;

  @override
  Future<WorksResponse> fetchPage(int page) =>
      _apiService.getFavorites(page: page);

  @override
  Future<void> loadPage(int page) async {
    if (!canLoad(page)) return;

    // 鉴权状态尚未从本地存储恢复：保持 loading 而非误报未登录，
    // 等 AuthViewModel 就绪后由 _onAuthReady 补一次加载。
    if (!_authViewModel.isAuthReady) {
      markAuthPending();
      return;
    }

    if (!_authViewModel.isLoggedIn) {
      markLoginRequired();
      return;
    }

    await runFetch(page);
  }

  /// 加载收藏列表(用于初始加载和刷新)
  Future<void> loadFavorites() async {
    await loadPage(1);
  }
}
