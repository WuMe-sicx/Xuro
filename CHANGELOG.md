# 更新记录 / Changelog

记录 Xuro 自 v1.1.11 之后的所有用户可见与开发者可见改动。版本号遵循 [SemVer](https://semver.org/lang/zh-CN/) 与 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 风格。

---

## 未发布 / Unreleased

### 新增 / Added
- **用户注册流程**（`POST /api/auth/reg`）：抽屉登录对话框新增「没有账号？去注册」入口；新对话框含用户名 / 密码 / 确认密码三字段，提交按钮按客户端校验状态自动启用。注册成功自动登录；服务端未返回 token 时回退到 `login` 兜底，账号创建成功但自动登录失败的边界场景通过 `RegisteredButNotLoggedInException` 单独提示。任务文档：[`done/20260515-user-registration.md`](docs/todos/done/20260515-user-registration.md)。
- **3 种主色调可切换**（蓝 / 黑 / 绿，默认蓝）：设置页「外观」之后新增「主色调」分组，三选一持久化到 `AppSettingsService.colorVariant`。`AppColors` 重构为 `lightSchemeFor(variant)` / `darkSchemeFor(variant)` 工厂，6 套手写 ColorScheme 不依赖 `fromSeed`。任务文档：[`done/20260515-color-palette-simplification.md`](docs/todos/done/20260515-color-palette-simplification.md)。
- **侧边抽屉视觉**（深色玻璃拟态）：深色蓝紫渐变 + 软光晕 + 半透明分组卡片 + 圆形资料卡。新增「最近播放」「排行榜」「深色模式」「关于我们」入口。宽度遵循 `ui-design-spec §5` 的 mobile/tablet 断点。任务文档：[`done/20260515-sidebar-glassmorphism-redesign.md`](docs/todos/done/20260515-sidebar-glassmorphism-redesign.md)。

### 变更 / Changed
- **`AuthService` 节点感知**：原硬编码 `https://api.asmr.one/api`，现注入 `AppSettingsService`、监听并同步 Dio baseUrl，登录与注册都会跟随用户在设置中选择的节点（主站 / 100 / 200 / 300）。
- **Surface 设计令牌中性化**：`AppColors.lightSurfaceL1/L2` 与 `darkSurfaceL1/L2` 之前略带紫调（`#F7F2FA` 等），现统一为无色相中性灰，避免与 mono/green 主色调撞色。
- **侧边抽屉「双色」简化**：抽屉内 9 处不同彩色的菜单图标背景统一为单一中性灰 `_kIconBgGray = #8E8E93`；唯一彩色 affordance 是 avatar / 圆形箭头 / footer 光点 / 渐变光晕 / 卡片阴影，全部从 `Theme.of(context).colorScheme.primary` 派生，随用户选的主色调动态切换。

### 修复 / Fixed
- **侧边抽屉首次打开 256ms 卡顿**：PerfDog 真机数据证实由 `Stack` 顶层的 `BackdropFilter(blur 18)` 引起。该模糊在不透明渐变之上是视觉 no-op，但首次绘制触发 Impeller offscreen layer + shader 编译。已删除 `BackdropFilter`，原 18% 黑色 overlay 通过 `0.82` 折算严格等价地烘焙进渐变 RGB 与软光晕 RGB（保持 alpha 不变，源叠加数学等价）。任务文档：[`done/20260515-sidebar-first-open-jank.md`](docs/todos/done/20260515-sidebar-first-open-jank.md)。
- **小米 HyperOS 3 + Adreno + Vulkan 长会话型崩溃**（`ErrorDeviceLost` → `SIGSEGV in libvulkan.so::CmdEndRenderPass+4`）：Android 上禁用 Impeller 回退到 Skia 渲染器（`AndroidManifest.xml` 加 `io.flutter.embedding.android.EnableImpeller=false`）。iOS 继续使用 Impeller。任务文档：[`done/20260515-disable-impeller-android.md`](docs/todos/done/20260515-disable-impeller-android.md)；后续 SDK 升级跟踪：[`active/20260515-upgrade-flutter-sdk.md`](docs/todos/active/20260515-upgrade-flutter-sdk.md)。
- **登录/注册 dialog 切换泄漏旧错误**：`AuthViewModel.clearError()` 新增；`LoginDialog` ⇄ `RegisterDialog` 切换时调用。
- **退出登录概率不弹对话框 / 偶发闪退**：`SidebarHeader` 改为 `StatefulWidget` + `_dialogScheduled` 守卫；`Navigator.maybePop(drawer)` + `addPostFrameCallback` 把对话框开启推到下一帧，避免同帧 pop+push 在同一 navigator 上的 race。退出按钮恢复 `dialogContext.mounted` 守卫，避免 dialog 已被外部关闭时误 pop 底层页。任务文档：[`done/20260515-auth-flow-bugfix.md`](docs/todos/done/20260515-auth-flow-bugfix.md)。
- **抽屉内对话框继承暗色 Theme**：登录/退出对话框改用 `rootNavigator` 打开，与抽屉内本地 dark Theme 解耦。

### 移除 / Removed
- **注册表单的「推荐人 UUID」字段**：UI 输入框移除，服务层可选参数保留（未来若有深链解析需求可继续传值）。

### 工程 / Internal
- **任务文档归档**：今日新增 5 个 `done/` 文档（注册流程 / 鉴权 bug 修复 / 抽屉首开卡顿 / Impeller 禁用 / 配色简化）+ 1 个 `cancelled/` 文档（[`flutter-performance-optimization.md`](docs/todos/cancelled/20260515-flutter-performance-optimization.md)，因审计基线过期 7/9 P0 已修，且剩余项需 profile 数据驱动）+ 1 个 `active/` 占位（Flutter SDK 升级，等 Skia 跑稳一周后启动）。
- **Codex 复审**：本会话所有 6 个独立 TODO 统一在 SESSION_ID `019e2873-2990-72e2-bc68-ba47328971b7` 下复审，全部走 ⚠️/❌ → ✅ PASS 闭环。
- **CLAUDE.md 反踩坑补丁**：标注侧边栏「Theme override 必须用 `darkSchemeFor(variant)` 而非只切 brightness」、「不要再加全屏 BackdropFilter」、「Android 已禁 Impeller」、「主题双轴 ThemeMode × ColorVariant」。
- **静态分析**：所有改动文件 `fvm flutter analyze` 零新增 warning（项目历史 33 条预存 `withOpacity` deprecation 维持不变）。

---

## v1.1.11 之前

历史版本变更记录见 git log 与 GitHub Releases（[releases](https://github.com/WuMe-sicx/Xuro/releases)）。
