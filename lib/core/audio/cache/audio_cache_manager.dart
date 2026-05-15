import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:xuro/utils/logger.dart';

/// 音频缓存管理器
/// 负责管理音频文件的缓存,对外隐藏具体的缓存实现
class AudioCacheManager {
  static const int _maxCacheSize = 1024 * 1024 * 1024; // 总缓存限制 1024MB
  static const Duration _cacheExpiration = Duration(days: 30);

  /// 创建音频源
  /// 内部处理缓存逻辑,对外只返回 AudioSource
  static Future<AudioSource> createAudioSource(String url, {String? hash}) async {
    try {
      final cacheFile = await _getCacheFile(url, hash: hash);
      final fileName = _generateFileName(url, hash: hash);
      AppLogger.debug('准备创建音频源 - URL: $url, 缓存文件名: $fileName');
      
      // 检查缓存文件是否存在且有效
      final isValid = await _isCacheValid(cacheFile, fileName);
      
      if (isValid) {
        AppLogger.debug('[$fileName] 使用已有缓存文件');
        return _createCachingSource(url, cacheFile);
      }

      AppLogger.debug('[$fileName] 创建新的缓存源');
      return _createCachingSource(url, cacheFile);
      
    } catch (e, stackTrace) {
      AppLogger.warning('创建缓存音频源失败,降级为流式播放: $url');
      AppLogger.error('缓存源创建异常', e, stackTrace);
      return ProgressiveAudioSource(Uri.parse(url));
    }
  }

  /// 清理过期和超量的缓存（真 LRU：删最旧直到总量 ≤ 上限）
  static Future<void> cleanCache() async {
    try {
      final cacheDir = await _getCacheDir();
      final entities = await cacheDir.list().toList();

      // 一次性异步收集 (file, stat)，避免在 sort comparator 里同步 statSync
      // 造成 O(N log N) 次阻塞文件系统调用拖垮主隔离区。
      final entries = <({File file, FileStat stat})>[];
      for (final e in entities) {
        if (e is! File) continue;
        try {
          entries.add((file: e, stat: await e.stat()));
        } catch (_) {
          // 文件可能正被占用或已被删除，跳过。
        }
      }

      final now = DateTime.now();

      // 1) 先删过期文件，其余进入存活集合。
      final live = <({File file, FileStat stat})>[];
      for (final entry in entries) {
        if (now.difference(entry.stat.modified) > _cacheExpiration) {
          try {
            await entry.file.delete();
          } catch (_) {
            // 占用中删不掉：文件仍在磁盘，必须计入容量；它 modified 最旧，
            // 会排到 live 队首，在 LRU 阶段优先重试删除。不能直接丢弃，
            // 否则容量统计偏小、实际占用可能远超上限。
            live.add(entry);
          }
        } else {
          live.add(entry);
        }
      }

      // 2) 真 LRU：按 modified 升序（最旧在前），从最旧开始删，
      //    每删一个回退 totalSize，直到总量不超上限。
      live.sort((a, b) => a.stat.modified.compareTo(b.stat.modified));
      var totalSize = live.fold<int>(0, (sum, e) => sum + e.stat.size);
      for (final entry in live) {
        if (totalSize <= _maxCacheSize) break;
        try {
          await entry.file.delete();
          totalSize -= entry.stat.size;
        } catch (_) {
          // 占用中跳过，继续尝试下一个较旧文件。
        }
      }
    } catch (e) {
      AppLogger.error('清理缓存失败', e);
    }
  }

  /// 清空所有音频缓存（用户主动清理时调用）
  /// 返回删除结果，如有文件无法删除则抛出异常
  static Future<void> clearAllCache() async {
    final cacheDir = await _getCacheDir();
    final entities = await cacheDir.list().toList();

    var deleted = 0;
    var failed = 0;

    for (var entity in entities) {
      try {
        if (entity is File) {
          await entity.delete();
          deleted++;
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
          deleted++;
        }
      } catch (e) {
        failed++;
        AppLogger.warning('无法删除缓存文件: ${entity.path}, 可能正在使用中');
      }
    }

    if (failed == 0) {
      AppLogger.debug('音频缓存已清空，共删除 $deleted 个文件');
    } else {
      AppLogger.warning('音频缓存部分清理: 成功 $deleted, 失败 $failed');
      throw Exception('部分缓存文件无法删除（$failed 个），可能正在播放中');
    }
  }

  /// 获取缓存大小
  static Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDir();
      final files = await cacheDir.list().toList();
      
      var totalSize = 0;
      for (var file in files) {
        if (file is File) {
          totalSize += (await file.stat()).size;
        }
      }
      return totalSize;
    } catch (e) {
      AppLogger.error('获取缓存大小失败', e);
      return 0;
    }
  }

  // 私有方法

  /// 创建缓存音频源
  static AudioSource _createCachingSource(String url, File cacheFile) {
    return LockCachingAudioSource(
      Uri.parse(url),
      cacheFile: cacheFile,
    );
  }

  /// 检查缓存是否有效
  static Future<bool> _isCacheValid(File cacheFile, String fileName) async {
    final exists = await cacheFile.exists();
    if (!exists) {
      AppLogger.debug('[$fileName] 缓存验证: 文件不存在');
      return false;
    }

    try {
      final stat = await cacheFile.stat();
      final size = stat.size;
      final age = DateTime.now().difference(stat.modified);
      
      AppLogger.debug('[$fileName] 缓存验证: 大小=${size}bytes, 年龄=$age');
      
      // 移除单个文件大小检查，只保留过期检查
      if (age > _cacheExpiration) {
        AppLogger.debug('[$fileName] 缓存无效: 文件过期 ($age > $_cacheExpiration)');
        await cacheFile.delete();
        return false;
      }

      AppLogger.debug('[$fileName] 缓存验证: 有效');
      return true;
    } catch (e) {
      AppLogger.error('[$fileName] 检查缓存有效性失败', e);
      return false;
    }
  }

  /// 获取缓存文件
  static Future<File> _getCacheFile(String url, {String? hash}) async {
    final cacheDir = await _getCacheDir();
    final fileName = _generateFileName(url, hash: hash);
    return File('${cacheDir.path}/$fileName');
  }

  /// 生成缓存文件名
  static String _generateFileName(String url, {String? hash}) {
    if (hash != null && hash.isNotEmpty) {
      // Sanitize hash to ensure filesystem safety
      return hash.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    }
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// 获取缓存目录
  static Future<Directory> _getCacheDir() async {
    final appDir = await getApplicationSupportDirectory();
    final audioCacheDir = Directory('${appDir.path}/audio_cache');
    if (!await audioCacheDir.exists()) {
      await audioCacheDir.create(recursive: true);
    }
    return audioCacheDir;
  }

  /// One-time cleanup of legacy temp cache directory
  static Future<void> cleanLegacyCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final legacyDir = Directory('${tempDir.path}/audio_cache');
      if (await legacyDir.exists()) {
        await legacyDir.delete(recursive: true);
        AppLogger.info('已清理旧版临时缓存目录');
      }
    } catch (e) {
      AppLogger.warning('清理旧版缓存失败: $e');
    }
  }
}