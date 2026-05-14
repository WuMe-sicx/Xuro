# 侧边栏抽屉视觉重构（暗色玻璃拟态）

- **创建时间**：2026-05-15
- **负责人**：claude
- **状态**：active
- **关联 Issue / PR**：N/A

---

## 1. 目标（Goal）

将左侧抽屉从默认 Material Drawer 重构为深色玻璃拟态风格：深色蓝紫渐变背景 + 磨砂玻璃质感 + 半透明分组卡片 + 彩色圆角图标，提升视觉层级与品质感，并补齐用户期望的「最近播放 / 排行榜 / 深色模式 / 关于我们」入口。

## 2. 范围（Scope）

**包含：**
- 重构 `lib/widgets/sidebar/sidebar_menu.dart`：抽屉宽度约 72% 屏宽，仅右侧上下圆角，深色蓝紫渐变 + 频率较低的磨砂玻璃叠层。
- 重构 `lib/widgets/sidebar/sidebar_header.dart`：大尺寸资料卡（圆形渐变头像 + 主副文案 + 右侧圆形箭头按钮）。
- 重构 `lib/widgets/sidebar/sidebar_group.dart`：分组标题 + 半透明卡片 + 微弱发光边框。
- 重构 `lib/widgets/sidebar/sidebar_tile.dart`：彩色方形图标、白色中文文案、轻量 chevron。
- 三组分区（内容 / 发现 / 系统），新增条目：最近播放、排行榜、深色模式、关于我们。
- 「深色模式」直接调用 `ThemeController.toggleThemeMode()`，并通过 trailing 状态徽标显示当前模式。
- 「关于我们」跳转到 `SettingsScreen`（关于版块已存在）。
- 「最近播放 / 排行榜」暂无后端数据，点击弹「敬请期待」SnackBar 占位。
- 抽屉底部版本号沿用 `pubspec.yaml` 实际版本（`PackageInfo`）。

**不包含：**
- 不新增 RankingScreen / RecentPlayScreen / 独立 AboutScreen。
- 不修改任何 ViewModel / Service / 数据模型。
- 不修改 `MainScreen` 中关于 Drawer 的接入方式（仍为 `Scaffold.drawer`）。
- 不调整其他抽屉外的 UI（顶栏、底栏、内容区）。

## 3. 验收标准（Acceptance）

- [ ] 抽屉打开时占用约 72% 屏宽，右侧上下圆角明显（≥24px），左侧贴边。
- [ ] 背景呈现深蓝→深紫垂直渐变，叠加磨砂玻璃细微纹理；右侧 scrim 蒙层使主内容区可见但变暗。
- [ ] 资料卡显示圆形渐变头像 + 「立即登录 / 同步收藏与记录」（未登录态）或用户名（登录态），右侧有圆形 arrow 按钮。
- [ ] 三个分组标题（内容 / 发现 / 系统）使用浅灰描边；分组卡片半透明并有 1px 发光描边。
- [ ] 每个菜单项左侧为彩色圆角方形图标，文字白色，右侧 chevron；按下有微弱反馈。
- [ ] 「深色模式」点击即切换 ThemeMode，trailing 显示当前模式文字（系统/浅/深）。
- [ ] 「最近播放 / 排行榜」点击弹出「敬请期待」SnackBar，不报错。
- [ ] 「关于我们」跳转到 SettingsScreen。
- [ ] 「我的收藏 / 标签 / 社团 / 声优 / 设置」沿用现有跳转逻辑。
- [ ] 浅色模式下打开抽屉同样保持深色玻璃风格（强制 dark scheme over drawer，避免被全局主题反色破坏）。
- [ ] `flutter analyze` 通过，无新增 warning。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：重构 `sidebar_tile.dart`，支持 trailing 自定义（用于深色模式状态文字）+ 透明背景、白色文字、彩色图标。
  - 产物：`lib/widgets/sidebar/sidebar_tile.dart`
- [x] **Step 2**：重构 `sidebar_group.dart` 为半透明圆角卡片 + 发光描边。
  - 产物：`lib/widgets/sidebar/sidebar_group.dart`
- [x] **Step 3**：重构 `sidebar_header.dart` 为大资料卡，未登录显示「立即登录 / 同步收藏与记录」+ 圆形箭头按钮。
  - 产物：`lib/widgets/sidebar/sidebar_header.dart`
- [x] **Step 4**：重构 `sidebar_menu.dart`：72% 宽度、右侧大圆角、深色蓝紫渐变 + BackdropFilter 玻璃叠层、三组菜单、底部版本号。
  - 产物：`lib/widgets/sidebar/sidebar_menu.dart`
- [x] **Step 5**：`flutter analyze` 通过。
  - 验证：`fvm flutter analyze lib/widgets/sidebar/` 输出 `No issues found!`。全项目分析仅有 33 条预先存在的 `withOpacity` 弃用提示，均不在本次改动文件中。

## 5. 风险与回滚（Risks）

- **风险**：BackdropFilter 在低端设备上可能影响打开抽屉的帧率。
  - 缓解：blur sigma 控制在 18 以内，仅在 drawer 内部一次叠加。
- **风险**：强制 dark scheme over drawer 可能与现有亮色主题产生轻微对比突兀感。
  - 缓解：drawer 是抽屉式独立层级，全屏内已被 scrim 遮罩，视觉过渡自然。
- **回滚方案**：四个文件均为单文件重构，`git revert` 即可恢复。

## 6. 备注 / 决策记录

- 「最近播放 / 排行榜」未来如新增独立屏幕，只需替换对应 onTap 即可。
- 版本号通过 `package_info_plus` 已是项目内依赖（settings_screen 已使用），无需新增。

---

## ✅ 完成标记

- 完成时间：2026-05-15
- 执行命令：`/init`
- CLAUDE.md 更新摘要：补齐 FVM 命令、`lib/core/{database,image,settings}`、`lib/presentation/{layouts,models,widgets}`、`lib/utils/` 目录描述与测试现状说明；`lib/widgets/sidebar/` 段落新增暗色 Theme 局部覆盖注记。
- 关联 commit：`feat(sidebar): glassmorphism dark drawer redesign`（hash 见 git log）
- Codex 复审：SESSION_ID `019e2873-2990-72e2-bc68-ba47328971b7`，三轮 ⚠️→⚠️→✅ PASS（详见 CHANGELOG.md 未发布段）。

## 7. 验收说明（运行时）

下列项需用户在 `fvm flutter run` 后人工核对：抽屉宽度比例、玻璃模糊感、登录卡阴影发光、深色模式徽标切换、未实现入口的 SnackBar 提示。代码层面均已落地。
