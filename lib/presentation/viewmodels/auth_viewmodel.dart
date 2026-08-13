import 'package:flutter/foundation.dart';
import 'package:xuro/data/models/auth/auth_resp/auth_resp.dart';
import 'package:xuro/data/services/auth_service.dart';
import 'package:xuro/data/repositories/auth_repository.dart';
import 'package:xuro/utils/logger.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AuthRepository _authRepository;
  AuthResp? _authData;
  bool _isLoading = false;
  String? _error;
  bool _authReady = false;

  AuthViewModel({
    required AuthService authService,
    required AuthRepository authRepository,
  })  : _authService = authService,
        _authRepository = authRepository {
    _loadSavedAuth();
  }

  Future<void> _loadSavedAuth() async {
    _authData = await _authRepository.getAuthData();
    if (_authData != null) {
      AppLogger.info('加载保存的认证数据: ${_authData?.user?.name}');
    }
    _authReady = true;
    notifyListeners();
  }

  Future<void> login(String name, String password) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('AuthViewModel: 开始登录流程');
      _authData = await _authService.login(name, password);

      // 保存认证数据
      await _authRepository.saveAuthData(_authData!);

      AppLogger.info('''
登录成功，完整数据:
- token: ${_authData?.token}
- loggedIn: ${_authData?.user?.loggedIn}
- name: ${_authData?.user?.name}
- group: ${_authData?.user?.group}
- email: ${_authData?.user?.email}
- recommenderUuid: ${_authData?.user?.recommenderUuid}
      ''');
    } catch (e) {
      AppLogger.error('AuthViewModel: 登录失败', e);
      _error = e.toString();
      _authData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String name,
    String password, {
    String? recommenderUuid,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('AuthViewModel: 开始注册流程');
      _authData = await _authService.register(
        name,
        password,
        recommenderUuid: recommenderUuid,
      );

      await _authRepository.saveAuthData(_authData!);

      AppLogger.info(
        '注册成功: name=${_authData?.user?.name}, group=${_authData?.user?.group}',
      );
    } catch (e) {
      AppLogger.error('AuthViewModel: 注册失败', e);
      _error = e.toString();
      _authData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    AppLogger.info('AuthViewModel: 执行登出');
    AppLogger.info('''
登出用户信息:
- name: ${_authData?.user?.name}
- group: ${_authData?.user?.group}
- token: ${_authData?.token}
    ''');

    await _authRepository.clearAuthData();
    _authData = null;
    notifyListeners();
  }

  bool get isLoggedIn => _authData?.user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// True once the first saved-auth restore has resolved. Callers that key
  /// off [isLoggedIn] on cold start (Favorites/Recommend) must wait for this
  /// before treating a still-loading state as "not logged in" — otherwise
  /// they flash a login prompt before the persisted token has been read.
  bool get isAuthReady => _authReady;

  /// Clears the last login/register error so a freshly opened dialog doesn't
  /// inherit a stale message from a previous attempt.
  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  String? get username => _authData?.user?.name;
  String? get token => _authData?.token;
  String? get group => _authData?.user?.group;
  String? get recommenderUuid => _authData?.user?.recommenderUuid;
}
