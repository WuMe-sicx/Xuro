# 升级 Flutter SDK（3.27.0 → 最新稳定版）

- **创建时间**：2026-05-15
- **负责人**：（待分配）
- **状态**：active（**未启动**——本任务为「后续根治」占位，先观察方案 A 「禁用 Impeller」效果）
- **关联**：
  - 前置：[`docs/todos/done/20260515-disable-impeller-android.md`](../done/20260515-disable-impeller-android.md)（已完成的应急止血）
  - 触发动机：Adreno + Vulkan + Impeller 在 HyperOS 3 / Android 16 真机上 `ErrorDeviceLost` 崩溃

---

## 1. 目标（Goal）

把项目从 Flutter 3.27.0 升级到当前稳定版（执行时检查最新），目的是：
1. 拿到 Flutter 3.29+ / 3.30+ 在 Adreno 上对 Impeller 的大量兼容性修复，未来可重新评估是否切回 Impeller。
2. 同步 Dart SDK / 第三方依赖到长期可维护的版本。
3. 修复 33 处 `withOpacity` deprecation warning（新版 SDK 已是 `.withValues(alpha:)`）。

## 2. 范围（Scope）

**包含：**
- `.fvmrc`：升级 `flutter` 字段到目标版本。
- `pubspec.yaml`：必要时调整 `environment.sdk` 与依赖版本约束。
- `pubspec.lock`：跟随 `fvm flutter pub get` 自动更新。
- 第三方依赖兼容性核对：`just_audio`、`audio_service`、`dio`、`provider`、`get_it`、`freezed`、`json_serializable`、`rxdart`、`shared_preferences`、`flutter_lints` 等的目标版本是否仍受支持。
- `android/`、`ios/`：可能需要的 Gradle / Kotlin / Pod / iOS 部署目标版本调整。
- 全量 `fvm flutter analyze` + `fvm flutter test` + 真机冒烟（含登录、注册、播放、字幕导入、悬浮歌词、缓存清理）。

**不包含：**
- 不一次性修 33 处 `withOpacity` deprecation——升级后单独起 PR。
- 不重构架构。
- 不切换状态管理库 / 渲染器。

## 3. 验收标准（Acceptance）

- [ ] `.fvmrc` 指向新版本，`fvm install` 通过。
- [ ] `fvm flutter pub get` 无 conflict。
- [ ] `fvm dart run build_runner build --delete-conflicting-outputs` 通过。
- [ ] `fvm flutter analyze` 通过；新增 warning 必须列出且评估。
- [ ] `fvm flutter build apk --release` 与 `fvm flutter build ios --no-codesign` 通过。
- [ ] 真机冒烟：登录 / 注册 / 列表滚动 / 详情 / 播放 / 字幕 / 悬浮歌词 / 缓存清理 全部不回归。
- [ ] 重新评估是否在 Android 上启用 Impeller（删除 `EnableImpeller=false` meta-data 后跑 30 分钟长会话，验证 `ErrorDeviceLost` 是否仍出现）。

## 4. 拆解步骤（Steps）

- [ ] **Step 1**：调研当前 Flutter stable 版本与该版本的 breaking changes（特别是 Material 3、Impeller、Android Gradle plugin 兼容矩阵）。
- [ ] **Step 2**：本地分支 `chore/flutter-sdk-upgrade`，仅升 `.fvmrc`，跑 `fvm flutter pub get` 看依赖冲突。
- [ ] **Step 3**：逐项消化依赖版本告警；必要时升 `pubspec.yaml` 中的依赖约束。
- [ ] **Step 4**：跑 `analyze` + `test` + Android/iOS 双端 release 构建。
- [ ] **Step 5**：真机冒烟矩阵。
- [ ] **Step 6**：评估 Impeller 切回——若 stable，删 manifest meta-data；若仍崩，保留禁用并再开 follow-up。

## 5. 风险与回滚（Risks）

- **风险 1**：依赖兼容性破裂（特别是 `freezed` / `json_serializable` 的代码生成）。
  - 缓解：升级前先 `git tag`，逐项消化；问题严重则 revert。
- **风险 2**：Material 3 在新版本细节调整可能导致视觉回归。
  - 缓解：每次大改前后录屏 / 截图对比关键页面。
- **回滚方案**：因为是 SDK 级升级，整个 PR 走 feature branch + PR review，不直接 push main。出问题就 revert PR。

## 6. 备注 / 决策记录

- 此 TODO 在 `disable-impeller-android` 落地后立即创建，确保「应急止血 + 长期根治」两条线都有跟踪。
- 启动时机：等用户在 Skia 后端跑一段时间（≥ 1 周日常使用），确认无渲染回归后再着手——避免一次性引入太多变化定位困难。

---

## ✅ 完成标记

- 完成时间：
- 执行命令：`/init`
- CLAUDE.md 更新摘要：
- 关联 commit：
