# 用户注册功能（/api/auth/reg）

- **创建时间**：2026-05-15
- **负责人**：claude
- **状态**：active
- **关联 Issue / PR**：N/A

---

## 1. 目标（Goal）

接入 ASMR.ONE 的 `POST /api/auth/reg` 接口，在 App 内完成「账号注册 → 自动登录 → 同步收藏与记录」闭环；当前应用仅有登录入口，对新用户不友好。

## 2. 范围（Scope）

**包含：**
- `AuthService.register(name, password, {recommenderUuid})`：实现 POST `/auth/reg`，复用现有 `AuthService` 的 Dio 实例与异常封装。
- `AuthViewModel.register(...)`：与现有 `login()` 行为对齐——成功后写入 `AuthRepository`，`isLoggedIn` 翻转，错误暴露在 `error`。
- `RegisterDialog`（新增）：与 `LoginDialog` 同风格的 `AlertDialog`，含用户名、密码、确认密码、推荐人 UUID（选填）四项；客户端校验 `name.length >= 5 && password.length >= 5 && password == confirmPassword`。
- `LoginDialog` 底部新增「没有账号？去注册」TextButton，关闭当前 LoginDialog → 打开 RegisterDialog（同样走 root navigator）。
- `Strings`：补全 `register / noAccountCta / nameMinLength / passwordMinLength / passwordMismatch / recommenderUuid / recommenderUuidOptional / registerSuccess` 等文案。

**不包含：**
- 不做邮箱验证、验证码、密码强度计、找回密码、第三方登录。
- 不新增节点切换 UI（已存在于设置页）。
- 不引入多节点自动 fallback / 重试（用户可在设置中手动切换节点）。
- 不删除/更名 `AuthService.login` 或现有 `AuthRepository` 字段。

## 3. 验收标准（Acceptance）

- [ ] `AuthService.register('abcde', 'abcde')` 在真实接口下返回与 `login` 一致的 `AuthResp`（含 `token` 与 `user`）。
- [ ] 客户端校验：用户名 < 5 / 密码 < 5 / 两次密码不一致时按钮置灰，提示文案出现在对应字段下方。
- [ ] 注册成功后：`authVM.isLoggedIn == true`、`authVM.username` 显示新用户名、抽屉资料卡同步刷新、`AuthRepository` 已持久化、SnackBar 提示「注册成功」。
- [ ] 服务端返回错误（如用户名已被占用）时：保留对话框、显示 `authVM.error`、按钮可重试。
- [ ] `recommenderUuid` 选填：空时请求体不包含该字段；非空时校验为 8-4-4-4-12 格式的 UUID。
- [x] `flutter analyze` 通过，无新增 warning。验证：`fvm flutter analyze` 改动文件均 `No issues found!`。
- [~] `fvm flutter test` 现状：唯一存在的 `test/widget_test.dart` 是项目脚手架自带的 Counter 烟测，期待的是 Flutter starter 模板的计数器 UI——本项目早已替换为 `MainScreen` 音频界面，**该测试在 HEAD 上即失败**（已经 `git stash` 验证），与本次改动无关。后续应清理或重写此测试，本任务不在范围内。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：扩展 `Strings`，新增注册相关文案常量。
  - 产物：`lib/common/constants/strings.dart`（新增 14 项注册相关常量）
- [x] **Step 2a**：`AuthService` 重构——构造函数注入 `AppSettingsService`，Dio baseUrl 改读 `_settings.serverUrl`，监听 `_settings` 变化时同步更新 baseUrl。
  - 产物：`lib/data/services/auth_service.dart`、`lib/core/di/service_locator.dart`
- [x] **Step 2b**：`AuthService.register(name, password, {recommenderUuid})`：POST `/auth/reg`，仅在 UUID 非空时携带；HTTP 200/201 都接收；响应缺 `token`/`user` 兜底调用 `login`。
  - 产物：`lib/data/services/auth_service.dart`
- [x] **Step 3**：`AuthViewModel.register(...)` 镜像 `login` 状态机。
  - 产物：`lib/presentation/viewmodels/auth_viewmodel.dart`
- [x] **Step 4**：新增 `RegisterDialog`，4 个 TextField + 即时校验 + 提交按钮按 `_isFormValid` 自动启用/禁用。
  - 产物：`lib/presentation/widgets/auth/register_dialog.dart`
- [x] **Step 5**：`LoginDialog` 增加「没有账号？去注册」TextButton，通过 root navigator 关闭 LoginDialog 并打开 RegisterDialog；RegisterDialog 内同款「已有账号？去登录」反向跳转。
  - 产物：`lib/presentation/widgets/auth/login_dialog.dart`
- [x] **Step 6**：`fvm flutter analyze` 通过；`fvm flutter test` 因脚手架烟测预存 fail（见验收标准说明）。
- [ ] **Step 7**：手动验证（用户侧）：用 `abcde` / `abcde` + 空 recommenderUuid 真实注册一次，确认抽屉资料卡刷新、登出后能用同账号登录回来。

## 5. 风险与回滚（Risks）

- **风险 1**：`/api/auth/reg` 在 `api.asmr.one` 上行为是否与 curl 中 `api.asmr-200.com` 一致未知（两者可能是镜像）。
  - 缓解：复用 `AuthService` 的 `api.asmr.one` baseUrl，与 `login` 同源；若上线后真机测试失败，再单独评估是否引入第二个 baseUrl 或走 `AppSettingsService.serverUrl`。
- **风险 2**：注册响应体结构可能与 `/auth/me` 不一致（例如只返回成功标志，没有 token）。
  - 缓解：`AuthService.register` 内部做兜底——若 `AuthResp.token == null && user == null`，则同步调用 `login(name, password)` 再返回，确保对 ViewModel 透明。
- **风险 3**：占用一个真实推荐人 UUID 会把后续所有新注册用户挂到该 UUID 名下，存在道德与产品定位风险。
  - 缓解：默认空，**不**硬编码 curl 里的 `ec2abb35-4010-4a81-98da-8b4cfb2e3a6b`；只在用户主动填写时上送。
- **回滚方案**：所有改动均为新增或同文件内追加，`AuthService.register` / `AuthViewModel.register` / `RegisterDialog` 三处可独立 revert，不影响 login 主路径。

## 6. 备注 / 决策记录

- **决策 A（修订）：`AuthService` 改用 `AppSettingsService.serverUrl`**。`AppSettingsService.serverOptions` 已支持 4 个节点（主站 + 节点1/2/3，包含 curl 中的 `asmr-200.com`），但既有 `AuthService.login` 硬编码 `asmr.one`——这是一处遗留 bug，本次顺手修复。注册 + 登录均改为读 `_settings.serverUrl`，并监听 `_settings` 变化更新 Dio baseUrl，与 `ApiService` 对齐。
- **决策 B：`recommenderUuid` 设为可选 + 默认空**。不硬编码 curl 中的 `ec2abb35-…` 作为默认值——那是该 curl 录制者的个人邀请码，硬编码等同于强制所有新注册用户与之绑定。
- **决策 C：注册成功后即时自动登录**。`AuthService.register` 内部保证返回带 token 的 `AuthResp`（必要时回调 `login` 兜底），上层 ViewModel 直接复用持久化逻辑。
- **决策 D：UI 入口放在 `LoginDialog` 而非独立 `RegisterScreen`**。注册是低频操作，对话框已够用；扩展全屏页面是过度设计。

---

## ✅ 完成标记

- 完成时间：2026-05-15
- 执行命令：`/init`
- CLAUDE.md 更新摘要：补齐「认证流程」章节——`AuthService` 现读 `AppSettingsService.serverUrl` 并监听节点切换；新增 `register()` + 自定义 `RegisteredButNotLoggedInException`；`AuthViewModel` 增 `register()`/`clearError()`；`presentation/widgets/auth/` 同时拥有 LoginDialog 与 RegisterDialog。
- 关联 commit：（待提交，commit message 引用本文件归档后的路径）
- Codex 复审：SESSION_ID `019e2873-2990-72e2-bc68-ba47328971b7`，两轮 ⚠️→✅ PASS。
- 运行时验收（Step 7）：仍待用户在真机执行。

---

## 7. 复审 / Review

- **Round 1**（⚠️ OPTIMIZE）：
  - 注册成功但 fallback login 失败被通用 catch 包成「注册失败」，与服务端真实状态不符 → 已新增 `RegisteredButNotLoggedInException` 区分；
  - login ⇄ register 切换泄漏旧 `authVM.error` → 已新增 `AuthViewModel.clearError()` 并在两侧 `_switchToXxx` 调用。
- **Round 2**（✅ PASS）：异常捕获顺序正确，`_authData == null` 语义保留；`clearError()` 由 `_error == null` 短路守卫，无多余 rebuild。
