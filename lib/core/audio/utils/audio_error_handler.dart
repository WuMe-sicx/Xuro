import 'package:xuro/utils/logger.dart';

enum AudioErrorType {
  playback,    // 播放错误
  playlist,    // 播放列表错误
  state,       // 状态错误
  context,     // 上下文错误
  init,        // 初始化错误
}

class AudioError implements Exception {
  final AudioErrorType type;
  final String message;
  final dynamic originalError;

  AudioError(this.type, this.message, [this.originalError]);

  @override
  String toString() => '$message${originalError != null ? ': $originalError' : ''}';
}

class AudioErrorHandler {
  static void handleError(
    AudioErrorType type,
    String operation,
    dynamic error, [
    StackTrace? stack,
  ]) {
    final message = _getErrorMessage(type, operation);
    AppLogger.error(message, error, stack);
  }
  
  static Never throwError(
    AudioErrorType type,
    String operation,
    dynamic error,
  ) {
    final message = _getErrorMessage(type, operation);
    throw AudioError(type, message, error);
  }

  static String _getErrorMessage(AudioErrorType type, String operation) {
    switch (type) {
      case AudioErrorType.playback:
        return '播放操作失败: $operation';
      case AudioErrorType.playlist:
        return '播放列表操作失败: $operation';
      case AudioErrorType.state:
        return '状态操作失败: $operation';
      case AudioErrorType.context:
        return '上下文操作失败: $operation';
      case AudioErrorType.init:
        return '初始化失败: $operation';
    }
  }
} 