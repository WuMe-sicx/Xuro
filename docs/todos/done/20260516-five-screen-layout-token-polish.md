# 五屏纯布局/令牌打磨（严守不臆造，零虚构功能）

- **创建时间**：2026-05-16
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联**：续 `docs/todos/done/20260516-ui-refactor-plan.md`（Phase D 已把 5 屏结构对齐参考图）；并行于 `docs/todos/active/20260516-reskin-sidebar-settings-to-reference.md`
- **视觉基准**：用户重新提供的参考图（ChatGPT 直链，3 配色 × 侧边栏/首页/播放器/设置/关于 5 屏）

---

## 0. 决策记录（关键）

- 用户要求「5 个参考屏整体过一遍，重新优化 UI 布局」。
- 经审计：参考图与当前 app 的视觉差距**绝大多数是无后端支撑的虚构功能**（首页推荐/分类/最新上传策展、设置定时关闭/音量/音效/均衡器/语言、关于用户协议/隐私政策/support 邮箱、侧边栏选中态、播放器关注/音效行）。这些在 `ui-refactor-plan` Phase D 已被**刻意且正确地**排除（[[feedback-reference-reskin-discipline]]：不为对齐 mockup 臆造功能/数据）。
- **用户明确选择「纯布局/令牌打磨」**：只动真实可做的布局/令牌项，**零虚构、零无缺陷 churn**。不新增功能、不造数据源、不堆控制行（[[feedback-player-ui-minimal]]）。

## 1. 目标（Goal）

> 在不臆造任何功能/数据的前提下，把 5 屏中**真实存在的 spec/令牌偏差**收敛到 `docs/ui-design-spec.md`：统一列表行节奏（spec §2.3）、消除播放器硬编码间距（spec §1.3「禁裸数字」不变量）、把 ad-hoc 透明度色改为语义令牌（spec §1.1）。视觉上更贴参考图的留白与层级，但不引入参考图里无后端的元素。

## 2. 范围（Scope）

**包含（全部为 spec 既有规则的合规修复，非 churn）：**
- `settings_tile.dart`：行 `minHeight` 48→56（spec §2.3「单行列表项 56」）；leading 槽 32→40（spec §2.3「前置 40 图标」）。
- `settings_group.dart`：`_dividerIndent` 60→68（耦合更正 = 左 16 + leading 40 + 间距 12，保持分割线对齐标题文字）。
- `sidebar_tile.dart`：行 `minHeight` 加 56 约束（spec §2.3），使侧边栏列表节奏与设置一致（用户要的「5 屏整体过一遍」=跨屏节奏统一）。
- `about_screen.dart`：简介文字 `cs.onSurface.withValues(alpha:0.7)` → `cs.onSurfaceVariant`（spec §1.1 次要文本语义令牌；消除 ad-hoc 透明度）。
- `player_screen.dart`：硬编码 `32/8/12` 间距字面量 → `AppSpacing.space32/space8/space12`（CLAUDE.md/spec §1.3「UI 禁裸数字」不变量）；曲名副标 `onSurface.withValues(alpha:0.7)` → `onSurfaceVariant`（同 about，spec §1.1）。

**不包含（严守不臆造）：**
- 首页推荐/分类/最新上传策展、问候头——无数据源，Phase D 已决策不造，本次维持「首页零改动 by design」。
- 设置定时关闭/音量/音效/均衡器/语言——无后端，不新增行。
- 关于用户协议/隐私政策/support 邮箱——无对应页/后端，不编造。
- 侧边栏选中实心胶囊——抽屉无 current-section 模型，不造该模型。
- 播放器关注 pill / 底部动作行 / AppBar 新功能键——无后端 / §2 不含新入口 / [[feedback-player-ui-minimal]]。
- 不动 `AppSpacing/AppRadius/AppTextStyles` 令牌值（`design_tokens_test.dart` 锁定）。
- 不重引入任何全屏 BackdropFilter / 玻璃拟态回退。

## 3. 验收标准（Acceptance）

- [ ] 设置/关于列表单行 ≥56dp、leading 槽 40dp，分割线仍对齐标题文字（无错位）。
- [ ] 侧边栏菜单行 ≥56dp，与设置节奏一致；三配色仅 accent 变化不破坏。
- [ ] `about_screen`/`player_screen` 不再出现 `onSurface.withValues(alpha: 0.7)`；改用 `onSurfaceVariant`。
- [ ] `player_screen.dart` 无裸数字间距（grep 仅余 token / 已注明的非间距常量）。
- [ ] 首页**零改动**（明确 by design，非遗漏）。
- [ ] `flutter analyze` 无新增告警；**全量 `flutter test` 零回归**；`settings_d1_test`/`sidebar_d3_test`/`design_tokens_test` 仍过。
- [ ] Codex review 出 ✅ PASS（Coder 未启用，Claude 直接编辑；用户要 Codex review）。
- [ ] 用户三配色×明暗目测确认更贴参考图留白/层级后 → `/init` 收口。

## 4. 拆解步骤（Steps）

- [x] **Step 1 TODO 文档**（本文件）✅ 2026-05-16。
- [x] **Step 2 设置行度量** ✅ 2026-05-16：`settings_tile.dart` minHeight 48→56（新增 `_kRowMinHeight=56`）+ leading 槽 `space32`→`space40`；`settings_group.dart` `_dividerIndent` 60→68 + 注释。`flutter analyze lib/screens/settings/` → No issues。
- [x] **Step 3 侧边栏行节奏** ✅ 2026-05-16：`sidebar_tile.dart` 在 InkWell/Padding 间插 `ConstrainedBox(minHeight:_kRowMinHeight=56)` + 具名常量；`flutter analyze lib/widgets/sidebar/` → No issues。
- [x] **Step 4 离令牌色归位** ✅ 2026-05-16：`about_screen.dart` 简介 + `player_screen.dart` 曲名副标 `onSurface.withValues(alpha:0.7)` → `onSurfaceVariant`（cs 仍被引用，无未用变量）。
- [x] **Step 5 播放器间距令牌化** ✅ 2026-05-16：`player_screen.dart` `12/32/8` 字面量全改 `AppSpacing.space12/32/8`；grep 验证无裸数字间距残留。
- [x] **Step 6 全量验证** ✅ 2026-05-16：`flutter analyze`（5 文件 No issues）+ 全量 `flutter test` **95/95 零回归**（`design_tokens`/`settings_d1`/`sidebar_d3` 仍过）。
- [x] **Step 7 Codex review** ✅ 2026-05-16：SESSION_ID `019e2dfd-621a-7652-a5a0-eb75b483bbd8` → **✅ PASS**。独立核实分割线几何 16+40+12=68 对齐标题、sidebar `ConstrainedBox` 括号/无溢出、`onSurfaceVariant` 无未用变量、`AppSpacing.space*` const 合法、无虚构功能引入。
- [x] **Step 8 收口** ✅ 2026-05-16：用户确认观感 OK、同意正式收尾 → 填完成标记 + `/init` + 移 done。

## 5. 风险与回滚（Risks）

- **风险**：行高/leading 槽变大导致分割线错位或截断。
  - **缓解**：`_dividerIndent` 同步 60→68（几何一致）；行变高仅增留白，文字单行 ellipsis 不变。
- **风险**：56 无 `AppSpacing` 令牌（4px 网格缺 56）。
  - **缓解**：沿用既有 `SettingsGroup._dividerIndent` 先例——文件内具名+注释引 spec §2.3 的局部常量，符合现有代码风格，不为单个数字造共享常量（避免过度抽象）。
- **风险**：误判为「无缺陷 churn」。
  - **缓解**：每项均对应 `ui-design-spec` 既有条款（§1.1/§1.3/§2.3）或文档化不变量，非主观重塑；首页明确零改动。
- **回滚**：单一提交聚焦，可整体 `git revert`；各文件改动彼此独立。

## 6. 备注 / 决策记录

- 2026-05-16：用户审完侧边栏「可以」/设置「也行」，要求 5 屏过一遍优化布局；经审计差距多为虚构功能，用户拍板「纯布局/令牌打磨」。延续协作纪律：不臆造（[[feedback-reference-reskin-discipline]]）、播放器极简（[[feedback-player-ui-minimal]]）、CCG Coder 未启用 Claude 直接编辑 + Codex review（[[feedback-codex-review-loop]]）。

---

## ✅ 完成标记

- 完成时间：2026-05-16 17:40
- 执行命令：`/init`
- CLAUDE.md 更新摘要：设置/侧边栏/about/player 列表行度量对齐 spec §2.3（行 56dp、leading 40dp、分割线 indent 68）、离令牌色归位 `onSurfaceVariant`、播放器间距全令牌化；首页按设计零改动。
- 关联 commit：未提交（用户未要求 commit；待用户决定提交时机）

---

## ⛔ 取消标记（仅 cancelled 任务填写）

- 取消时间：YYYY-MM-DD HH:mm
- 取消原因：<...>
- 后续指向：<...>
