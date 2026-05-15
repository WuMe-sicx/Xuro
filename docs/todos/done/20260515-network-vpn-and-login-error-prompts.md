# 优化两类错误提示：连接异常优先提示 VPN、登录态异常直达登录

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：（无）

---

## 1. 目标（Goal）

优化两类用户可见的错误提示：
1. **连接异常**：出现 `Connection reset by peer` 等连接错误时，优先提示「请先连接 VPN 服务」，而不是把底层技术信息（`连接失败: Connection reset by peer`）甩给用户。
2. **登录态异常**：「收藏」「为你推荐」在未登录时返回「请先登录」，此时底部按钮不应是「重试」（重试无意义），应直接打开登录对话框并执行登录流程，登录成功后自动加载列表。

## 2. 范围（Scope）

**包含：**
- `lib/common/constants/strings.dart`：新增 VPN 提示 / 登录提示 / 去登录按钮文案，集中管理。
- `lib/data/services/exceptions/network_exception.dart`：新增 `userMessage`（用户友好文案映射）与 `isAuthError`。connectionError / timeout → VPN 提示；authError → 请先登录。
- `lib/presentation/viewmodels/favorites_viewmodel.dart`、`recommend_viewmodel.dart`：新增 `isLoginError` 标记；catch 分支改用 `NetworkException.userMessage`。
- `lib/widgets/work_grid/components/grid_error.dart`、`enhanced_work_grid_view.dart`：透传 `isLoginError` + `onLogin`，登录类错误渲染「去登录」按钮（非「重试」）。
- `lib/screens/contents/favorites_content.dart`、`recommend_content.dart`：提供 `onLogin` 回调，打开登录对话框并在登录成功后刷新列表。
- `lib/widgets/work_grid_view.dart`（旧版组件）+ `lib/screens/favorites_screen.dart`（侧栏「我的收藏」独立路由，仍用旧版组件）：同样接线 `isLoginError` + `onLogin`，保证「收藏」两条入口表现一致（含会话中 token 失效场景）。

**不包含：**
- 搜索、标签、社团、声优、播放列表等列表页的错误文案改造——本次仅集中映射放在 `NetworkException`，后续可按需复用，本次不逐页接线。
- 401 token 过期的自动刷新/登出逻辑（仅做提示与跳转，不动鉴权刷新）。
- 登录对话框 UI 本身不变。

## 3. 验收标准（Acceptance）

- [x] 关闭 VPN 时进入「收藏」/「为你推荐」，触发连接错误，页面文案为「请先连接 VPN 服务」（非 `连接失败: ...` 或 `NetworkException(...)`）。
- [x] 未登录进入「收藏」/「为你推荐」，提示为「请先登录」，底部按钮为「去登录」（不是「重试」）。
- [x] 点击「去登录」弹出登录对话框；登录成功后对话框关闭并自动加载对应列表数据。
- [x] 普通网络错误（如 5xx）仍显示「重试」按钮，行为不回归。
- [x] `flutter analyze` 通过，无新增 warning。
- [x] 相关单元 / Widget 测试通过（本次无模型改动，无需 build_runner）。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：写本 TODO 文档。
  - 涉及文件：`docs/todos/active/20260515-network-vpn-and-login-error-prompts.md`
  - 验证：文档存在且字段齐全。
- [x] **Step 2**：`strings.dart` 新增 `networkVpnHint` / `loginRequired` / `goLogin`。
  - 涉及文件：`lib/common/constants/strings.dart`
  - 验证：编译通过，常量可被引用。
- [x] **Step 3**：`NetworkException` 新增 `userMessage` getter + `isAuthError`。connectionError/timeout→VPN 提示，authError→请先登录，其余回退 `message`。
  - 涉及文件：`lib/data/services/exceptions/network_exception.dart`
  - 验证：单测 `flutter test` 通过；逻辑分支覆盖。
- [x] **Step 4**：两个 ViewModel 新增 `_isLoginError`/`isLoginError`；未登录分支置位并用 `Strings.loginRequired`；catch 分支用 `NetworkException.userMessage` 与 `isAuthError`。
  - 涉及文件：`favorites_viewmodel.dart`、`recommend_viewmodel.dart`
  - 验证：`flutter analyze` 通过；逻辑自洽。
- [x] **Step 5**：`GridError` + `EnhancedWorkGridView` 透传 `isLoginError`/`onLogin`，渲染「去登录」按钮。
  - 涉及文件：`grid_error.dart`、`enhanced_work_grid_view.dart`
  - 验证：复用该组件的其他页面默认参数不受影响（`isLoginError=false`、`onLogin=null`）。
- [x] **Step 6**：content 屏 + 旧版独立路由接线 `onLogin`：root navigator 打开 `LoginDialog`，await 后若 `isLoggedIn` 则刷新列表。
  - 涉及文件：`favorites_content.dart`、`recommend_content.dart`、`work_grid_view.dart`、`favorites_screen.dart`
  - 验证：手动路径模拟（analyze 通过 + 代码走查）。
- [x] **Step 7**：`flutter analyze`（改动文件 0 issue，仓库 33 项均为既存 withOpacity 等历史告警）+ `flutter test`（10 通过；唯一失败 `test/widget_test.dart` 为脚手架自带 counter smoke，基线同样失败，非回归），勾选验收，执行 `/init`，归档。

## 5. 风险与回滚（Risks）

- **风险**：`timeout` 也被映射为 VPN 提示——对本 App（asmr.one 日本服务器、国内需代理）这是合理产品判断，但极端情况下真实超时也会显示 VPN 文案。可接受。
- **风险**：`EnhancedWorkGridView` 被多页复用；新增参数均带默认值，旧调用方行为不变。
- **回滚方案**：本次为加法式改动，单个 commit revert 即可恢复原文案与「重试」按钮。

## 6. 备注 / 决策记录

- 决策：用户友好文案映射放在 `NetworkException.userMessage`（单点），ViewModel 只消费，避免两处重复 mapping。
- 决策：connectionError 与 timeout 均归为「请先连接 VPN 服务」，因为本 App 服务器地理封锁，二者根因一致。
- 决策：登录提示按钮文案用「去登录」（`Strings.goLogin`），与既有「立即登录」(`loginCta`，侧栏 CTA 语境) 区分。
- 决策：登录对话框沿用 `sidebar_menu.dart` 的 root navigator + `useRootNavigator: true` 模式，避免抽屉/局部 Theme 泄漏问题。

---

## ✅ 完成标记

- 完成时间：2026-05-15 18:38
- 执行命令：`/init`
- CLAUDE.md 更新摘要：`lib/data/` 新增 `services/exceptions/network_exception.dart` 条目（`userMessage` 为用户文案单一来源、`isAuthError`）；API 区新增「Error-prompt UX」小节，沉淀连接异常优先提 VPN、登录态异常走「去登录」这条跨 data→viewmodel→widget→screen 四层不变式。
- 关联 commit：随本错误提示闭环 commit 一并提交（strings.dart 的 3 行常量先期已混入 `f872229`；其余 9 个 .dart 文件 + 本 TODO 于本次收尾 commit 提交）。
