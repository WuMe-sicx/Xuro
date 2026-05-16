# 设置页图标协调性修复 + 播放器睡眠定时快捷入口

- **创建时间**：2026-05-16
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联**：续 `20260516-five-screen-layout-token-polish.md`（行度量已修）、`20260516-sleep-timer-and-background-play.md`（SleepTimerController 已实现）
- **视觉基准**：用户新提供的「设置页」专项参考图（蓝白/黑白深色/绿白 三配色，`~/Downloads/ChatGPT Image 2026年5月16日 16_49_10.png`）

## 0. 决策记录（关键）

- 用户反馈：「整体 UI 规划不错，但设置页 UI 布局很不协调，需要调整布局（如图）」+「定时播放按钮加到播放器里，方便快速开启」。
- **沿用既定纪律**：用户此前明确选「纯布局/令牌打磨，严守不臆造」。参考图含大量**无后端支撑的虚构行**（自动播放下一首/播放完成后操作/音量调节/音效模式/均衡器/语言设置）——**一律不臆造**（[[feedback-reference-reskin-discipline]]）。
- 设置页「不协调」的**具体可定位缺陷**（非主观重塑）：组内**重复同一 leading 图标**——外观 `Icons.palette_outlined`×3、配色 `Icons.circle`×3（且全中性灰，色彩选择器看不出颜色）、网络 `Icons.lan_outlined`×N。参考图每行用**不同且达意**的图标；配色行应显示**各自真实强调色**。这是教科书级「列表不协调」，修它即对齐参考图的协调度，无需造功能。
- 播放器睡眠定时快捷键：`SleepTimerController` 已存在（真实功能），在播放器 AppBar **现有 actions 行**加一个图标按钮即可，**不新增控制行**（[[feedback-player-ui-minimal]]）。

## 1. 目标（Goal）

> 修掉设置页「组内重复同一图标」的不协调（外观三行不同达意图标；配色三行显示各自真实强调色——色彩选择器恢复语义），并把睡眠定时做成播放器 AppBar 一键入口；全程不臆造任何无后端的参考图行。

## 2. 范围（Scope）

**包含：**
- `settings_tile.dart`：新增可选 `Color? leadingColor`（贯穿私有构造 + `.selection` 工厂；为 `null` 时维持现 `onSurfaceVariant`——既有行为/`settings_d1_test` 不受影响）。
- `settings_screen.dart`：
  - 外观组：跟随系统/浅色/深色 改 `Icons.brightness_auto_outlined`/`light_mode_outlined`/`dark_mode_outlined`（替换 `palette_outlined`×3，纯图标语义化）。
  - 配色组：leading 用实心 `Icons.circle` + `leadingColor` = 该配色在**当前亮暗下的真实 `primary`**（`AppColors.lightSchemeFor/darkSchemeFor(variant).primary`）——蓝/黑白/绿三点真实呈色，色彩选择器恢复语义。
- `player_screen.dart`：AppBar `actions` 增一个 `IconButton`（`Icons.bedtime`/`bedtime_outlined`，`SleepTimerController.isActive` 时染 `primary`），点开既有 `SleepTimerDialog`；`ListenableBuilder` 监听控制器（镜像现有 wakelock action 写法）。复用 `Strings.sleepTimer`。

**不包含（严守不臆造）：**
- 不新增参考图里无后端的行：自动播放下一首、播放完成后操作、音量调节、音效模式、均衡器、语言设置——一律不做。
- 不重构设置分组语义（用户指「不协调」=重复图标/无语义色，非「分组不对」；激进重组属无具体缺陷 churn，按反馈纪律不做）。
- 网络组保留单一 `lan` 图标（同质节点列表，单图标是惯例，非显著缺陷，不 churn）。
- 不破坏三配色不变量：配色行的彩色 leading 是**色彩选择器的内容数据**（刻意按 variant 呈色，语义必需的例外），其余 leading 仍中性。
- 播放器不新增控制行 / 不动播放逻辑。

## 3. 验收标准（Acceptance）

- [ ] 设置→外观三行图标各异且达意；配色三行显示蓝/黑白/绿真实强调色（三配色×明暗均正确，深色下 mono=白点、浅色下 mono=黑点）。
- [ ] 其余设置行 leading 仍为中性 `onSurfaceVariant`（`leadingColor` 默认不变）。
- [ ] 播放器 AppBar 有睡眠定时按钮，点开 `SleepTimerDialog`；定时激活时按钮染 accent；选定后到点暂停（复用既有 controller，无新逻辑）。
- [ ] 未新增任何无后端参考图行。
- [ ] `flutter analyze` 无新增告警；全量 `flutter test` 零回归（`settings_d1_test`/`atom_three_variant_test` 仍过——`leadingColor` 默认 null 不改既有断言）。
- [ ] Codex review ✅ PASS。
- [ ] 用户三配色×明暗目测设置页协调 + 播放器按钮可用后 → `/init` 收口。

## 4. 拆解步骤（Steps）

- [x] **Step 1** 本 TODO 文档 ✅ 2026-05-16。
- [x] **Step 2** ✅ 2026-05-16：`settings_tile.dart` 加可选 `leadingColor`（默认 null→onSurfaceVariant，贯穿 `.selection`）；`settings_screen` 外观 `brightness_auto/light_mode/dark_mode` 三图标语义化、配色三行 `leadingColor=_variantSwatch(当前亮暗的真实 primary)`，import `AppColors`。
- [x] **Step 3** ✅ 2026-05-16：`player_screen.dart` AppBar actions 首位加 `ListenableBuilder`→睡眠定时 `IconButton`（active 染 primary），开既有 `SleepTimerDialog`；未新增控制行。
- [x] **Step 4** ✅ 2026-05-16：`flutter analyze`（settings/player No issues）+ 全量 `flutter test` **103/103 零回归**（`settings_d1_test`/`atom_three_variant_test` 仍过）。
- [x] **Step 5** ✅ 2026-05-16：Codex review（SESSION_ID `019e2dfd-621a-7652-a5a0-eb75b483bbd8`）→ **✅ PASS**（leadingColor 向后兼容/语义图标/配色取色三配色×明暗正确/播放器单 action 复用 controller/无虚构 均核实）。
- [x] **Step 6** ✅ 2026-05-16：用户确认、同意正式收尾 → 完成标记 + `/init` + 移 done。

## 5. 风险与回滚（Risks）

- **风险**：`leadingColor` 触发 `settings_d1_test`（断言 leading==onSurfaceVariant）回归。
  - **缓解**：参数可选默认 `null`→`onSurfaceVariant`；仅配色行 opt-in；全量 test 验证。
- **风险**：配色彩色 leading 被误读为违反三配色不变量。
  - **缓解**：这是色彩选择器**内容**（每行就该显示对应色），非组件 chrome；TODO/注释标注为语义必需例外；其余 leading 仍中性。
- **风险**：播放器 AppBar action 过多拥挤。
  - **缓解**：仅 +1 图标，复用既有 actions 行（不新增行），与 wakelock/字幕等同级；[[feedback-player-ui-minimal]] 合规。
- **回滚**：改动小且文件独立，可按文件 `git revert`。

## 6. 备注 / 决策记录

- 2026-05-16：用户指设置页不协调（给设置专项参考图）+ 要播放器睡眠定时快捷键。延续：纯布局/不臆造（[[feedback-reference-reskin-discipline]]）、播放器极简扩展现有行（[[feedback-player-ui-minimal]]）、Coder 未启用 Claude 直接编辑 + Codex review（[[feedback-codex-review-loop]]）。

---

## ✅ 完成标记

- 完成时间：2026-05-16 17:40
- 执行命令：`/init`
- CLAUDE.md 更新摘要：`SettingsTile` 新增可选 `leadingColor`（默认中性）；设置外观三行语义化图标、配色三行显示各 variant 真实强调色（色彩选择器恢复语义）；播放器 AppBar 增睡眠定时快捷入口。无虚构无后端行。
- 关联 commit：未提交（用户未要求 commit；待用户决定提交时机）

---

## ⛔ 取消标记（仅 cancelled 任务填写）

- 取消时间：YYYY-MM-DD HH:mm
- 取消原因：<...>
- 后续指向：<...>
