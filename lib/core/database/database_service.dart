import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:xuro/utils/logger.dart';

class DatabaseService {
  static const _databaseName = 'xuro.db';
  static const _databaseVersion = 2;

  // schema 定义集中一处，`_onCreate`（全新安装拿到最新完整 schema）与
  // `_migrations`（旧库逐版本升级）共用同一字符串，避免两条路径漂移。
  static const _createUserSubtitlesTable = '''
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
    ''';

  // file_key = 稳定身份摘要（md5(hash|url|title)）。去重/UNIQUE 用 file_key，
  // 不用展示名 file_name：同一作品下不同目录/URL 的同名文件（如两个 01.mp3）
  // 必须算作不同下载，否则会互相误判命中。file_name 仅用于展示。
  static const _createDownloadsTable = '''
      CREATE TABLE downloads (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        work_id     TEXT    NOT NULL,
        file_key    TEXT    NOT NULL,
        file_name   TEXT    NOT NULL,
        file_path   TEXT    NOT NULL,
        media_type  TEXT    NOT NULL,
        source_url  TEXT    NOT NULL,
        size        INTEGER NOT NULL DEFAULT 0,
        created_at  INTEGER NOT NULL,
        UNIQUE(work_id, file_key)
      )
    ''';

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

  /// 全新安装：sqflite 只调 onCreate（**不会**再调 onUpgrade），因此这里必须
  /// 建出「当前版本」的完整 schema（所有表），而非只建 v1。新增表时两处都要加：
  /// 这里（给全新安装）+ `_migrations`（给旧库升级）。
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createUserSubtitlesTable);
    await db.execute(_createDownloadsTable);
    AppLogger.debug('数据库表创建完成 (v$version)');
  }

  /// 版本顺序迁移表：键为目标版本，值为「从 (键-1) 升到 键」要执行的步骤。
  /// 新增一次 schema 变更时：bump [_databaseVersion]，在 `_onCreate` 补上新表/列
  /// （给全新安装），并在此加一条 `<newVersion>: (db) async {...}`（给旧库升级）。
  /// `_onUpgrade` 会按版本号升序逐步应用，保证多版本跨越升级也安全。
  static final Map<int, Future<void> Function(Database db)> _migrations = {
    // 1 由 _onCreate 建立，无迁移。
    // 2: 新增 downloads 表（本地下载/离线）。旧 v1 库走此路径补建；
    //    全新安装由 _onCreate 直接建好，不会进 _onUpgrade。
    2: (db) async {
      await db.execute(_createDownloadsTable);
    },
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
