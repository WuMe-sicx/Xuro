# Flutter 性能优化：启动、列表滚动、播放页卡顿治理

- **创建时间**：2026-05-15
- **负责人**：codex
- **状态**：cancelled
- **关联 Issue / PR**：N/A（用户反馈：软件速度与卡顿问题）

---

## 1. 目标（Goal）

系统性降低 Xuro 在启动、首页/推荐/热门列表滚动、详情页打开、播放器与歌词页交互中的卡顿，先建立 profile 基线，再分阶段优化高频路径，保证性能改进可测量、可回归验证。

## 2. 范围（Scope）

**包含：**
- 建立性能基线与回归记录：profile 模式下记录冷启动、首页首屏、作品列表滚动、切换 tab、打开详情页、开始播放、播放器封面页、歌词页、后台恢复等关键场景。
- 列表渲染优化：重点检查并优化 `lib/widgets/work_grid.dart`、`lib/widgets/work_row.dart`、`lib/widgets/work_card/`、`lib/widgets/work_grid/` 相关实现，降低 build/layout/raster 成本。
- 播放器刷新优化：重点检查并优化 `lib/presentation/viewmodels/player_viewmodel.dart`、`lib/widgets/mini_player/`、`lib/widgets/player/`、`lib/widgets/lyrics/`，拆分高频进度刷新与低频元信息刷新。
- 启动路径优化：重点检查 `lib/main.dart`、`lib/core/di/service_locator.dart`、缓存清理、悬浮歌词初始化、播放状态恢复等首屏前/首帧后任务边界。
- 详情页与文件树优化：重点检查 `lib/screens/detail_screen.dart`、`lib/presentation/viewmodels/detail_viewmodel.dart`、`lib/widgets/detail/work_files_list.dart`、`lib/widgets/detail/work_folder_item.dart`。
- 音频首响与播放列表准备优化：重点检查 `lib/core/audio/controllers/playback_controller.dart`、`lib/core/audio/utils/playlist_builder.dart`、`lib/core/audio/cache/audio_cache_manager.dart`。
- 图片缓存与解码策略评估：重点检查 `lib/core/image/cache/image_cache_manager.dart` 与 `CachedNetworkImage` 使用点，降低列表滚动时的解码与内存压力。
- 日志策略优化：评估 `lib/utils/logger.dart` 及高频路径 debug 日志，避免 profile/release 下日志打印干扰性能。

**不包含：**
- 不做全量 UI 改版或视觉风格重设计。
- 不更换 Provider/GetIt 状态管理体系。
- 不重写音频架构；只在现有事件驱动架构内做通知粒度、播放列表准备、缓存策略优化。
- 不升级 Flutter、Dart、Gradle、CocoaPods 或第三方依赖版本，除非后续证明确为性能问题根因并另建 TODO。
- 不改变 ASMR.ONE API 协议与后端请求语义。
- 不调整数据模型字段结构；若后续必须修改 `lib/data/models/` 下 Freezed/json_serializable 模型，需要在本 TODO 中补充步骤并运行 build_runner。

## 3. 验收标准（Acceptance）

- [ ] 已在 Android 真机 profile 模式完成性能基线记录，并在本 TODO 的「备注 / 决策记录」或独立性能记录文档中保存测试设备、Flutter 版本、测试步骤、关键指标与截图/日志引用。
- [ ] 冷启动到首页首屏可交互耗时有可观测下降，或至少明确证明首屏前任务已按必要/非必要分类并完成非关键任务后移。
- [ ] 首页/推荐/热门作品列表连续滚动时，profile 记录中的 jank 帧数量较基线下降；UI/Raster frame p95 不得劣化。
- [ ] 播放中停留首页时，迷你播放器进度更新不再导致封面、标题、按钮等低频区域随每次进度 tick 重建。
- [ ] 播放器页拖动进度条时不连续触发播放器 seek；松手后定位准确，播放/暂停/上一首/下一首行为不回归。
- [ ] 歌词页自动滚动、手动滚动、点击歌词跳转均正常；播放过程中歌词同步无明显抖动或掉帧。
- [ ] 打开详情页时文件列表较大的作品不出现明显长时间主线程阻塞；详情页加载、播放文件、返回流程不回归。
- [ ] 开始播放多文件作品时，首响时间不劣化；如优化播放列表准备，需覆盖当前曲、上一首/下一首、顺序播放、播放状态恢复。
- [ ] 图片缓存、音频缓存、字幕缓存清理策略不误删正在使用的文件；缓存管理页面显示与清理功能不回归。
- [ ] `fvm flutter analyze` 通过；允许已有 withOpacity deprecation warning，但本任务不得新增 warning。
- [ ] `fvm flutter test` 通过；若新增或调整测试，相关测试文件全部通过。
- [ ] 功能完成后按工作流填写「✅ 完成标记」、实际执行 `/init`，并将本文件移入 `docs/todos/done/`。

## 4. 拆解步骤（Steps）

- [ ] **Phase 0：性能基线与问题分级**
  - 涉及文件：`docs/todos/active/20260515-flutter-performance-optimization.md`，必要时新增 `docs/performance/` 下记录文档。
  - 工作内容：在 profile 模式下记录冷启动、列表滚动、tab 切换、详情页、播放首响、播放器封面页、歌词页、后台恢复等场景；标记 UI thread、Raster thread、图片解码、网络等待、日志输出、文件 IO 等瓶颈来源。
  - 验证：记录测试设备、系统版本、Flutter SDK、构建命令、每个场景的复现步骤、基线指标与后续对比方式。

- [ ] **Phase 1：播放器高频刷新降噪**
  - 涉及文件：`lib/presentation/viewmodels/player_viewmodel.dart`、`lib/widgets/mini_player/mini_player.dart`、`lib/widgets/mini_player/mini_player_progress.dart`、`lib/widgets/mini_player/mini_player_controls.dart`、`lib/widgets/player/player_progress.dart`、`lib/widgets/player/player_controls.dart`、`lib/screens/player_screen.dart`。
  - 工作内容：拆分进度、播放状态、音轨元信息、字幕状态的 UI 订阅边界；避免进度 tick 触发封面/标题/按钮大范围 rebuild；把进度条拖动改为本地预览 + 结束时 seek。
  - 验证：播放中首页、播放器页 profile 记录显示 rebuild 范围缩小；拖动进度条无连续 seek 风暴；播放控制行为不回归。

- [ ] **Phase 2：作品列表渲染优化**
  - 涉及文件：`lib/widgets/work_grid.dart`、`lib/widgets/work_row.dart`、`lib/widgets/work_grid_view.dart`、`lib/widgets/work_grid/enhanced_work_grid_view.dart`、`lib/widgets/work_grid/components/grid_content.dart`、`lib/widgets/work_card/`、`lib/presentation/layouts/work_layout_strategy.dart`。
  - 工作内容：评估并替换手动分组成行的 `SliverList + Row` 实现，优先采用真正的懒加载网格；限制列表卡片内标签数量和动态高度；避免 build 方法中重复做可缓存计算。
  - 验证：首页/推荐/热门列表滚动 profile 指标较基线改善；2/3/4 列布局正确；点击作品进入详情、刷新、分页、筛选面板不回归。

- [ ] **Phase 3：启动路径与后台任务后移**
  - 涉及文件：`lib/main.dart`、`lib/core/di/service_locator.dart`、`lib/core/cache/cache_lifecycle_manager.dart`、`lib/core/audio/audio_player_service.dart`、`lib/core/audio/storage/playback_state_repository.dart`、`lib/core/platform/lyric_overlay_manager.dart`。
  - 工作内容：梳理首屏前必须等待的任务与可延后任务；评估悬浮歌词初始化、缓存清理、旧缓存迁移、播放状态恢复是否可在首帧后或空闲时执行；避免缓存清理与首屏渲染抢 IO。
  - 验证：冷启动 profile 记录首屏可交互时间不劣化并尽量下降；已有登录态、主题、播放状态恢复、悬浮歌词权限流程不回归。

- [ ] **Phase 4：详情页与文件树懒构建**
  - 涉及文件：`lib/screens/detail_screen.dart`、`lib/presentation/viewmodels/detail_viewmodel.dart`、`lib/widgets/detail/work_files_list.dart`、`lib/widgets/detail/work_folder_item.dart`、`lib/widgets/detail/work_file_item.dart`、`lib/core/audio/models/file_path.dart`。
  - 工作内容：避免一次性把大型文件树全部 map 成 widget；展开文件夹时再构建子节点；把智能路径搜索从 build 高频路径中移出或缓存到 ViewModel；保持默认展开策略可预测。
  - 验证：大文件数作品详情页打开和滚动无明显卡顿；默认展开第一个音频目录仍正确；点击音频文件播放不回归。

- [ ] **Phase 5：播放首响与音频队列准备**
  - 涉及文件：`lib/core/audio/controllers/playback_controller.dart`、`lib/core/audio/utils/playlist_builder.dart`、`lib/core/audio/cache/audio_cache_manager.dart`、`lib/core/audio/models/playback_context.dart`、`lib/core/audio/state/playback_state_manager.dart`。
  - 工作内容：评估当前按顺序为整张同目录播放列表创建 AudioSource 的成本；优先保障当前曲首响，必要时延后准备非当前曲；保留上一首/下一首和恢复播放语义。
  - 验证：播放首响时间不劣化；多文件作品切歌、播放完成、恢复播放、缓存命中/未命中路径均正常。

- [ ] **Phase 6：图片与缓存策略细化**
  - 涉及文件：`lib/core/image/cache/image_cache_manager.dart`、`lib/widgets/work_card/components/work_cover_image.dart`、`lib/widgets/detail/work_cover.dart`、`lib/widgets/player/player_cover.dart`、`lib/widgets/mini_player/mini_player_cover.dart`、`lib/core/cache/cache_coordinator.dart`。
  - 工作内容：评估列表缩略图是否需要固定解码尺寸；确认缓存对象数量、过期策略与内存压力；缓存清理放在不会影响首屏和播放的时机。
  - 验证：图片列表滚动不出现明显解码抖动；封面 Hero、详情大图、迷你播放器封面显示正常；缓存管理功能不回归。

- [ ] **Phase 7：日志与验证收尾**
  - 涉及文件：`lib/utils/logger.dart` 及本任务触及的高频路径文件。
  - 工作内容：降低 profile/release 下高频 debug 日志成本；补充必要的单元/Widget 测试或手测记录；运行分析与测试；整理优化前后指标。
  - 验证：`fvm flutter analyze`、`fvm flutter test` 通过；性能记录包含优化前后对比；本 TODO 所有验收标准完成。

## 5. 风险与回滚（Risks）

- **风险**：列表布局替换可能影响平板/桌面列数、卡片高度、点击区域与 Hero 动画。
- **回滚方案**：列表渲染改动应独立提交；如出现布局回归，优先 revert 对应提交恢复旧 `WorkGrid` 路径。
- **风险**：播放器刷新拆分可能造成某些 UI 区域漏更新，例如播放/暂停按钮、当前曲标题、字幕导入状态。
- **回滚方案**：播放器状态拆分必须保留清晰的状态边界与手测矩阵；若漏更新，先回滚对应订阅拆分，再以更小粒度重做。
- **风险**：启动任务后移可能改变播放状态恢复、悬浮歌词恢复或缓存清理时机。
- **回滚方案**：所有首帧后任务迁移保持可单独 revert；播放状态恢复和悬浮歌词初始化优先保证功能正确。
- **风险**：音频队列延迟准备可能影响下一首/上一首的即时可用性。
- **回滚方案**：若 `just_audio` 队列动态补齐成本或行为不可控，保留现有整队列准备策略，仅优化缓存检查和日志成本。
- **风险**：性能优化容易扩大范围，演变为架构重写。
- **回滚方案**：每个 Phase 单独提交、单独验证；未被 profile 数据支持的重构不进入本任务。

## 6. 备注 / 决策记录

- 初步静态分析认为优先级最高的热点是：作品列表手动分行渲染、播放器高频 `notifyListeners()` 触发大范围 rebuild、启动阶段非关键任务与首屏竞争、详情页文件树一次性构建。
- 性能判断必须以 profile 模式数据为准；debug 模式下的卡顿只作为线索，不作为最终验收依据。
- 推荐实施顺序：先基线，再播放器刷新与进度条 seek，随后列表网格，之后启动路径、详情页文件树、播放首响和缓存策略。

---

## ⛔ 取消标记

- 取消时间：2026-05-15
- 取消原因：本 TODO 由 codex 起草时**基于已经过期的 `ui-design-spec.md §7.1` 审计结果**。当天稍晚的静态再核对显示，文档列出的 9 项 P0/P1 热点中 **7 项已经在过去的提交里修复**（PlayerViewModel 60Hz 节流、PlaybackEventHub `==`/`hashCode`、SubtitleList 二分查找、Shimmer 移除、WorkRow 无 IntrinsicHeight、WorkFilesList 移出 build 副作用、PlayerLyricView 移出 build 副作用），**1 项已通过本次会话其他独立 TODO 修复**（侧边栏 BackdropFilter 卡顿，见下文），剩下 1-2 项要么改动太小不值得 7-阶段任务，要么必须先有 profile 数据才能判断是否真问题。继续按本 TODO 7-阶段全推等于盲改已修复代码，回归风险大于收益。
- 已被替代的相关工作：
  - [`done/20260515-sidebar-first-open-jank.md`](../done/20260515-sidebar-first-open-jank.md) — 用 PerfDog 真机数据定位侧边栏首次打开 256ms jank，通过删除冗余 `BackdropFilter` 解决，等价于本 TODO Phase 0+2 的一个垂直切片。
  - [`done/20260515-disable-impeller-android.md`](../done/20260515-disable-impeller-android.md) — 解决 Adreno + Vulkan + Impeller 长会话型 `ErrorDeviceLost` 崩溃；不在原 TODO 范围内但属于性能/稳定性总目标。
  - [`done/20260515-color-palette-simplification.md`](../done/20260515-color-palette-simplification.md) — 顺手中性化了 surface tokens、删除多套硬编码彩色，间接降低首帧绘制复杂度。
- 后续指向：未来若再出现具体性能问题，请基于 **真机 profile 数据 + Flutter DevTools Timeline 火焰图** 定位到具体 widget/方法，再开**单独 TODO**（参照本会话三个垂直切片的粒度），不要再做 7-阶段大爆炸式优化任务。
- **不执行 `/init`**——本次取消仅是 TODO 文档归档，无代码 / 架构变化。
