import 'package:dio/dio.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/data/models/auth/auth_resp/auth_resp.dart';
import 'package:xuro/data/services/exceptions/network_exception.dart';
import '../../utils/logger.dart';

/// Thrown when `/auth/reg` succeeded (account exists on the server) but the
/// follow-up auto-login call failed. The account is real; the user just needs
/// to log in manually with the credentials they just submitted.
class RegisteredButNotLoggedInException implements Exception {
  const RegisteredButNotLoggedInException(this.cause);
  final Object cause;

  @override
  String toString() => Strings.registerOkButLoginFailed;
}

class AuthService {
  final AppSettingsService _settings;
  final Dio _dio;

  AuthService({required AppSettingsService settings})
      : _settings = settings,
        _dio = Dio(
          BaseOptions(
            baseUrl: settings.serverUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 15),
          ),
        ) {
    _settings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (_dio.options.baseUrl != _settings.serverUrl) {
      _dio.options.baseUrl = _settings.serverUrl;
      AppLogger.info('Auth API 服务器已切换: ${_settings.serverUrl}');
    }
  }

  Future<AuthResp> login(String name, String password) async {
    try {
      AppLogger.info('开始登录请求: name=$name, baseUrl=${_dio.options.baseUrl}');
      final response = await _dio.post(
        '/auth/me',
        data: {
          'name': name,
          'password': password,
        },
      );

      AppLogger.info('收到登录响应: statusCode=${response.statusCode}');

      if (response.statusCode == 200) {
        final authResp = AuthResp.fromJson(response.data);
        AppLogger.info(
          '登录成功: username=${authResp.user?.name}, group=${authResp.user?.group}',
        );
        return authResp;
      }

      throw Exception('登录失败: ${response.statusCode}');
    } on DioException catch (e) {
      AppLogger.error('登录请求失败', e);
      AppLogger.error('错误详情: ${e.response?.data}');
      throw NetworkException.fromDioException(e);
    } catch (e) {
      AppLogger.error('登录失败', e);
      throw Exception('登录失败: $e');
    }
  }

  /// Registers a new account via `POST /auth/reg` and returns an authenticated
  /// [AuthResp]. If the server response omits a token (i.e. doesn't auto-login
  /// on register), this transparently calls [login] with the same credentials
  /// so callers can treat register and login as equivalent state transitions.
  Future<AuthResp> register(
    String name,
    String password, {
    String? recommenderUuid,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'password': password,
      };
      if (recommenderUuid != null && recommenderUuid.isNotEmpty) {
        body['recommenderUuid'] = recommenderUuid;
      }

      AppLogger.info(
        '开始注册请求: name=$name, hasRecommender=${body.containsKey('recommenderUuid')}, baseUrl=${_dio.options.baseUrl}',
      );
      final response = await _dio.post('/auth/reg', data: body);
      AppLogger.info('收到注册响应: statusCode=${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = response.data;
        if (raw is Map<String, dynamic>) {
          final authResp = AuthResp.fromJson(raw);
          if (authResp.token != null && authResp.user != null) {
            AppLogger.info('注册成功且已携带 token，跳过补充登录');
            return authResp;
          }
        }
        AppLogger.info('注册成功但响应未携带 token/user，回退到 login 兜底');
        try {
          return await login(name, password);
        } catch (loginErr) {
          // Account creation already succeeded server-side. Surface a distinct
          // exception so callers can guide the user to log in manually instead
          // of asking them to "retry" the registration (which would now fail
          // with "name already exists").
          AppLogger.error('注册成功但自动登录失败', loginErr);
          throw RegisteredButNotLoggedInException(loginErr);
        }
      }

      throw Exception('注册失败: ${response.statusCode}');
    } on RegisteredButNotLoggedInException {
      rethrow;
    } on DioException catch (e) {
      AppLogger.error('注册请求失败', e);
      AppLogger.error('错误详情: ${e.response?.data}');
      throw NetworkException.fromDioException(e);
    } catch (e) {
      AppLogger.error('注册失败', e);
      throw Exception('注册失败: $e');
    }
  }
}
