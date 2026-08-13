# 修复进度条拖动卡顿：拖动期间不再每个 pointer move 打一次 seek

- **创建时间**：2026-08-13
- **负责人**：WuMe-sicx
- **状态**：done <!-- active | done | cancelled -->
- **关联 Issue / PR**：<待补>

---

## 1. 目标（Goal）

`WaveformProgress` 的 `onHorizontalDragUpdate` 直接调用 `PlayerViewModel.seek()`，
一次连续拖动实测产生 **53 次** seek，每次都是 `await ready` + just_audio 平台通道
往返，表现为拖动响应卡顿。改为拖动期间只更新本地绘制位置，抬手时 seek 一次。

## 2. 范围（Scope）

**包含：**
- `lib/widgets/player/waveform_progress.dart`：拖动期间的本地位置状态 + 抬手 seek。
- 对应回归测试。

**不包含：**
- 页面/组件切换动画掉帧（另一个性能 bug，尚无可复现回路，单独立项）。
- `mini_player_progress.dart`（当前只显示、不可拖动，无同类问题）。
- 音频缓冲策略、`PlaybackController.seek` 内部实现。

## 3. 验收标准（Acceptance）

- [ ] 一次 60 步的连续拖动产生的 `seek()` 调用 ≤ 5 次。
- [ ] 抬手后最终 `seek()` 落在抬手位置（不被节流吞掉）。
- [ ] 拖动过程中滑块跟手，抬手后不出现位置回跳闪烁。
- [ ] `fvm flutter analyze` 通过，无新增 warning（基线 4 条）。
- [ ] `fvm flutter test test/widgets/player/waveform_progress_seek_rate_test.dart` 全绿。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：建立可跑红的回路
  - 涉及文件：`test/widgets/player/waveform_progress_seek_rate_test.dart`
  - 验证：已跑红，实测 53 次 seek（上限断言 5）。
- [x] **Step 2**：`WaveformProgress` 改为 StatefulWidget，拖动期间维护本地
      `_dragFraction`，只重绘不 seek；`onHorizontalDragEnd` seek 一次
  - 涉及文件：`lib/widgets/player/waveform_progress.dart`
  - 验证：回路两条断言均绿（53 次 → 1 次，抬手位置 70s 正确）。
- [x] **Step 3**：`flutter analyze` + 全量测试回归
  - 验证：`flutter analyze` 4 条基线 warning 无新增；`flutter test` 175 项全绿。

## 5. 风险与回滚（Risks）

- **风险**：抬手后清除 `_dragFraction` 的时机若早于新 position 到达，滑块会闪回
  旧位置。方案是 `await seek()` 完成后再清除。
- **回滚方案**：单文件改动，revert 该 commit 即可；回路测试保留，可独立说明问题。

## 6. 备注 / 决策记录

- 选「抬手 seek 一次」而非「拖动中节流 seek」：后者仍会打出多次平台通道调用，
  且中途 seek 会让音频反复重新缓冲，体验更差。
- 回路第一版用 `find.byType(CustomPaint).first` 抓错了目标 widget，手势落空导致
  **0 次 seek 假绿**。现已改为按 `painter is LinearTrackPainter` 定位，并加了
  `duration` 前置断言 + `seeks` 非空断言，防止回路失效而无人察觉。

---

## ✅ 完成标记

- 完成时间：2026-08-13
- 执行命令：`/init`（**待执行**——仓库当前有他人未提交的 `CLAUDE.md` 改动，
  为免把无关 diff 卷进本次提交，`/init` 与本 commit 分开做）
- CLAUDE.md 更新摘要：待 `/init` 后补。需记入的不变量：`WaveformProgress`
  拖动期间只更新本地 `_dragFraction`，**不得**在 `onHorizontalDragUpdate` 里
  直调 `seek()`；seek 只在抬手（`onHorizontalDragEnd`）发生一次。
- 关联 commit：见分支 `fix/seek-drag-throttle`
