import 'dart:collection';
import 'package:asmrapp/data/services/api_service.dart';
import 'package:asmrapp/utils/logger.dart';

class RecommendationCacheManager {
  // 单例模式
  static final RecommendationCacheManager _instance = RecommendationCacheManager._internal();
  factory RecommendationCacheManager() => _instance;
  RecommendationCacheManager._internal();

  // 使用 LinkedHashMap 便于按访问顺序管理缓存
  final _cache = <String, _CacheItem>{};
  
  // 缓存配置
  static const int _maxCacheSize = 1000; // 最大缓存条目数
  static const Duration _cacheDuration = Duration(hours: 24); // 缓存有效期

  /// 生成缓存键
  String _generateKey(String itemId, int page, int subtitle) {
    return '$itemId-$page-$subtitle';
  }

  /// 获取缓存数据
  WorksResponse? get(String itemId, int page, int subtitle) {
    final key = _generateKey(itemId, page, subtitle);
    final item = _cache[key];

    if (item == null) {
      return null;
    }

    // 检查是否过期
    if (item.isExpired) {
      _cache.remove(key);
      AppLogger.debug('缓存已过期: $key');
      return null;
    }

    AppLogger.debug('命中缓存: $key');
    return item.data;
  }

  /// 存储缓存数据
  void set(String itemId, int page, int subtitle, WorksResponse data) {
    final key = _generateKey(itemId, page, subtitle);
    
    // 检查缓存大小,如果达到上限则移除最早的条目
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = _CacheItem(data);
    AppLogger.debug('添加缓存: $key');
  }

  /// 清除所有缓存
  void clear() {
    _cache.clear();
    AppLogger.debug('清除所有推荐缓存');
  }

  /// 移除指定作品的缓存
  void remove(String itemId) {
    _cache.removeWhere((key, _) => key.startsWith('$itemId-'));
    AppLogger.debug('移除作品缓存: $itemId');
  }
}

/// 缓存条目包装类
class _CacheItem {
  final WorksResponse data;
  final DateTime timestamp;

  _CacheItem(this.data) : timestamp = DateTime.now();

  bool get isExpired => 
    DateTime.now().difference(timestamp) > RecommendationCacheManager._cacheDuration;
} 