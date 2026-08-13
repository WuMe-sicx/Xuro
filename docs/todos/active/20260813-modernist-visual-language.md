# Modernist 视觉语言迁移——零圆角 / 2px 分隔线 / Archivo，四屏按设计稿重塑

- **创建时间**：2026-08-13
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **视觉基准**：Claude Design 项目「Flutter ASMR播放器设计」`f11e0a02-12c2-476f-8591-aaf9384c4922`，文件 `ASMR Player.dc.html`（4 屏静态稿）+ 设计系统 `_ds/modernist-*/styles.css`

---

## 1. 目标（Goal）

> 把 Xuro 的视觉语言整体换成设计稿的 Modernist 体系（零圆角、2px 分隔线、Archivo 800 字重标题、中性纸墨底色、accent 只给主操作），并按稿子重塑发现首页 / 播放器 / 分类三屏。**只做代码库真实具备数据源的部分，缺失能力一律不造。**

## 2. 范围（Scope）

**包含：**
- 令牌层整体替换：`AppRadius` 全档归零；`AppColors` 换为 Modernist 纸墨底色 + 共享中性阶；`AppTextStyles` 换为 Modernist 字号/字重/字距；`app_theme` 接入 Archivo + 2px 分隔线。
- 新增 `ColorVariant.still`（红 `#ec3013`）作为第 4 个可选 accent —— 稿子的招牌色，不加则设计稿的原始观感无法呈现。blue/mono/green 保留。
- Archivo 字体随包（400/600/800，OFL 协议），仅覆盖拉丁字母与数字。
- **发现首页**：时间问候语、继续播放卡片（读持久化播放态）、作品网格的「在线/本地」角标（读下载表）。
- **播放器**：方形大封面（取代圆形）、2px 直条进度 + 方块滑块（取代波形）、大方块主播放键、底部定时行。
- **分类屏**：按稿子的编号列表形式重塑 `browse/tags_screen`，**内容换成 `/tags/` 接口的真实标签**。

**不包含（缺数据源或属新功能，按「不为对齐 UI 反向造功能」原则一律不做）：**
- **渐弱停止**（稿中「最后 2 分钟音量渐弱」+ 渐弱时长选择器）—— `SleepTimerController` 到点直接 `pause()`，无音量斜坡。属新功能，另开任务。
- **「播完为止」定时模式** —— 无此模式。
- **「本周主题」红色策展块** —— 无策展后端。
- **「12.4万次播放」** —— 接口只有 `dl_count`（销量），无播放次数。改用销量。
- **底部导航改为 发现/分类/收藏/我的** —— 改信息架构属产品决策，本轮保持 收藏/主页/推荐/热门。
- 稿中「雨声/白噪音/耳语/篝火」这类环境音分类 —— asmr.one 的 tag 语义完全不同，分类屏用真实 tag 顶替。
- 稿子只有亮色；Modernist 暗色一档由本任务按「纸墨互换 + 共享中性阶」推导，非稿子原意。

## 3. 验收标准（Acceptance）

- [ ] 全库无圆角矩形（`AppRadius` 四档均为 0，且组件不绕过令牌写死 `circular(n)`）。
- [ ] 亮/暗 × 四配色（blue/mono/green/still）下，表面恒中性、仅 accent 轮换——三配色不变量仍成立（含底部导航 indicator）。
- [ ] 拉丁字母与数字走 Archivo；中日文回退到系统字体且不出现豆腐块。
- [ ] 发现首页：有时间问候、继续播放卡片（有上次播放态时出现、无则不占位）、卡片角标正确区分在线/已下载。
- [ ] 播放器：方形封面（`Hero(tag:'mini-player-cover')` 保留）、2px 进度条可拖拽 seek、行为与改版前一致。
- [ ] 分类屏：编号列表渲染真实 tag，点击进入对应标签作品列表。
- [ ] `flutter analyze` 通过无新增 warning；`flutter test` 通过（`design_tokens_test` 的「md 必须仍是 12」回归闸需**刻意**改写为「必须为 0」并注明原因）。
- [ ] 真机四配色 × 明暗截图对照设计稿。

## 4. 拆解步骤（Steps）

- [ ] **Phase 1 — 令牌层（地基，其余全部依赖）**
  - `pubspec.yaml` 声明 `assets/fonts/Archivo-{400,600,800}.ttf`
  - `AppRadius`：sm/md/lg/full 全部 → 0
  - `AppColors`：Modernist 纸墨 + 中性阶；新增 `ColorVariant.still`
  - `AppTextStyles`：Modernist 字号/字重/字距
  - `app_theme`：`fontFamily: 'Archivo'`、`dividerTheme` 2px、各 theme 圆角随令牌归零
  - `settings_screen`：第 4 个配色行 + `Strings` 常量
  - `design_tokens_test`：刻意改写回归闸
  - 验证：`flutter analyze` + `flutter test` + 真机四配色截图
- [x] **Phase 2 — 发现首页**（依赖 Phase 1）
  - 顶栏（品牌字 + 搜索图标 + 底部 2px 分隔线）、时段问候 kicker/大标题、「今晚精选」分区头：`lib/screens/contents/home_content.dart`（重排布局，分页/筛选/滚动逻辑不变；MainScreen 的跨 4 tab 通用 AppBar 不在本次改动范围，保留在上层，首页 body 内再叠一层品牌顶栏）
  - 问候语纯逻辑（早/午/晚/深夜四档，含日期/星期 kicker 格式化）：`lib/widgets/home/home_greeting.dart`（`HomeGreeting`，无数据源，纯 `DateTime` 计算）
  - 继续播放卡片：`lib/widgets/home/continue_playing_card.dart`（`ContinuePlayingCard`，数据来自 `PlayerViewModel.currentTrackInfo`/`position`/`duration`，即 `AudioPlayerService.restorePlaybackState` 恢复的上次播放态；无播放态时 `SizedBox.shrink()`，不占位不造假数据；显式注入 `PlayerViewModel` 而非内部 `GetIt`，便于纯 fake 服务单测）
  - 作品网格对齐：`lib/widgets/work_card/work_card.dart`（新增 `DownloadedWorksScope` InheritedWidget + 消费方，见下）、`lib/widgets/work_card/components/work_cover_image.dart`（封面改零圆角方形 `aspect-ratio 1`；角标统一为 `_CoverBadge`，RJ 号移到右上、时长仍左下、新增左上在线/本地角标）、`lib/widgets/work_card/components/work_title.dart`（标题改 `AppTextStyles.titleMedium`/800 字重）、`lib/widgets/work_card/components/work_footer.dart`（副标题改「发售日期 · 销量 N」单行 11px/55%，接口无播放次数字段故用销量替代）
  - `Strings` 新增：`lib/common/constants/strings.dart`（`continuePlaying`/`todaysPicks`/`dayPeriod*`/`greeting*`/`salesCountLabel`；在线/本地文案复用 Phase 3 已加的 `playerOnline`/`playerLocal`，未重复定义）
  - 在线/本地角标判定：`DownloadService.localPathsForWork(workId)` 按当前页 `works` 批量查一次（`Future.wait`，`identical()` 守卫避免重复查询），结果通过 `DownloadedWorksScope`（`work_card.dart` 内新增的 InheritedWidget）越过不在本轮改动范围的 `WorkRow`/`WorkGrid`/`GridContent` 传给 `WorkCard`；没有该 Scope 的网格（收藏/推荐/热门/搜索）`maybeOf` 返回 `null`，角标不显示，不猜错误默认值
  - 新增测试：`test/widgets/home/home_greeting_test.dart`（四时段边界 + kicker 格式）、`test/widgets/home/continue_playing_card_test.dart`（无播放态不渲染；有播放态渲染标题/进度，进度条 `valueColor` 随 blue/still 取 `colorScheme.primary`）、`test/widgets/work_card/work_cover_download_badge_test.dart`（`isDownloaded` 三态显隐取词 + 角标 `surface` 实底随 blue/still 轮换）
  - 已知空白点（详见任务报告）：`lib/widgets/filter/filter_panel.dart`（筛选 chip 零圆角/选中态实底视觉）与 `lib/screens/main_screen.dart`（跨 tab 共用 AppBar）不在授权文件清单内，本轮未动，筛选 chip 仍是旧版圆角浮层样式
  - 验证：`fvm flutter analyze lib/screens/contents/ lib/widgets/home/ lib/widgets/work_card/ test/widgets/` 无新增 issue（4 条 pre-existing warning 不变）；`fvm flutter test` 169/169 通过
- [x] **Phase 3 — 播放器**（依赖 Phase 1）
  - 方形封面（原圆形 `CircularCover` 改名重写）：`lib/widgets/player/square_cover.dart`（`SquareCover`，零圆角 + 1px `outlineVariant` 描边，去阴影；无封面回退图标染 accent 供三配色测试挂载点）
  - 2px 直条 + 12x12 方块滑块（取代装饰性波形）：`lib/widgets/player/waveform_progress.dart`（`LinearTrackPainter` 几何拆成 `trackRect`/`playedRect`/`thumbRect` 三个纯函数，供无 DI 单测；seek/`positionListenable` 订阅方式原样复用，未改 `PlayerViewModel`）
  - 控制行：`lib/widgets/player/player_controls.dart`（主按钮改 72x72 accent 零圆角方块，`Colors.white`→`cs.onPrimary`；保留原有快进/快退 10 秒——设计稿未画出但属既有功能，不算新增）
  - 曲目信息三段式（kicker/曲名/副标）：`lib/screens/player_screen.dart`（kicker+曲名内联，`Hero('mini-player-cover')`/`Hero('player-title')` 原样保留）+ `lib/widgets/player/player_work_info.dart`（副标：作品名跑马灯 + 声优，降级为 caption 级别）
  - 顶栏「正在播放」标签 + 右侧「在线/本地」角标：`lib/screens/player_screen.dart`（`_DownloadStatusBadge`，经 `DownloadService.localPathIfDownloaded` 判定，查询失败/未在播放时不渲染，不写死「在线」）
  - 底部睡眠定时行：`lib/screens/player_screen.dart`（`_buildSleepTimerFooter`，读 `SleepTimerController.minutes`/`isActive`，「更改」打开既有 `SleepTimerDialog`；不做渐弱停止文案）
  - `Strings` 新增：`lib/common/constants/strings.dart`（`playerOnline`/`playerLocal`/`playerSleepTimerChange`/`playerSleepTimerInactive`/`playerSleepTimerActive`）
  - 测试：`test/widgets/player/square_cover_test.dart`（零圆角 + accent 回退图标随 blue/still 轮换 + 无封面回退）、`test/widgets/player/linear_track_painter_test.dart`（滑块位置随 fraction 线性变化、12x12 尺寸、shouldRepaint、边界 fraction 不抛异常——`WaveformProgress` 本体因 `GetIt.I<PlayerViewModel>()` 走不了无 DI harness，故拆纯函数单测，颜色到 `colorScheme.primary` 的绑定见 `waveform_progress.dart:71`，未做自动化断言）
  - 验证：`fvm flutter analyze lib/screens/player_screen.dart lib/widgets/player/ test/widgets/player/` 无 issue；`fvm flutter test` 151/151 通过
- [x] **Phase 4 — 分类屏（真实 tag）**（依赖 Phase 1）
  - 新版编号列表行 + 共用顶栏：`lib/screens/browse/widgets/browse_grid_item.dart`（`BrowseListItem` + `browseAppBar`，替代旧 `BrowseGridItem` 网格卡片）
  - 三屏接入（数据/导航逻辑不变，仅换渲染形式为 `ListView.separated` + 编号）：`lib/screens/browse/tags_screen.dart`、`lib/screens/browse/circles_screen.dart`、`lib/screens/browse/voice_actors_screen.dart`
  - 计数文案常量：`lib/common/constants/strings.dart`（`browseItemCountLabel`）
  - 新增测试：`test/screens/browse/browse_list_item_test.dart`（编号生成/真实名称渲染/count=null 时无编号/blue·still 两配色下颜色恒为中性非 accent/点击回调）
  - 验证：`fvm flutter analyze lib/screens/browse/ test/screens/browse/` 无 issue；`fvm flutter test` 148/148 通过
  - 计数字段：`TagItem`/`CircleItem`/`VoiceActor`（`lib/data/models/{tags,circles,vas}/`）均有 `int? count`，为 null 时只显示箭头不编数字
- [x] **Phase 6（追加）— 侧边栏 Modernist 化 + 清除 5 月旧参考图残留**
  - 侧边栏：品牌区 2px 线、组间 2px / 行间 1px 两级分隔、行标题 800 字重（与 `BrowseListItem` 同规格）、分组头改 accent（与 `SettingsGroup` 一致）、尾部箭头统一 `→`
  - **删除 `sidebar_decoration.dart`**（叶片/弦月水印，旧参考图产物）及其撑起的 `Stack` 层
  - **`BrandWordmark` 重写为纯排版**：字标 `onSurface` + accent 句点（对应设计系统 `.nav-brand` 与稿中的 `STILL.`），移除波形图标与硬编码 `TextStyle`
  - 修 Phase 1 漏网的零圆角违规：`Drawer.shape` 的硬编码 `_cornerRadius = 28.0`
  - **全库圆角清零补扫**：另有 23 处 `BorderRadius.circular(n)` 绕过令牌（mini player 封面 / 筛选面板 / 搜索框 / TagChip / 详情页封面等）+ 2 处 `BoxShape.circle`（侧边栏头像、版本圆点）全部收回令牌。现全库 `circular(n)` / `BoxShape.circle` / `CircleAvatar` / `ClipOval` / `StadiumBorder` 均为 0 处
  - 删死文件 `player_cover.dart`（被 `square_cover.dart` 取代后零引用）
  - 测试：`sidebar_modernist_test.dart`（分组头 accent / 选中态前景，四配色）；`sidebar_d3_test` 与 `atom_three_variant_test` 的 BrandWordmark 断言按新形态改写（断言句点=accent、字标=onSurface、不含 Icon）；`about_screen_test` 的 `find.text('Xuro')` 改为断言组件参数
- [ ] **Phase 5 — 真机四配色 × 明暗验收截图，回填本文**
  - 已验（暗色 × green，浅色 × green）：零圆角全线生效、800 字重问候语、继续播放卡片、在线/本地角标、销量用真实字段、导航 indicator 随 accent 轮换、侧边栏两级分隔线与 accent 分组头
  - **未验**：`still`（红）配色、`blue`/`mono` 配色、亮/暗完整八种组合的逐屏对照
  - **未验**：播放器屏（方形封面 / 2px 直条进度 / 72×72 主键）真机观感——本轮无人打开过播放器全屏

## 5. 风险与回滚（Risks）

- **风险**：零圆角是全局不可逆观感改变，影响每一个屏。缓解：全部收敛在 `AppRadius` 一个文件，`git revert` Phase 1 即整体回退。
- **风险**：Archivo 无 CJK 字形，中文/日文走系统回退，与稿子的纯 Archivo 观感有差距。**这是稿子未考虑的客观约束**，不是实现缺陷。
- **风险**：方形封面 + 直条进度会推翻 5 月刚落地的 `CircularCover` / `WaveformProgress`。缓解：两者均只换视觉层，`Hero` tag 与 seek 逻辑复用，Phase 3 单独成 commit 可独立回退。
- **风险**：暗色一档为推导而非稿子给定，可能与设计意图有偏差。缓解：Phase 1 出真机暗色截图供确认后再铺开。
- **回滚**：Phase 独立 commit，逐阶段可 revert；Phase 1 回退即恢复原设计语言。

## 6. 备注 / 决策记录

> - 设计稿由 Claude Design 产出，其脚注写明「Xuro 代码库读取工具暂不可用」——**设计时未读过代码库**，因此信息架构（分类/本周主题/播放次数/渐弱停止）与 asmr.one 的真实能力不匹配。本任务按用户裁决只落地有数据源的部分。
> - 品牌名以 Xuro 为准，不采用稿中的 STILL。
> - 新增第 4 配色 `still`（红 `#ec3013`）是对用户「全局换成 Modernist」的补足：稿子的 accent 就是这个红，不加则原始观感不可达。blue/mono/green 一并保留，用户可随时切回。
> - Modernist 暗色推导规则：纸墨互换（底 `#201e1d` / 字 `#f3f2f2`），中性阶 100–900 共用，分隔线取中性 700。

---

## ✅ 完成标记

- 完成时间：YYYY-MM-DD HH:mm
- 执行命令：`/init`
- CLAUDE.md 更新摘要：<一两句话>
- 关联 commit：<commit hash>

---

## ⛔ 取消标记（仅 cancelled 任务填写，与上方完成标记互斥）

- 取消时间：YYYY-MM-DD HH:mm
- 取消原因：<...>
- 后续指向：<...>
