import 'package:dio/dio.dart';
import 'package:xuro/common/constants/strings.dart';

/// 检查更新的错误分类。
///
/// **刻意不复用 `NetworkException`**：后者的 `userMessage` 强绑定 asmr.one
/// 语义（403/401 → 「请先登录」、连接失败 → 「请先连接 VPN 服务」，因为
/// asmr.one 被地理封锁）。GitHub 不被地理封锁，且 403/429 是 rate limit 而
/// 非鉴权失败——直接复用会给用户错误的恢复指引。
enum UpdateErrorType {
  /// 连接失败 / 超时 / 证书 / 无响应的未知网络错误。
  network,

  /// GitHub 未鉴权 REST API 限流：60 次/小时/IP，超限返回 403 或 429。
  rateLimited,

  /// 仓库 / releases 端点 404。
  notFound,

  /// 列表为空，或没有任何 tag 形如 `vX.Y.Z` 的合法发布。
  noRelease,

  /// 响应 JSON 结构非法 / 缺关键字段。
  invalidPayload,

  /// 其它未归类错误。
  unknown,
}

class UpdateException implements Exception {
  final UpdateErrorType type;

  /// 技术描述，仅用于日志，不直接展示给用户。
  final String message;
  final int? statusCode;
  final dynamic originalError;

  UpdateException({
    required this.type,
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory UpdateException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return UpdateException(
          type: UpdateErrorType.network,
          message: '网络错误: ${e.message}',
          originalError: e,
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 403 || code == 429) {
          // 公开只读端点的 403/429 ≈ 未鉴权限流（GitHub 文档）。
          return UpdateException(
            type: UpdateErrorType.rateLimited,
            message: 'GitHub 限流: $code',
            statusCode: code,
            originalError: e,
          );
        }
        if (code == 404) {
          return UpdateException(
            type: UpdateErrorType.notFound,
            message: '未找到发布信息: 404',
            statusCode: code,
            originalError: e,
          );
        }
        return UpdateException(
          type: UpdateErrorType.unknown,
          message: '响应错误: $code',
          statusCode: code,
          originalError: e,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return UpdateException(
          type: UpdateErrorType.network,
          message: '网络错误: ${e.message}',
          originalError: e,
        );
    }
  }

  /// 面向用户的恢复指引文案。
  String get userMessage {
    switch (type) {
      case UpdateErrorType.network:
        return Strings.updateErrorNetwork;
      case UpdateErrorType.rateLimited:
        return Strings.updateErrorRateLimited;
      case UpdateErrorType.notFound:
        return Strings.updateErrorNotFound;
      case UpdateErrorType.noRelease:
        return Strings.updateErrorNoRelease;
      case UpdateErrorType.invalidPayload:
        return Strings.updateErrorInvalidPayload;
      case UpdateErrorType.unknown:
        return Strings.updateErrorUnknown;
    }
  }

  @override
  String toString() => 'UpdateException($type): $message';
}
