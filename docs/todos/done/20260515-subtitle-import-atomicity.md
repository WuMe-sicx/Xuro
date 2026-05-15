# 字幕导入原子化——消除"先删旧→copy→upsert"的数据丢失与孤儿

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：本地持久化优化清单第 4 项（Codex SESSION 019e2c0c…2962 分析 C3）

---

## 1. 目标（Goal）

`SubtitleImportService.importSubtitle` 按「删旧文件 → `file.copy(destPath)` → DB `upsert`」顺序执行，任一步失败会留下孤儿文件或失效 DB 行；尤其**先删旧文件后 copy 失败 = 用户旧字幕丢失且无新字幕**；`file.copy` 非原子，同名重导入中途失败会得到截断文件。`removeImportedSubtitle` 先删文件后删 DB 行且整体吞异常，文件删成功但 DB 删失败会留下指向不存在文件的失效行。本任务把导入改为 **temp 文件 + 原子 rename + 成功后才删旧 + 失败只清 temp（绝不动旧文件）**，并把删除改为 **DB 优先、文件删除 best-effort 独立**。

## 2. 范围（Scope）

**包含：**
- `importSubtitle` 步骤 5–7 重排为原子序：copy 到同目录临时文件 → `File.rename(tmp → destPath)`（同文件系统原子替换）→ DB `upsert` → 成功后才删除「不同路径的旧文件」（仅扩展名变化时存在）；任一步失败 `finally`/catch 清理临时文件，**不触碰旧文件**（保住用户既有字幕），仍返回 `ImportResult.ioError`。
- `removeImportedSubtitle` 重排：先 `_repository.remove`（一致性关键，失败单独记录）→ 再 best-effort 删本地文件（失败仅 log，不回滚 DB、不影响调用方）。

**不包含：**
- 不改 `importSubtitle` / `removeImportedSubtitle` 的方法签名与返回契约（`ImportResponse` 保留；`removeImportedSubtitle` 仍 `Future<void>`——两处调用方均不消费返回值，向用户上报"移除失败"属 UI 层 scope，本次不做，记为后续可选）。
- 不引入 DB 事务跨「文件系统 + SQLite」（SQLite 无法纳管文件系统操作；原子 rename + 操作定序已消除数据丢失与失效行）。
- 不做启动期 `.import_tmp` 残留扫描清扫（进程中途被杀残留的小临时文件无害；下次同名导入 `copy` 覆盖之）。记为后续可选。
- 不动 `loadLocalSubtitle` / `findImported` / `_getDestPath` / 校验解析逻辑（步骤 1–4）。

## 3. 验收标准（Acceptance）

- [x] 旧文件仅在 rename + upsert 全部成功后才删除；同路径重导入额外加 `.import_bak` 备份，copy/rename/upsert 任一失败时旧字幕内容与旧 DB 行均恢复/保持不变（无数据丢失）。
- [x] `destPath` 永不处于半写状态：写入经 `tmp` 再 `rename` 原子替换；同名重导入中途失败经 bak 恢复，不产生截断文件。
- [x] 失败路径清理临时文件 + 恢复备份，孤儿仅限无害 `.import_tmp`/`.import_bak`；返回 `ImportResult.ioError` 不变。
- [x] `removeImportedSubtitle`：DB 行先删，`dbRemoved` 标志保护——**仅 DB 删成功才删文件**（杜绝失效行），DB 删失败保留文件且单独 error log，签名不变。
- [x] `player_viewmodel.dart:275/326` 两处调用行为不回退（Codex 确认）。
- [x] `flutter analyze lib/core/subtitle/` 仅既有 `path` info（本次 diff 未碰 import），无新增 warning。
- [x] 相关单元 / Widget 测试通过（31 通过；`test/widget_test.dart` 既有 stale 无关）。
- [x] Codex review ✅ PASS（SESSION 019e2c0c…2962，首轮 ❌ 2 个 high → 修复 → 二轮 PASS）。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：`importSubtitle` 原子序（copy→tmp / 旧 dest→bak / tmp→dest / upsert；成功删 bak+旧异路径文件；失败清 tmp+恢复 bak）
- [x] **Step 2**：`removeImportedSubtitle` DB 优先 + `dbRemoved` 保护（仅 DB 删成功才删文件）+ 失败分别记录
- [x] **Step 3**：`flutter analyze`（仅既有 path info）+ `flutter test`（31 通过，1 既有 stale）全量回归
- [x] **Step 4**：Codex review —— 首轮 ❌ 2 high（同路径 upsert 失败覆盖旧字幕 / remove DB 删失败仍删文件）→ 修复（bak 备份恢复 / dbRemoved 门控）→ 二轮 ✅ PASS

## 5. 风险与回滚（Risks）

- **风险**：`File.rename` 在同目录（同文件系统）原子替换，Android/iOS 走 POSIX `rename(2)`，可靠；若极端环境 rename 失败则按失败路径清 tmp、旧文件不变（退化为"导入失败"，无数据损坏）。DB 先删后文件删失败 → 孤儿文件（仅占盘，app 不会误判存在字幕，无一致性问题）。
- **回滚方案**：revert 本次 commit（纯逻辑改动，无 model/生成产物）。

## 6. 备注 / 决策记录

- 定序原则：用户既有数据（旧字幕文件 + 旧 DB 行）在新导入**确认成功前绝不破坏**；一致性关键操作（DB upsert / DB remove）相对文件操作的先后，按"失效 DB 行比孤儿文件更有害"选择——导入时 DB 指向的 destPath 必须在 upsert 前已是完整内容（故 rename 在 upsert 前）；删除时 DB 行先移除（孤儿文件无害，失效行会误导加载）。
- Codex 首轮 2 个 high 修正：(1) 同路径重导入 rename 已替换旧文件、upsert 再失败则旧字幕不可恢复——补 `.import_bak`：copy→tmp 后先把旧 destPath rename 到 bak（`backedUp`），upsert 失败时 `bakFile.rename(destPath)` 覆盖恢复；成功才删 bak。(2) remove 时 DB 删失败仍删文件仍会留失效行——加 `dbRemoved` 门控，仅 DB 删成功才删本地文件，否则保留文件让既有有效行可继续/重试。

---

## ✅ 完成标记

- 完成时间：2026-05-15 18:55
- 执行命令：`/init`
- CLAUDE.md 更新摘要：补充字幕导入/移除原子性不变量——导入经 tmp+原子 rename，同路径重导入用 `.import_bak` 备份并在失败时恢复（任一步失败旧字幕与旧 DB 行不变），仅全成功后删旧文件；移除以 `dbRemoved` 门控，DB 行先删且仅其成功后才删本地文件（杜绝失效行）。
- 关联 commit：未提交（用户未要求提交，待统一提交时机）
