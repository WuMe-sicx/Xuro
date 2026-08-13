import 'package:sqflite/sqflite.dart';
import 'package:xuro/core/database/database_service.dart';
import 'package:xuro/core/download/models/download_entry.dart';
import 'package:xuro/utils/logger.dart';

class DownloadRepository {
  static const _table = 'downloads';
  final DatabaseService _db;

  DownloadRepository(this._db);

  /// 按稳定身份键查找（[fileKey]，**非**展示名）。
  Future<DownloadEntry?> find(String workId, String fileKey) async {
    final db = await _db.database;
    final results = await db.query(
      _table,
      where: 'work_id = ? AND file_key = ?',
      whereArgs: [workId, fileKey],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return DownloadEntry.fromMap(results.first);
  }

  Future<void> upsert(DownloadEntry entry) async {
    final db = await _db.database;
    await db.insert(
      _table,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    AppLogger.debug('下载记录已保存: ${entry.workId}/${entry.fileName}');
  }

  Future<void> remove(String workId, String fileKey) async {
    final db = await _db.database;
    await db.delete(
      _table,
      where: 'work_id = ? AND file_key = ?',
      whereArgs: [workId, fileKey],
    );
    AppLogger.debug('下载记录已删除: $workId/$fileKey');
  }

  Future<List<DownloadEntry>> listByWork(String workId) async {
    final db = await _db.database;
    final results = await db.query(
      _table,
      where: 'work_id = ?',
      whereArgs: [workId],
      orderBy: 'created_at DESC',
    );
    return results.map(DownloadEntry.fromMap).toList();
  }

  /// 全部记录，按 createdAt 升序（最旧在前）——供 LRU 容量回收使用。
  Future<List<DownloadEntry>> listAllOldestFirst() async {
    final db = await _db.database;
    final results = await db.query(_table, orderBy: 'created_at ASC');
    return results.map(DownloadEntry.fromMap).toList();
  }
}
