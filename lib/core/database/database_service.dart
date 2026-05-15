import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:xuro/utils/logger.dart';

class DatabaseService {
  static const _databaseName = 'xuro.db';
  static const _databaseVersion = 1;

  // 缓存的是 Future 而非已解析的 Database：`??=` 与赋值之间没有 await
  // 挂起点，单线程事件循环下并发首访只会触发一次 _open()，所有调用方
  // 共享同一 in-flight Future，避免重复 openDatabase() 双句柄。
  Future<Database>? _databaseFuture;

  Future<Database> get database => _databaseFuture ??= _open();

  Future<Database> _open() async {
    try {
      return await _initDatabase();
    } catch (e) {
      // 一次打开失败不应永久毒化后续访问：清缓存让下次访问可重试。
      _databaseFuture = null;
      rethrow;
    }
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

  /// 版本顺序迁移表：键为目标版本，值为「从 (键-1) 升到 键」要执行的步骤。
  /// 新增一次 schema 变更时：bump [_databaseVersion]，并在此加一条
  /// `<newVersion>: (db) async { await db.execute('ALTER TABLE ...'); }`。
  /// `_onUpgrade` 会按版本号升序逐步应用，保证多版本跨越升级也安全。
  static final Map<int, Future<void> Function(Database db)> _migrations = {
    // 1 由 _onCreate 建立，无迁移。后续版本在此追加。
  };

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.debug('数据库升级: $oldVersion -> $newVersion');
    for (var v = oldVersion + 1; v <= newVersion; v++) {
      final migration = _migrations[v];
      if (migration != null) {
        AppLogger.debug('应用数据库迁移: -> v$v');
        await migration(db);
      }
    }
  }

  Future<void> close() async {
    final future = _databaseFuture;
    _databaseFuture = null;
    if (future == null) return;
    try {
      final db = await future;
      await db.close();
    } catch (e) {
      AppLogger.error('关闭数据库失败', e);
    }
  }
}
