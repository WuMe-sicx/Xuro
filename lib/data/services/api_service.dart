import 'package:xuro/core/cache/recommendation_cache_manager.dart';
import 'package:xuro/data/models/mark_status.dart';
import 'package:xuro/data/models/playlists_with_exist_statu/playlists_with_exist_statu.dart';
import 'package:dio/dio.dart';
import 'package:xuro/data/models/files/files.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/pagination.dart';
import 'package:xuro/data/models/works/works_response.dart';
import 'package:xuro/utils/logger.dart';
import 'package:xuro/data/services/interceptors/auth_interceptor.dart';
import 'package:xuro/data/services/interceptors/retry_interceptor.dart';
import 'package:xuro/data/services/exceptions/network_exception.dart';
import 'package:xuro/data/models/tags/tag_item.dart';
import 'package:xuro/data/models/circles/circle_item.dart';
import 'package:xuro/data/models/vas/voice_actor.dart';
import 'package:xuro/data/models/works/work_info.dart';
import 'package:xuro/core/settings/app_settings_service.dart';

class ApiService {
  final Dio _dio;
  final _recommendationCache = RecommendationCacheManager();

  final AppSettingsService _settings;

  /// [dio] 可注入：默认路径（`dio == null`）逐字保留原行为——内联构造带
  /// 超时三元组的 `Dio`，并依次挂 `RetryInterceptor` + `AuthInterceptor`。
  /// 写法对齐仓库里 `DownloadService(dio: dio ?? Dio())` 的既有约定。测试
  /// 注入自定义 `Dio` 时**不挂这两个拦截器**——测试要的是可控短路通道，
  /// 重试/鉴权语义会干扰断言。
  ApiService({required AppSettingsService settings, Dio? dio})
      : _settings = settings,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: settings.serverUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 15),
            )) {
    if (dio == null) {
      _dio.interceptors.add(RetryInterceptor(dio: _dio));
      _dio.interceptors.add(AuthInterceptor());
    }
    // Listen for server URL changes
    _settings.addListener(_onSettingsChanged);
  }

  /// 与构造函数里的 `_settings.addListener` 配对。生产中 `ApiService` 是
  /// DI 里的 lazySingleton、活到进程退出，从不调用；但测试里每 `new` 一个
  /// 都会往 `AppSettingsService` 上永久挂一个监听器，不清理会在多个测试
  /// 之间累积悬挂回调。
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (_dio.options.baseUrl != _settings.serverUrl) {
      _dio.options.baseUrl = _settings.serverUrl;
      _recommendationCache.clear();
      AppLogger.info('API服务器已切换: ${_settings.serverUrl}');
    }
  }

  /// 请求 → 解包 → 错误分类。15 个端点共用这一条通路，取代此前 15 处逐字
  /// 相同的 `on DioException` + 裸 catch 三件套。
  ///
  /// **刻意没有状态码闸门。** 重构前每个方法都有一份 `if (statusCode == 200)`
  /// 加一句 `throw Exception('...失败: $statusCode')`，共 12 份。它们全是多余的：
  /// Dio 默认 `validateStatus` 是 200-299（`dio_mixin.dart` 的 `_dispatchRequest`
  /// 里），非 2xx 早就被抛成 `DioException` 了；而 2xx 之内唯一的失败模式是
  /// 「响应体不是预期形状」，那件事 [parse] 自己会抛。留着闸门只会误杀合法的
  /// 201 Created / 204 No Content —— `POST /playlist/add-works-to-playlist`
  /// 返回 201 完全正常，而 `AuthService.register` 就明确接受 `200 || 201`。
  ///
  /// [label] 只进日志，不进抛出的消息（用户可见文案统一由 `userMessageOf` 决定）。
  /// [send] 在 try 内执行，所以请求体构造里的 `int.parse` 之类抛出仍归入
  /// 「解析失败」这一类，与重构前一致。
  Future<T> _request<T>({
    required String label,
    required Future<Response> Function() send,
    required T Function(dynamic data) parse,
  }) async {
    try {
      return parse((await send()).data);
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw NetworkException.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('$label解析数据失败', e, stackTrace);
      throw Exception('解析数据失败: $e');
    }
  }

  /// works+pagination 信封解包，收敛 getWorks/getFavorites/getRecommendations/
  /// getPopular/getItemNeighbors 这 5 个响应体形状完全相同的端点。
  /// pagination 不兜底：畸形响应下 `Pagination.fromJson(null)` 该抛就抛，
  /// 兜底会把「抛错」静默变成「空列表」，是可见行为变化。
  static WorksResponse _parseWorksResponse(dynamic data) {
    final List<dynamic> works = data['works'] ?? [];
    final pagination = Pagination.fromJson(data['pagination']);
    return WorksResponse(
      works: works.map((work) => Work.fromJson(work)).toList(),
      pagination: pagination,
    );
  }

  /// 顶层数组响应解包，收敛 getTags/getCircles/getVoiceActors。
  static List<T> _parseList<T>(dynamic data, T Function(dynamic) fromJson) {
    final List<dynamic> list = data;
    return list.map(fromJson).toList();
  }

  /// 获取作品文件列表
  Future<Files> getWorkFiles(String workId, {CancelToken? cancelToken}) {
    return _request<Files>(
      label: '获取文件列表',
      send: () => _dio.get(
        '/tracks/$workId',
        queryParameters: {
          'v': '2',
        },
        cancelToken: cancelToken, // 添加 cancelToken 支持
      ),
      parse: (data) => Files.fromJson({
        'type': 'root',
        'title': 'Root',
        'children': data,
      }),
    );
  }

  /// 获取作品列表
  Future<WorksResponse> getWorks({
    int page = 1,
    bool hasSubtitle = false,
    String order = 'create_date',
    String sort = 'desc',
    String playlistId = '',
  }) {
    return _request<WorksResponse>(
      label: '获取作品列表',
      send: () {
        final queryParams = {
          'page': page,
          'subtitle': hasSubtitle ? 1 : 0,
          'order': order,
          'sort': sort,
        };

        // 如果提供了收藏夹ID，添加到查询参数
        if (playlistId.isNotEmpty) {
          queryParams['withPlaylistStatus[]'] = playlistId;
        }

        return _dio.get('/works', queryParameters: queryParams);
      },
      parse: _parseWorksResponse,
    );
  }

  /// 搜索作品
  ///
  /// 注意：`keyword` 直接作为路径段拼接。某些标签的 `name` 含 `/`
  /// （例如 "巨乳/爆乳"），如果用字符串拼接构造 path，`%2F` 在 Dio
  /// 内部 `Uri.parse` 后可能被还原为 `/`，服务器收到后会按路径分隔符
  /// 拆段 → 404。这里改用 `Uri.pathSegments` 显式构造，再走 `getUri`
  /// 直接交给 Dio，确保整段 keyword 在 wire 上始终是单个 segment。
  Future<WorksResponse> searchWorks({
    required String keyword,
    int page = 1,
    String order = 'create_date',
    String sort = 'desc',
    bool hasSubtitle = false,
  }) {
    return _request<WorksResponse>(
      label: '搜索',
      send: () => _dio.getUri(
        _buildSearchUri(
          keyword: keyword,
          page: page,
          order: order,
          sort: sort,
          hasSubtitle: hasSubtitle,
        ),
      ),
      // works 用直接 cast（不兜底 `?? []`），与其它端点的解包故意不同——
      // 保留原状：缺 works 键时的报错形状不在本次重构范围内。
      parse: (data) {
        AppLogger.debug('搜索返回数据: $data');

        final works =
            (data['works'] as List).map((work) => Work.fromJson(work)).toList();

        final pagination = Pagination.fromJson(data['pagination']);

        return WorksResponse(
          works: works,
          pagination: pagination,
        );
      },
    );
  }

  Uri _buildSearchUri({
    required String keyword,
    required int page,
    required String order,
    required String sort,
    required bool hasSubtitle,
  }) {
    return buildSearchUri(
      baseUrl: _dio.options.baseUrl,
      keyword: keyword,
      page: page,
      order: order,
      sort: sort,
      hasSubtitle: hasSubtitle,
    );
  }

  /// 公开供单元测试覆盖：构造 `/search/<keyword>` 的完整 URI。
  /// 关键保证：keyword 在 wire 上始终是 **单个 path segment** —
  /// `Uri.pathSegments` 不会把 `/` 当分隔符，并且会把会破坏路径解析的
  /// 保留字（`/ ? #` 等）一律 percent-encode，从而避免服务器把 `/`
  /// 当分隔符拆段。其它字符（如 `+`、`:`）作为合法的 pchar 不会被编码。
  static Uri buildSearchUri({
    required String baseUrl,
    required String keyword,
    required int page,
    required String order,
    required String sort,
    required bool hasSubtitle,
  }) {
    final base = Uri.parse(baseUrl);
    return base.replace(
      pathSegments: [...base.pathSegments, 'search', keyword],
      queryParameters: <String, String>{
        'page': '$page',
        'order': order,
        'sort': sort,
        'subtitle': hasSubtitle ? '1' : '0',
        'includeTranslationWorks': 'true',
      },
    );
  }

  /// 获取收藏列表
  Future<WorksResponse> getFavorites({int page = 1}) {
    return _request<WorksResponse>(
      label: '获取收藏列表',
      send: () => _dio.get('/review', queryParameters: {
        'page': page,
        'order': 'updated_at',
        'sort': 'desc',
      }),
      parse: _parseWorksResponse,
    );
  }

  /// 获取推荐作品
  Future<WorksResponse> getRecommendations({
    required String uuid,
    int page = 1,
    bool hasSubtitle = false,
  }) {
    return _request<WorksResponse>(
      label: '获取推荐列表',
      send: () => _dio.post(
        '/recommender/recommend-for-user',
        data: {
          'keyword': ' ',
          'userId': uuid,
          'page': page,
          'subtitle': hasSubtitle ? 1 : 0,
          'localSubtitledWorks': [],
          'withPlaylistStatus': [],
        },
      ),
      parse: _parseWorksResponse,
    );
  }

  /// 获取热门作品
  Future<WorksResponse> getPopular({
    int page = 1,
    bool hasSubtitle = false,
  }) {
    return _request<WorksResponse>(
      label: '获取热门列表',
      send: () => _dio.post(
        '/recommender/popular',
        data: {
          'keyword': ' ',
          'page': page,
          'subtitle': hasSubtitle ? 1 : 0,
          'localSubtitledWorks': [],
          'withPlaylistStatus': [],
        },
      ),
      parse: _parseWorksResponse,
    );
  }

  /// 获取相关推荐作品
  Future<WorksResponse> getItemNeighbors({
    required String itemId,
    int page = 1,
    bool hasSubtitle = false,
  }) async {
    // 先尝试从缓存获取。命中直接返回，不进 `_request`——缓存路径没有
    // 网络请求，套错误分类通路没有意义。
    final cachedData =
        _recommendationCache.get(itemId, page, hasSubtitle ? 1 : 0);
    if (cachedData != null) {
      return cachedData;
    }

    final worksResponse = await _request<WorksResponse>(
      label: '获取相关推荐',
      send: () => _dio.post(
        '/recommender/item-neighbors',
        data: {
          'keyword': '',
          'itemId': itemId,
          'page': page,
          'subtitle': hasSubtitle ? 1 : 0,
          'localSubtitledWorks': [],
          'withPlaylistStatus': [],
        },
      ),
      parse: _parseWorksResponse,
    );

    // 存入缓存
    _recommendationCache.set(itemId, page, hasSubtitle ? 1 : 0, worksResponse);

    return worksResponse;
  }

  /// 获取作品在收藏夹中的状态
  Future<PlaylistsWithExistStatu> getWorkExistStatusInPlaylists({
    required String workId,
    int page = 1,
  }) {
    return _request<PlaylistsWithExistStatu>(
      label: '获取收藏夹列表',
      send: () => _dio.get(
        '/playlist/get-work-exist-status-in-my-playlists',
        queryParameters: {
          'workID': workId,
          'page': page,
          'version': 2,
        },
      ),
      parse: (data) => PlaylistsWithExistStatu.fromJson(data),
    );
  }

  /// 添加作品到收藏夹
  Future<void> addWorkToPlaylist({
    required String playlistId,
    required String workId,
  }) {
    return _request<void>(
      label: '添加到收藏夹',
      send: () => _dio.post(
        '/playlist/add-works-to-playlist',
        data: {
          'id': playlistId,
          'works': [int.parse(workId)],
        },
      ),
      parse: (_) {},
    );
  }

  /// 从收藏夹移除作品
  Future<void> removeWorkFromPlaylist({
    required String playlistId,
    required String workId,
  }) {
    return _request<void>(
      label: '从收藏夹移除',
      send: () => _dio.post(
        '/playlist/remove-works-from-playlist',
        data: {
          'id': playlistId,
          'works': [int.parse(workId)],
        },
      ),
      parse: (_) {},
    );
  }

  /// 更新作品的标记状态
  Future<void> updateWorkMarkStatus(String workId, String status) {
    return _request<void>(
      label: '标记',
      send: () => _dio.put(
        '/review',
        data: {
          'work_id': int.parse(workId),
          'progress': status,
        },
      ),
      parse: (_) {},
    );
  }

  /// 将 MarkStatus 枚举转换为 API 参数
  String convertMarkStatusToApi(MarkStatus status) {
    switch (status) {
      case MarkStatus.wantToListen:
        return 'marked';
      case MarkStatus.listening:
        return 'listening';
      case MarkStatus.listened:
        return 'listened';
      case MarkStatus.relistening:
        return 'replay';
      case MarkStatus.onHold:
        return 'postponed';
    }
  }

  /// 获取所有标签列表
  Future<List<TagItem>> getTags() {
    return _request<List<TagItem>>(
      label: '获取标签列表',
      send: () => _dio.get('/tags/'),
      parse: (data) => _parseList(data, (item) => TagItem.fromJson(item)),
    );
  }

  /// 获取所有社团列表
  Future<List<CircleItem>> getCircles() {
    return _request<List<CircleItem>>(
      label: '获取社团列表',
      send: () => _dio.get('/circles/'),
      parse: (data) => _parseList(data, (item) => CircleItem.fromJson(item)),
    );
  }

  /// 获取所有声优列表
  Future<List<VoiceActor>> getVoiceActors() {
    return _request<List<VoiceActor>>(
      label: '获取声优列表',
      send: () => _dio.get('/vas/'),
      parse: (data) => _parseList(data, (item) => VoiceActor.fromJson(item)),
    );
  }

  /// 获取作品详细信息
  Future<WorkInfo> getWorkInfo(String workId, {CancelToken? cancelToken}) {
    return _request<WorkInfo>(
      label: '获取作品详情',
      send: () => _dio.get('/workInfo/$workId', cancelToken: cancelToken),
      parse: (data) => WorkInfo.fromJson(data),
    );
  }
}
