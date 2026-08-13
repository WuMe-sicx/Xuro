# 让「当前播放列表」只有一个权威——修复过滤后的列表被重新推导碾平

- **创建时间**：2026-08-13
- **负责人**：Elvis Juan (thanhtran0606en@gmail.com)
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：架构评审候选 B（`/improve-codebase-architecture` 报告）

---

## 1. 目标（Goal）

`PlaybackController` 在部分音源构造失败时建立的「过滤后播放列表」，会在同一次调用内被 `copyWithFile` 碾平回完整文件树的推导结果，导致 just_audio 队列下标去索引一个更长的列表、取到错位的曲目。让播放列表在建立之后只有一个权威。

## 2. 范围（Scope）

**包含：**
- `PlaybackContext.copyWithFile` 改为在已确定的列表上移动游标，不重新推导
- `PlaybackStateManager.updateTrackAndContext` 去掉同曲目的重复 `PlaybackContextEvent` 发射
- 补 `copyWithFile` / `withFilteredPlaylist` 的单测（此前零覆盖）

**不包含：**
- 在 `_getPlaylistFromSameDirectory` 里预先剔除 `mediaDownloadUrl == null` 的兄弟文件。
  评估后**主动放弃**：`copyWithFile` 的修复已完整堵住分歧，而这条会在「本地已下载
  但 API 后来不返回 URL」的边缘情况下误伤离线播放——多加的这层防御带来的风险
  大于它挡掉的东西。
- `TrackInfoCreator` 的 `mediaDownloadUrl!` 强解包。根因修好后索引不再错位；
  单独加防御属另一件事。
- `AudioPlayerHandler.queueIndex` 这第三个索引命名空间（当前无处可索引，无害）。
- 架构评审的其余候选（C ApiService、D 登录态不变量、E 分页 seam、F 原子落盘、
  G 字幕三连）。

## 3. 验收标准（Acceptance）

- [x] 新增的回归测试在**修复前的代码上必须失败**（已验证：`Expected ['01.mp3','03.mp3']` / `Actual ['01.mp3','02.mp3','03.mp3']`，游标 `Expected 1 / Actual 2`）
- [x] `fvm flutter analyze` 保持 **No issues found**
- [x] `fvm flutter test` 全绿
- [x] 既有的 12 条 `PlaybackContext` 断言（同扩展名分组、跨目录隔离、可播格式闸门）全部保留

## 4. 拆解步骤（Steps）

- [x] **Step 1**：子代理测绘播放上下文的完整读写路径与修复约束
- [x] **Step 2**：修 `copyWithFile`，改为移动游标
- [x] **Step 3**：`updateTrackAndContext` 去重复发射
- [x] **Step 4**：补测试，并验证它们在修复前失败
- [ ] **Step 5**：对抗性复核（子代理试图推翻修复）
- [ ] **Step 6**：手动回归——找一个含无 `mediaDownloadUrl` 兄弟文件的作品，确认锁屏标题与字幕跟随正确曲目

## 5. 风险与回滚（Risks）

- **风险**：若存在某条路径上 `newFile` 不在当前 playlist 里，旧代码会重新推导出
  包含它的列表，新代码不会。已知的两条路径（`playlist[index]` 与
  `context.currentFile`）都必然在列表内，但这条由对抗性复核兜底。
- **风险（已排除）**：跳过 `updateContext` 会连带吞掉 `_persistSuppressed = false`
  导致播放态不再持久化。已查清：`stop()` 里 `clearState()` 与 `clearSavedState()`
  成对调用（`audio_player_service.dart:163-165`），「suppressed」恒蕴含
  「context == null」，而解除抑制的通道在 `playback_controller.dart:140`
  无条件执行、位于本守卫上游。
- **回滚方案**：两处改动共一个 commit，`git revert` 即可。

## 6. 备注 / 决策记录

- `copyWithFile` 与 `withFilteredPlaylist` 各自**只有一个调用方**，签名可自由更改
  ——这是修复能这么小的原因。
- 触发条件：同目录同扩展名的兄弟文件里有 `mediaDownloadUrl == null` 的
  （`playlist_builder.dart:54` 强解包 → `:60` catch 吞掉 → 跳过该轨）。
  `detail_viewmodel.dart:331-333` 只校验用户点的那个文件的 URL，兄弟文件从未被校验。
- 错位的后果不止是显示错：错位往往精确落回被丢弃的那个文件，
  `TrackInfoCreator:26` 的 `mediaDownloadUrl!` 便在 `currentIndexStream` 的
  监听器里抛出、**逃逸到 zone**（该监听器无 try/catch）。
- 本分支基于未合入的 PR #10（它又基于 PR #9）。
