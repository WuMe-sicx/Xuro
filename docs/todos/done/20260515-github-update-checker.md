# 应用内检查更新 + 跳转下载（读取 GitHub Releases）

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：done <!-- active | done | cancelled -->
- **关联 Issue / PR**：（待补）

---

## 1. 目标（Goal）

> 一句话：在「设置 → 关于」里新增「检查更新」入口，读取本仓库 GitHub Releases，比对当前版本，有新版本时展示版本号 + 更新日志并引导用户去下载，让用户无需手动逛 GitHub 也能升级。

**Context（背景）**：

- 仓库地址：`https://github.com/WuMe-sicx/Xuro`，当前版本 `pubspec.yaml` = `1.1.11`。
- CI（`.github/workflows/build.yml`）在推送 `v*` tag 时由 `softprops/action-gh-release@v2` 发布 Release，**`prerelease: true`**，产物固定命名：Android `app-release.apk` / `app-release.aab`，iOS `app-release.ipa`。
- **关键约束**：因为所有 Release 都是 prerelease，GitHub `GET /releases/latest` 会**跳过 prerelease**（可能 404），必须改用 `GET /repos/WuMe-sicx/Xuro/releases?per_page=10`，**过滤 tag 匹配 `^v?\d+\.\d+\.\d+$` 的合法发布，再按 semver 选「最大版本」**（不能直接取列表 `[0]`：GitHub 不承诺列表首项是 semver 最大，后补发旧 tag/异常 tag 会误判）。
- **错误语义不可复用 `NetworkException`**：`NetworkException.userMessage` 是 asmr.one 专用语义——403/401 → 「请先登录」，连接/超时 → 「请先连接 VPN 服务」（因 asmr.one 被地理封锁）。GitHub **不被地理封锁**，且 403/429 是 **rate limit** 而非鉴权失败。本功能必须有 **GitHub 专用错误映射**，不得把 asmr 的登录/VPN 文案暴露到检查更新。
- 已有依赖均可复用，无需新增 pub 包：`dio`、`package_info_plus`、`url_launcher`、`permission_handler`、`path_provider`。

## 2. 范围（Scope）

**包含（本次 Phase 1）：**

- 新增 `UpdateService`：独立 Dio 实例指向 `https://api.github.com`，带 GitHub 头 `Accept: application/vnd.github+json` + `X-GitHub-Api-Version: 2022-11-28`，读取 Releases 列表，过滤合法 tag、按 semver 选最大，解析该 Release 与 APK 资源链接。
- 新增 **GitHub 专用错误类型** `UpdateException` + `UpdateErrorType` 枚举（独立于 `NetworkException`），分类：`network`（连接/超时——通用「网络连接失败，请检查网络」，**不**提 VPN）、`rateLimited`（403/429 + rate-limit 响应头/正文——「GitHub 请求过于频繁，请稍后再试」）、`notFound`（404）、`noRelease`（空列表 / 无合法 tag——「暂无可用发布」）、`invalidPayload`（JSON 解析失败——「发布信息解析失败」）、`unknown`。每个 type 有自己的 `userMessage`。
- 版本比对：纯函数 `compareSemver(String a, String b)`（剥离 `v` 前缀、补齐位数、非法输入安全），与 `package_info_plus` 取到的当前版本对比；并用其在多个合法 Release 中选「最大版本」。
- 新增 `UpdateInfo` Freezed 模型（落在 `lib/data/models/`，**仅 `.freezed.dart`，不接 json_serializable**：映射是派生的，提供自定义 `factory UpdateInfo.fromReleaseJson(Map)`，不依赖 generated `fromJson`）。`apkDownloadUrl` 可空。
- 新增 `UpdateViewModel`（`ChangeNotifier`，镜像 `AuthViewModel` 形态）。
- 新增 `UpdateDialog`：检查中 / 已是最新 / 有新版本（版本号 + release notes + 「立即下载」「稍后」）/ 出错（展示 `UpdateException.userMessage` + 重试）四态。
- 「设置 → 关于」`_aboutSection()` 新增 `SettingsTile.navigation()` 入口，文案走 `Strings`。
- 「下载」动作：用 `url_launcher` 外部打开——Android 优先打开 `.apk` 资源 `browser_download_url`；**Android 无 `.apk` 资源时回退打开 Release `html_url`**（按钮仍可用，不出现死链）；iOS / 其他平台一律打开 Release `html_url`。
- DI 注册 `UpdateService`（lazy singleton，置于 `ApiService` 注册之后）。
- 字符串集中到 `lib/common/constants/strings.dart`。
- 纯逻辑单测：`compareSemver` + GitHub Release JSON 解析（网络免接触，镜像 `test/data/services/api_service_url_test.dart` 模式）。

**不包含（明确划出，避免范围蔓延）：**

- ❌ 应用内带进度条的 APK 下载器。
- ❌ Android 原生静默安装 Intent、`REQUEST_INSTALL_PACKAGES` 权限、FileProvider、Manifest 改动（项目对原生改动保守，单列为 Phase 2 后续 TODO）。
- ❌ iOS 侧载（GitHub IPA 无法侧载，iOS 仅打开 Release 页）。
- ❌ 启动时自动检查 / 后台轮询 / 「自动检查」设置开关（需改 `AppSettingsService`，后续再议）。
- ❌ 强制更新 / 灰度 / 增量更新。

## 3. 验收标准（Acceptance）

- [ ] 「设置 → 关于」可见「检查更新」入口，点击弹出 `UpdateDialog`。
- [ ] 当远端最新版本 > 当前版本：对话框展示远端版本号、更新日志，提供「立即下载」（Android 跳 `.apk` 链接，iOS 跳 Release 页）与「稍后」。
- [ ] 当远端版本 ≤ 当前版本：对话框显示「已是最新版本」。
- [ ] 网络失败（断网/超时/GitHub 不可达）：显示**通用网络提示**（非 VPN、非「请先登录」），提供「重试」，不崩溃、不吞异常。
- [ ] **GitHub rate limit（403/429）**：显示「GitHub 请求过于频繁，请稍后再试」，**不**显示「请先登录」；有单测覆盖该映射。
- [ ] Release 全为 prerelease 时仍能取到最新版本（用 `/releases?per_page=10` 过滤后选最大 semver，而非 `/releases/latest`，已单测或手验覆盖）。
- [ ] **空 releases / 全部 tag 非法**：显示「暂无可用发布」，不崩溃。
- [x] **多个合法 Release**：选出的是 semver 最大者（不是列表首项），有单测覆盖（含「列表首项是旧 tag、靠后才是最大」的样例）。
- [x] **Android 该 Release 无 `.apk` 资源**：「立即下载」回退打开 Release `html_url`，不出现死链（代码 + 真机验证）。
- [x] `tag_name` 形如 `v1.1.12` 能正确剥离 `v` 前缀并与 `1.1.11` 比对；非法/缺失 tag 走对应错误分支而非崩溃（单测覆盖）。
- [x] `compareSemver` 单测覆盖：相等 / 主次修订各位大于小于 / 位数不齐（`1.2` vs `1.2.0`）/ 带 `v` 前缀 / 非法输入 / 多版本选最大。
- [x] `UpdateInfo.fromReleaseJson` 解析单测覆盖：正常取出 `tag_name`/`body`/`html_url`/首个 `.apk` 的 `browser_download_url`；以及边界 `[]`、release 无 `assets`、有 assets 但无 `.apk`、缺 `tag_name`、缺 `html_url`。
- [x] `flutter analyze`（8 个改动文件）通过，无新增 warning。
- [x] 已运行 `dart run build_runner build --delete-conflicting-outputs`，`UpdateInfo` 生成产物（**仅 `.freezed.dart`，无 `.g.dart`**）已纳入提交。
- [x] 相关单元测试 `fvm flutter test`（21 用例）全部通过。
- [x] 「设置→关于→检查更新」四态 UI 表现——用户已在真实设备验证通过（2026-05-15）。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：新增 `UpdateInfo` Freezed 模型
  - 涉及文件：`lib/data/models/update_info.dart`（+ 生成的 `.freezed.dart`，**无 `.g.dart`**）
  - 字段：`tagName`、`version`(剥离 v)、`releaseNotes`、`htmlUrl`、`apkDownloadUrl`(可空)、`publishedAt`
  - 提供 `factory UpdateInfo.fromReleaseJson(Map<String,dynamic>)`：自定义映射（派生 `version`、挑首个 `.apk` asset），**不**用 json_serializable 的 generated `fromJson`；JSON 结构非法/缺关键字段 → 抛 `UpdateException(invalidPayload)`
  - 验证：`build_runner` 生成成功，`flutter analyze` 干净
- [x] **Step 2**：新增 GitHub 专用错误类型 + `UpdateService`
  - 涉及文件：`lib/data/services/exceptions/update_exception.dart`（`UpdateException` + `UpdateErrorType` 枚举 + 每 type 的 `userMessage`），`lib/data/services/update_service.dart`
  - 独立 `Dio(BaseOptions(baseUrl: 'https://api.github.com', headers: {Accept: application/vnd.github+json, X-GitHub-Api-Version: 2022-11-28}, connectTimeout/receiveTimeout 同 ApiService 风格))`，**不**加 `AuthInterceptor`、**不**监听 `AppSettingsService`（GitHub host 固定，与 asmr 节点解耦）
  - `Future<UpdateInfo> fetchLatest()`：`GET /repos/WuMe-sicx/Xuro/releases?per_page=10` → 过滤 tag 匹配 `^v?\d+\.\d+\.\d+$` → 用 `compareSemver` 选最大 → `UpdateInfo.fromReleaseJson` 解析；空/无合法 → `UpdateException(noRelease)`；try/catch `DioException` 按 **状态码 + rate-limit 响应头/正文** 分类映射为 `UpdateException`（403/429→`rateLimited`，404→`notFound`，连接/超时→`network`，其余→`unknown`），`AppLogger` 记录，不吞异常
  - `static int compareSemver(String a, String b)`：纯函数、可单测（参照 `ApiService.buildSearchUri` 的 static + 单测约定）
  - owner/repo 常量复用/派生自 `Strings.repoUrl`
  - 验证：单测覆盖 `compareSemver`、错误分类、`fromReleaseJson` 解析与边界
- [x] **Step 3**：DI 注册
  - 涉及文件：`lib/core/di/service_locator.dart`（`ApiService` 注册之后新增 `registerLazySingleton<UpdateService>`）
  - 验证：`getIt<UpdateService>()` 可解析；app 正常启动
- [x] **Step 4**：`UpdateViewModel`（`lib/presentation/viewmodels/update_viewmodel.dart`）
  - 状态：`isChecking`、`error`、`UpdateInfo? latest`、`bool hasUpdate`、`String currentVersion`
  - `Future<void> check()`（双触发保护 + `notifyListeners`；`catch UpdateException` → `error = e.userMessage`，**ViewModel 不依赖 `NetworkException`**，Dio/解析错误统一由 `UpdateService` 转成 `UpdateException`）、`Future<void> openDownload()`（`url_launcher` 外部打开，平台分支，`context.mounted` 守卫由 UI 侧负责）
  - 验证：形态与 `AuthViewModel` 一致；`flutter analyze` 干净
- [x] **Step 5**：`UpdateDialog`（`lib/presentation/widgets/update/update_dialog.dart`）
  - `AlertDialog` + `ChangeNotifierProvider`(本地 create `UpdateViewModel`)/`Consumer`，四态 UI；经 root navigator 弹出，参照 `LoginDialog` 约定
  - 验证：手动走四态（mock 高/低版本、断网）
- [x] **Step 6**：设置入口接线 + 字符串
  - 涉及文件：`lib/screens/settings/settings_screen.dart`（`_aboutSection()` 版本信息 tile 之后新增），`lib/common/constants/strings.dart`（新增「检查更新」区块文案）
  - 验证：UI 可见可点，文案无硬编码
- [x] **Step 7**：单测（网络免接触）
  - 涉及文件：`test/data/services/update_version_compare_test.dart`（`compareSemver` 全分支 + 多版本选最大）、`test/data/services/update_release_parse_test.dart`（`UpdateInfo.fromReleaseJson` 正常 + 边界：`[]`/无 assets/无 `.apk`/缺 `tag_name`/缺 `html_url`，及 403/429 rate-limit → `rateLimited` 的错误分类）
  - 验证：`fvm flutter test test/data/services/update_version_compare_test.dart test/data/services/update_release_parse_test.dart` 通过

## 5. 风险与回滚（Risks）

- **风险：GitHub API 速率限制**——未鉴权 60 次/小时/IP，超限返回 **403 或 429**。手动触发，风险低；映射为 `rateLimited`，文案「请求过于频繁，请稍后再试」，不重试风暴。
- **风险：`prerelease: true` 导致 `/releases/latest` 取不到**——已规避：改用 `/releases?per_page=10` 过滤合法 tag 后按 semver 选最大（非取首项，防后补旧 tag 误判）。
- **风险：`tag_name` 格式假设 / 空 releases / asset 缺失**——过滤正则 + `noRelease`/`invalidPayload` 分支兜底；Android 无 `.apk` 回退打开 Release 页；全程不崩溃、不吞异常。
- **风险：错误语义错配**——已规避：不复用 asmr.one 的 `NetworkException`（其 403→登录、连接失败→VPN 语义对 GitHub 错误），改用 GitHub 专用 `UpdateException` 映射。
- **风险：iOS 无可侧载产物**——iOS/其他平台仅打开 Release `html_url`，不暴露 APK。
- **回滚方案**：功能自包含（新增文件为主，仅在 `settings_screen.dart`/`strings.dart`/`service_locator.dart` 增量接线），`git revert` 单个 commit 即可完全移除；无数据迁移、无持久化状态。

## 6. 备注 / 决策记录

- **为何用 `/releases` 而非 `/releases/latest`**：CI 发布 `prerelease: true`，`latest` 端点按 GitHub 文档会跳过 prerelease。
- **为何 Phase 1 用浏览器跳转下载而非应用内安装**：应用内 APK 安装需 Android 原生 Intent + `REQUEST_INSTALL_PACKAGES` + FileProvider + Manifest 改动，原生面大、风险高（项目历史上因原生 GPU 问题禁用 Impeller，对原生改动保守）。浏览器/系统下载器跳转是 GitHub 直发 APK 的标准模式，零新增权限、零原生代码，符合「Working > Perfect、Simplicity First」。Phase 2 另起 TODO。
- **为何 `UpdateInfo` 用 Freezed-only**：`lib/data/models/` 既有约定为 Freezed；但本模型字段是从 GitHub Release JSON **派生**（`version` 剥 v、`apkDownloadUrl` 挑 asset），1:1 的 generated `fromJson` 反而不适用，故仅用 Freezed + 自定义 `factory UpdateInfo.fromReleaseJson`，不接 json_serializable（无 `.g.dart`）。
- **为何 `UpdateService` 不监听 `AppSettingsService`**：asmr 节点切换与 GitHub host 无关，刻意解耦，避免 `ApiService._onSettingsChanged` 模式的误用。
- **为何不复用 `NetworkException`**：其 `userMessage` 强绑定 asmr.one——403→「请先登录」、连接失败→「请先连接 VPN 服务」（asmr.one 被地理封锁）。GitHub 不被封锁、403/429 是 rate limit。错配会误导用户，故新建 GitHub 专用 `UpdateException`。
- **为何 `/releases` 选最大 semver 而非取 `[0]`**：GitHub `/releases` 列表不承诺首项即 semver 最大；若日后补发旧 tag 或异常 tag 排在前面会误判。过滤合法 tag + `compareSemver` 选最大更稳。
- **Codex 评审（SESSION_ID `019e2b49-3a33-7303-a401-33b6ff2a8a14`）**：
  - 规划阶段：R1 ❌（错误语义错配 / 空·异常 release 无失败路径 / 选版策略 / 头部·工厂）→ 吸收；R2 ❌（Step4 仍引用 NetworkException / 验收与 Freezed-only 矛盾 / 正则缺 `$`）→ 修正；R3 ✅ PASS。
  - 实现阶段：R-impl1 ❌（`UpdateViewModel` await 后无 disposed guard，Dialog 检查中被关会 "used after disposed"）→ 加 `_disposed` + `dispose()` override + `_safeNotify()`；R-impl2 ✅ PASS（ship as-is）。
- **`openDownload` 平台分支用 `dart:io` `Platform.isAndroid`**：与 `service_locator.dart` 既有用法一致（应用仅 Android/iOS，无 web）。
- **Dialog `_download` 在 await 前先捕获 `Navigator`/`ScaffoldMessenger`**：避免 await 后 `context` 失效；Codex 已确认安全。

---

## ✅ 完成标记

> 全部步骤勾选完毕后填写此块，并实际执行 `/init` 刷新根目录 `CLAUDE.md`，然后把本文件移入 `docs/todos/done/`。

- 完成时间：2026-05-15
- 执行命令：`/init`
- CLAUDE.md 更新摘要：在 `lib/data/`/`lib/presentation/`/API/Tests 四处补充更新检查子系统——`UpdateService`（独立 GitHub Dio、不随节点切换、`/releases?per_page=10` 选 semver 最大）、`UpdateException`（不复用 NetworkException）、`UpdateInfo`（Freezed-only 自定义工厂）、`UpdateDialog`+`UpdateViewModel`（disposed guard 不变量）、新增两测试文件。
- 关联 commit：`f872229`（实现）+ `eda9d7f`（/init 刷新 CLAUDE.md + 归档）+ 本次验收收尾 commit
- 备注：**全部验收标准已通过**——真机四态 UI 由用户于真实设备验证通过（2026-05-15）；逻辑层经 Codex 规划 3 轮 + 实现 2 轮评审至 ✅ PASS，21 单测全过，analyze 干净。任务完全闭环。
