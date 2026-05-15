import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/data/services/api_service.dart';

void main() {
  group('ApiService.buildSearchUri', () {
    test('keyword 含 / 时，path 中的 / 必须保持 %2F (Issue #2)', () {
      final uri = ApiService.buildSearchUri(
        baseUrl: 'https://api.asmr.one/api',
        keyword: r'$tag:巨乳/爆乳$',
        page: 1,
        order: 'create_date',
        sort: 'desc',
        hasSubtitle: false,
      );

      expect(uri.pathSegments, ['api', 'search', r'$tag:巨乳/爆乳$']);
      expect(uri.path.contains('%2F'), isTrue,
          reason: 'keyword 中的 / 必须 percent-encoded');
      expect(uri.path.endsWith(r'/$'), isFalse,
          reason: r'keyword 段不应以原始 $ 收尾');
    });

    test('keyword 不含特殊字符时仍能正常构造', () {
      final uri = ApiService.buildSearchUri(
        baseUrl: 'https://api.asmr.one/api',
        keyword: r'$tag:啊哦淫叫$',
        page: 1,
        order: 'create_date',
        sort: 'desc',
        hasSubtitle: false,
      );
      expect(uri.pathSegments, ['api', 'search', r'$tag:啊哦淫叫$']);
    });

    test('查询参数齐全且 hasSubtitle/page 正确序列化', () {
      final uri = ApiService.buildSearchUri(
        baseUrl: 'https://api.asmr.one/api',
        keyword: 'demo',
        page: 3,
        order: 'release',
        sort: 'asc',
        hasSubtitle: true,
      );
      expect(uri.queryParameters, {
        'page': '3',
        'order': 'release',
        'sort': 'asc',
        'subtitle': '1',
        'includeTranslationWorks': 'true',
      });
    });

    test('镜像节点 baseUrl 同样工作（保留 /api 前缀）', () {
      final uri = ApiService.buildSearchUri(
        baseUrl: 'https://api.asmr-100.com/api',
        keyword: r'$tag:巨乳/爆乳$',
        page: 1,
        order: 'create_date',
        sort: 'desc',
        hasSubtitle: false,
      );
      expect(uri.host, 'api.asmr-100.com');
      expect(uri.pathSegments, ['api', 'search', r'$tag:巨乳/爆乳$']);
      expect(uri.path.contains('%2F'), isTrue);
    });

    group('keyword 保留字符 percent-encoding', () {
      Uri build(String keyword) => ApiService.buildSearchUri(
            baseUrl: 'https://api.asmr.one/api',
            keyword: keyword,
            page: 1,
            order: 'create_date',
            sort: 'desc',
            hasSubtitle: false,
          );

      test('keyword 含 ? 必须被编码（否则与 query 串混淆）', () {
        final uri = build('foo?bar');
        expect(uri.pathSegments.last, 'foo?bar');
        expect(uri.path.contains('%3F'), isTrue);
      });

      test('keyword 含 # 必须被编码（否则与 fragment 混淆）', () {
        final uri = build('foo#bar');
        expect(uri.pathSegments.last, 'foo#bar');
        expect(uri.path.contains('%23'), isTrue);
      });

      test('keyword 含已有 % 必须被再编码为 %25', () {
        final uri = build('100%off');
        expect(uri.pathSegments.last, '100%off');
        expect(uri.path.contains('100%25off'), isTrue);
      });

      test('keyword 含 + 作为合法 pchar 保持字面值', () {
        final uri = build('a+b');
        expect(uri.pathSegments.last, 'a+b');
        // + 在 path segment 中合法，不需要编码
        expect(uri.path.contains('a+b'), isTrue);
      });
    });

    test('baseUrl 末尾带斜杠也能正确构造', () {
      final uri = ApiService.buildSearchUri(
        baseUrl: 'https://api.asmr.one/api/',
        keyword: r'$tag:巨乳/爆乳$',
        page: 1,
        order: 'create_date',
        sort: 'desc',
        hasSubtitle: false,
      );
      // 末尾斜杠会引入一个空 segment，但 keyword 段仍然是最后一段
      expect(uri.pathSegments.last, r'$tag:巨乳/爆乳$');
      expect(uri.path.contains('/search/'), isTrue);
      expect(uri.path.contains('%2F'), isTrue);
    });
  });

  group('ApiService.buildSearchUri × Dio.getUri 拦截器集成', () {
    test('Dio 收到的 RequestOptions.uri.path 保留 %2F（wire-level 保证）', () async {
      Uri? captured;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.asmr.one/api'));
      // 拦截器在请求出口处捕获最终 URI，再短路掉避免真发网络。
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options.uri;
          handler.reject(
            DioException.requestCancelled(
              requestOptions: options,
              reason: 'test-short-circuit',
            ),
            true,
          );
        },
      ));

      final builtUri = ApiService.buildSearchUri(
        baseUrl: 'https://api.asmr.one/api',
        keyword: r'$tag:巨乳/爆乳$',
        page: 1,
        order: 'create_date',
        sort: 'desc',
        hasSubtitle: false,
      );

      try {
        await dio.getUri(builtUri);
      } on DioException {
        // 拦截器主动 reject，符合预期
      }

      expect(captured, isNotNull,
          reason: 'Dio 应当至少触发一次 onRequest 让我们拿到 URI');
      expect(captured!.path.contains('%2F'), isTrue,
          reason: 'Dio 在 wire 上必须保留 keyword 中的 %2F，否则等于没修');
      expect(captured!.pathSegments.last, r'$tag:巨乳/爆乳$');
    });
  });
}
