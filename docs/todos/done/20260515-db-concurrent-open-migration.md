# DB 防并发首开 + 迁移框架——消除双开句柄、为 schema 演进兜底

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：本地持久化优化清单第 5 项（Codex SESSION 019e2c0c…2962 分析 C4）

---

## 1. 目标（Goal）

`DatabaseService.database` 用 `_database ??= await _initDatabase();`——`??=` 与 `await` 之间存在挂起点，并发首次访问（`UserSubtitleRepository` 的 find/upsert/remove/listByWork 各自独立 `await _db.database`，切歌/查询可并发）会让多个调用方都判定 `_database == null` 并各自 `openDatabase()`，产生重复句柄（泄漏 + 潜在锁冲突）。同时 `_onUpgrade` 为空，未来 schema 变更无安全迁移机制。本任务：缓存 **Future** 而非已解析的 `Database`（null 检查与赋值之间无 await，单线程事件循环下原子），打开失败清缓存允许重试；并补一个**版本顺序迁移框架**（空步骤，提供机制）。

## 2. 范围（Scope）

**包含：**
- `database` getter 改为 `_databaseFuture ??= _open()`：所有并发调用方共享同一 in-flight Future；`_open()` 内 `try { await _initDatabase() } catch { _databaseFuture = null; rethrow; }` 使一次打开失败不会永久毒化后续访问。
- `close()` 适配：await 在途 open（若有）再 `db.close()`，并置 `_databaseFuture = null` 以便后续重开。
- `_onUpgrade` 改为按版本顺序循环应用 `_migrations`（有序 Map `{version: (db) async {...}}`，当前为空 + 用法注释）；`_databaseVersion` 保持 1（无实际迁移）。

**不包含：**
- 不新增表/列、不改 schema、不 bump `_databaseVersion`（无功能性迁移需求）。
- 不引入 sqflite 之外的迁移库；不做 down-migration（移动端单向升级足够）。
- 不改 `UserSubtitleRepository` 调用方（getter 签名 `Future<Database>` 不变）。

## 3. 验收标准（Acceptance）

- [x] 并发多次 `await db.database` 只触发一次 `_open()`/`openDatabase()`，共享同一 in-flight Future（Codex 确认 getter 无 await 挂起点）。
- [x] `_initDatabase()` 失败后 `_databaseFuture` 清空，下次访问重试；已等待的并发方一致收到异常，无残留毒化。
- [x] `close()` 等待在途 open 后关闭并复位，getter 返回类型仍 `Future<Database>`，调用方零改动（`close()` 全仓无调用方，仅定义）。
- [x] `_onUpgrade` 版本顺序循环 `(oldVersion, newVersion]`，多版本跳跃安全；version=1 永不触发、空 `_migrations`、行为零变化。
- [x] `flutter analyze lib/core/database/` 仅既有 `path` info（本次未碰 import），无新增 warning。
- [x] 相关单元 / Widget 测试通过（31 通过；`test/widget_test.dart` 既有 stale 无关）。
- [x] Codex review ✅ PASS（SESSION 019e2c0c…2962，首轮通过）。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：`_database` → `_databaseFuture`；`database` 表达式体 getter 原子化 + `_open()` 失败清缓存
- [x] **Step 2**：`close()` 适配 Future 缓存（取出置 null → await → close → catch log）
- [x] **Step 3**：`_onUpgrade` 版本顺序迁移框架（空 `_migrations` Map + `(oldVersion,newVersion]` 循环 + 用法注释）
- [x] **Step 4**：`flutter analyze`（仅既有 path info）+ `flutter test`（31 通过，1 既有 stale）全量回归
- [x] **Step 5**：Codex review —— 首轮 ✅ PASS（确认无 await 挂起点、失败不毒化、迁移多版本安全）

## 5. 风险与回滚（Risks）

- **风险**：缓存 Future 的关键正确性依赖"`??=` 与 `_open()` 同步段（首个 await 前）之间无挂起点"——Dart 单线程事件循环成立。`close()` 若在 open 在途时调用需正确串行。空迁移框架为后续机制，当前零行为变化。
- **回滚方案**：revert 本次 commit（单文件纯逻辑，无 model/生成产物/schema 变更）。

## 6. 备注 / 决策记录

- 选「缓存 Future」而非加锁/Completer：最简且 Dart 惯用法，`??=` 在赋值前不 await 即原子。失败清缓存避免毒化。
- 迁移框架保持「机制而非投机功能」：仅有序循环 + 空 Map + 注释，不预写任何 speculative 迁移（constraint.md：Simplicity > Over-engineering，但需 multi-version-safe 机制兜底，符合任务"迁移框架"要求）。

---

## ✅ 完成标记

- 完成时间：2026-05-15 19:35
- 执行命令：`/init`
- CLAUDE.md 更新摘要：补充 `DatabaseService` 不变量——`database` 缓存 Future（`??= _open()` 无 await 挂起点，并发首访只开一次）、`_open()` 失败清 `_databaseFuture` 防毒化、`close()` 适配、`_onUpgrade` 走版本顺序 `_migrations` 循环（新增迁移须 bump version 并在表中加步骤）。
- 关联 commit：未提交（用户未要求提交，待统一提交时机）
