import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/data/services/exceptions/network_exception.dart';

void main() {
  group('userMessageOf / isAuthErrorOf', () {
    test('非 NetworkException 回落到通用文案，不出现 Dart 异常 dump', () {
      final message = userMessageOf(StateError('x'));
      expect(message, Strings.loadFailed);
      expect(message.contains('Instance of'), isFalse);
    });

    test('鉴权失败的 NetworkException 映射为登录提示', () {
      final e = NetworkException(
        type: NetworkErrorType.authError,
        message: '认证失败: 401',
        statusCode: 401,
      );
      expect(userMessageOf(e), Strings.loginRequired);
      expect(isAuthErrorOf(e), isTrue);
    });

    test('非 NetworkException 一律视为非鉴权错误', () {
      expect(isAuthErrorOf(Exception('boom')), isFalse);
    });
  });
}
