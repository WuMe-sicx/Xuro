import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:xuro/core/download/models/download_entry.dart';
import 'package:xuro/core/download/storage/i_download_repository.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/utils/logger.dart';

enum DownloadStatus {
  success,
  alreadyExists,
  cancelled,
  networkError,
  ioError,
}

class DownloadResult {
  final DownloadStatus status;

  /// 完成（success / alreadyExists）时的本地绝对路径，否则 null。
  final String? localPath;

  const DownloadResult(this.status, [this.localPath]);

  bool get isPlayable =>
      status == DownloadStatus.success || status == DownloadStatus.alreadyExists;
}

/// 本地媒体下载服务。
///
/// - 用**独立 `Dio()`**（无 `AuthInterceptor`、不随节点轮换）：媒体
///   `mediaDownloadUrl` 是 API 下发的预签名/限时绝对地址，与 asmr 节点无关，
///   `LockCachingAudioSource` 也是无 token 直取（见 spike 结论）。
/// - 落盘在 App 私有 `getApplicationDocumentsDirectory()/downloads/<workId>/`
///   ——"本地磁盘" = App 私有存储，规避 scoped storage，无需广义存储权限。
/// - 原子写复刻 `SubtitleImportService`：tmp → (备份旧文件) → rename → upsert，
///   任一步失败回滚，**新文件确认前绝不破坏已存在的好文件**。
/// - 容量 LRU 复刻 `AudioCacheManager`：删不掉的文件仍计入容量、不丢弃，
///   避免实际占用突破上限。
class DownloadService {
  static const int _maxTotalSize = 4 * 1024 * 1024 * 1024; // 4 GB

  final IDownloadRepository _repository;
  final Dio _dio;

  DownloadService({required IDownloadRepository repository, Dio? dio})
      : _repository = repository,
        _dio = dio ?? Dio();

  /// 文件名安全化（保留可读性与扩展名，供 `OpenFilex` 识别类型）。
  /// 退化输入（空 / 无任何字母数字，仅符号）回退为 `file`，结果确定。
  /// 真实 ASMR 文件名总带字母数字+扩展名，回退只是防御兜底。
  static String sanitizeFileName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[^a-zA-Z0-9._\- ]'), '_').trim();
    final hasAlnum = RegExp(r'[a-zA-Z0-9]').hasMatch(cleaned);
    return hasAlnum ? cleaned : 'file';
  }

  /// 稳定身份键：DB 去重 / 查询 / 删除 / 落盘名都用它，**不用展示名**。
  ///
  /// 不同标题（`a/b.mp4` vs `a:b.mp4`、大量非 ASCII、不同子目录下同名
  /// `01.mp3`）必须算作不同下载，否则会互相误判命中（DB 行或物理路径）。
  /// 身份取 `hash`（API 提供，最稳）> `mediaDownloadUrl` > `title`，md5 摘要。
  static String fileKey(Child file) {
    final idSource = (file.hash != null && file.hash!.isNotEmpty)
        ? file.hash!
        : (file.mediaDownloadUrl ?? file.title ?? 'file');
    return md5.convert(utf8.encode(idSource)).toString();
  }

  /// 落盘文件名 = [fileKey] + 原扩展名（扩展名保留以便 `OpenFilex` 识别类型）。
  static String diskFileName(Child file) {
    final ext = p.extension(file.title ?? '');
    return '${fileKey(file)}$ext';
  }

  Future<Directory> _workDir(String workId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'downloads', workId));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String> _destPath(String workId, Child file) async {
    final dir = await _workDir(workId);
    return p.join(dir.path, diskFileName(file));
  }

  /// 已完成且文件确实在盘上的下载记录（按稳定身份 [key] 查）；若 DB 有行但
  /// 文件已丢失，删除失效行（一致性：失效行会让 app 误判已下载）后返回 null。
  Future<DownloadEntry?> findCompleted(String workId, String key) async {
    final entry = await _repository.find(workId, key);
    if (entry == null) return null;
    if (await File(entry.filePath).exists()) return entry;
    AppLogger.warning('下载记录指向缺失文件，清理失效行: ${entry.filePath}');
    try {
      await _repository.remove(workId, key);
    } catch (e) {
      AppLogger.error('清理失效下载行失败', e);
    }
    return null;
  }

  /// 若该文件已完整下载，返回本地路径（供离线播放走本地源）。
  Future<String?> localPathIfDownloaded(String workId, Child file) async {
    if (file.title == null) return null;
    final entry = await findCompleted(workId, fileKey(file));
    return entry?.filePath;
  }

  /// 下载一个文件（音频或视频）到 App 私有目录。幂等：已完整下载则直接返回。
  Future<DownloadResult> download({
    required String workId,
    required Child file,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final url = file.mediaDownloadUrl;
    final fileName = file.title;
    if (url == null || url.isEmpty || fileName == null || fileName.isEmpty) {
      AppLogger.warning('下载缺少 URL 或文件名: $fileName');
      return const DownloadResult(DownloadStatus.ioError);
    }

    final key = fileKey(file);

    // 去重：已完整下载直接复用。
    final existing = await findCompleted(workId, key);
    if (existing != null) {
      return DownloadResult(DownloadStatus.alreadyExists, existing.filePath);
    }

    final destPath = await _destPath(workId, file);
    final tmpPath = '$destPath.dl_tmp';
    final bakPath = '$destPath.dl_bak';
    final tmpFile = File(tmpPath);
    final bakFile = File(bakPath);
    var backedUp = false;

    try {
      // 1. 先下载到临时文件——失败时不动既有任何文件。
      await _dio.download(
        url,
        tmpPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (onProgress != null && total > 0) {
            onProgress(received / total);
          }
        },
      );

      // 2. 既有同路径文件先挪到备份，便于失败回滚。
      if (await File(destPath).exists()) {
        await File(destPath).rename(bakPath);
        backedUp = true;
      }

      // 3. 同卷 rename 原子生效。
      await tmpFile.rename(destPath);

      // 4. 持久化 DB（文件已就位）。
      final size = await File(destPath).length();
      await _repository.upsert(DownloadEntry(
        workId: workId,
        fileKey: key,
        fileName: fileName,
        filePath: destPath,
        mediaType: (file.type ?? '').toLowerCase(),
        sourceUrl: url,
        size: size,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));

      // 5. 成功——丢弃刚被替换文件的备份。
      if (backedUp) {
        try {
          if (await bakFile.exists()) await bakFile.delete();
        } catch (_) {}
      }

      // 6. 容量回收（失败不影响本次下载结果）。排除刚完成的文件，
      //    避免"先返回 success 再被异步回收删掉"导致 OpenFilex 打开到空路径。
      unawaited(enforceCapacity(
        exceptWorkId: workId,
        exceptFileKey: key,
      ));

      AppLogger.debug('下载完成: $workId/$fileName -> $destPath');
      return DownloadResult(DownloadStatus.success, destPath);
    } catch (e) {
      // 清理临时文件并还原用户原文件，失败绝不破坏既有数据。
      try {
        if (await tmpFile.exists()) await tmpFile.delete();
      } catch (_) {}
      if (backedUp) {
        try {
          await bakFile.rename(destPath);
        } catch (_) {}
      }
      if (e is DioException && CancelToken.isCancel(e)) {
        AppLogger.debug('下载已取消: $workId/$fileName');
        return const DownloadResult(DownloadStatus.cancelled);
      }
      if (e is DioException) {
        AppLogger.error('下载网络错误: $workId/$fileName', e);
        return const DownloadResult(DownloadStatus.networkError);
      }
      AppLogger.error('下载失败: $workId/$fileName', e);
      return const DownloadResult(DownloadStatus.ioError);
    }
  }

  Future<void> removeDownload(String workId, Child file) async {
    final key = fileKey(file);
    String? path;
    try {
      path = (await _repository.find(workId, key))?.filePath;
    } catch (e) {
      AppLogger.error('查询待移除下载失败', e);
    }
    // DB 行先删（一致性关键：失效行会让 app 误判已下载）；
    // 本地文件 best-effort，孤儿文件只是磁盘浪费、无害。
    var dbRemoved = false;
    try {
      await _repository.remove(workId, key);
      dbRemoved = true;
    } catch (e) {
      AppLogger.error('移除下载 DB 行失败（保留文件以免失效行）', e);
    }
    if (dbRemoved && path != null) {
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (e) {
        AppLogger.warning('移除下载文件失败（DB 行已删，孤儿无害）: $e');
      }
    }
  }

  /// 真 LRU：总量超上限时从最旧开始逐条删（文件 + DB 行），直到不超上限。
  /// 删不掉的文件仍在盘上 → 必须继续计入容量、且不删其 DB 行（行仍有效），
  /// 否则容量统计偏小、实际占用可能远超上限。
  Future<void> enforceCapacity({
    String? exceptWorkId,
    String? exceptFileKey,
  }) async {
    try {
      final entries = await _repository.listAllOldestFirst();
      var total = 0;
      final live = <DownloadEntry>[];
      for (final e in entries) {
        try {
          final f = File(e.filePath);
          if (await f.exists()) {
            total += (await f.stat()).size;
            live.add(e);
          } else {
            // 文件已不在：清失效行，不计容量。
            await _repository.remove(e.workId, e.fileKey);
          }
        } catch (_) {
          // stat 失败但行可能仍指向占用文件：用 DB size 保守计容量、
          // 保留在 live（与"删不掉/不可 stat 文件仍计容量"不变量一致）。
          total += e.size;
          live.add(e);
        }
      }
      for (final e in live) {
        if (total <= _maxTotalSize) break;
        // 跳过刚完成的文件：不能把用户刚要的东西回收掉。
        if (e.workId == exceptWorkId && e.fileKey == exceptFileKey) continue;
        try {
          final f = File(e.filePath);
          int sz;
          try {
            sz = await f.exists() ? (await f.stat()).size : e.size;
          } catch (_) {
            sz = e.size;
          }
          await f.delete();
          await _repository.remove(e.workId, e.fileKey);
          total -= sz;
        } catch (_) {
          // 占用中删不掉：保留文件与 DB 行（行仍有效），容量继续计，跳过。
        }
      }
    } catch (e) {
      AppLogger.error('下载容量回收失败', e);
    }
  }
}
