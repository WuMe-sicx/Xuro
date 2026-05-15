# 播放状态瘦身 + 节流落盘——降低主隔离区 JSON 编码开销

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：本地持久化优化清单第 1 项（Codex SESSION 019e2c0c…2962 分析 B1/C6）

---

## 1. 目标（Goal）

`last_playback_state` 当前在主隔离区把完整 `Work + Files + currentFile + playlist + currentIndex` JSON 编码后写 SharedPreferences，且每个 `playerStateStream` 事件都重置 5s debounce。大文件树作品会卡顿。本任务在**不改变恢复语义**的前提下，移除恢复根本用不到的冗余字段、拉长节流间隔、补齐生命周期 flush 与 stop 清理，直接降低播放/切歌时的掉帧风险。

## 2. 范围（Scope）

**包含：**
- `PlaybackState` 模型移除 `playlist`、`currentIndex`（恢复路径不消费，仅冗余复制 `files` 中的节点）。
- 保存 debounce 间隔 5s → 20s。
- `pause()` 立即 flush 一次；播放完成已有的立即保存保留。
- `PlaybackStateManager.dispose()` 取消 timer 前尽力 flush。
- `stop()` 清除持久化的 `last_playback_state`（新增 `clearState()`）。
- 修正 `restorePlaybackState()` 中对 `state.playlist`/`state.currentIndex` 的引用（改为基于重建后的 `context.playlist` 做空判断与日志）。

**不包含：**
- 不把 `work`/`files` 替换为 `workId` + 启动时 API 重新拉取（这是网络依赖的架构级改动，恢复语义会变，离线恢复受影响）——记为后续独立任务，本次保持离线可恢复。
- 不引入新的 `WidgetsBindingObserver`：后台/detached 的 flush 由 `pause()` flush + 完成时保存 + 20s 周期 + dispose 尽力 flush 覆盖现实路径。
- 不动 `audio_player_handler.dart` 里 `audio_service` 包自带的同名 `PlaybackState`（不同类型，无关）。

## 3. 验收标准（Acceptance）

- [x] `PlaybackState` 仅保留 `work/files/currentFile/playMode/position/timestamp`，旧版含 `playlist`/`currentIndex` 的 JSON 仍能被 `fromJson` 正常加载（Codex 核对 `.g.dart` 无未知键校验，多余键被忽略）。
- [x] 切歌/播放/暂停时不再每 5s 触发整树 JSON 编码；间隔为 20s，`pause()` 立即落盘。
- [x] `stop()` 后 `last_playback_state` 被清空，下次启动不误恢复已停止的内容（含写入竞态修复）。
- [x] 恢复行为不变：仍能从 `work/files/currentFile/playMode/position` 还原播放上下文（playlist/index 由 `PlaybackContext` 工厂从 `files` 派生）。
- [x] `flutter analyze` 通过，无新增 warning（仅 2 个既有 warning：`playback_controller.dart:9`、`playback_context.dart:196`）。
- [x] 已运行 `dart run build_runner build --delete-conflicting-outputs`，`playback_state.freezed.dart`/`.g.dart` 已重新生成。
- [x] 相关单元 / Widget 测试通过（31 通过；`test/widget_test.dart` 默认计数器模板测试在干净树上同样失败，属既有 stale，与本次无关）。
- [x] Codex review 出具 ✅ PASS（SESSION 019e2c0c…2962，竞态修复后第二轮 PASS）。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：`PlaybackState` 移除 `playlist`/`currentIndex` 字段（`playback_state.dart`，build_runner 已重生成）
- [x] **Step 2**：`PlaybackStateManager` —— `saveState()` 去两字段、`_saveInterval` 20s、`dispose()` best-effort flush（`playback_state_manager.dart`）
- [x] **Step 3**：接口与仓库新增 `clearState()` + manager `clearSavedState()` passthrough（`i_playback_state_repository.dart` / `playback_state_repository.dart`）
- [x] **Step 4**：`audio_player_service.dart` —— `pause()` flush、`stop()` 调 `clearSavedState()`、`restorePlaybackState()` 改用 `context.playlist`
- [x] **Step 5**：`flutter analyze`（无新增 warning）+ `flutter test`（31 通过，1 既有 stale 无关）全量回归
- [x] **Step 6**：Codex review —— 首轮 ❌ 发现 save/clear 写入竞态 → 修复（持久化串行化 `_persistChain` + `_persistSuppressed` tombstone）→ 第二轮 ✅ PASS

## 5. 风险与回滚（Risks）

- **风险**：硬杀进程（未经 pause）最多丢失约 20s 进度；可接受（完成/暂停/dispose 均有 flush）。恢复字段裁剪若有遗漏消费方会导致恢复失败——已 grep 确认仅 restore 日志与 manager 构造引用。
- **回滚方案**：revert 本次 commit；模型字段回退后需重跑 build_runner。

## 6. 备注 / 决策记录

- 关键依据：`PlaybackContext` 工厂 `playback_context.dart:51-68` 自行从 `files`+`currentFile` 派生 playlist/currentIndex；`restorePlaybackState` `audio_player_service.dart:174-179` 走该工厂，故持久化的 playlist/currentIndex 对恢复是死数据。
- 向后兼容无需迁移：json_serializable 默认 `includeIfNull`/未知键忽略，旧 JSON 多余键被丢弃即可。
- **Codex 首轮发现的竞态（已修）**：原 `saveState()` fire-and-forget，若在途 save 的 `setString` 在 `stop()` 的 `remove` 之后完成，会把已停止内容写回。修复：所有 save/clear 串行化进单条 `_persistChain`（remove 必排在在途 save 之后），并加 `_persistSuppressed` tombstone（`clearSavedState()` 同步置位，stop 后、新非空 `updateContext` 前的 save 全部 no-op；调用时刻快照 `context`/`positionMs` 防止链体执行时 `_currentContext` 已被置空）。第二轮 Codex ✅ PASS。

---

## ✅ 完成标记

- 完成时间：2026-05-15 16:20
- 执行命令：`/init`
- CLAUDE.md 更新摘要：刷新音频子系统持久化描述——`PlaybackState` 瘦身（移除 playlist/currentIndex）、20s 节流 + pause/完成/dispose flush、`stop()` 清持久化、save/clear 经 `_persistChain` 串行化 + `_persistSuppressed` tombstone 消除写回竞态。
- 关联 commit：未提交（用户未要求提交，待统一提交时机）
