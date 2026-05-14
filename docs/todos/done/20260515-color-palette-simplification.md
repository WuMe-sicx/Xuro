# 配色简化：3 种可切换主色调（蓝/黑/绿）+ 主题令牌 + 侧边栏适配

- **创建时间**：2026-05-15
- **负责人**：claude
- **状态**：active
- **关联**：上一任务 `20260515-flutter-performance-optimization.md` 已观察到大部分 P0 已修；本任务是用户驱动的 UI 简化，不属于性能任务范围。

---

## 1. 目标（Goal）

把 App 当前紫色 Material 3 主题简化为 **3 种"主色 + 黑白"双色方案**（Blue+White / Mono / Green+White），用户在设置页可切换、持久化到 `AppSettingsService`。同时清理侧边栏中 8 处硬编码彩色图标背景，统一收敛到主题令牌驱动。

## 2. 范围（Scope）

**包含：**
- `lib/core/theme/app_colors.dart`：废除单一固定 `lightColorScheme` / `darkColorScheme`，改为**按 `ColorVariant` 枚举生成 3 套 light + dark 方案**（共 6 个 ColorScheme）。
- `lib/core/theme/app_theme.dart`：`AppTheme.light(variant)` / `AppTheme.dark(variant)` 工厂函数。
- `lib/core/theme/theme_controller.dart`：复用 `AppSettingsService` 持久化（不在 ThemeController 自维护，避免双源）；或新增 `colorVariant` getter 监听 settings 变化。
- `lib/core/settings/app_settings_service.dart`：新增 `ColorVariant` 枚举 + `colorVariant` getter/setter + 持久化 key。
- `lib/main.dart`：`MaterialApp.theme` / `darkTheme` 跟随当前 `colorVariant`。
- `lib/screens/settings/settings_screen.dart`：在「外观」分组**之后**新增「主色调」分组，3 个 SettingsTile.selection。
- `lib/widgets/sidebar/sidebar_menu.dart`：
  - `_DrawerBackground` 渐变 → **中性深色**（去掉紫色调），与所有 3 种方案兼容。
  - `_SoftGlow` × 2 → 颜色改为 `Theme.of(context).colorScheme.primary` + 低 alpha。
  - 9 个 `SidebarTile.iconBackgroundColor` 全部统一为单一中性灰（消除 8 种彩色）。
  - footer 紫色发光圆点 → 主题 `primary`。
- `lib/widgets/sidebar/sidebar_header.dart`：
  - `_ProfileAvatar` 紫色渐变 → 主题 `primary` 渐变（深浅两端）。
  - 阴影 / 发光颜色 → 主题 `primary`。
- `lib/common/constants/strings.dart`：新增 `colorVariantTitle`、`colorVariantBlue`、`colorVariantMono`、`colorVariantGreen`、`colorVariantDesc`。

**不包含：**
- 不动 `SidebarGroup` / `SidebarTile`（它们已经只用白色 + alpha，本来就 scheme-agnostic）。
- 不做全 App 配色审计（30+ 文件硬编码颜色）——按用户决策保持「主题令牌 + 侧边栏」范围。
- 不动迷你播放器、播放器全屏、详情页、列表卡片的硬编码颜色。这些主要用 `Theme.of(context)`，应当**自动跟随**新主题；如出现局部硬编码颜色冲突视觉，留作后续单独 PR。
- 不改深色 Theme override 模式——侧边栏继续强制 dark 玻璃外观，只是主色 / 光晕跟随新方案。

## 3. 验收标准（Acceptance）

- [ ] `AppSettingsService` 暴露 `ColorVariant { blue, mono, green }` 枚举与 `colorVariant` 字段，默认 `blue`。
- [ ] 切换 `colorVariant` 后，整个 App 的 `colorScheme.primary` 立即跟随；Light / Dark 模式独立生效。
- [ ] 设置页「外观」下方新增「主色调」分组，三选一交互与现有「跟随系统/浅/深」保持一致。
- [ ] 侧边栏在 3 种方案下：
  - 渐变背景 = 中性深色（无紫色残留）
  - 资料卡头像 / 圆形箭头按钮 / footer 圆点 = 当前 `primary`
  - 9 处图标背景 = 同一中性灰（无 8 种彩色）
- [ ] `fvm flutter analyze` 通过。
- [ ] 持久化：杀进程后冷启动恢复上次选择的 `colorVariant`。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：`AppSettingsService` 新增 `ColorVariant { blue, mono, green }` 枚举 + `colorVariant` getter / `setColorVariant` setter + 持久化（key `color_variant`，默认 `blue`）。
- [x] **Step 2**：`AppColors.lightSchemeFor(variant)` / `darkSchemeFor(variant)` 工厂；3×2 = 6 套手写 ColorScheme（accent + onAccent + accentContainer 三表，surfaces 全部中性）。
- [x] **Step 3**：`AppTheme.light(variant)` / `AppTheme.dark(variant)` 工厂；保留 cardTheme / appBarTheme。
- [x] **Step 4**：`main.dart` 用 `Consumer2<ThemeController, AppSettingsService>` 拼装；`AppSettingsService` 通过 `ChangeNotifierProvider.value(getIt<AppSettingsService>())` 提供。
- [x] **Step 5**：`Strings` 新增 `colorVariantTitle / Desc / Blue / Mono / Green` 5 项。
- [x] **Step 6**：`SettingsScreen._colorVariantSection` 插在「外观」与「网络」之间，3 个 SettingsTile.selection（leading: `Icons.circle`）。
- [x] **Step 7**：`sidebar_menu.dart` — 渐变中性化（near-black 三段）、glows + footer dot 改用 `Theme.of(context).colorScheme.primary`、9 处 iconBackgroundColor 统一为顶层 `_kIconBgGray = 0xFF8E8E93`。
- [x] **Step 8**：`sidebar_header.dart` — avatar gradient 改用 `primary` + `Color.lerp(primary, black, 0.45)`；卡片阴影改用 `primary.withValues(alpha: 0.18)`。
- [x] **Step 9**：`fvm flutter analyze` 全项目 → 33 条预存 `withOpacity` deprecation 不变，无新增。

## 5. 风险与回滚（Risks）

- **风险 1**：手写 ColorScheme 缺少 M3 派生令牌（`primaryContainer`、`onPrimaryContainer`、`tertiary` 等），可能导致某些组件颜色丢失。
  - 缓解：复用现有 `AppColors.lightColorScheme` 字段集作为最低集，必要扩展令牌再补。
- **风险 2**：侧边栏取消彩色图标后视觉过于单调。
  - 缓解：保留渐变 + 边框 + 阴影提供层次；如确感不足，可选择给「我的收藏」一个例外的 accent 色。先按统一灰落地，再看反馈。
- **风险 3**：未在范围内的页面（如详情页、播放器）可能存在硬编码紫色，新主题下视觉割裂。
  - 缓解：本 TODO 不修这些；如出现刺眼割裂，单独建 follow-up TODO。
- **回滚方案**：所有改动文件清单已列；分步提交便于按需 revert 单个 phase。

## 6. 备注 / 决策记录

- **决策 A**：手写 6 个 ColorScheme，不用 `ColorScheme.fromSeed`——后者会派生 secondary/tertiary 引入第二色相，违反「双色」简化原则。
- **决策 B**：`colorVariant` 持久化放在 `AppSettingsService` 而非 `ThemeController`——`ThemeController` 只管 light/dark/system 切换；色调是用户偏好，与现有 settings（serverUrl / smartPath / audioFormatOrder）同层。
- **决策 C**：侧边栏继续强制 dark 玻璃外观，只是主色随用户选择。理由：原本设计就是 always-dark drawer 提供品质感，不能让浅色主题用户失去这个 affordance。
- **决策 D**：9 处图标背景全部统一为单一中性灰（去掉 8 种彩色），是「双色」最严格执行。

---

## ✅ 完成标记

- 完成时间：2026-05-15
- 执行命令：`/init`
- CLAUDE.md 更新摘要：在 `core/theme/` 段落注记「主题由 (`ThemeMode` × `ColorVariant`) 双轴决定」，`widgets/sidebar/` 段落补「侧边栏强制本地 dark Theme 时必须显式用 `AppColors.darkSchemeFor(variant)`，不能只 `copyWith(brightness: dark)`」反踩坑提示。
- 关联 commit：（待提交）
- Codex 复审：SESSION_ID `019e2873-2990-72e2-bc68-ba47328971b7`，三轮 ⚠️→❌→✅ PASS。
- 运行时验收：仍待用户在真机切 3 种主色 + light/dark 6 种组合视觉核对。

## 7. 复审 / Review

- **Round 1**（❌ CHANGE）：
  - **High**：`sidebar_menu.dart` 用 `Theme.copyWith(brightness: dark)` 强制暗色，但这只切 brightness flag、不切 primary——light + mono variant 时 primary 仍是黑色，抽屉里 glow/avatar/footer 在近黑背景下不可见。修复：`copyWith(brightness: dark, colorScheme: AppColors.darkSchemeFor(variant))`，并 watch `AppSettingsService` 拿 variant。
  - **Medium**：`lightSurfaceL1/L2` 仍是旧紫调（`#F7F2FA / #F3EDF7`），被 `SettingsTheme` 消费 → mono/green light 模式泄漏紫色。修复：中性化为 `#F7F7F7 / #F2F2F2`，dark L1/L2 同步中性化为 `#1F1F1F / #252525`。
- **Round 2**（❌ CHANGE）：
  - **Medium**：`_ArrowButton` 仍是固定白色，但 `sidebar_menu.dart` 注释和 TODO 验收都声明 arrow 应该走 primary——代码与文档不一致。修复：背景 / 边框 / 图标全部派生自 `accent`（mono dark 下退化为白色，与原视觉一致）。
- **Round 3**（✅ PASS）：所有承诺的 accent affordance（avatar / arrow / footer dot / glow / card shadow）都从 dark variant primary 派生；本地 Theme 双轴一致；`SettingsTheme` 中性化合规。
