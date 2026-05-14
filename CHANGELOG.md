# 更新记录 / Changelog

记录 Xuro 自 v1.1.11 之后的所有用户可见与开发者可见改动。版本号遵循 [SemVer](https://semver.org/lang/zh-CN/) 与 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 风格。

---

## 未发布 / Unreleased

### 变更 / Changed
- **侧边抽屉视觉重构**：左侧抽屉从默认 Material Drawer 重构为深色玻璃拟态风格。
  - 深蓝→深紫垂直渐变 + 顶/底两处软光晕；`BackdropFilter(blur 18)` 玻璃叠层；仅右侧上下圆角 28px。
  - 宽度策略：移动端 `min(屏宽 × 72%, 360px)`，平板/桌面 `304px`（与 [`docs/ui-design-spec.md §2.6`](docs/ui-design-spec.md) 同步更新）。
  - 资料卡：圆形渐变头像（带高光）+ 「立即登录 / 同步收藏与记录」主副文案 + 圆形箭头按钮；登录态显示用户名 + 「点击管理账户」。
  - 分组卡片采用半透明渐变白叠层 + 0.6px 微弱发光描边。
  - 菜单项左侧统一改为彩色渐变方形图标（30 → 32px），文字白色，trailing chevron 更细。
  - 通过本地 `Theme(brightness: Brightness.dark)` 覆盖，保证浅色全局主题下抽屉视觉一致。

### 新增 / Added
- **抽屉新增四项入口**：
  - 「最近播放」、「排行榜」：暂无后端，点击弹「敬请期待」SnackBar 占位。
  - 「深色模式」：直接调用 `ThemeController.toggleThemeMode()` 切换主题，trailing 显示当前模式徽标（系统/浅/深）。
  - 「关于我们」：跳转到 `SettingsScreen`（关于版块）。
- 抽屉底部版本号通过 `package_info_plus` 拉取真实 `pubspec.yaml` 版本（缓存 future，避免每次 rebuild 重发请求）。
- `lib/common/constants/strings.dart` 新增 18 个抽屉相关文案常量，遵循项目字符串集中管理规范。

### 修复 / Fixed
- 抽屉内对话框（登录/退出）改用 `rootNavigator` + `useRootNavigator: true` 打开，避免抽屉内本地暗色 `Theme` 渗入对话框样式。
- SnackBar 在 `Navigator.pop` 前提前捕获 `ScaffoldMessenger`，规避抽屉关闭后 messenger 失活的潜在时序问题。

### 工程 / Internal
- 任务文档：`docs/todos/done/20260515-sidebar-glassmorphism-redesign.md`。
- Codex 三轮复审通过（SESSION_ID `019e2873-2990-72e2-bc68-ba47328971b7`）：⚠️→⚠️→✅ PASS。
- 静态分析：`fvm flutter analyze lib/widgets/sidebar/` 全程 `No issues found!`。

---

## v1.1.11 之前

历史版本变更记录见 git log 与 GitHub Releases（[releases](https://github.com/WuMe-sicx/Xuro/releases)）。
