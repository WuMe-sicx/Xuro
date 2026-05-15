# 修复：应用内播放器「无法暂停」（_isToggling 被 play() 长 Future 卡死）

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：（用户口头反馈，Codex SESSION_ID 019e2be0-4cce-7f82-aa9f-e8d2b2e9f783 已确认非本周期改动引入）

---

## 1. 目标（Goal）

修复既有 bug：通过应用内播放器「播放」按钮恢复播放后，再点「暂停」无效。根因是 `PlayerViewModel.playPause()` `await _audioService.resume()`，而 just_audio `play()` 的 Future「仅在暂停/停止/播放完成时才 complete」（just_audio 0.9.42 文档明确说明），导致 `_isToggling` 永久为 `true`，后续暂停点击被 `if (_isToggling) return;` 吞掉。

## 2. 范围（Scope）

**包含：**
- 仅修改 `lib/presentation/viewmodels/player_viewmodel.dart` 的 `playPause()`：恢复播放路径不再 `await` 永不完成的 `play()` Future。

**不包含：**
- 不改 `PlaybackController.play()` / `AudioPlayerService.resume()` / `playWithContext`（其 `await resume()` 同样长挂起属既有行为，调用方未因此卡死 UI，本次不扩大范围；如需根治另起任务）。
- 不改暂停路径（`pause()` 的 Future 正常及时 complete）。

## 3. 验收标准（Acceptance）

- [x] 真机：选曲播放 → 暂停 → 用应用内按钮恢复 → 再点暂停可正常暂停（可反复）。（代码修复完成，**待用户真机点测**）
- [x] MiniPlayer 与 PlayerScreen 两处按钮均生效（共用 `playPause`）。（同上，代码路径一致）
- [x] `flutter analyze` 通过，无新增 warning（该文件 No issues found）。
- [x] 不涉及数据模型，无需 build_runner。

## 4. 拆解步骤（Steps）

- [x] **S1**：`playPause()` 恢复分支由 `await _audioService.resume()` 改为 `unawaited(_audioService.resume().catchError(...→ emit PlaybackErrorEvent('resume', e, st)))`，并加 WHY 注释。
  - 涉及文件：`lib/presentation/viewmodels/player_viewmodel.dart`
  - 验证：analyze；`_isToggling` 在 finally 立即释放；错误经既有 `_eventHub.errors` 订阅更新 UI + 日志。
- [x] **S2**：`flutter analyze lib/presentation/viewmodels/player_viewmodel.dart` → No issues found。
- [x] **S3**：Codex 复审（SESSION_ID `019e2be0-4cce-7f82-aa9f-e8d2b2e9f783`）：首轮 ❌ CHANGE（fire-and-forget 缺错误处理）→ 修正后 ✅ PASS。
- [x] **收尾**：完成块已填；无结构性变更，**无需 /init**（无新增/重命名 服务/VM/Screen，CLAUDE.md 未涉及 playPause 内部）；移入 done/。

## 5. 风险与回滚（Risks）

- **风险（已修正认知）**：经 Codex 复审指出，`resume()`→`PlaybackController.play()=>_player.play()` **并无** 内部错误封装（不同于 `next/previous/setPlaybackContext`）。故 fire-and-forget 必须自带 `catchError`，将错误 `emit(PlaybackErrorEvent('resume', e, st))` 走 `PlayerViewModel` 既有 `_eventHub.errors` 订阅（设 `_errorMessage` + `AppLogger.error`）。已据此实现。
- **次要**：连点窗口内（resume 已发、`_isPlaying` 未回写 true）二次点击会再发一次 resume 而非 pause；just_audio `play()` 早置 `playing=true` 故基本幂等 no-op，相较原「永久锁死」可接受。
- **回滚**：单行改动，直接还原即可。

## 6. 备注 / 决策记录

- 选择在 `playPause()` 局部 fire-and-forget 而非改 `PlaybackController.play()`：最小爆炸半径，不触碰 `playWithContext` 既有语义（Karpathy：只修上报的 bug，不扩大范围）。根因证据：just_audio-0.9.42 `just_audio.dart` 第 918-920 行文档 + 第 971 行 `await playCompleter.future`。

---

## ✅ 完成标记

- 完成时间：2026-05-15
- 执行命令：无需 `/init`（纯行为修复，无结构性变更；CLAUDE.md 不描述 `playPause` 内部，无需刷新）
- CLAUDE.md 更新摘要：无变更
- 关联 commit：（待用户确认后提交，本次未自动 commit）
- Codex：SESSION_ID `019e2be0-4cce-7f82-aa9f-e8d2b2e9f783`，最终 ✅ PASS
- 遗留：真机点测「恢复后可反复暂停」待用户验收
