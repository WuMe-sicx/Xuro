/// search_viewmodel_test.dart：钉住 `SearchViewModel` 相对共用 `PagedWorks` mixin
/// 的两处刻意背离——`paged_works_test.dart` 里的 7 个 mixin 测试只打在
/// `_FakePagedWorks` 上，从不构造真正的 `SearchViewModel`，所以那两处背离
/// （totalPages 覆写、search() 无 in-flight 守卫）实际上是 0 覆盖率，而且
/// mixin 测试里恰好各自钉了相反的默认行为——真把它们当"搜索页也这样"来读，
/// 结论是反的。这里直接打在真实 `SearchViewModel` 上。
///
/// 网络短路手法照抄 `api_service_test.dart`：自定义 `Dio` + `InterceptorsWrapper`
/// 在 `onRequest` 直接 `resolve`，不发真网络，也不挂 `AuthInterceptor`。
/// `SearchViewModel` 的 `_apiService` 字段在构造时就同步取
/// `GetIt.I<ApiService>()`（非懒加载），所以必须先把 `ApiService` 注册进 GetIt
/// 再构造 `SearchViewModel`。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-18
library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/presentation/viewmodels/search_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppSettingsService settings;
  ApiService? currentApi;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settings = AppSettingsService(prefs);
  });

  tearDown(() {
    // 与 api_service_test.dart 的约定一致：dispose 掉在 AppSettingsService 上
    // 挂的监听器，避免测试间累积悬挂回调；GetIt 是进程级单例，必须每个测试
    // 结束就注销，否则下一个测试文件的 `GetIt.I<ApiService>()` 会拿到本文件
    // 留下的短路实例。
    if (GetIt.I.isRegistered<ApiService>()) {
      GetIt.I.unregister<ApiService>();
    }
    currentApi?.dispose();
    currentApi = null;
  });

  /// 构造短路 Dio 的 ApiService 并注册进 GetIt。[onRequest] 拿到的是
  /// Dio 组装好的 `RequestOptions`——取 `options.uri` 能拿到含完整
  /// query 的 URI（用法与 `api_service_url_test.dart` 一致）。
  void registerApi(
    void Function(RequestOptions options, RequestInterceptorHandler handler)
        onRequest,
  ) {
    final dio = Dio(BaseOptions(baseUrl: 'https://x.test'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
    final api = ApiService(settings: settings, dio: dio);
    currentApi = api;
    GetIt.I.registerSingleton<ApiService>(api);
  }

  /// 一份能被 `_parseWorksResponse`/searchWorks 解析成功的最小合法响应体。
  Response<dynamic> okResponse(RequestOptions options) => Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'works': [
            {'id': 1, 'title': 'r'},
          ],
          'pagination': {'currentPage': 1, 'pageSize': 20, 'totalCount': 1},
        },
      );

  group('A. totalPages 覆写：搜索页分页器不能在"统一"重构中被摸掉', () {
    test('一次搜索都没发起过时，totalPages 已经是非空的 1', () {
      // grid_content.dart 只在 totalPages != null 时渲染 PaginationControls。
      // mixin 默认值（未加载时）是 null——`search_viewmodel.dart` 里
      // `int get totalPages => super.totalPages ?? 1;` 这行覆写就是为了在
      // 拿到真实 pagination 之前也能把分页器摆出来。删掉这行覆写去"跟其余
      // 5 个列表 VM 保持一致"，这里会变成 null，搜索页的分页器直接消失，
      // 而 paged_works_test.dart 里名字很像的
      // "totalPages：分页信息缺失或不完整时必须是 null，不能回落成 1" 一条
      // 测的是 mixin 默认值本身，钉的恰恰是相反的行为，不会因为这处删除变红。
      registerApi((options, handler) => handler.resolve(okResponse(options)));
      final vm = SearchViewModel();

      expect(vm.totalPages, 1,
          reason: '删掉 SearchViewModel.totalPages 的覆写，这里会变成 null');
    });
  });

  group('B. search() 无 in-flight 守卫：筛选/排序在请求途中必须能立刻重发', () {
    test('不等第一次 search() 返回就调用第二次，两次请求都真的发了出去', () async {
      // 后果：把 search() 改走 loadPage/canLoad 的话，第二次调用会撞见
      // `!_isLoading` 守卫——第一次调用同步执行到 `runFetch` 里
      // `_isLoading = true` 那一行时还没遇到真正的 await 暂停点，这行赋值
      // 在第二次调用发生前就已经落地，第二次调用会被直接吞掉、请求数停在 1。
      final requestUris = <Uri>[];
      final pending = <Completer<void>>[];
      registerApi((options, handler) {
        requestUris.add(options.uri);
        final gate = Completer<void>();
        pending.add(gate);
        gate.future.then((_) => handler.resolve(okResponse(options)));
      });
      final vm = SearchViewModel();

      final first = vm.search('kw');
      final second = vm.search('kw');
      // 两次调用之间没有 await，靠 pumpEventQueue 把两条请求链各自的微任务
      // 都跑到底，让它们真正抵达拦截器（而不是只跑完各自调用里第一段同步前缀）。
      await pumpEventQueue();

      expect(requestUris.length, 2,
          reason: '第二次 search() 必须真的发出请求，不能被 in-flight 守卫吞掉');

      for (final gate in pending) {
        gate.complete();
      }
      await first;
      await second;
    });

    test('search 在途时 toggleSubtitle() 立即重发新请求，回到第1页', () async {
      final requestUris = <Uri>[];
      final pending = <Completer<void>>[];
      registerApi((options, handler) {
        requestUris.add(options.uri);
        final gate = Completer<void>();
        pending.add(gate);
        gate.future.then((_) => handler.resolve(okResponse(options)));
      });
      final vm = SearchViewModel();

      vm.search('kw', page: 3); // 模拟正翻在第3页、请求还没回来
      await pumpEventQueue();
      expect(requestUris.length, 1);
      expect(requestUris[0].queryParameters['page'], '3');

      vm.toggleSubtitle(); // 第一次请求仍在途（pending[0] 未 complete）
      await pumpEventQueue();

      expect(requestUris.length, 2,
          reason: '若 toggleSubtitle 走 canLoad 的 in-flight 守卫，这里会停在 1——'
              '用户点了筛选却没有任何反应');
      expect(requestUris[1].queryParameters['page'], '1',
          reason: '重新搜索必须回到第1页，不能停在旧的第3页');
      expect(requestUris[1].queryParameters['subtitle'], '1',
          reason: '新请求必须带上刚切换的字幕筛选');

      for (final gate in pending) {
        gate.complete();
      }
      await pumpEventQueue();
    });

    test('search 在途时 setOrder() 立即重发新请求，回到第1页', () async {
      final requestUris = <Uri>[];
      final pending = <Completer<void>>[];
      registerApi((options, handler) {
        requestUris.add(options.uri);
        final gate = Completer<void>();
        pending.add(gate);
        gate.future.then((_) => handler.resolve(okResponse(options)));
      });
      final vm = SearchViewModel();

      vm.search('kw', page: 2);
      await pumpEventQueue();
      expect(requestUris.length, 1);
      expect(requestUris[0].queryParameters['page'], '2');

      vm.setOrder('release', 'asc'); // 第一次请求仍在途
      await pumpEventQueue();

      expect(requestUris.length, 2,
          reason: '若 setOrder 走 canLoad 的 in-flight 守卫，排序切换会被吞掉');
      expect(requestUris[1].queryParameters['page'], '1',
          reason: '重新搜索必须回到第1页');
      expect(requestUris[1].queryParameters['order'], 'release');
      expect(requestUris[1].queryParameters['sort'], 'asc');

      for (final gate in pending) {
        gate.complete();
      }
      await pumpEventQueue();
    });
  });
}
