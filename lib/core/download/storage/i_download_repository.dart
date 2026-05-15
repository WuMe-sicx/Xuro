import 'package:xuro/core/download/models/download_entry.dart';

abstract class IDownloadRepository {
  /// 按稳定身份键查找（[fileKey]，**非**展示名）。
  Future<DownloadEntry?> find(String workId, String fileKey);
  Future<void> upsert(DownloadEntry entry);
  Future<void> remove(String workId, String fileKey);
  Future<List<DownloadEntry>> listByWork(String workId);

  /// 全部记录，按 createdAt 升序（最旧在前）——供 LRU 容量回收使用。
  Future<List<DownloadEntry>> listAllOldestFirst();
}
