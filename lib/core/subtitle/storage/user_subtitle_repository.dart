import 'package:sqflite/sqflite.dart';
import 'package:asmrapp/core/database/database_service.dart';
import 'package:asmrapp/core/subtitle/models/user_subtitle_entry.dart';
import 'package:asmrapp/core/subtitle/storage/i_user_subtitle_repository.dart';
import 'package:asmrapp/utils/logger.dart';

class UserSubtitleRepository implements IUserSubtitleRepository {
  static const _table = 'user_subtitles';
  final DatabaseService _db;

  UserSubtitleRepository(this._db);

  @override
  Future<UserSubtitleEntry?> find(String workId, String fileName) async {
    final db = await _db.database;
    final results = await db.query(
      _table,
      where: 'work_id = ? AND file_name = ?',
      whereArgs: [workId, fileName],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserSubtitleEntry.fromMap(results.first);
  }

  @override
  Future<void> upsert(UserSubtitleEntry entry) async {
    final db = await _db.database;
    await db.insert(
      _table,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    AppLogger.debug('用户字幕关联已保存: ${entry.workId}/${entry.fileName}');
  }

  @override
  Future<void> remove(String workId, String fileName) async {
    final db = await _db.database;
    await db.delete(
      _table,
      where: 'work_id = ? AND file_name = ?',
      whereArgs: [workId, fileName],
    );
    AppLogger.debug('用户字幕关联已删除: $workId/$fileName');
  }

  @override
  Future<List<UserSubtitleEntry>> listByWork(String workId) async {
    final db = await _db.database;
    final results = await db.query(
      _table,
      where: 'work_id = ?',
      whereArgs: [workId],
      orderBy: 'created_at DESC',
    );
    return results.map(UserSubtitleEntry.fromMap).toList();
  }
}
