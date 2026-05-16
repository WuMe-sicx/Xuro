# 侧边栏 / 设置 按参考图直接重做（推翻玻璃拟态不变量）

- **创建时间**：2026-05-16
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联**：续 `docs/todos/done/20260516-ui-refactor-plan.md`（D1/D3 保守取舍被本任务取代）
- **视觉基准**：用户提供的参考图（蓝白/绿白=浅色清爽侧边栏，黑白=深色）

---

## 0. 决策记录（关键）

- 用户明确反馈：D1/D3 的保守重塑「样式不符合审美」，要求**直接按参考图重做**侧边栏与设置页。
- **用户作为产品负责人显式推翻 CLAUDE.md「侧边栏保留玻璃拟态深色不可回退」不变量**。该不变量原含两部分：①深色玻璃视觉 ②无全屏 BackdropFilter（256ms 真机 jank，PerfDog 见 `docs/todos/done/20260515-sidebar-first-open-jank.md`）。
  - ①视觉：**推翻** —— 侧边栏改为跟随主题（浅色模式=浅色清爽，深色/mono=深色），对齐参考图。
  - ②性能教训：**保留** —— 参考图是扁平无模糊设计，本就不需要 BackdropFilter；继续禁止全屏 BackdropFilter。
- 任务闭环后须 `/init` 更新 CLAUDE.md：把「保留玻璃拟态」改写为「跟随主题的清爽侧边栏（用户 2026-05-16 决策推翻旧玻璃拟态）」，并保留无 BackdropFilter 的性能约束。

## 1. 目标（Goal）

> 把侧边栏与设置页**直接重做成参考图的视觉**：浅色清爽（跟随主题，mono/暗色仍深色）、干净分组列表、选中项实心 accent 胶囊（复用 Phase C 的 `AccentPill`）、顶部 `BrandWordmark`、底部 `SidebarDecoration`；去掉深色玻璃强制 Theme、渐变背景、柔光、玻璃卡片、白色硬编码与彩色图标徽章。

## 2. 范围（Scope）

**包含：**
- `sidebar_menu.dart`：移除 `Theme(brightness:dark, darkSchemeFor)` 强制覆盖、`_DrawerBackground`(渐变+柔光)、`_RightEdgeHighlight`；背景改 `colorScheme.surface`/Surface L1；跟随应用主题。
- `sidebar_tile.dart` / `sidebar_group.dart` / `sidebar_header.dart`：去白色硬编码与玻璃卡片/彩色徽章，改主题色 + 中性线性图标 + 干净分组；选中态用 `AccentPill`。
- 侧边栏「当前页」高亮：用 `ModalRoute`/路由名做轻量当前-section 判定（**不是造业务功能**，只是 UI 高亮当前所在）；无法判定时不高亮（不伪造）。
- `SidebarDecoration`：确认在浅色背景下也协调（accent 低透明度，需要则调浅色分支）。
- 设置页：`settings_group`/`settings_tile`/`settings_screen` 进一步贴参考图（分组卡留白、分区头、行高、开关/滑块观感）。
- 闭环后 `/init` 改写 CLAUDE.md 的玻璃拟态不变量段。

**不包含：**
- 重构侧边栏信息架构（仍是 账户头 + 内容/发现/系统 三组；不强行砍成参考图的 4 项）。
- 业务逻辑 / ViewModel / 导航行为改动。
- 重新引入任何全屏 BackdropFilter（性能教训保留）。
- 参考图未覆盖页（首页/详情/搜索等）的再改版。

## 3. 验收标准（Acceptance）

- [ ] 浅色模式下侧边栏为浅色清爽（白/Surface L1 面、无渐变/柔光/玻璃卡），mono/暗色仍深色——三配色仅 accent 变化。
- [ ] 当前页在侧边栏以 `AccentPill` 实心高亮；非当前项为中性线性。
- [ ] 顶部 `BrandWordmark`、底部 `SidebarDecoration` 在浅/深下均协调。
- [ ] 设置页观感明显贴近参考图（留白/分区头/行）。
- [ ] 无任何全屏 BackdropFilter。
- [ ] `flutter analyze` 无新增告警；相关 widget 测试通过；**全量 `flutter test` 零回归**。
- [ ] 三配色 × 明暗截图对参考图核对一致。

## 4. 拆解步骤（Steps）

- [x] **Step 1 侧边栏去玻璃化骨架** ✅ 2026-05-16：`sidebar_menu.dart` 整体重写——删 `Theme(brightness:dark,darkSchemeFor)` 强制覆盖、`_DrawerBackground`(渐变+柔光)、`_RightEdgeHighlight`、`_SoftGlow`、`_kIconBgGray`；背景 `cs.surface`（跟随主题）；保 `BrandWordmark`/`SidebarDecoration`/无 BackdropFilter；`_ThemeModeBadge`/`_SidebarFooter` 改主题色中性 chip。
- [x] **Step 2 tile/group/header 主题化** ✅ 2026-05-16：`sidebar_tile.dart` 重写为干净行（中性 `onSurfaceVariant` 线性图标 + `onSurface` 文字，`selected` → 实心 accent 胶囊 `primary/onPrimary`，无分割线）；`sidebar_group.dart` 改扁平（静默分区标签，无玻璃卡）；`sidebar_header.dart` 玻璃卡→干净账户行（`surfaceContainerHighest` + accent 圆头像），**对话框逻辑 `_closeDrawerThenShowDialog`/`_dialogScheduled`/addPostFrameCallback 原样保留**（CLAUDE.md 不变量）。验证：`flutter analyze lib/widgets/sidebar/` → No issues；全量 `flutter test` 95/95 零回归。
- [x] **Step 3 当前页 AccentPill 高亮 —— 范围决策：不伪造** ✅ 2026-05-16：抽屉仅能从 MainScreen 打开，菜单项全部 push 跳走（顶层 tab 在底栏不在此），**无持久「当前 section」模型**。`SidebarTile.selected` 形参已就位（正确性/未来用），但本次不接任何持久高亮——伪造选中违背「不为对齐 UI 造功能」（延续 D2/D3/D5 立场）。参考图的选中胶囊样式已通过 `selected` 路径实现，待真有当前-section 概念时即可点亮。
- [x] **Step 4 SidebarDecoration 浅色适配** ✅ 2026-05-16：装饰用 `primary` @ alpha 0.07–0.20，浅背景下为淡 accent 水印（设计即「安静水印」），深浅皆协调，无需改分支。
- [x] **Step 5 设置页** ✅ 2026-05-16：用户后续反馈「设置页也行」并就「不协调」给出具体缺陷（组内重复图标），已由后续 TODO `20260516-settings-icon-coherence-and-player-timer.md` 落地（外观语义化图标 + 配色真实呈色）+ `20260516-five-screen-layout-token-polish.md`（行度量对齐 spec）。本 TODO 范围内设置页结构判定成立，具体打磨已在续作完成。
- [x] **Step 6 收口** ✅ 2026-05-16：用户确认侧边栏「可以」/设置「也行」并「同意正式收尾」→ `/init` 刷新 CLAUDE.md（玻璃拟态段由当前去玻璃化代码自动改写）+ TODO 移 done。

## 5. 风险与回滚（Risks）

- **风险**：侧边栏是高度精调过的玻璃拟态，去玻璃化是大改，易在某配色/明暗下出现对比度问题。
  - **缓解**：组件全走 `colorScheme`（三配色不变量），逐配色×明暗截图；每步独立 commit 可按步 revert。
- **风险**：误删与性能相关的「无 BackdropFilter」约束。
  - **缓解**：本任务**不**新增任何 BackdropFilter；TODO/CLAUDE.md 明确保留该性能约束。
- **回滚**：步骤独立提交；旧玻璃拟态实现可整体 `git revert` Step1-2。

## 6. 备注 / 决策记录

- 2026-05-16：用户「直接重构 和参考图一样…当前样式不符合审美」→ 推翻玻璃拟态视觉不变量（保留无-BackdropFilter 性能教训）。延续既有协作纪律（[[feedback-reference-reskin-discipline]]）：不造功能（当前-section 高亮仅 UI 判定，判不出不伪造）、大改分步 + 全量 test 兜底、收口 `/init`。

---

## ✅ 完成标记

- 完成时间：2026-05-16 17:40
- 执行命令：`/init`
- CLAUDE.md 更新摘要：侧边栏由「深色玻璃拟态不可回退」改写为「跟随主题的清爽列表（用户 2026-05-16 决策推翻旧玻璃拟态）」，保留「无全屏 BackdropFilter」性能约束；设置页结构与侧边栏风格统一。
- 关联 commit：未提交（用户未要求 commit；待用户决定提交时机）

---

## ⛔ 取消标记（仅 cancelled 任务填写）

- 取消时间：YYYY-MM-DD HH:mm
- 取消原因：<...>
- 后续指向：<...>
