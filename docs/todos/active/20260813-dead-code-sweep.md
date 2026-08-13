# 全仓死代码清理——删掉零引用的功能链、模型、接口与碎片

- **创建时间**：2026-08-13
- **负责人**：Elvis Juan (thanhtran0606en@gmail.com)
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：无

---

## 1. 目标（Goal）

`ponytail-audit` 全仓扫描出约 880 行 lib 源码 + 1,974 行生成物零引用。删掉它们，让 `flutter analyze` 归零，并让 CLAUDE.md 停止为没人跑的代码守护不变量。

## 2. 范围（Scope）

**包含：**
- 零引用的完整功能链：「我的收藏夹」（`PlaylistsContent` 及其 2 个 view / 2 个 VM）及其级联的 API 方法与模型目录
- 零引用的数据模型目录：`mark_lists/`、`my_lists/`、`works/works.dart`
- 零引用的类与方法：`AudioService`（本地抽象类）、`MicroInteractions`、`PlaybackContext` 四个死方法、`AuthViewModel.loadSavedAuth` 重复实现等
- 单实现且测试无 fake 的 4 个接口：`IFilePickerService` / `IUserSubtitleRepository` / `IDownloadRepository` / `IPlaybackStateRepository`
- 零引用的常量与 getter 碎片
- `flutter analyze` 的 4 条既有 warning

**不包含：**
- **`DownloadService.removeDownload`**：零调用，但更像是「漏接 UI 入口」而非死设计——单独拍板，不在本次删除
- **收藏夹功能是否真砍**：五个文件写得完整，疑似做完没挂进 tab——已确认删除，但保留在独立 commit 便于回滚
- 任何行为变更、重构、性能优化——本次只做减法
- `cupertino_icons` 等依赖：18 个依赖全部有真实调用点，一个不删

## 3. 验收标准（Acceptance）

- [ ] `fvm flutter analyze` 输出 `No issues found`（从 4 条 warning 归零）
- [ ] `fvm flutter test` 全绿，测试文件数不减少
- [ ] 删除后全仓 grep 不到任何指向已删符号的引用
- [ ] 涉及 `lib/data/models/` 下 Freezed 模型删除，对应 `.freezed.dart` / `.g.dart` 一并删除
- [ ] 相关单元 / Widget 测试通过

## 4. 拆解步骤（Steps）

- [ ] **Step 1**：删纯死物——模型目录 + 抽象类 + 零引用方法/常量碎片 + 2 条死 import
  - 涉及文件：`lib/data/models/{mark_lists,my_lists}/`、`lib/data/models/works/works.*`、`lib/core/audio/audio_service.dart`、`lib/core/theme/app_animations.dart`、`lib/core/audio/models/playback_context.dart`、`lib/presentation/viewmodels/*.dart` 等
  - 验证：`fvm flutter analyze` 归零 + `fvm flutter test` 全绿
- [ ] **Step 2**：删「我的收藏夹」功能链及其级联 API 方法
  - 涉及文件：`lib/screens/contents/playlists*`、`lib/presentation/viewmodels/playlist*`、`lib/data/services/api_service.dart`
  - 验证：同上；独立 commit，便于日后需要时 revert
- [ ] **Step 3**：拆掉 4 个单实现无 fake 的接口，DI 直接注册具体类
  - 涉及文件：`lib/core/**/i_*.dart`、`lib/core/di/service_locator.dart`
  - 验证：同上

## 5. 风险与回滚（Risks）

- **风险**：「我的收藏夹」若只是漏接线而非弃用，删除会丢掉一份可用实现。
- **回滚方案**：该功能链单独成一个 commit，`git revert` 即可整体恢复。其余步骤为纯零引用删除，无运行时影响。

## 6. 备注 / 决策记录

- `cupertino_icons` 看似零 import，实际提供 `CupertinoIcons` 字形资源（`sidebar_menu` / `sidebar_header` 在用），保留。
- `IAudioPlayerService` / `ISubtitleService` 保留：`test/` 有 4 个 `_FakeAudioService` + 3 个 `_FakeSubtitleService` 在用，接口是挣来的；其余 4 个接口没有任何 fake。
- `MicroInteractions` 被 `docs/ui-design-spec.md` 点名为设计 token，删除时需同步改文档。
