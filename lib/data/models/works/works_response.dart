/// works_response.dart：作品列表接口的统一响应体（作品数组 + 分页信息）。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-14

import 'pagination.dart';
import 'work.dart';

/// `ApiService` 各类"作品列表"接口（getWorks/searchWorks/getFavorites/
/// getRecommendations/getPopular/getItemNeighbors）共享的响应壳。原先定义
/// 在服务层 `api_service.dart` 里，导致 `core/cache/recommendation_cache_manager.dart`
/// 为了拿这一个 DTO 被迫 import 服务层，形成 core 反向依赖 data/services。
/// 迁到模型层后，调用方只需 import 模型本身。
class WorksResponse {
  final List<Work> works;
  final Pagination pagination;

  WorksResponse({required this.works, required this.pagination});
}
