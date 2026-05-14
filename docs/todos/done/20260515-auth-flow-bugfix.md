# 鉴权流程 Bug 修复 + 注册去字段

- **创建时间**：2026-05-15
- **负责人**：claude
- **状态**：active
- **关联 Issue / PR**：N/A（运行时回归，由用户手测发现）

---

## 1. 目标（Goal）

修复抽屉资料卡的退出登录链路（点击后概率不弹对话框 / 偶发闪退），同时按产品决策从 `RegisterDialog` 去掉「推荐人 UUID」输入框，让注册流程更轻。

## 2. 范围（Scope）

**包含：**
- `lib/widgets/sidebar/sidebar_header.dart`：重写 `_closeDrawerThenShowDialog`，把 `showDialog` 推到下一帧，避免与抽屉 pop 在同一帧操作同一 navigator；退出按钮 `onPressed` 改用 `NavigatorState.mounted` 守卫，规避 dialogContext 在 await 后被 deactivate 的边界。
- `lib/presentation/widgets/auth/register_dialog.dart`：删掉推荐人 UUID 的 TextField + 控制器 + 校验；`_isFormValid` 去掉对应分支；`_handleRegister` 直接传 `recommenderUuid: null`。
- `lib/common/constants/strings.dart`：移除两条与该字段绑定的常量（`recommenderUuidLabel`、`recommenderUuidInvalid`）。
- 保留 `AuthService.register` 与 `AuthViewModel.register` 的 `recommenderUuid` 可选参数（未来如需再加 UI，无需改服务层）。

**不包含：**
- 不调整 `LoginDialog` 链路（用户未报登录侧问题）。
- 不重构 `Drawer` / `Navigator` 体系。
- 不改 `AuthService.register` 的接口签名。

## 3. 验收标准（Acceptance）

- [ ] 登录态下点击抽屉资料卡 → **每次都**弹出退出确认对话框，无闪退。
- [ ] 在退出确认对话框点「退出登录」→ 对话框关闭、`AuthViewModel.isLoggedIn == false`、再次打开抽屉资料卡显示「立即登录」。
- [ ] 未登录态点击资料卡 → 同样能稳定弹出 `LoginDialog`（同 race 修复同时生效）。
- [ ] `RegisterDialog` UI 仅剩 3 个 TextField（用户名 / 密码 / 确认密码）。
- [ ] 注册流程仍能成功（请求体不携带 `recommenderUuid`）。
- [ ] `fvm flutter analyze` 改动文件 → `No issues found!`。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：`sidebar_header.dart` — `_closeDrawerThenShowDialog` 改为 capture root navigator → `Navigator.maybePop` → `addPostFrameCallback` → `showDialog`；退出按钮 `onPressed` 切换到 `final navigator = Navigator.of(dialogContext); ... if (navigator.mounted) navigator.pop();` 模式。
- [x] **Step 2**：`register_dialog.dart` — 删除 `_recommenderController` / `_recommenderError` / `_uuidPattern` / 第 4 个 TextField；`_isFormValid` 去掉 recommender 分支；`_handleRegister` 调用 `authVM.register(name, password)` 不传 recommenderUuid。
- [x] **Step 3**：`strings.dart` — 删除 `recommenderUuidLabel`、`recommenderUuidInvalid`。
- [x] **Step 4**：`fvm flutter analyze lib/widgets/sidebar/sidebar_header.dart lib/presentation/widgets/auth/ lib/common/constants/strings.dart` → `No issues found!`。

## 5. 风险与回滚（Risks）

- **风险**：`addPostFrameCallback` 推迟一帧打开对话框，理论上让 tap → 对话框可见之间多了 ~16ms 延迟；但相比当前「概率不弹 / 闪退」是绝对改进。
- **回滚方案**：三个文件改动均小且独立，`git revert` 即可。

## 6. 备注 / 决策记录

- 推荐人 UUID 的服务层通道保留：`AuthService.register(..., recommenderUuid: ...)` 仍可被未来调用方使用（例如从邀请链接深链解析后注入）；只是默认 UI 不再让用户手填。
- 不做 `Theme` override 的彻底重构（drawer 仍包暗色 Theme），因为当前 dialog 已通过 root navigator 完全绕开该 Theme，无需动 drawer 自身。

---

## ✅ 完成标记

- 完成时间：2026-05-15
- 执行命令：`/init`
- CLAUDE.md 更新摘要：`widgets/auth/` 段落注记 dialog 切换走 root navigator 与 `clearError()` 已在前次刷新中说明；本次仅微调 `widgets/sidebar/` 段落，注记 `SidebarHeader` 现为 StatefulWidget 且用 `_dialogScheduled` + `addPostFrameCallback` 防双击 race。
- 关联 commit：（待提交）
- Codex 复审：SESSION_ID `019e2873-2990-72e2-bc68-ba47328971b7`，两轮 ❌ CHANGE → ✅ PASS。

## 7. 复审 / Review

- **Round 1**（❌ CHANGE）：
  - High：退出按钮 `NavigatorState.mounted` 守卫不能证明该 dialog 仍在栈顶，用户在 await 期间通过 barrier/back 关 dialog 会让后续 `pop()` 弹掉底层页 → 已回退到 `dialogContext.mounted`。
  - Medium：`addPostFrameCallback` 缺再入守卫，快速双击可叠多个 dialog → 改 `SidebarHeader` 为 StatefulWidget，新增 `_dialogScheduled` flag + `showDialog<void>(...).whenComplete(reset)`。
- **Round 2**（✅ PASS）：所有进入/退出路径均能复位 flag；`mounted` 守卫覆盖 widget unmount 后异步回调；`_dialogScheduled` 不参与渲染所以无需 `setState`。
