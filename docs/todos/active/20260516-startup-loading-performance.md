# 启动与加载性能优化——更快的冷启动 + 更顺滑的图片/列表加载

- **创建时间**：2026-05-16
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：PR #4（代码优化已随分支合入）
- **2026-05-16 进度说明（Codex 合并前审 MEDIUM 消解）**：启动关键路径优化的**代码改动已随 PR #4 合入**；但验收要求的「设备 Profile/Release 冷启动首帧 + 列表滚动 before/after 实测数据」**尚未采集**，刻意**不臆造性能数字**。故本任务**保持 active** 作为明确的后续待办（仅剩设备实测验收），不计入本批 done 收口；待真机采数达标后再按流程闭环。

---

## 1. 目标（Goal）

> 缩短 App 冷启动到首个可交互帧的时间，并让列表/图片加载"看起来快"：精简 `runApp` 之前的同步路径，优化封面图的请求/解码/缓存策略、懒加载，以及加载态反馈，避免白屏与启动期掉帧。

## 2. 范围（Scope）

**包含：**
- 审计并最小化 `runApp` 之前被 `await` 的同步初始化：把非首帧必需的 init（`LyricOverlayManager.initialize()` 等）挪到首帧之后执行，首帧前只保留 `MaterialApp` 渲染真正依赖的部分（`SharedPreferences` + 鉴权门控）。
- 引入轻量首屏（品牌化/骨架）即时绘制，消除冷启动白屏；为 `MainScreen` 各 tab 的异步内容补齐骨架/错误态反馈（复用现有 `SkeletonPulse` / `GridError` 模式）。
- 图片性能：给四个封面组件按实际渲染盒尺寸设置 `memCacheWidth` / `maxWidthDiskCache`（按显示分辨率降采样解码），加上克制的 `fadeInDuration`；必要时校准 `PaintingBinding.imageCache` 内存预算与 `ImageCacheManager` 配置。
- 懒加载核查：确认所有分页列表/网格统一走 builder delegate（已知 `work_grid.dart` 用 `SliverChildBuilderDelegate`），核对分页预取阈值是否合理。
- 断言缓存清理扫描不阻塞首帧（`CacheLifecycleManager` 已用 `addPostFrameCallback` + 6h 节流——只做校验/补防护）。

**不包含：**
- 音频/字幕下载、离线播放（见 `20260516-local-media-download-and-video.md`）。
- 视频格式兼容（同上，归入本地媒体那份）。
- 更换图片缓存后端或图片库。
- 服务端 / API 响应结构改动。

## 3. 验收标准（Acceptance）

- [ ] 冷启动到首个可交互帧的时间有可量化下降：用启动埋点（`main()` 起点 → 首帧 `addPostFrameCallback` 时间戳）在真机测出 before/after 并记录到本文「备注」。**（代码侧已就位：`main.dart` 的 `[startup]` debugPrint；before/after 数值待真机运行，AI 无设备访问）**
- [ ] 首帧即显示品牌首屏或骨架——无空白闪屏；启动期无可归因于文件扫描的 >16ms 掉帧（确认清理已 deferred）。**（已确认：原生 `LaunchTheme`→Flutter 首帧即 `Scaffold`+`AppBar`，grid 用 `GridLoading`/`SkeletonPulse`；视觉无闪屏待真机录屏确认）**
- [ ] 滚动列表流畅：封面图按 ≤ 显示分辨率解码（DevTools 内存：图片缓存内存相对基线下降），封面在显示尺寸下不糊。**（代码侧已就位：4 个封面组件 `memCacheWidth`；DevTools 内存对比待真机）**
- [x] 每个异步 列表/网格/封面 在加载时都有骨架/占位；错误态给出可操作信息（复用 `GridError`）。— 现状已满足（`EnhancedWorkGridView`→`GridLoading`/`GridError`，封面 `SkeletonPulse` 占位）。
- [x] `flutter analyze` 通过，无新增 warning。— 改动文件 analyze clean；`work_cover.dart`/`player_cover.dart`/`work_cover_image.dart` 的 `withOpacity` info 为既有、非本次新增。
- [x] 相关单元 / Widget 测试通过。— 31 通过；唯一失败 `test/widget_test.dart`（`flutter create` 计数器样板）在干净 HEAD 同样失败（`+0 -1`），非本次回归。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：加启动埋点（`kDebugMode` 守卫的 `[startup]` debugPrint：`main()` → 首帧毫秒，零 release 开销）。
  - 涉及文件：`lib/main.dart`（`Stopwatch` + `addPostFrameCallback` + `kDebugMode`，新增 `import 'package:flutter/foundation.dart'`）
  - 验证：`flutter analyze` clean；真机运行控制台打印 `[startup] main() → first frame: N ms`（数值待用户在真机记录）。
- [x] **Step 2**：拆分 `setupSubtitleServices()`——仅做注册（改为同步 `void`），新增 `initDeferredStartupServices()` 承载 `LyricOverlayManager.initialize()`；`main.dart` 在 `runApp` 后的 `addPostFrameCallback` 里执行该 init + `CacheLifecycleManager().initialize()` + `AudioCacheManager.cleanLegacyCache()`。`prefs` + `AuthViewModel.loadSavedAuth()` **保留**在关键路径（MainScreen 各 VM 构造即发带 token 请求，推迟会误报登录态异常）。DI 注册次序（`AppSettingsService` 先于 `setupSubtitleServices`）不变。
  - 涉及文件：`lib/main.dart`、`lib/core/di/service_locator.dart`
  - 验证：`flutter analyze` clean；启动后 1 帧内触发延迟 init，悬浮歌词仍可用（恢复延后 ≤1 帧，已记入风险）。
- [x] **Step 3**：决策——**不**新增冗余 Flutter 首屏。原生 `LaunchTheme`/`NormalTheme` 已覆盖进程启动窗口，Flutter 首帧即 `MainScreen` 的 `Scaffold`+`AppBar`（非空白），各 tab 走 `EnhancedWorkGridView`→`GridLoading`/`SkeletonPulse`，状态反馈已具备。再叠一层 Flutter splash 属过度设计，按 guidelines 收敛范围、不改动。
  - 涉及文件：无（决策记录）
  - 验证：代码路径核实首帧非空白 + 骨架已接（视觉确认待真机录屏）。
- [x] **Step 4**：四个封面组件加 `memCacheWidth`（`LayoutBuilder`/已知 size × `MediaQuery.devicePixelRatio` 取整）+ `fadeInDuration: 150ms`。**仅** `memCacheWidth`，**不**用 `maxWidthDiskCache`——磁盘缓存被全 App 共享，降采样磁盘文件会让复用同一封面 URL 的大尺寸消费者（如 `PlayerCover`）取到糊图（决策记入备注）。
  - 涉及文件：`lib/widgets/work_card/components/work_cover_image.dart`、`lib/widgets/detail/work_cover.dart`、`lib/widgets/player/player_cover.dart`、`lib/widgets/mini_player/mini_player_cover.dart`
  - 验证：`flutter analyze` clean；DevTools 图片缓存内存下降待真机。
- [x] **Step 5**：`main.dart` 设 `PaintingBinding.instance.imageCache.maximumSizeBytes = 100<<20`。`ImageCacheManager` 配置（`stalePeriod 30d` / `maxNrOfCacheObjects 500`）核为合理，保持不变。
  - 涉及文件：`lib/main.dart`
  - 验证：`flutter analyze` clean。
- [x] **Step 6**：核查——`GridContent`→`WorkGrid` 已用 `SliverList`+`SliverChildBuilderDelegate(childCount:)`，**完全惰性**；分页为显式页码（`PaginationControls`）非无限滚动，无"预取阈值"可调；改成无限滚动属功能变更、超出本性能任务范围。**无需改动**。
  - 涉及文件：核查 `lib/widgets/work_grid.dart`、`lib/widgets/work_grid/components/grid_content.dart`、`enhanced_work_grid_view.dart`
  - 验证：阅读确认惰性 delegate 已就位。
- [ ] **Step 7**：复测启动 + 滚动，把 before/after 写入「备注」。埋点已 `kDebugMode` 守卫（release 零开销，无需移除）。**待用户真机运行采数**——AI 无真机/DevTools 访问，代码与采集手段已就位。
  - 验证：本文备注含 before/after 数值（待补）。

## 5. 风险与回滚（Risks）

- **风险**：延后 `LyricOverlayManager.initialize()` 可能推迟悬浮歌词首次可用——缓解：在首帧后立即初始化（而非首次使用时懒初始化），并保持其依赖 `AppSettingsService` 的注册次序不变。
- **风险**：`memCacheWidth` 过小导致高 DPI 下封面糊——按 `devicePixelRatio × 布局宽度` 取值。
- **回滚方案**：每步独立可 revert，改动保持加法式、单步单 commit，无需 feature flag。

## 6. 备注 / 决策记录

> - 已核实现状（file:line）：`main.dart:14-26` 同步 `await setupServiceLocator()`；`service_locator.dart` 内 `SharedPreferences`(38)/`AuthViewModel.loadSavedAuth()`(121)/`LyricOverlayManager.initialize()`(158) 均在首帧前 await；`CacheLifecycleManager` 已用 `addPostFrameCallback`+6h 节流（低风险，仅校验）；图片用 `CachedNetworkImage`+`SkeletonPulse`，**无 fade-in、无降采样**；`work_grid.dart` 已用 `SliverChildBuilderDelegate`（懒加载 OK）。
> - **决策（Step 3）**：不加 Flutter splash——原生 LaunchTheme + 首帧即 Scaffold + 现有 grid 骨架已覆盖"首帧非空白 + 状态反馈"，再叠一层属过度设计。
> - **决策（Step 4）**：只用 `memCacheWidth` 不用 `maxWidthDiskCache`。`ImageCacheManager.instance` 磁盘缓存全 App 共享；若 grid 缩小盘上文件，复用同一封面 URL 的 `PlayerCover`（大图）会从盘取到糊图。`memCacheWidth` 只影响各 widget 内存解码尺寸、不动共享盘文件，是正确解法。
> - **决策（Step 2）**：`loadSavedAuth()` 不延后——MainScreen 的 4 个 VM 构造即发带 token 请求，延后会导致首批请求未带 token、误报登录态异常（与 CLAUDE.md「错误提示 UX」不变量冲突）。延后项仅限：悬浮歌词 init + 缓存生命周期/旧缓存迁移。
> - **设备依赖**：启动毫秒数、DevTools 图片缓存内存、滚动 timeline before/after 均需真机 + DevTools，AI 无访问；埋点（`[startup]` debugPrint）与降采样代码已就位，待用户真机采数后回填下方。
> - 启动埋点 before/after 数值：<待用户真机回填>
> - 滚动 timeline / 图片缓存内存 before/after：<待用户真机回填>
>
> **Codex review（SESSION_ID `019e2c83-d6d9-7583-928e-2f3a589037e5`）**：
> - 第 1 轮 ⚠️ OPTIMIZE，3 个 low 项 → 已逐项修复：
>   1. `CacheLifecycleManager().initialize()`/`cleanLegacyCache()` 移出外层 post-frame、改为 `runApp()` 后直接调用（其内部自带 post-frame+6h 节流；外套一层会把启动清理推到更后帧，且 `addPostFrameCallback` 不主动请求下一帧）。
>   2. 4 个封面组件 `memCacheWidth` 加 `isFinite && >0` 防御 + `<1?1` 兜底，否则传 `null`（规避 `double.infinity.round()` 抛 `UnsupportedError`）。
>   3. `Stopwatch` 由 `kDebugMode` 三元门控，release 真正零分配。
> - 第 2 轮（复审，同 SESSION_ID）✅ PASS — ship as-is。
> - 变更日志：`lib/main.dart`、`lib/core/di/service_locator.dart`、`lib/widgets/{work_card/components/work_cover_image,detail/work_cover,player/player_cover,mini_player/mini_player_cover}.dart`；`flutter analyze` 仅余既有 `withOpacity` info；测试 31 通过、`widget_test.dart` 样板失败为既有非回归。

---

## ✅ 完成标记

> 全部步骤勾选完毕后填写此块，并实际执行 `/init` 刷新根目录 `CLAUDE.md`，然后把本文件移入 `docs/todos/done/`。

- 完成时间：YYYY-MM-DD HH:mm
- 执行命令：`/init`
- CLAUDE.md 更新摘要：<一两句话>
- 关联 commit：<commit hash>

---

## ⛔ 取消标记（仅 cancelled 任务填写，与上方完成标记互斥）

- 取消时间：YYYY-MM-DD HH:mm
- 取消原因：<...>
- 后续指向：<...>
