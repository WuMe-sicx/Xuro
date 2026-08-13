import 'package:dio/dio.dart';
import 'package:xuro/common/constants/strings.dart';

enum NetworkErrorType {
  timeout,
  connectionError,
  serverError,
  clientError,
  authError,
  cancelled,
  unknown,
}

class NetworkException implements Exception {
  final NetworkErrorType type;
  final String message;
  final int? statusCode;
  final dynamic originalError;

  NetworkException({
    required this.type,
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory NetworkException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException(
          type: NetworkErrorType.timeout,
          message: '请求超时: ${e.message}',
          originalError: e,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          type: NetworkErrorType.connectionError,
          message: '连接失败: ${e.message}',
          originalError: e,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          type: NetworkErrorType.cancelled,
          message: '请求已取消',
          originalError: e,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return NetworkException(
            type: NetworkErrorType.authError,
            message: '认证失败: $statusCode',
            statusCode: statusCode,
            originalError: e,
          );
        } else if (statusCode != null &&
            statusCode >= 400 &&
            statusCode < 500) {
          return NetworkException(
            type: NetworkErrorType.clientError,
            message: '客户端错误: $statusCode',
            statusCode: statusCode,
            originalError: e,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return NetworkException(
            type: NetworkErrorType.serverError,
            message: '服务器错误: $statusCode',
            statusCode: statusCode,
            originalError: e,
          );
        }
        return NetworkException(
          type: NetworkErrorType.unknown,
          message: '未知响应错误: $statusCode',
          statusCode: statusCode,
          originalError: e,
        );
      case DioExceptionType.badCertificate:
        return NetworkException(
          type: NetworkErrorType.connectionError,
          message: '证书验证失败: ${e.message}',
          originalError: e,
        );
      case DioExceptionType.unknown:
        return NetworkException(
          type: NetworkErrorType.unknown,
          message: '未知网络错误: ${e.message}',
          originalError: e,
        );
    }
  }

  bool get isAuthError => type == NetworkErrorType.authError;

  /// User-facing message. asmr.one is geo-blocked, so any connection failure
  /// or timeout almost always means the user's VPN is off — surface that
  /// actionable hint instead of the raw Dio reason. Auth failures map to the
  /// "please log in" prompt so callers can offer a login action. Everything
  /// else falls back to the technical [message].
  String get userMessage {
    switch (type) {
      case NetworkErrorType.connectionError:
      case NetworkErrorType.timeout:
        return Strings.networkVpnHint;
      case NetworkErrorType.authError:
        return Strings.loginRequired;
      default:
        return message;
    }
  }

  @override
  String toString() => 'NetworkException($type): $message';
}

/// VM 层错误翻译的统一入口：`NetworkException` 走 [NetworkException.userMessage]，
/// 其余异常（解析失败、断言等未包装的原始 Dart 异常）一律回落到通用文案——
/// 调用方不应再各自写 `e.toString()`，那会把英文异常 dump 直接上屏。
String userMessageOf(Object e) =>
    e is NetworkException ? e.userMessage : Strings.loadFailed;

/// 与 [userMessageOf] 配套：非 `NetworkException` 一律视为非鉴权错误。
bool isAuthErrorOf(Object e) => e is NetworkException && e.isAuthError;
