/// api_service_test.dart：`ApiService` 特征化测试（characterization test）——
/// 在不改任何方法体逻辑的前提下，先把「现状」用测试钉住，给后续消样板重构
/// 当护栏。仓库里没有任何 mock/http-mock 库，短路手法沿用
/// `api_service_url_test.dart` 已验证的做法：用 `InterceptorsWrapper` 在
/// `onRequest` 出口直接 `handler.resolve/reject` 假响应，不发真网络——本文件
/// 用的是它的反向，`handler.resolve` 喂假响应而非 `reject` 拦截。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-14

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/data/services/exceptions/network_exception.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppSettingsService settings;
  // 每个测试 new 出来的 ApiService 都会往 settings 上挂一个监听器，
  // tearDown 统一 dispose，避免测试间累积悬挂回调（见 ApiService.dispose 注释）。
  final createdServices = <ApiService>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settings = AppSettingsService(prefs);
  });

  tearDown(() {
    for (final s in createdServices) {
      s.dispose();
    }
    createdServices.clear();
  });

  /// 构造一个注入了「短路 Dio」的 ApiService：`onRequest` 直接
  /// `handler.resolve/reject`，不挂 `RetryInterceptor`/`AuthInterceptor`，
  /// 不发真网络（对齐任务约定：注入自定义 Dio 时跳过这两个拦截器）。
  ApiService buildApi(
    void Function(RequestOptions options, RequestInterceptorHandler handler)
        onRequest,
  ) {
    final dio = Dio(BaseOptions(baseUrl: 'https://x.test'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
    final api = ApiService(settings: settings, dio: dio);
    createdServices.add(api);
    return api;
  }

  group('WorksResponse 方法：getWorks', () {
    test('正常响应：works 条数与 pagination 字段正确', () async {
      final api = buildApi((options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'works': [
              {'id': 1, 'title': 'A'},
              {'id': 2, 'title': 'B'},
            ],
            'pagination': {
              'currentPage': 1,
              'pageSize': 20,
              'totalCount': 2,
            },
          },
        ));
      });

      final result = await api.getWorks();

      expect(result.works.length, 2);
      expect(result.works[0].id, 1);
      expect(result.works[1].title, 'B');
      expect(result.pagination.currentPage, 1);
      expect(result.pagination.pageSize, 20);
      expect(result.pagination.totalCount, 2);
    });

    // 现状钉点：`works` 用 `response.data['works'] ?? []` 兜了底，但紧邻的
    // `Pagination.fromJson(response.data['pagination'])` 形参非空、没有
    // 兜底——`works`/`pagination` 键都缺失（真实的畸形响应）时，
    // `Pagination.fromJson(null)` 在运行时抛 TypeError，被自己的裸
    // `catch (e, stackTrace)` 二次包裹成 `Exception`。这不是我们「觉得该
    // 发生」的行为，是先跑一次实测出来的：断言就钉在这个实测结果上，
    // 不要在重构时被静默改成别的错误类型。
    test('works 与 pagination 键都缺失：实测抛出被二次包裹的 Exception，'
        '不是 NetworkException', () async {
      final api = buildApi((options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ));
      });

      await expectLater(
        api.getWorks(),
        throwsA(
          allOf(
            isNot(isA<NetworkException>()),
            predicate<Object>(
              (e) =>
                  e.toString().contains('解析数据失败') &&
                  e
                      .toString()
                      .contains("is not a subtype of type 'Map<String, dynamic>'"),
              '裸 catch 包裹了 Pagination.fromJson(null) 抛出的 TypeError',
            ),
          ),
        ),
      );
    });

    // 行为变更（有意）：重构前每个方法都有一份 `if (statusCode == 200)`，
    // 2xx-非-200 会走进 else 抛异常、再被自己的裸 catch 二次包裹成
    // 「解析数据失败: Exception: 获取作品列表失败: 201」。
    //
    // 那 12 份闸门已全部删除，不是"收敛成一份"：Dio 默认 validateStatus 已经
    // 拦掉非 2xx，而 2xx 之内唯一的失败模式是响应体形状不对——那件事解包自己
    // 会抛。留着闸门只会误杀合法的 201 Created（`POST add-works-to-playlist`
    // 返回 201 完全正常，`AuthService.register` 就明确接受 `200 || 201`）。
    //
    // 所以现在 201 + 合法响应体 = 正常解析。
    test('状态码 201（2xx 但非 200）：正常解析，不再因状态码被拒', () async {
      final api = buildApi((options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: {
            'works': [
              {'id': 7, 'title': 'created'}
            ],
            'pagination': {'currentPage': 1, 'pageSize': 20, 'totalCount': 1},
          },
        ));
      });

      final result = await api.getWorks();

      expect(result.works.single.id, 7);
      expect(result.pagination.totalCount, 1);
    });

    test('401：分类为 NetworkException 且 isAuthError 为真', () async {
      final api = buildApi((options, handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: options, statusCode: 401),
          ),
        );
      });

      await expectLater(
        api.getWorks(),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.isAuthError,
            'isAuthError',
            isTrue,
          ),
        ),
      );
    });
  });

  group('List<T> 方法：getTags', () {
    test('正常响应：条数正确', () async {
      final api = buildApi((options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            {'id': 1, 'name': 'tag-a'},
            {'id': 2, 'name': 'tag-b'},
            {'id': 3, 'name': 'tag-c'},
          ],
        ));
      });

      final tags = await api.getTags();

      expect(tags.length, 3);
      expect(tags[2].name, 'tag-c');
    });
  });

  group('void 方法：addWorkToPlaylist', () {
    // 现状钉点：方法体自身既不检查 statusCode 也不读 response。
    //
    // ⚠️ 这条**不能**读成「服务器返回 500 时不报错」。`handler.resolve()` 在
    // 拦截器里直接短路，绕过了 Dio 的 validateStatus（它在 dio_mixin.dart
    // 的 _dispatchRequest 里、属于 HTTP adapter 路径）。真实的 500 会先被
    // Dio 抛成 DioException——见下一条。这里钉的只是「方法体自己没有状态码
    // 分支」，用于保证后续重构若给它补上检查，这条会红。
    test('方法体自身无状态码分支：拿到 500 的响应对象也不会自己抛', () async {
      final api = buildApi((options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 500,
          data: {'ok': false},
        ));
      });

      await expectLater(
        api.addWorkToPlaylist(playlistId: 'p1', workId: '1'),
        completes,
      );
    });

    // 生产路径：非 2xx 由 Dio 的 validateStatus（默认 200-299）先行拒绝，
    // 方法体根本走不到。所以「不检查状态码」在实际行为上并不等于「吞掉错误」。
    test('生产路径：真实的 500 由 Dio 先拒，分类为 NetworkException', () async {
      final api = buildApi((options, handler) {
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: options, statusCode: 500),
        ));
      });

      await expectLater(
        api.addWorkToPlaylist(playlistId: 'p1', workId: '1'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('CancelToken：getWorkFiles', () {
    // 现状钉点：Dio 对「请求发起前已被 cancel 的 token」直接同步抛
    // DioException(cancel)，走的是 `on DioException catch` 分支，最终分类成
    // NetworkException(cancelled)——不是裸 DioException 逃逸出去。
    test('已 cancel 的 CancelToken：分类为 NetworkException(cancelled)，'
        '不是裸 DioException', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://x.test'));
      final api = ApiService(settings: settings, dio: dio);
      createdServices.add(api);

      final token = CancelToken();
      token.cancel('pre-cancelled');

      await expectLater(
        api.getWorkFiles('123', cancelToken: token),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.type,
            'type',
            NetworkErrorType.cancelled,
          ),
        ),
      );
    });
  });
}
