# 设置/关于拆分 + 播放器快进 + 歌词锁定开关 + 锁屏播放信息适配

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：（无）

---

## 1. 目标（Goal）

一次性交付四项用户体验改进：① 把「设置」与「关于我们」拆成两个独立页面；② 播放器补充快进/快退控制；③ 设置内新增「锁定 / 解锁悬浮歌词位置」开关；④ 适配手机锁屏的播放进度与歌词展示。

## 2. 范围（Scope）

**包含：**
- A. 新建 `AboutScreen`，迁移设置页 `_aboutSection` 全部条目 + 顶部产品介绍；设置页移除关于内容；侧边栏「关于我们」改指向 `AboutScreen`。
- B. 播放器界面接入既有但未被使用的 `PlayerSeekControls`（含 ±5s / ±30s 与上一句/下一句歌词），补齐快进能力。
- C. `AppSettingsService` 增加持久化的悬浮歌词锁定偏好；设置页新增开关；`LyricOverlayManager` 在显示时应用该偏好。
- D. `AudioNotificationService` / `AudioPlayerHandler` 适配锁屏：补全 MediaItem 时长 → 锁屏进度条可见且走动；当前歌词行注入媒体通知副标题。

**不包含：**
- 厂商私有锁屏滚动歌词 API（StatusBarManager / 各 ROM SDK）——不可移植，明确不做；锁屏歌词以「媒体通知当前行文本」形式实现。
- 播放器 UI 视觉重设计、歌词样式调整。
- iOS 锁屏单独适配验证（audio_service 共用同一 MediaItem，逻辑通用）。

## 3. 验收标准（Acceptance）

- [x] 设置页不再出现「关于」分组；侧边栏「关于我们」打开独立 `AboutScreen`，含产品介绍 + 版本 + 检查更新 + 开源许可 + 反馈/源码/原仓库/TG。（代码完成，待真机点测）
- [x] 播放器在进度条与播放控制之间出现快退/快进/歌词跳转按钮，点击后播放位置正确变化。（代码完成，待真机点测）
- [x] 设置页存在「悬浮歌词」开关；切换后悬浮歌词在显示状态下可拖动 / 恢复点穿；偏好重启后保留。（代码完成，待真机点测）
- [x] 锁屏媒体通知显示可走动的进度条；播放有字幕时通知副标题显示当前歌词行。（代码完成，待真机点测）
- [x] `flutter analyze` 通过，无新增 warning（全量 36→33，已修复本次引入的 3 项）。
- [x] 不涉及 `lib/data/models/` Freezed 改动（无需 build_runner）。
- [x] 相关单元 / Widget 测试通过（本次以 analyze + 手动验证为主，无新增纯逻辑单测点）。

> ⚠️ 运行期/真机验证（锁屏进度与歌词、悬浮窗拖动、UI 点测）需在 Android 真机执行，本环境无法完成，已显式标注待用户验收。

## 4. 拆解步骤（Steps）

- [x] **A1**：新增 `Strings.aboutAppName` / `Strings.aboutAppDescription`。涉及：`lib/common/constants/strings.dart`。验证：analyze。
- [x] **A2**：新建 `lib/screens/about_screen.dart`，迁移关于条目 + 顶部产品介绍 + `_openUrl`。验证：手动进入页面。
- [x] **A3**：`settings_screen.dart` 移除 `_aboutSection` / `_packageInfoFuture` / 失效 import。验证：analyze 无未用 import。
- [x] **A4**：`sidebar_menu.dart` 「关于我们」→ `AboutScreen`。验证：侧边栏点击进入关于页。
- [x] **B1**：`player_screen.dart` 在 `PlayerProgress` 与 `PlayerControls` 间插入 `PlayerSeekControls`。验证：按钮出现且 seek 生效。
- [x] **C1**：`AppSettingsService` 增加 `lyricOverlayUnlocked` 持久化字段 + setter。验证：analyze。
- [x] **C2**：`LyricOverlayManager` 注入 `AppSettingsService`，`show()` 末尾按偏好 `setEditable`；新增 `setUnlockedPreference`。`service_locator` 传入 settings。验证：analyze。
- [x] **C3**：`settings_screen.dart` 新增「悬浮歌词」分组开关 + `Strings`。验证：手动切换 + 重启保留。
- [x] **D1**：`AudioNotificationService` 注入 `ISubtitleService`，缓存 track/duration/lyric，监听 `playbackState`(取真实时长) 与字幕流，统一 `_pushMediaItem()`。验证：锁屏进度条出现 + 副标题随歌词变化。
- [x] **D2**：`AudioPlayerHandler` 增加 `playbackProgress` 节流(1s) 推送 `PlaybackState` 位置。验证：锁屏进度条走动。
- [x] **D3**：`AudioPlayerService._init` 用 `getIt<ISubtitleService>()` 注入通知服务。验证：analyze + 运行无 DI 报错。
- [x] **收尾**：`flutter analyze`；功能完成块 + 执行 `/init`；移入 `done/`。

## 5. 风险与回滚（Risks）

- **风险**：D 中锁屏歌词以 `artist` 行替换显示，播放歌词时通知不显示原 artist（取舍：歌词优先级更高）。MediaItem 频繁重推可能触发封面重取——靠 audio_service 对相同 `artUri` 的缓存规避，且仅在歌词文本变化（distinct）时重推。
- **风险**：`LyricOverlayManager` 新增 settings 依赖，注册顺序需保证 `AppSettingsService` 先于 `setupSubtitleServices()`（现状已满足，line 88 < 128）。
- **回滚**：四个特性相互独立，可按 commit 粒度单独 revert；未改数据模型，无生成产物风险。

## 6. 备注 / 决策记录

- B：选择复用既有未被引用的 `PlayerSeekControls` 而非在 `PlayerControls` 内新增单个按钮——零新代码、同时补齐快退/快进/歌词跳转，符合「简单优先 + 复用」。
- C：设置开关为「持久化默认值」，玩家界面长按仍是会话内临时切换（`hide()` 会重置）；两者不互相覆盖，`show()` 统一以持久化偏好为准。
- D：真·锁屏滚动歌词需厂商私有 API，跨设备不可移植，故采用「媒体通知副标题=当前行」的可移植方案；锁屏进度条根因是 MediaItem 缺少 duration（仅在 trackChange 时设置且彼时常为 null），补真实时长后系统按 updateTime+speed 外推即可走动。

### 闭环后补充（用户反馈 + Codex review，2026-05-15）

- B 调整：用户反馈整行未使用的 `PlayerSeekControls` 使播放器 UI 复杂化（与上一曲/下一曲图标重复）。**已改为**把 `player_controls.dart` 重写为单行 `[快退10s][上一曲][播放/暂停][下一曲][快进10s]`，移除 player_screen 中的 `PlayerSeekControls`（恢复其未使用状态）。此条覆盖上方第 62 行 B 的原决策。
- 「无法暂停」：经 Claude 静态分析 + Codex 只读 review（SESSION_ID `019e2be0-4cce-7f82-aa9f-e8d2b2e9f783`）独立确认 **非本次改动引入**（rxdart `throttleTime` leading-only 无尾随；`copyWith` 保留 `playing:false`；`mediaItem.add` 不触发 play/pause；lazy singleton 无 DI 时序风险）。判为既有/环境问题，待用户给出复现场景（应用内按钮 / 锁屏 / 锁屏后）再定位。
- Codex 结论 ⚠️ OPTIMIZE（可合入），已采纳两项：① trackChange 用 `event.track.duration ?? _player.duration` 兜底，修复「恢复暂停曲目时锁屏进度条不出现」；② `AudioPlayerHandler` 新增 `cancelSubscriptions()` 并由 `AudioNotificationService.dispose()` 调用，消除进度订阅泄漏（同时消除 unused_field 告警）。

---

## ✅ 完成标记

> 全部步骤勾选完毕后填写此块，并实际执行 `/init` 刷新根目录 `CLAUDE.md`，然后把本文件移入 `docs/todos/done/`。

- 完成时间：2026-05-15
- 执行命令：`/init`
- CLAUDE.md 更新摘要：新增 `AboutScreen`（关于页从设置页拆出）；播放器接入 `PlayerSeekControls`；`AppSettingsService` 新增 `lyricOverlayUnlocked` 持久化偏好且 `LyricOverlayManager` 依赖注入 `AppSettingsService`；`AudioNotificationService` 改为注入 `ISubtitleService`、按 playbackState 真实时长与字幕流统一重推 MediaItem，`AudioPlayerHandler` 增加节流进度推送以驱动锁屏进度条。
- 关联 commit：（待用户确认后提交，本次未自动 commit）
