# Xuro UI 设计规范 v5.0（Modernist · 代码事实对齐）

> **视觉基准**：Claude Design 项目《Flutter ASMR播放器设计》
> （`f11e0a02-12c2-476f-8591-aaf9384c4922`，文件 `ASMR Player.dc.html`）
> 及其设计系统 `_ds/modernist-*/styles.css`。用 `DesignSync` 工具读取。
>
> **⚠️ 该稿设计时未读过本代码库**（稿子脚注自述）。因此它的信息架构——环境音分类、
> 「本周主题」策展位、播放次数、渐弱停止、发现/分类/收藏/我的 四标签导航——与
> asmr.one 的真实能力不匹配。**取它的视觉语言，功能逐条对着真实数据核。**
>
> **两条反复确认的立场**：稿子没画的屏 ≠ 该删；稿子画了的功能 ≠ 该造。
>
> v4.0（2026-05-16 参考图基准）已**整篇作废**——那张参考图被用户以产品负责人身份
> 弃用。本文档不保留其内容，只保留仍然成立的性能与工作流条款。

---

## 目录

1. [设计令牌](#1-设计令牌)
2. [组件标准](#2-组件标准)
3. [动画与微交互](#3-动画与微交互)
4. [无障碍](#4-无障碍)
5. [响应式](#5-响应式)
6. [组件开发规范](#6-组件开发规范)
7. [性能准则](#7-性能准则)
8. [已知缺口](#8-已知缺口)

---

## 1. 设计令牌

事实源是 `lib/core/theme/`，**本文档与代码冲突时以代码为准**。

### 1.1 颜色：纸墨 + 中性阶 × 四配色

Modernist 的底色体系是一对纸墨加一条共享中性阶；配色只轮换 accent。

| 角色 | 亮色 | 暗色 |
| :--- | :--- | :--- |
| 纸 / 墨 | `paper #F3F2F2` / `ink #201E1D` | 互换 |
| `surface` | `paper` | `ink` |
| `onSurface` | `ink` | `paper` |
| `surfaceContainerHighest` | `neutral200` | `neutral900` |
| `onSurfaceVariant` | `neutral600` | `neutral500` |
| `outlineVariant` | `neutral400` | `neutral700` |

中性阶 `neutral100..900` 明暗共用——同一档的任意角色视觉重量相等，这是 Modernist
「一个墨色的九个层级」的来源。**暗色档是本项目从纸墨互换推导的，稿子只给了亮色。**

四个 `ColorVariant`：

| variant | 亮色 accent | 暗色 accent |
| :--- | :--- | :--- |
| `blue` | `#0066FF` | `#4D9AFF` |
| `mono` | `ink` | `paper` |
| `green` | `#00A86B` | `#4DD7A1` |
| `still` | `#EC3013`（稿子的招牌红） | `#FF563C` |

**多配色不变量**：可复用组件禁止写死颜色，一律取 `colorScheme.*` 或
`AppColors.neutral*`。切换 variant 必须**只**改变 accent 像素。

**⚠️ 未赋值 token 陷阱**：`secondary` / `secondaryContainer` / `tertiary` 刻意留空，
Flutter 会填入**不随 variant 轮换**的固定基线色。`NavigationBar` 的 indicator 默认
吃 `secondaryContainer`——底部导航胶囊曾因此在四个配色下恒为同一个薄荷绿。要用这
几个 token 之前，必须先在八套 scheme 里全部补齐赋值。

**唯一有文档的例外**：设置页的配色选择器行，用 `SettingsTile.leadingColor` 显示每个
variant 的真实 `primary`——那是*选择器内容*，不是 chrome。

### 1.2 排版

事实源 `AppTextStyles`。标题 **800 字重 + 负字距**，正文 400——这个对比比颜色更承担
Modernist 的识别度。

| 令牌 | 字号 / 字重 / 行高 | 用途 |
| :--- | :--- | :--- |
| `headlineMedium` | 28 / w800 / 1.12，字距 −0.42 | 首页问候、播放器曲名 |
| `titleLarge` | 22 / w800 / 1.12，字距 −0.33 | AppBar、分区大标题 |
| `titleMedium` | 16 / w800 / 1.2 | 列表行标题、卡片标题 |
| `bodyLarge` | 15 / w400 / 1.55 | 正文 |
| `bodyMedium` | 13 / w400 / 1.5 | 次要描述 |
| `labelMedium` | 11 / w800 / 1.3，字距 1.1 | 分区 kicker（accent 色） |
| `caption` | 10 / w600 / 1.2 | 时长、角标、版权 |

令牌**不绑定颜色**，颜色由使用处从 `colorScheme` 取。

**字体**：`assets/fonts/Archivo-{400,600,800}.ttf`（OFL），设为 `ThemeData.fontFamily`。
**Archivo 无 CJK 字形**，中日文回退系统字体——它实际只作用于品牌字、数字、时长、
RJ 号。这是设计的客观约束（稿子里的中文同样是回退渲染），不是实现打折。

### 1.3 间距

`AppSpacing`，4px 网格 `space4..space64`，页面边距 `pageMobile` 16 / `pageTabletDesktop` 24。
稿子里不在 4px 网格上的具体值（行高 56、行内边距 18 等）用**具名局部常量 + 注释说明
几何来源**处理，不塞进令牌层。

### 1.4 圆角 —— 全部为 0

`AppRadius` 四档 `sm/md/lg/full` **全部为 0**。层级由 2px / 1px 分隔线和留白表达，
不由圆角和阴影表达。四个名字保留，是为了让调用点继续声明「这是什么层级的元素」。

**零圆角排查**：以下 grep 在 `app_radius.dart` 之外必须恒为 0 命中——

```
BorderRadius.circular(   Radius.circular(   BoxShape.circle
CircleAvatar             ClipOval           StadiumBorder
```

**圆形是「最大圆角」，会躲过任何按半径*值*做的排查**——侧边栏头像就是这样活下来的。

**M3 组件默认形状不读 `AppRadius`**：按钮默认 `StadiumBorder`，输入框、SnackBar、
BottomSheet 各有自己的默认圆角。`app_theme` 必须显式覆盖
`filledButton / elevatedButton / textButton / outlinedButton / inputDecoration /
snackBar / bottomSheet / dialog / chip / navigationBar`，否则零圆角在这些组件上整体失效。

### 1.5 分隔线

`AppColors.dividerThickness = 2`。**两级层级**：

- **2px** —— 分区之间、品牌区与导航之间、页面级边界
- **1px** —— 同一组内的行之间

这个粗细差是 Modernist 表达「组 > 行」的唯一手段，不要抹平。

### 1.6 海拔

**不用**。`elevation: 0`，无阴影。Modernist 靠线和留白分层。

---

## 2. 组件标准

### 2.1 原子库 `lib/widgets/common/`

`BrandWordmark` · `AppFooter` · `SocialIconRow` · `AppSearchField` · `SkeletonPulse` · `TagChip`

**原子靠「吃掉散装实现」长出来，不是靠新增。** `SectionHeader` / `CategoryChip` /
`AccentPill` 曾被建出来又删掉——它们的指定消费方是这个 App 不具备的功能，零调用点。
**在有真实消费方之前不要新建原子**：一个有三配色测试却没有调用点的原子，是给「无法
影响任何像素的代码」打了绿勾，反而让删除显得有风险。

`BrandWordmark` 是纯排版：字标 `onSurface` + **accent 句点**（对应设计系统
`.nav-brand` 与稿中的 `STILL.`）。句点是品牌里唯一着色的字符——这是「accent 只给
一处」在品牌上的体现。

`TagChip` **自己拥有颜色**，通过 `TagTone`（`primary` / `neutral` / `outline`）+ `dense`。
它此前暴露裸 `backgroundColor` / `textColor`，五个调用点立刻塞了
`Colors.orange/green/blue`，详情页 chip 在所有 scheme 下都是固定色相，且暗色下一处
不过 WCAG AA。**允许调用方决定颜色的浅接口，一定会被那样使用。**

### 2.2 列表行

行高 56（与 `SettingsTile` / `SidebarTile` / `BrowseListItem` 一致），零圆角，无卡片，
行间 1px 分隔线，尾部箭头 `→`。编号列表（浏览页）左侧编号用 `onSurface` 35% 透明。

### 2.3 异步状态

四态编排收敛在 `EnhancedWorkGridView` 一处（legacy `WorkGridView` 已删）：

- **loading 只在 `works.isEmpty` 时替换内容**——翻页不得把列表换成裸转圈
- **error 只在 `works.isEmpty` 时显示**——VM 的 catch 不清空 `_works`，陈旧内容优先于错误页
- **empty 必须有可见提示**，禁止 `SizedBox.shrink()` 兜底
- 错误态按钮：连接/未知错误 → 「重试」；鉴权错误且有 `onLogin` → 「去登录」

骨架列数走 `WorkLayoutStrategy`，不得写死。

### 2.4 侧边栏

跟随应用主题的清爽列表。**禁止**：全屏 `BackdropFilter`（真机 256ms 首开 jank，
证据见 `docs/todos/done/20260515-sidebar-first-open-jank.md`）、玻璃拟态、渐变、
柔光、玻璃卡、强制深色 `Theme` 覆盖。

`SidebarHeader` 的 `addPostFrameCallback` + `_dialogScheduled` 重入标志必须保留
（同帧 `Navigator.pop` + `showDialog` 造成过生产崩溃）。

抽屉是**纯导航**，不要为了视觉好看编造「当前选中区块」的持久化状态。

---

## 3. 动画与微交互

### 3.1 时长与曲线

一律取 `AppAnimations`，禁止硬编码 `Duration` / `Curve`。

### 3.2 微交互

`MicroInteractions` 定义了按压缩放 0.95、收藏弹跳等常量。**目前 0 调用点**——
交互反馈层尚未落地，见 §8。

### 3.3 页面转场

不得自创过渡。现有两处自定义：mini player → 播放器（`PageRouteBuilder` + 两对
`Hero`）、详情 → 相似作品（右进左出）。其余走默认 `MaterialPageRoute`。

`Hero(tag:'mini-player-cover')` 与 `Hero(tag:'player-title')` 不得更名。

### 3.4 动画性能

- 优先隐式动画与 `AnimatedBuilder`，避免整树 `setState`
- 高频重绘节点包 `RepaintBoundary`
- **必须尊重 `MediaQuery.disableAnimations`**——目前全库 0 处，是真实无障碍缺口（§8）

---

## 4. 无障碍

- 可点击元素最小触达 48×48
- 图标按钮提供 `tooltip` 或 `Semantics.label`
- 正文对比度 ≥ 4.5:1。**新增或修改 chip / 角标 / 次要文字时实测对比度**——
  详情页 chip 曾在暗色下测得 ≈2.7:1
- 尊重系统的「减弱动效」（§3.4）

---

## 5. 响应式

断点与列数由 `WorkLayoutConfig` / `WorkLayoutStrategy` 统一（1200 / 800；4 / 3 / 2 列）。
屏幕内不要各自读 `MediaQuery.size` 造第二套断点。

---

## 6. 组件开发规范

**拆分**：单文件超 300 行考虑拆分；跨屏复用的抽 `widgets/common/`，与屏强耦合的
就近放在该屏目录。

**命名**：文件 `snake_case`，类 `PascalCase`，私有 `_` 前缀。

**Provider**：订阅范围尽量窄。`Selector` 的 record 必须包含所有会影响该子树的字段。
高频通知（如播放位置）不要走 `ChangeNotifier` 的全员广播——见
`PlayerViewModel.positionListenable`。

**字符串**：UI 可见文案一律走 `Strings`。诊断/异常串豁免（它们经
`NetworkException.userMessage` 翻译后才面向用户）。

**注释**：只写「为什么」，中文，不写变更史。

---

## 7. 性能准则

### 7.1 状态管理

- 订阅范围最小化；`const` 构造尽量用满
- 高频事件先节流，再考虑是否该走独立的 `Listenable`

### 7.2 列表与滚动

- 分页列表用 builder delegate（`SliverChildBuilderDelegate`）
- **不要在滚动/构建路径上引入 per-item 的 DB 或文件系统查询**。需要整页的附加信息
  时批量查一次（例：首页在线/本地角标）

### 7.3 图片

封面按布局宽 × DPR 设 `memCacheWidth` 降采样；**不要**设 `maxWidthDiskCache`——
磁盘缓存全 App 共享，降采样盘文件会让复用同一 URL 的大图消费者取到糊图。

### 7.4 启动路径

见 `CLAUDE.md` 的 App Initialization Flow。要点：ViewModel 不在构造函数联网；
非首帧必需的初始化推迟到首帧后；恢复播放态不得阻塞用户的首次操作。

### 7.5 发版前检查（Profile 模式，非 debug）

- 首页列表滚动 ≥ 55fps
- 冷启动首帧：`flutter run --profile --trace-startup`，读 `start_up_info.json`。
  **debug 下的 `[startup]` 埋点是 JIT 数据，不能代表 release**

---

## 8. 已知缺口

以下为**已知未做**，不是遗漏，记录在此避免重复发现：

| 缺口 | 说明 |
| :--- | :--- |
| 交互反馈层 | `MicroInteractions` 0 调用点；按压缩放未落地；触觉只在 `settings_tile.dart` 两处；mini player 与播放器主体用 `GestureDetector` 无涟漪 |
| `disableAnimations` | 全库 0 处，真实无障碍缺口 |
| 列表入场动画 | 未做。分页 Sliver 每次筛选/翻页/换主题都重建，stagger 会反复闪，且正对 §7.5 的 55fps 硬线 |
| 播放器 drag-to-dismiss | 未做。当前唯一出口是左上角按钮，单手够不着 |
| 真机验收 | release/profile 冷启动毫秒未采集；四配色 × 明暗未逐屏对照；播放器全屏未验 |

---

## 9. 工作流

任何跨文件或有可观察行为变化的改动，**先建 TODO 文档**（`docs/todos/_template.md`），
再动代码；完成时执行 `/init` 刷新 `CLAUDE.md` 并把文档移入 `done/`。
详见 `docs/dev_workflow.md`。
