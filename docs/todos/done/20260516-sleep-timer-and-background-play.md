# 睡眠定时器 + 后台播放开关（真实功能，非占位）

- **创建时间**：2026-05-16
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联**：用户在 `docs/todos/active/20260516-five-screen-layout-token-polish.md` 之后明确要求「添加设置睡眠定时器和后台播放开关功能」——此前审计列为「参考图中无后端支撑」的两项，现用户显式要求**真实实现**（非臆造占位），符合 [[feedback-reference-reskin-discipline]]（用户显式要求即可做，且必须真实可用）。

## 1. 目标（Goal）

> 在设置「播放」分区新增两项**真实可用**功能：①睡眠定时器——选定时长后到点自动暂停播放；②后台播放开关——关闭后 app 切到后台自动暂停（默认开启＝保持现有「始终后台播放」行为）。两者复用现有 `WakeLockController`/`CacheLifecycleManager` 既有模式，不臆造、不破坏音频子系统不变量。

## 2. 范围（Scope）

**包含：**
- 新增 `lib/core/platform/sleep_timer_controller.dart`：`ChangeNotifier`，持 `Timer`＋选定分钟数；到点调 `IAudioPlayerService.pause()`；`setMinutes(null|0)` 取消；`dispose()` 取消 Timer。
- 新增 `lib/screens/settings/sleep_timer_dialog.dart`：单选时长对话框（关闭/15/30/45/60/90 分钟），镜像 `AudioFormatOrderDialog` 结构。
- 新增 `lib/core/platform/background_play_controller.dart`：`WidgetsBindingObserver`，`AppLifecycleState.paused` 且 `!backgroundPlayEnabled` 且在播 → `pause()`；`initialize()` 幂等（镜像 `CacheLifecycleManager`）。
- `app_settings_service.dart`：新增持久化 `backgroundPlayEnabled`（默认 `true`，镜像既有 setter 模式）。
- `service_locator.dart`：注册两控制器（SleepTimer 依赖 `IAudioPlayerService`；BackgroundPlay 依赖 `AppSettingsService`+`IAudioPlayerService`）。
- `main.dart`：`BackgroundPlayController().initialize()`（紧随 `CacheLifecycleManager().initialize()`）。
- `settings_screen.dart` `_playbackSection`：+ 睡眠定时 `SettingsTile.navigation`（value=当前选择，onTap 开对话框）；+ 后台播放 `SettingsTile.toggle`。
- `strings.dart`：新增文案常量（睡眠定时/关闭/N 分钟函数/后台播放/描述）。
- 单测 `test/core/platform/sleep_timer_controller_test.dart`（纯状态逻辑，network/timing-free 主体）。

**不包含（严守边界）：**
- 睡眠定时**不持久化**（会话级控制；重启后静默重新计时＝坏 UX，且避开 `playback_state` 持久化不变量）。
- 到点动作用 **`pause()` 而非 `stop()`**：`stop()` 会清空 `last_playback_state`（CLAUDE.md 不变量），睡眠场景需可恢复；`pause()` 为播客/音乐 app 标准睡眠行为。
- 后台播放关闭时**只暂停、不自动恢复**（前台返回不自动续播——最小、可预期）。
- 不重构 `audio_service`/`AudioPlayerHandler`/前台服务；不动锁屏通知与播放态持久化链路。
- 不臆造参考图其它无后端项（音量/音效/均衡器/语言等仍不做）。

## 3. 验收标准（Acceptance）

- [ ] 设置→播放：睡眠定时行显示当前选择（关闭/X 分钟），点开对话框可选；选定后到点播放自动暂停，可手动恢复。
- [ ] 选「关闭」或重新选别的时长能正确取消/重置旧 Timer（无双 Timer 泄漏）。
- [ ] 后台播放开关默认 **ON**（升级用户行为不变）；关闭后切后台自动暂停，前台不自动续播；开启时后台继续播（现行为）。
- [ ] `backgroundPlayEnabled` 持久化（重启保持）；睡眠定时不持久化（重启＝关闭）。
- [ ] `flutter analyze` 无新增告警；**全量 `flutter test` 零回归** + 新增 SleepTimer 单测通过。
- [ ] Codex review ✅ PASS（Coder 未启用，Claude 直接编辑）。
- [ ] 用户实机验证两功能后 → `/init` 收口。

## 4. 拆解步骤（Steps）

- [x] **Step 1** 本 TODO 文档 ✅ 2026-05-16。
- [x] **Step 2** ✅ 2026-05-16：`sleep_timer_controller.dart`（ChangeNotifier，Timer→`pause()`，不持久化）+ `sleep_timer_dialog.dart`（关闭/15/30/45/60/90 单选）+ `service_locator` 注册 + `settings_screen._playbackSection` 接入导航行。
- [x] **Step 3** ✅ 2026-05-16：`AppSettingsService.backgroundPlayEnabled`（持久化默认 true，镜像既有 setter）+ `background_play_controller.dart`（WidgetsBindingObserver，`paused`&`!enabled`→`pause()`，不自动恢复，幂等 initialize）+ `service_locator` 注册 + `main.dart` initialize + `settings_screen` toggle 行。
- [x] **Step 4** ✅ 2026-05-16：`strings.dart` +5 文案（sleepTimer/Off/Minutes(n)/backgroundPlay/Desc）。
- [x] **Step 5** ✅ 2026-05-16：`test/core/platform/sleep_timer_controller_test.dart` 8 用例（fakeAsync）；`pubspec` 显式声明 `fake_async ^1.3.1`（消除 depend_on_referenced_packages info）；`flutter analyze` 7 项 No issues；全量 `flutter test` **103/103 零回归**。
- [x] **Step 6** ✅ 2026-05-16：Codex review（SESSION_ID `019e2dfd-621a-7652-a5a0-eb75b483bbd8`）→ **✅ PASS**（Timer 生命周期/后台暂停门控/DI 时序/Listenable.merge/持久化边界/无虚构 均核实）。
- [x] **Step 7** ✅ 2026-05-16：用户确认、同意正式收尾 → 完成标记 + `/init` + 移 done。

## 5. 风险与回滚（Risks）

- **风险**：睡眠 Timer 未在 `setMinutes`/`dispose` 正确取消 → 双 Timer / 应用退出后回调。
  - **缓解**：每次 `setMinutes` 先 `_timer?.cancel()`；`dispose()` 取消；单测覆盖取消/重置。
- **风险**：后台暂停误伤——`paused` 在某些设备也在短暂遮挡时触发。
  - **缓解**：仅在 `!backgroundPlayEnabled` 且当前在播时 `pause()`；默认开启＝零行为变化；不自动恢复避免抢占用户意图。
- **风险**：触碰音频子系统不变量。
  - **缓解**：只调既有 `IAudioPlayerService.pause()`（公共 API），不动 handler/通知/持久化链；睡眠不持久化绕开 `playback_state` 不变量。
- **回滚**：新增文件独立；`settings_screen`/`app_settings`/`service_locator`/`main` 改动小且聚焦，可按文件 revert。

## 6. 备注 / 决策记录

- 2026-05-16：用户显式要求实现睡眠定时器与后台播放开关。设计「合理判断」：时长档 关闭/15/30/45/60/90；到点 `pause()` 非 `stop()`；睡眠不持久化、后台开关持久化默认 ON；后台只暂停不自动恢复。延续：Coder 未启用 Claude 直接编辑 + Codex review（[[feedback-codex-review-loop]]）；播放器/设置极简（[[feedback-player-ui-minimal]]）——复用既有 tile 工厂，不堆砌。

---

## ✅ 完成标记

- 完成时间：2026-05-16 17:40
- 执行命令：`/init`
- CLAUDE.md 更新摘要：新增 `SleepTimerController`（会话级，到点 `pause()`，不持久化）+ `BackgroundPlayController`（生命周期观察者，`paused`&`!enabled` 暂停，不自动恢复）；`AppSettingsService.backgroundPlayEnabled` 持久化默认 true；设置「播放」分区接入两控制 + 播放器 AppBar 睡眠定时快捷键。
- 关联 commit：未提交（用户未要求 commit；待用户决定提交时机）

---

## ⛔ 取消标记（仅 cancelled 任务填写）

- 取消时间：YYYY-MM-DD HH:mm
- 取消原因：<...>
- 后续指向：<...>
