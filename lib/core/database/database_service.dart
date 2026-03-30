import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:asmrapp/utils/logger.dart';

class DatabaseService {
  static const _databaseName = 'yuro.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    AppLogger.debug('初始化数据库: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_subtitles (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        work_id       TEXT    NOT NULL,
        file_name     TEXT    NOT NULL,
        subtitle_path TEXT    NOT NULL,
        original_name TEXT,
        format        TEXT    NOT NULL,
        created_at    INTEGER NOT NULL,
        UNIQUE(work_id, file_name)
      )
    ''');
    AppLogger.debug('数据库表创建完成');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.debug('数据库升级: $oldVersion -> $newVersion');
    // Future migrations go here
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
