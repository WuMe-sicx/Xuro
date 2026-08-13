/// load_failure_test.dart：失败态的文案与恢复路径必须同源。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/data/services/exceptions/network_exception.dart';
import 'package:xuro/presentation/models/load_failure.dart';

DioException _dio(int? status, {DioExceptionType? type}) => DioException(
      requestOptions: RequestOptions(path: '/works'),
      type: type ?? DioExceptionType.badResponse,
      response: status == null
          ? null
          : Response(
              requestOptions: RequestOptions(path: '/works'),
              statusCode: status,
            ),
    );

LoadFailure _from(DioException e) =>
    LoadFailure.from(NetworkException.fromDioException(e));

void main() {
  group('from —— 文案与恢复路径同源', () {
    test('401 / 403 → 请先登录 + 走登录', () {
      for (final code in [401, 403]) {
        final f = _from(_dio(code));
        expect(f.needsLogin, isTrue, reason: '$code');
        expect(f.message, Strings.loginRequired, reason: '$code');
      }
    });

    test('连接失败 / 超时 → VPN 提示 + 走重试', () {
      for (final t in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final f = _from(_dio(null, type: t));
        expect(f.needsLogin, isFalse, reason: '$t');
        expect(f.message, Strings.networkVpnHint, reason: '$t');
      }
    });

    test('500 → 非鉴权，走重试', () {
      final f = _from(_dio(500));
      expect(f.needsLogin, isFalse);
      expect(f.message, isNotEmpty);
    });

    test('非 NetworkException 一律回落通用文案，不上屏异常 dump', () {
      final f = LoadFailure.from(StateError('boom'));
      expect(f.message, Strings.loadFailed);
      expect(f.needsLogin, isFalse);
      expect(f.message, isNot(contains('boom')));
    });

    test('needsLogin 与文案不会分叉——凡是登录文案必然 needsLogin', () {
      // 这条是整个值类型存在的理由：此前 error 与 isLoginError 是两个字段，
      // 屏幕可能只拿到其中一个，于是 401 渲染成「请先登录」配「重试」。
      for (final e in [
        _dio(401),
        _dio(403),
        _dio(500),
        _dio(null, type: DioExceptionType.connectionError),
      ]) {
        final f = _from(e);
        expect(f.needsLogin, f.message == Strings.loginRequired,
            reason: '$e');
      }
    });
  });

  group('loginRequired —— 请求未发出的早返回', () {
    test('直接给登录文案与登录路径', () {
      const f = LoadFailure.loginRequired();
      expect(f.message, Strings.loginRequired);
      expect(f.needsLogin, isTrue);
    });

    test('与 401 推导出的失败态相等', () {
      expect(_from(_dio(401)), const LoadFailure.loginRequired());
    });
  });

  group('值语义', () {
    test('相等性按内容', () {
      expect(const LoadFailure('x'), const LoadFailure('x'));
      expect(const LoadFailure('x'), isNot(const LoadFailure('y')));
      expect(const LoadFailure('x'),
          isNot(const LoadFailure('x', needsLogin: true)));
    });

    test('默认不走登录——但默认值只在显式构造时出现，不再是屏幕忘记传的后果', () {
      expect(const LoadFailure('x').needsLogin, isFalse);
    });
  });
}
