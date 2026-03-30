import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/data/repositories/auth_repository.dart';
import 'package:xuro/utils/logger.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options, 
    RequestInterceptorHandler handler,
  ) async {
    try {
      final authRepository = GetIt.I<AuthRepository>();
      final authData = await authRepository.getAuthData();
      
      if (authData?.token != null) {
        options.headers['Authorization'] = 'Bearer ${authData!.token}';
      }
      
      handler.next(options);
    } catch (e) {
      AppLogger.error('AuthInterceptor: 处理请求失败', e);
      handler.next(options);  // 即使出错也继续请求
    }
  }
} 