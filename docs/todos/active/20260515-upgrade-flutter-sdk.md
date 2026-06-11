# 升级 Flutter SDK（3.27.0 → 最新稳定版）

- **创建时间**：2026-05-15
- **负责人**：（待分配）
- **状态**：active（**实施中** —— 2026-06-12 本机改动已完成，待真机冒烟 + CI 验证）
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

- [x] `.fvmrc` 指向新版本（3.44.1），`fvm install` 通过。
- [x] `fvm flutter pub get` 无 conflict（14 个传递依赖自动升级；112 个 outdated 包按既定决策不主动升）。
- [x] `fvm dart run build_runner build --delete-conflicting-outputs` 通过（238 outputs / 11.1s）。
- [x] `fvm flutter analyze` 通过；新增 warning 列出 + 评估：
  - 3 个新 deprecation info：`Radio.groupValue` / `Radio.onChanged`（3.32 弃用，需迁 RadioGroup）、`onReorder`（3.41 弃用），按本 TODO §2 决策**本次不修**，与 33 处 `withOpacity` 一起单独 PR；
  - 1 个 `LockCachingAudioSource` experimental warning：just_audio 升级后 API 被标 experimental，第三方 API 行为，**不动**；
  - 5 个 pre-existing warning（unused imports/elements / logger printTime）保持不变，无新增项。
- [x] `fvm flutter build apk --debug` 通过（assembleDebug 204.9s 含首次 NDK/SDK 安装）。
- [x] `pod install` 通过（18 pods，确认 iOS 13.0 部署目标在 CocoaPods 层生效）。
- [ ] `fvm flutter build apk --release` 通过 —— **本机缺 keystore，留 CI 验证**。
- [ ] `fvm flutter build ios --no-codesign` 通过 —— **本机 Xcode 安装不完整（`flutter doctor` 报 `Xcode installation is incomplete`），留 CI 验证**。
- [ ] 真机冒烟：登录 / 注册 / 列表滚动 / 详情 / 播放 / 字幕 / 悬浮歌词 / 缓存清理 全部不回归（待 Step 5 用户配合）。
- [ ] 重新评估是否在 Android 上启用 Impeller —— **本次决议不动 Impeller**，已起 follow-up TODO [`20260612-impeller-android-revisit.md`](20260612-impeller-android-revisit.md) 在 SDK 升级合入后单独跟踪。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：调研当前 Flutter stable 版本与该版本的 breaking changes（Material 3、Impeller、AGP/KGP、Dart 3.12、iOS 部署目标、依赖兼容矩阵）。
  - 结论摘要：3.44.1 (Dart 3.12.1)；iOS 部署目标硬抬到 13.0；AGP 9 + Built-in Kotlin 未来强制（3.44 仅 warning）；freezed 2.x 在 Dart 3.12 仍兼容（不动）；`withOpacity` 仍是 warning（不动）。
- [x] **Step 2**：worktree `chore/flutter-sdk-upgrade`（隔离工作区），升 `.fvmrc` → 3.44.1，`fvm install` + `fvm flutter pub get` 通过。
- [x] **Step 3**：iOS 部署目标 12.0 → 13.0（`ios/Podfile` + `ios/Runner.xcodeproj/project.pbxproj` 3 处）；`pubspec.yaml` 依赖约束保持不变（pub get 已通过，无必要主动升）。
- [x] **Step 4**：`build_runner` / `analyze` / `test` / `build apk --debug` / `pod install` 本机全过；`build apk --release` / `build ios --no-codesign` 留 CI（host 限制详见 §3）。
- [ ] **Step 5**：真机冒烟矩阵（待用户配合）。
- [x] **Step 6**：本次决议不动 Impeller，已起 follow-up TODO [`20260612-impeller-android-revisit.md`](20260612-impeller-android-revisit.md)。

## 5. 风险与回滚（Risks）

- **风险 1**：依赖兼容性破裂（特别是 `freezed` / `json_serializable` 的代码生成）。
  - 缓解：升级前先 `git tag`，逐项消化；问题严重则 revert。
- **风险 2**：Material 3 在新版本细节调整可能导致视觉回归。
  - 缓解：每次大改前后录屏 / 截图对比关键页面。
- **回滚方案**：因为是 SDK 级升级，整个 PR 走 feature branch + PR review，不直接 push main。出问题就 revert PR。

## 6. 备注 / 决策记录

- 此 TODO 在 `disable-impeller-android` 落地后立即创建，确保「应急止血 + 长期根治」两条线都有跟踪。
- 启动时机：等用户在 Skia 后端跑一段时间（≥ 1 周日常使用），确认无渲染回归后再着手——避免一次性引入太多变化定位困难。
- 2026-06-12 实施记录：
  - 目标版本由 Flutter 官方 release manifest 实时查询确定为 **3.44.1**（Dart 3.12.1）。
  - 工作区使用 `git worktree` 隔离（`.claude/worktrees/chore+flutter-sdk-upgrade`，基于 origin/main fresh），未污染主仓与 docs 分支；`.gitignore` 同步加入 `.claude/worktrees/`。
  - iOS 部署目标 12.0 → 13.0 是 Flutter 3.44 硬要求（用户已确认接受、放弃 iOS 12 支持）。
  - Android 当前 AGP 8.9.1 + Kotlin 2.1.0 + Gradle 8.11.1 已较新，本次不动；Flutter migrator 自动在 `android/gradle.properties` 写入 `android.builtInKotlin=false` / `android.newDsl=false` 显式 opt-out，保留当前 KGP 模式。
  - Built-in Kotlin 迁移 / `Radio` 系 deprecation / `onReorder` deprecation / `withOpacity` deprecation 等本次不修，留独立 PR 收口（不阻塞 SDK 升级）。
  - `flutter_lints: ^2.0.0` 偏旧但 pub get 已通过，不阻塞，留独立 PR 升至 3.44 配套版本。
  - 本机 release apk 与 iOS build 未能验证（缺 keystore / Xcode 不完整），CI 路径已配置，留 CI 验证。

---

## ✅ 完成标记

- 完成时间：
- 执行命令：`/init`
- CLAUDE.md 更新摘要：
- 关联 commit：
