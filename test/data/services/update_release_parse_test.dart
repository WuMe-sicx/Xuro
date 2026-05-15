import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/data/models/update_info.dart';
import 'package:xuro/data/services/exceptions/update_exception.dart';

void main() {
  group('UpdateInfo.fromReleaseJson 正常解析', () {
    test('取出 tag/version/body/html_url 及首个 .apk 直链', () {
      final info = UpdateInfo.fromReleaseJson({
        'tag_name': 'v1.2.3',
        'html_url': 'https://github.com/WuMe-sicx/Xuro/releases/tag/v1.2.3',
        'body': '  更新内容  ',
        'published_at': '2026-05-15T00:00:00Z',
        'assets': [
          {
            'name': 'app-release.aab',
            'browser_download_url': 'https://example.com/app-release.aab',
          },
          {
            'name': 'app-release.apk',
            'browser_download_url': 'https://example.com/app-release.apk',
          },
          {
            'name': 'second.apk',
            'browser_download_url': 'https://example.com/second.apk',
          },
        ],
      });

      expect(info.tagName, 'v1.2.3');
      expect(info.version, '1.2.3');
      expect(info.releaseNotes, '更新内容');
      expect(info.htmlUrl,
          'https://github.com/WuMe-sicx/Xuro/releases/tag/v1.2.3');
      expect(info.apkDownloadUrl, 'https://example.com/app-release.apk',
          reason: '应取首个 .apk，跳过 .aab');
      expect(info.publishedAt, '2026-05-15T00:00:00Z');
    });
  });

  group('UpdateInfo.fromReleaseJson 边界', () {
    test('缺 tag_name → FormatException', () {
      expect(
        () => UpdateInfo.fromReleaseJson({
          'html_url': 'https://x/y',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('缺 html_url → FormatException', () {
      expect(
        () => UpdateInfo.fromReleaseJson({
          'tag_name': 'v1.0.0',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('无 assets 字段 → apkDownloadUrl 为 null', () {
      final info = UpdateInfo.fromReleaseJson({
        'tag_name': 'v1.0.0',
        'html_url': 'https://x/y',
      });
      expect(info.apkDownloadUrl, isNull);
    });

    test('有 assets 但无 .apk → apkDownloadUrl 为 null', () {
      final info = UpdateInfo.fromReleaseJson({
        'tag_name': 'v1.0.0',
        'html_url': 'https://x/y',
        'assets': [
          {
            'name': 'app-release.aab',
            'browser_download_url': 'https://example.com/app-release.aab',
          },
          {
            'name': 'app-release.ipa',
            'browser_download_url': 'https://example.com/app-release.ipa',
          },
        ],
      });
      expect(info.apkDownloadUrl, isNull);
    });

    test('body 缺失 → releaseNotes 为空字符串', () {
      final info = UpdateInfo.fromReleaseJson({
        'tag_name': 'v1.0.0',
        'html_url': 'https://x/y',
      });
      expect(info.releaseNotes, '');
    });
  });

  group('UpdateException.fromDioException 分类', () {
    DioException dio(DioExceptionType type, {int? status}) {
      final ro = RequestOptions(path: '/repos/WuMe-sicx/Xuro/releases');
      return DioException(
        requestOptions: ro,
        type: type,
        response: status == null
            ? null
            : Response(requestOptions: ro, statusCode: status),
      );
    }

    test('403 → rateLimited（不是「请先登录」）', () {
      final e = UpdateException.fromDioException(
        dio(DioExceptionType.badResponse, status: 403),
      );
      expect(e.type, UpdateErrorType.rateLimited);
    });

    test('429 → rateLimited', () {
      final e = UpdateException.fromDioException(
        dio(DioExceptionType.badResponse, status: 429),
      );
      expect(e.type, UpdateErrorType.rateLimited);
    });

    test('404 → notFound', () {
      final e = UpdateException.fromDioException(
        dio(DioExceptionType.badResponse, status: 404),
      );
      expect(e.type, UpdateErrorType.notFound);
    });

    test('connectionError → network（不提 VPN）', () {
      final e = UpdateException.fromDioException(
        dio(DioExceptionType.connectionError),
      );
      expect(e.type, UpdateErrorType.network);
    });

    test('connectionTimeout → network', () {
      final e = UpdateException.fromDioException(
        dio(DioExceptionType.connectionTimeout),
      );
      expect(e.type, UpdateErrorType.network);
    });

    test('500 → unknown', () {
      final e = UpdateException.fromDioException(
        dio(DioExceptionType.badResponse, status: 500),
      );
      expect(e.type, UpdateErrorType.unknown);
    });
  });
}
