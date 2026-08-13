# Xuro UI 设计规范 v4.0（参考图基准 · 代码事实对齐）

> 本规范的视觉基准是用户提供的参考图（蓝白 / 黑白 / 绿白 三配色 × 侧边栏 / 首页 / 播放器 / 设置 / 关于我们 五屏）。
> **三者必须一致：参考图 = 本规范 = 代码**。与代码冲突时以代码为事实源并回修本规范，不得让规范继续失真。
> 设计核心：作为 ASMR 音频应用，围绕 **宁静、沉浸、平顺**；遵循 Material 3，但**颜色采用自研双轴体系（非 `ColorScheme.fromSeed`）**。
>
> v4.0 变更摘要：①颜色章节由「紫色 fromSeed」改写为真实的 `ColorVariant × Brightness` 双轴体系；②组件章节按参考图重构为「原子组件库 + 5 屏复用矩阵 + 三配色不变量」；③§7 性能审计表更新为真实状态（多数 P0/P1 已闭环）；④动画/无障碍/响应式/工作流等仍属实部分保留。

---

## 目录

1. [设计令牌 (Design Tokens)](#1-设计令牌-design-tokens)
2. [组件设计标准（参考图基准）](#2-组件设计标准参考图基准)
3. [动画与微交互](#3-动画与微交互)
4. [无障碍标准](#4-无障碍标准)
5. [响应式布局规则](#5-响应式布局规则)
6. [组件开发规范](#6-组件开发规范)
7. [性能优化准则](#7-性能优化准则)
8. [开发工作流规范](#8-开发工作流规范)

---

## 1. 设计令牌 (Design Tokens)

### 1.1 颜色系统：双轴体系（事实源 `lib/core/theme/app_colors.dart`）

颜色由**两个正交轴**决定，组合出 6 个手搓 `ColorScheme`：

```
ThemeMode (light / dark / system)   ×   ColorVariant (blue / mono / green)
        ↑ ThemeController                       ↑ AppSettingsService
```

> ⚠️ **禁止使用 `ColorScheme.fromSeed`**：它会按色相派生 secondary/tertiary，破坏「双色简化」意图。`AppColors.lightSchemeFor(variant)` / `darkSchemeFor(variant)` 手工构造。

#### 三配色不变量（参考图「三种配色」的落地规则）

> **同一套组件，三配色之间只有 accent 像素不同**。表面恒为白（亮）/ 近黑（暗），图标底/卡片底为中性灰。
> 只有以下三个 token 随 `ColorVariant` 轮换，其余全部中性：`primary`、`onPrimary`、`primaryContainer`。
> 组件**禁止写死颜色**——一律取 `Theme.of(context).colorScheme.*` 或 §1.2–1.6 令牌。

| 配色 | 标签(Strings) | 参考图副标 | Light `primary` | Dark `primary` |
| :--- | :--- | :--- | :--- | :--- |
| `blue` | 蓝 | 清新·舒缓·放松 | `#0066FF` | `#4D9AFF` |
| `mono` | 黑 | 简约·专注·沉浸 | `#000000` | `#FFFFFF` |
| `green` | 绿 | 自然·治愈·清新 | `#00A86B` | `#4DD7A1` |

`onPrimary`：三配色均 light=白 / dark=黑。
`primaryContainer`（chip/选中底）：blue `#E3EEFF`/`#1A2A4A`，mono `#EEEEEE`/`#2A2A2A`，green `#D8F4E7`/`#1A3A2A`。
默认配色 `ColorVariant.blue`；深浅模式独立持久化。

#### 中性表面与语义色（不随配色变化）

| 语义 | Light | Dark | 用途 |
| :--- | :--- | :--- | :--- |
| `surface` | `#FFFFFF` | `#1C1B1F` | 基础底色 |
| `onSurface` | `black87` | `#FFFFFF` | 主文本 |
| `surfaceContainerHighest` | `#E6E6E6` | `#2B2B2B` | 最高对比层 / 暗色卡片底 |
| Surface L1（自研令牌） | `#F7F7F7` | `#1F1F1F` | 容器层、迷你播放器底 |
| Surface L2（自研令牌） | `#F2F2F2` | `#252525` | 侧边栏、搜索框、对话框底 |
| `onSurfaceVariant` | `#49454F` | `#CAC4D0` | 次要文本/图标 |
| `outlineVariant` | `#CAC4D0` | `#49454F` | 分割线/描边 |
| `error` | `#B3261E` | `#F2B8B5` | 错误态 |

> Surface L1/L2 经「调色板简化」任务**已实现并中性化**（去除原紫色调），通过 `AppColors.surfaceL1/L2(brightness)` 取用。旧规范「尚未实现」的备注作废。

#### 交互状态叠加

| 状态 | 叠加层 |
| :--- | :--- |
| Hover | Primary 8% |
| Pressed | Primary 12% |
| Focused | Primary 12% + 2px Outline |
| Disabled | 38% 不透明度（统一，不定义自定义禁用色） |

> 颜色透明度统一用 `.withValues(alpha:)`（**禁止新增 `.withOpacity()`**，历史 25 处由 Phase E 清理）。

### 1.2 排版 (Typography)

> 状态：`AppTextStyles` 为 Phase B 待建令牌类；落地前组件取 `Theme.of(context).textTheme.*`，**禁止用 `fontSize:` 硬覆盖**（现 `work_info_section.dart` 等违规点 Phase C 清理）。

| 类型 | 粗细 | sp | 行高 | 用途 |
| :--- | :--- | :--- | :--- | :--- |
| Headline Medium | Medium | 28 | 1.2 | 大标题 |
| Title Large | Medium | 22 | 1.3 | AppBar 标题、播放器曲名 |
| Title Medium | Medium | 16 | 1.5 | 列表标题、卡片标题、分区头 |
| Body Large | Regular | 16 | 1.5 | 主要正文 |
| Body Medium | Regular | 14 | 1.5 | 次要描述、副标题 |
| Label Medium | Medium | 12 | 1.3 | 标签、按钮、小注 |
| Caption | Regular | 10 | 1.2 | 时间戳（如 `30:45`）、版权 |

### 1.3 间距 (Spacing)

> 状态：`AppSpacing` 为 Phase B 待建令牌类。4px 基准网格。

- Tokens：4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 48 / 64
- 布局边距：移动端 16，平板/桌面 24

### 1.4 圆角 (Border Radius)

> 状态：`AppRadius` 为 Phase B 待建令牌类。当前 `app_theme.dart` 卡片硬编码 12（Phase B 接入令牌）。

| Token | 值 | 用途 |
| :--- | :--- | :--- |
| Small | 8 | Chip、Tooltip |
| Medium | 12 | 作品卡片、列表项 |
| Large | 16 | 播放器抽屉、底部面板、对话框 |
| Full | 999 | 胶囊按钮、搜索框、头像、`AccentPill` |
| Circle | — | 播放器圆形封面 `CircularCover`（参考图） |

### 1.5 图标系统

| Token | dp | 用途 |
| :--- | :--- | :--- |
| Inline | 16 | 正文内嵌 |
| List Leading | 20–24 | 列表前置图标（线性 outlined） |
| Standard | 24 | 标准操作 |
| Emphasis | 32 | 播放/暂停 |
| Feature | 48 | 空状态/特性 |

- 不透明度：激活 87% / 非激活 60% / 禁用 38%。图标默认中性，**仅激活态用 accent**。
- 点击区域：24px 图标 → 48×48；20px → 40×40（移动端强制 ≥48×48）。

### 1.6 海拔 (Elevation)

- 当前 `cardTheme.elevation = 0`；亮色卡片可叠 1dp 区分，**暗色不使用阴影**，靠 Surface 层级（L1/L2/Highest）区分深度。
- AppBar：`elevation:0` + `scrolledUnderElevation:0` + `centerTitle:true`（`app_theme.dart`）。

---

## 2. 组件设计标准（参考图基准）

### 2.0 三层组件架构

```
Layer 0  设计令牌   AppColors(双轴) + AppSpacing/AppRadius/AppTextStyles/AppAnimations
Layer 1  原子组件   跨 5 屏 × 3 配色复用；不写死颜色；全取 Theme/令牌
Layer 2  屏幕组合   Sidebar/Home/Player/Settings/About 仅做布局组合
```

### 2.1 原子组件 × 屏幕 复用矩阵

| 原子组件 | 侧边栏 | 首页 | 播放器 | 设置 | 关于 | 代码归宿 |
| :--- | :-: | :-: | :-: | :-: | :-: | :--- |
| `BrandWordmark`（≈ASMR 标志） | ● | | | | ● | `lib/widgets/common/` 新建 |
| `AccentPill`†（选中胶囊/关注/主按钮） | ● | | ● | | | `lib/widgets/common/` 新建 |
| `SectionHeader`†（标题 + 更多>） | | ● | | ● | ● | `lib/widgets/common/` 新建 |
| `AppSearchField`（圆角搜索框） | | ● | | | | 已吸收 `browse_search_bar.dart`（2026-08-13 起 tags/circles/voice_actors 三屏复用，该文件已删除） |
| `AppListTile`（图标+标题+尾控件） | ● | | | ● | ● | 泛化 `settings/widgets/settings_tile.dart` |
| `AppListGroup`（分组+头+脚） | | | | ● | ● | 上提 `settings/widgets/settings_group.dart` |
| `CategoryChip`†（图标+标签 chip） | | ● | | | | 演进 `widgets/common/tag_chip.dart` |
| `WorkCoverCard`（封面+时长角标+标题） | | ● | | | | `widgets/work_card/*` + 时长角标 |
| `CircularCover`（圆形封面+环） | | | ● | | | 改 `widgets/player/player_cover.dart` |
| `WaveformProgress`（波形进度） | | | ● | | | 替换 `widgets/player/player_progress.dart` 视觉层 |
| `NowPlayingRow`（最新上传行+迷你控件） | | ● | | | | 复用 `widgets/mini_player/*` 控件 |
| `SidebarDecoration`（底部装饰插画） | ● | | | | | `lib/widgets/sidebar/` 新建 |
| `SocialIconRow`（圆形社交图标排） | | | | | ● | `lib/widgets/common/` 新建 |
| `AppFooter`（© 版权脚） | | | | | ● | `lib/widgets/common/` 新建 |

复用率：设置/关于 ≈80% 复用现有 `SettingsGroup`/`SettingsTile`（已含 `.navigation/.toggle/.selection` 工厂变体）；首页为最大净增组合但全由原子拼成；播放器改动集中在 `CircularCover` + `WaveformProgress`。

> †延后未建（2026-08-13 UI 收敛任务结论）：`AccentPill`/`SectionHeader`/`CategoryChip` 在本 App 中全部零调用点，指定消费方不存在——首页策展区（"热门分类"两列网格、"推荐音频"/"最新上传" 分区标题）没有对应的数据源与屏幕；"关注" 功能没有对应后端；侧边栏选中态已由 `SidebarTile` 实现（且刻意用 `AppRadius.lg` 而非 `full` 圆角，与本节原描述不同）。三者连同专属测试组已删除；本节以下正文仍保留原表述作为设计意图记录，实现时以“延后未建”为准，不要为了对齐这里反向造功能。

### 2.2 五屏布局规格（对参考图）

**侧边栏**：顶 `BrandWordmark`；导航列表，选中项 = `AccentPill`†（实心 accent 底 + `onPrimary` 文字 + Full 圆角），未选中为纯文本+线性图标；底部 `SidebarDecoration`（蓝/绿叶、黑配色月+山）。移动端宽 `min(屏宽×72%, 360px)`，右侧上下圆角 28px，沿用现有玻璃拟态深色策略（见 `lib/widgets/sidebar/`，不回退）。

**首页**：AppBar 标题 + 通知铃；`AppSearchField`（Full 圆角，Surface L2 底，尾部放大镜）；`SectionHeader`†`("推荐音频", 更多>)` + `WorkCoverCard` 横滑（Medium 圆角封面 + 左下时长 Caption 角标 + 标题）；`SectionHeader`†`("热门分类")` + `CategoryChip`†两列网格（图标+标签，`primaryContainer` 软底）；`SectionHeader`†`("最新上传", 更多>)` + `NowPlayingRow`（方形小封面 + 标题 + "正在播放" + 迷你播放控件）。

**播放器**：AppBar 下箭头收起 + "播放器" + 收藏心 + 更多⋮；曲名 Title Large + 副标 Body Medium("ASMR · 自然") + `AccentPill`†`("关注")`；`CircularCover`（大圆形封面 + 细环，保留 `Hero(tag:'mini-player-cover')`）；`WaveformProgress`（波形 + 时间 Caption `12:34 / 30:45`，拖拽 seek 逻辑复用现 `PlayerProgress`）；主控行 `[循环][上一首][实心 accent 大播放][下一首][列表]`；底部动作行 定时关闭/倍速播放/音效设置/加入收藏（图标+Label）。
> 控制区遵守**播放器极简原则**：扩展现有单控制行，禁止堆叠重复/歧义图标；底部动作行中无后端支撑的项（倍速/音效/均衡器/定时）只做占位或暂不纳入，不为对齐 UI 反向造功能。

**设置**：AppBar "设置"；`AppListGroup` 分区（accent `SectionHeader`†）：播放设置 / 声音设置 / 通用设置；每行 `AppListTile` = 线性 leading 图标 + 标题 + 尾控件（值+`>` / 开关 / 滑块）。沿用现有 `SettingsTheme.pageBackground` + `noSplashTheme`。

**关于我们**：AppBar 返回 + "关于我们"；居中 `BrandWordmark` + "版本 Vx.y.z"（来自 `package_info_plus`，非硬编码）；产品简介段；`AppListGroup`（用户协议/隐私政策/意见反馈 等 `>` 项，复用现有 7 个 `SettingsTile.navigation`）；联系我们 + 邮箱；`SocialIconRow`；`AppFooter` 版权。

### 2.3 通用组件标准

- **作品卡片**：1:1 封面；按下缩放 0.95（取 `MicroInteractions.buttonScaleDown`，现 `WorkCard` 未实现 → Phase E）；hover 8% Primary 遮罩。
- **按钮**：Filled 高 40 / 横向 24 / Full 圆角 / Primary 底；Outlined 1px 边透明底；Text 无底 Primary 文字；IconButton 48×48 触达。
- **迷你播放器**：内容区 48 + 安全区；顶部 2px `LinearProgressIndicator`(Primary)；Surface L1 底；点击/上滑 Hero 展开。
- **列表项**：单行 56 / 双行 72 / 三行 88；前置 40（图标）或 56（缩略图）；分割线 1px `outlineVariant` 起始偏移 16；分区头 Label Medium + accent 色。
- **对话框**：宽 280–560，全周 24，Surface L2 底，Large 圆角；标题 `headlineSmall`，操作右对齐 8 间距。
- **Chip**：高 32 横向 12；只读 Surface L2；交互选中用 Primary + 前置 Checkmark；Wrap 间距水平/垂直各 8。
- **状态反馈**：空状态居中(宽280) 图标64(Tertiary)→标题→描述→操作；错误态分内联/全屏/Snackbar(4s+重试)/网络断顶部 Banner。错误文案须走 `NetworkException.userMessage`（连接失败=VPN 提示，401/403=去登录），不暴露 `e.toString()`。

---

## 3. 动画与微交互

> 状态：`AppAnimations` / `MicroInteractions` 已实现于 `lib/core/theme/app_animations.dart`，与本节**一致**。业务代码禁止硬编码 Duration/Curve。

### 3.1 时间曲线与时长（`AppAnimations`）

| 常量 | 值 | 用途 |
| :--- | :--- | :--- |
| `enter` | `easeOutCubic` | 进入：减速停止 |
| `exit` | `easeInCubic` | 退出：加速离开 |
| `standard` | `easeInOutCubic` | 状态切换 |
| `emphasis` | `elasticOut` | 强调回弹 |
| `smoothScroll` | `easeOutQuart` | 歌词滚动/长列表 |
| `micro` | 100ms | 涟漪、颜色、透明度 |
| `short` | 200ms | 标签/菜单/Chip |
| `medium` | 300ms | 列表进入、卡片展开、歌词同步 |
| `long` | 450ms | 播放器全屏、页面路由 |

单个动画绝对禁止 >500ms。

### 3.2 微交互（`MicroInteractions`）

按钮按下 scale 0.95 / opacity 0.8 / 100ms；卡片 elevation +2(仅亮色)/150ms；收藏 scale→1.3/300ms/elasticOut；播放图标 morph 200ms；下拉刷新指示器 40 / 触发距离 100；进度滑块 thumb 拖拽 8 / 空闲 0 / 150ms。

### 3.3 页面级动画（不得自创过渡）

| 场景 | 方案 | 时长 | 曲线 |
| :--- | :--- | :--- | :--- |
| 主网格进入 | Staggered fade-in，仅首屏前 6 项，最大延迟 250ms | 300ms | easeOutCubic |
| 播放器全屏展开 | Hero(封面) + Slide(控制区) | 450ms | easeOutCubic |
| 标签切换 | Crossfade（禁止水平滑动） | 200ms | easeInOut |
| 歌词高亮 | Scale 1.0→1.05 + Opacity 0.5→1.0 | 300ms | easeOutCubic |
| 筛选面板 | AnimatedSlide + AnimatedOpacity | 200ms | easeInOut |
| 骨架屏 | 纯色脉冲 Opacity 0.3↔0.7（`SkeletonPulse`，禁用 Shimmer 包） | 1500ms loop | easeInOut |

### 3.4 动画性能规则

优先隐式动画；高频重绘包 `RepaintBoundary`（见 §7.4）；禁止对 width/height/margin 加动画（改 `Transform`）；尊重 `MediaQuery.disableAnimations`（为真则 Duration 归零）；同屏非循环动画 ≤3；`Tween/Duration/Offset` 用 `const`；多动画屏用 `TickerProviderStateMixin`。

---

## 4. 无障碍标准

- 对比度：正文 ≥4.5:1，大文本(18pt+) ≥3:1。
- 点击目标：移动端强制 ≥48×48。
- 减弱动效：`MediaQuery.disableAnimations` 为真 → 全部 Duration 归零。
- 屏幕阅读器：所有 `IconButton` / 图像须 `semanticLabel`。
- 聚焦指示：2px Primary 外框，2px 偏移。

---

## 5. 响应式布局规则

| 断点 | 布局 | 卡片列数 | 间距 |
| :--- | :--- | :--- | :--- |
| < 800 (Mobile) | 底部导航 | 2 | 8 |
| 800–1200 (Tablet) | 底部导航/侧边栏 | 3 | 12 |
| ≥ 1200 (Desktop) | 固定侧边导航 | 4 | 16 |

---

## 6. 组件开发规范

### 6.1 拆分

- `build()` >80 行必须拆子 Widget；优先 `StatelessWidget`；单文件公开 Widget ≤3。

### 6.2 命名

Screen→`XxxScreen`；ViewModel→`XxxViewModel`；可复用→`XxxWidget`/`XxxView`；接口→`IXxxService`；实现→`XxxService`；Freezed→`Xxx`/`XxxModel`。

### 6.3 Provider

精确监听 `context.select<T,R>()`；只取方法用 `context.read`；**禁止 `context.watch` 包裹大 Widget 树**。

### 6.4 字符串

所有 UI 可见文案集中 `lib/common/constants/strings.dart`，**禁止硬编码中文**（日志/调试串可豁免）。现存 ~60–90 处 UI 违规由 Phase E 收口。

---

## 7. 性能优化准则

### 7.1 §7 审计真实状态（2026-05-16 实测，旧表已大面积过期）

| 项 | 文件 | 真实状态 |
| :--- | :--- | :--- |
| PlayerViewModel 进度流 60Hz rebuild（原 P0） | `player_viewmodel.dart` | ✅ **已闭环**：UI 路径 `.throttleTime(200ms)` + 字幕路径全精度不 notify（:78-98） |
| `work_row.dart` IntrinsicHeight（原 P1） | `work_row.dart` | ✅ **已闭环**：全库 `IntrinsicHeight` 0 处，已是 `Row+Expanded` |
| Shimmer 持续帧开销（原 P1） | 多处 | ⚠️ **主体已闭环**（`SkeletonPulse` opacity 脉冲+`RepaintBoundary`）；残留 `pubspec` `shimmer` 依赖 + `work_files_skeleton.dart` 引用待 Phase E 清 |
| `groupWorksIntoRows` 每 build 重算（原 P1） | `work_layout_strategy.dart:35` | ❌ **仍未闭环**：未缓存，`work_grid.dart:21` build 路径调用 → Phase E memo |
| `PlaybackEventHub` 节流（原 P0） | `playback_event_hub.dart` | ◐ `playbackProgress` 用自定义 `.distinct(position)` 比较器（有效）；`playbackState.distinct()` 依赖 `PlaybackStateEvent` 的 `==/hashCode`，执行阶段核验 |

### 7.2 状态管理性能

notifyListeners：UI ≤30 次/秒；进度 throttle 200ms；字幕仅行变化才通知。Provider 拆粒度，`context.select` 精确监听。禁止 `build()` 内 `addPostFrameCallback`/`Timer`/重计算。

### 7.3 列表与滚动

强制 `*.builder`，禁止 Column/Row spread 长列表；避免 `IntrinsicHeight`（用固定高/AspectRatio/LayoutBuilder）；网格分组计算须缓存；图片用 `CachedNetworkImage` 并指定 w/h 防 CLS。

### 7.4 RepaintBoundary

必须包：MiniPlayer、PlayerProgress、歌词活跃行、用 `AnimationController` 的自定义组件。禁止包静态组件/整页。仅用 Repaint Rainbow 确认热点后添加。

### 7.5 内存

Stream 在 initState 订阅 / dispose 取消，统一 `List<StreamSubscription>` 管理且 try-catch；Timer 全部 dispose 取消，优先 RxDart `throttle/debounce`；Controller 生命周期对齐 initState/dispose + `@mustCallSuper`。

### 7.6 发版前性能检查（Profile 模式，非 debug）

主列表滚动 ≥55fps；播放器动画 ≥55fps；冷启动首帧 <2s(release)；标签切换 <300ms；冷启动内存 <150MB；30min 播放无泄漏。

---

## 8. 开发工作流规范

> 权威文档为 [`dev_workflow.md`](dev_workflow.md)（强制流程：TODO → 开发 → `/init`）。本节仅列要点，冲突以 `dev_workflow.md` 为准。

- 改 `lib/data/models/` 下 Freezed 后必须 `dart run build_runner build --delete-conflicting-outputs`，生成物一并提交，禁止手改。
- 提交前：`flutter analyze`（无新增 warning）→ `flutter test`（全过）→ `dart format lib/`。
- 性能分析用 Profile/Release，**勿用 debug 测帧率**。
- 文档优先级：`dev_workflow > 子系统文档 > 本规范 > guidelines`。本规范的视觉判断以参考图为准。
