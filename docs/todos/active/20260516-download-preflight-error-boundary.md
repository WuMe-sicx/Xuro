# 下载前置 IO/DB 失败纳入错误边界（Codex 合并前审发现的 HIGH 阻断）

- **创建时间**：2026-05-16
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联**：PR #4 合并前 Codex 总审（SESSION_ID `019e2dfd-621a-7652-a5a0-eb75b483bbd8`）判 ❌ CHANGE 的 HIGH 项；修后须重审 ✅ 才合并

## 1. 目标（Goal）

> `DownloadService.download()` 的去重查询 `findCompleted()`、目标路径解析 `_destPath()`、tmp/bak 路径构造在 `try` **之外**执行——DB 打开/迁移失败、`path_provider`/目录创建失败、`File.exists()` 权限异常会直接抛出未捕获异步异常；两个下载对话框 `await widget.download(...)` 又无兜底 catch，导致弹窗卡在不可关闭进度态、且绕过下载服务承诺的 ioError + 清理路径。把前置 IO/DB 纳入同一 `try`（nullable tmp/bak/destPath 做清理），并给两个对话框加最后防线。

## 2. 范围（Scope）

**包含：**
- `lib/core/download/download_service.dart` `download()`：`findCompleted`/`_destPath`/tmp-bak 构造移入 `try`；`destPath/tmpFile/bakFile` 改 `try` 前 nullable 声明、`try` 内赋值；catch 清理加 null 守卫；`alreadyExists` 早返回仍在 try 内（正常 return 不入 catch）。**原子写顺序与回滚语义保持不变**（tmp→bak→rename→upsert；失败删 tmp、还原 bak、绝不毁既有好文件——CLAUDE.md 不变量）。
- `lib/widgets/detail/media_download_dialog.dart` `_start()`：`await widget.download` 包 try/catch，异常 → `pop(DownloadResult(DownloadStatus.ioError))`（防御纵深）。
- `lib/widgets/detail/batch_download_dialog.dart` `_start()`：同上，异常 → `pop(BatchDownloadOutcome(ok:0,skipped:0,failed:audioCount,cancelled:false))`。
- 流程一致性（Codex MEDIUM）：`20260516-local-media-download-and-video.md`（步骤全勾）填完成标记并移 done；`20260516-startup-loading-performance.md` 保持 active 并注明「代码优化已随 PR，设备前后采数为待办」（不臆造性能数据）。

**不包含：**
- 不改原子写顺序/回滚语义/容量 LRU/分类逻辑（Codex 已确认这些不变量完好）。
- 不动其它下载/字幕流程。

## 3. 验收标准（Acceptance）

- [ ] 前置 `findCompleted`/`_destPath`/`File.exists` 抛错时 `download()` 返回 `DownloadStatus.ioError`（非未捕获异常），tmp/bak 清理 null-safe 不 NPE。
- [ ] 两对话框遇异常以失败结果 `pop`，不再卡在不可关闭进度态。
- [ ] 原子写顺序与回滚行为不变；`fvm flutter analyze` 无新增告警；全量 `fvm flutter test` 零回归。
- [ ] Codex 重审（同 SESSION_ID）该 HIGH 项 → ✅；流程 MEDIUM 一并消解。
- [ ] 仅在 Codex ✅ 后方合并 PR #4（用户「确认无误才合并」）。

## 4. 拆解步骤（Steps）

- [x] **Step 1** 本 TODO ✅ 2026-05-16。
- [x] **Step 2** ✅ 2026-05-16：`download_service.dart` 前置（findCompleted/_destPath/tmp-bak）移入 try；`destPath/tmpFile/bakFile` nullable 前置声明、try 内赋值；catch 取 `tf/bf/dp` 局部 + `backedUp && bf!=null && dp!=null` 守卫；原子写/回滚顺序逐行不变。
- [x] **Step 3** ✅ 2026-05-16：`media_download_dialog`/`batch_download_dialog` `_start()` 包 try/catch，异常分别 `pop(DownloadResult.ioError)` / `pop(BatchDownloadOutcome(failed:audioCount))`。
- [x] **Step 4** ✅ 2026-05-16：`local-media-download-and-video.md` 填标记移 done；`startup-loading-performance.md` 保持 active + 注明设备采数待办（不臆造）。
- [x] **Step 5** ✅ 2026-05-16：`flutter analyze`（3 文件 No issues）+ 全量 `flutter test` **103/103 零回归**。
- [ ] **Step 6** Codex 重审（同 SESSION_ID）→ ✅ PASS。
- [ ] **Step 7** 提交 + push；Codex ✅ 后合并 PR #4。

## 5. 风险与回滚（Risks）

- **风险**：移动前置代码进 try 误改原子写顺序/回滚。
  - **缓解**：仅移动「去重查询/路径解析/tmp-bak 构造」三段，下载→备份→rename→upsert→清理顺序逐行保持；catch 还原逻辑仅加 null 守卫。
- **风险**：`destPath` 移入 try 后 catch 还原 `bak→destPath` 取不到。
  - **缓解**：`String? destPath` try 前声明、try 内赋值；catch 用 `backedUp && bakFile!=null && destPath!=null` 守卫（`backedUp` 必在 destPath 赋值后才可能为真）。
- **回滚**：单文件聚焦改动，可按文件 `git revert`。

## 6. 备注 / 决策记录

- 2026-05-16：Codex 合并前总审（PR #4）判 ❌，HIGH=下载前置错误边界。用户「Codex 替我审查，确认无误合并」→ 修复 + 重审，未 ✅ 不合并（[[feedback-codex-review-loop]]）。startup-perf 采数不臆造，保持 active 拆为后续。

---

## ✅ 完成标记

- 完成时间：YYYY-MM-DD HH:mm
- 执行命令：`/init`
- CLAUDE.md 更新摘要：<一两句话>
- 关联 commit：<commit hash>

---

## ⛔ 取消标记（仅 cancelled 任务填写）

- 取消时间：YYYY-MM-DD HH:mm
- 取消原因：<...>
- 后续指向：<...>
