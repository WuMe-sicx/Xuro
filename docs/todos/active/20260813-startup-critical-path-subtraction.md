# 启动关键路径减法——去掉构造即联网 / 恢复期串行 IO / 启动期权限弹窗

- **创建时间**：2026-08-13
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：无（接续 `docs/todos/active/20260516-startup-loading-performance.md` 未覆盖的结构性成本）

---

## 1. 目标（Goal）

> 缩短冷启动到首个可交互帧、并让「用户按下播放」不再排队：去掉 ViewModel 构造函数里的联网、去掉 `runApp` 前无实际作用的鉴权 `await`、把播放态恢复移出 `ready` 闸门与首帧、把恢复路径的每轨 IO 收成一次。**本轮全部为减法或复用既有方法，不新增任何 module / interface / 依赖。**

## 2. 范围（Scope）

**包含：**
- 删死代码：`maybePrefetchNext` 及其三个字段与 `loadPage` 命中分支（零调用方）、`AppLogger.init()`（零调用方且被调用也是 no-op）。
- 三个列表 ViewModel 的首载移出构造函数，改由各 content widget 的 `addPostFrameCallback` 触发。
- `AuthViewModel` 增加 `isAuthReady`，Favorites/Recommend 的未登录早返回改为「未就绪时保持 loading」，防止先画未登录再翻转。
- 删除 `service_locator.dart` 中 `runApp` 前的 `loadSavedAuth()` `await`，并**改正 `main.dart` 中关于该 await 的错误注释**。
- 播放态恢复移出 `_init()` 的 `ready` 闸门之前的位置，改到首帧之后触发。
- 恢复路径每轨 IO 收敛：删 `_isCacheValid` 调用（返回值被丢弃）、记忆化 `_getCacheDir()`、改用已存在但零调用者的 `DownloadRepository.listByWork`。
- 通知权限请求从启动期移到首次播放前。
- 修两个既有 bug：`_initCompleter` 失败后永久毒化；`enhanced_work_grid_view` 有数据时错误态盖掉内容。
- `printTime: true` → `dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart`（等价替换，消一条既有告警）。

**不包含：**
- `ensureStarted()` 音频启动 seam、mini player 快照 chrome —— 经复核 Drop（只有一个 adapter；`_init()` 本就非阻塞；首帧本来就显示「未在播放」）。
- 播放列表惰性子源 —— 被 just_audio 的 `ConcatenatingAudioSource` interface 否掉（children 必须全量，`useLazyPreparation` 默认已开在平台侧）。
- `compute()` 解码播放态 JSON —— 40-60KB / 1-3ms，spawn isolate 净亏。
- `kReleaseMode` 日志 level 分支 —— 前提不成立（`DevelopmentFilter.shouldLog` 整体在 `assert` 内，release 恒 false，且 filter 先于 printer）。
- 磁盘快照 / cache-first 读取（另见 UI 收敛之后的独立任务；本轮启动收益不依赖它）。
- **不动 `main.dart` 的 `getIt<BackgroundPlayController>().initialize()`** —— 它是进程被外部（蓝牙 / Android Auto）从死态唤起走 headless engine 时，唯一确定的 Dart 侧音频初始化触发点。该路径未经验证，改懒会留下「服务活着但 handler 没接线」的僵尸。

## 3. 验收标准（Acceptance）

- [ ] 冷启动期间发出的内容 API 请求由 3 个并发降为 1 个（可由 `AppLogger` 的「加载XX: 第1页」条数验证）。
- [ ] `runApp` 之前不再 `await` 任何 `flutter_secure_storage` 读取；登录态显示仍正确，且不出现「先未登录后翻转」的闪烁。
- [ ] 冷启动（全新安装）不再弹出通知权限对话框；首次按下播放时弹一次，再次播放不弹。
- [ ] 恢复一个 N 轨作品时，`localPathIfDownloaded` 式的逐轨 DB 查询降为一次 `listByWork`；`getApplicationSupportDirectory()` 由每轨一次降为进程一次。
- [ ] 恢复进行中按下任意作品的播放不再被阻塞（`restorePlaybackState` 不再排在 `_initCompleter.complete()` 之前）。
- [ ] `_init()` 失败后仍可重试，音频功能不再整个 session 不可用。
- [ ] 列表已有内容时翻页失败，不再被错误页整屏盖掉。
- [ ] `flutter analyze` 通过，无新增 warning，且 `logger` 的 `printTime` 弃用告警消失。
- [ ] 相关单元 / Widget 测试通过；新增测试见 Step 各条。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：删死代码。`maybePrefetchNext` + `_isPrefetching`/`_prefetchedResponse`/`_prefetchedPage` + `loadPage` 内的命中分支；`AppLogger.init()`；`printTime` → `dateTimeFormat`。
  - 涉及文件：`lib/presentation/viewmodels/base/paginated_works_viewmodel.dart`、`lib/utils/logger.dart`
  - 验证：`flutter analyze` 无新增告警且 `printTime` 告警消失；`flutter test` 零回归。
  - 产物：`maybePrefetchNext`/`_invalidatePrefetch`/三个预取字段整体删除，`refresh()` 不再调用 `_invalidatePrefetch`；`AppLogger.init()` 删除，`printTime: true` 换成 `dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart`。
- [x] **Step 2**：三个 VM 首载移出构造函数，搬进 content widget 的 `addPostFrameCallback`（照抄 `favorites_content.dart` 既有写法）。
  - 涉及文件：`paginated_works_viewmodel.dart`、`recommend_viewmodel.dart`、`screens/contents/{home,popular,recommend}_content.dart`
  - 验证：冷启动日志只剩 1 条首页加载；切到热门/推荐 tab 各触发一次，回切不再重复请求（keep-alive）。
  - 产物：`PaginatedWorksViewModel` 新增幂等 `ensureFirstLoad()`（替代构造函数里的 `_init()`）；`RecommendViewModel` 构造体不再调 `loadRecommendations`；`home/popular_content.dart` 的 `initState` 补 `addPostFrameCallback` 调 `ensureFirstLoad()`，`recommend_content.dart` 补调 `loadRecommendations()`（三处均 `AutomaticKeepAliveClientMixin`，回切不重复触发 `initState`）。冷启动请求条数未做真机埋点验证（仅代码走查：`PageView` 默认只构建当前页，切走的 3 个 tab widget 不会被构建，故不会发请求）。
- [x] **Step 3**：`AuthViewModel.isAuthReady` + Favorites/Recommend 早返回守卫。
  - 涉及文件：`presentation/viewmodels/{auth,favorites,recommend}_viewmodel.dart`
  - 验证：鉴权就绪前调用 `loadPage` 既不报错也不误报「未登录」。
  - 产物：`AuthViewModel.isAuthReady`（`_loadSavedAuth`/`loadSavedAuth` resolve 后置真）；`FavoritesViewModel`/`RecommendViewModel` 构造函数在未就绪时挂 `_onAuthReady` 监听，`loadPage` 顶部加 `!isAuthReady` 早返回（只置 `_isLoading=true`，不设 error/isLoginError），就绪回调里先清 `_isLoading` 再重放 `loadPage(_currentPage)`，`dispose()` 摘监听。
- [x] **Step 4**：删 `service_locator.dart` 的 `await getIt<AuthViewModel>().loadSavedAuth()`，改正 `main.dart` 相关注释（原注释称「VM 构造即发带 token 请求」，实际 token 由 `AuthInterceptor` → `AuthRepository` 每请求自取并自带 in-flight 去重，与 `AuthViewModel` 无关）。
  - 涉及文件：`lib/core/di/service_locator.dart`、`lib/main.dart`
  - 验证：`[startup] main() → first frame` 下降（真机记录）；冷启动登录态正确、无闪烁。
  - 产物：`service_locator.dart` 删掉该行 await（`AuthViewModel` 构造函数已自行发起加载）；`main.dart` 注释改写为「为何不必 await」。真机埋点未回填（无真机环境）。
- [x] **Step 5**：`AudioCacheManager` 减法——删 `createAudioSource` 里的 `_isCacheValid` 调用及该方法本身（两分支返回同一对象，返回值被丢弃；过期删除本就是 `cleanCache()` 职责）；`_getCacheDir()` 记忆化（沿用 `database_service.dart` 已文档化的「`??=` 与赋值之间无 await」模式）。
  - 涉及文件：`lib/core/audio/cache/audio_cache_manager.dart`
  - 验证：`flutter analyze` clean；起播路径每次少两次 IO。
  - 产物：`createAudioSource` 折叠为单一 return；新增 `_cacheDirFuture` 记忆化 + 失败清空重试（`_openCacheDir`）；`clearAllCache()` 只删目录内容不删目录本身，记忆化后长期安全，已核对。
- [x] **Step 6**：`DownloadService.localPathsForWork(workId)` 复用已存在零调用者的 `DownloadRepository.listByWork`；映射部分切成纯静态可测函数。保留 `localPathIfDownloaded`（`player_viewmodel` / `subtitle_preview_screen` 仍在用）。三条语义必须原样保留：`title == null → null`、`File.exists()` 存在性闸门、失效行清理。
  - 涉及文件：`lib/core/download/download_service.dart`
  - 验证：新增纯静态单测（多行→map、他作品行排除、同 key 幂等）。
  - 产物：`localPathsForWork` + `static pathsByFileKey`；`title==null` 语义下放到调用方（`PlaylistBuilder`，DB 行不携带该字段）；`test/core/download/download_service_test.dart` 新增 `pathsByFileKey` 组（4 用例，全过）。
- [x] **Step 7**：`PlaylistBuilder.buildAudioSources` 把 GetIt 查找与批量查询提到循环之上，循环体退化为 map 查表；新增可选注入参数以便计数验证。
  - 涉及文件：`lib/core/audio/utils/playlist_builder.dart`
  - 验证：新增测试——50 个 file 只调用一次解析函数；真机播放一个已下载作品确认仍走 `Uri.file`（未做真机验证，仅代码走查 + 单测）。
  - 产物：`resolveLocalPaths` 可选注入参数（默认 `DownloadService.localPathsForWork`）+ 批量解析失败降级为「当作无本地下载」；`remapIndex` 抽成纯函数；新增 `test/core/audio/utils/playlist_builder_test.dart`（remapIndex 4 用例 + N→1 回归 + title==null 短路 + 无 workId 不调用，全过）。
- [x] **Step 8**：播放态恢复移出 `ready` 闸门 —— `_initCompleter.complete()` 先行，恢复改由首帧后触发；并修 `_initCompleter` 失败永久毒化。
  - 涉及文件：`lib/core/audio/audio_player_service.dart`
  - 验证：新增测试——构造后不触发 `loadState`；显式调用后触发一次；首次失败后可重试成功。**该条测试因 `AudioPlayer()`/`AudioSession.instance`/`AudioService.init()`/`permission_handler` 均为真实平台通道、仓库内无现成 mock 基建而跳过**（见任务报告），改以代码走查 + 现有测试套件回归验证。
  - 产物：`Completer` → 记忆化 `Future<void>? _readyFuture`（`ready` getter 失败后自动允许重试，同 `database_service.dart` 模式）；`_notificationInitAttempted`（守 `AudioService.init()` 包内一次性 assert）+ `_coreBuilt`（守 `late final` 字段重复赋值）两个标志把「可重试」与「不可重试」的部分分开；`restorePlaybackState` 移出 `_init()` 主链，改由 `WidgetsBinding.instance.addPostFrameCallback` 触发，方法内补 `await ready` 防御（经分析不构成自死锁）。
- [x] **Step 9**：通知权限请求 latch 化并移到首次播放前。
  - 涉及文件：`lib/core/audio/notification/audio_notification_service.dart`、`lib/core/audio/audio_player_service.dart`
  - 验证：全新安装冷启动无弹窗；首次播放弹一次；再次播放不弹；锁屏通知正常（未做真机验证，仅代码走查：`init()` 不再含权限请求，`resume()` 内 `await ensureNotificationPermission()` 为唯一调用点）。
  - 产物：`ensureNotificationPermission()`（记忆化 `Future`，失败吞掉不阻塞播放）+ `resume()` 内一次 `await`；`playWithContext()` 复用 `resume()`，未重复调用。
- [ ] **Step 10**：修 `enhanced_work_grid_view` 的 `if (error != null)` → `error != null && works.isEmpty`，并补 widget 测试。
  - 涉及文件：`lib/widgets/work_grid/enhanced_work_grid_view.dart`
  - 验证：有数据时模拟翻页失败，列表内容不被清空。
- [ ] **Step 11**：真机 `[startup]` 埋点 before/after 回填本文备注（沿用 `20260516-startup-loading-performance.md` 的口径，**不臆造数字**）。
  - **2026-08-13 真机（Xiaomi 23127PN0CC / Android 16）已验证的行为项**：
    - 冷启动列表请求 **3 → 1**：日志只剩一条「加载主页: 第1页」；热门列表仅在用户手动切到该 tab 时才加载（实测晚 14.7s）
    - **首帧先于所有网络请求与播放态恢复**：`[startup] main() → first frame` 打印在「加载主页」「开始恢复播放状态」之前
    - **播放态恢复走通新的批量查询路径**：「开始恢复播放状态 → 已加载 → 恢复成功」，本地/流式源解析正确
    - 错误态四层 UX 正确：断网显示「请先连接 VPN 服务」+ 重试；未登录显示「请先登录」+ 去登录（非异常 dump、非分支错配）
  - **仍未采集**：release/profile 下的冷启动毫秒 before/after。debug 埋点实测 933ms / 980ms / 5408ms（首装），但 **debug 为 JIT，不能代表 release**；且 `[startup]` 埋点被 `kDebugMode` 门控，profile 下不打印。正确做法是 `flutter run --profile --trace-startup` 读 `start_up_info.json`，**本轮未做**。
  - **仍未验**：全新安装冷启动不弹通知权限（需先 `adb shell pm revoke com.xuro android.permission.POST_NOTIFICATIONS`）。

## 5. 风险与回滚（Risks）

- **风险**：Step 2 之后全新安装首次切 tab 会转一次圈（原先是启动时预取）。已接受——换来每次冷启动少两个并发请求；后续快照任务会消除它。
- **风险**：Step 4 之后若某处仍依赖「鉴权已就绪」的同步内存读，会误报未登录。缓解：Step 3 的 `isAuthReady` 守卫 + 对应测试。
- **风险**：Step 6/7 的批量查询若与逐条查询语义不等价（缺失文件未回退流式、失效行未清理），会导致播放时 `PlayerException` 而非降级。缓解：三条语义逐条保留 + 单测。
- **风险**：Step 8 恢复延后约一帧，mini player 填入时间略晚（今天本就是异步填入，预期肉眼无差异，待真机确认）。
- **回滚**：每步独立 commit，全部为删除/时序移动，无 feature flag，`git revert` 即可。

## 6. 备注 / 决策记录

> - 本任务来自 2026-08-13 的架构评审（7 个独立设计代理复核）。评审报告：会话内 HTML，未入库。
> - **初版评审的三处错误已修正并记录**：① 「音频栈构造即启动平台**阻塞**首帧」——错，`_init()` async 且不 await，是并发成本；② 「325 个日志点在 release 里格式化 + print」——错，`DevelopmentFilter.shouldLog` 整体在 `assert(() {…}())` 内、release 恒 false，且 `logger.dart` 是先 filter 后 printer；③ 「`loadSavedAuth` 必须阻塞 runApp」——`main.dart` 原注释本身是错的，见 Step 4。
> - **`AppLogger.init()` 即使被调用也是 no-op**：`AppLogger` 只暴露 debug/info/warning/error，最低 `Level.debug`(2000) > `Level.trace`(1000)，抬 level 不改变任何输出。故为纯删除。
> - **刻意不引入 `ProductionFilter` / 崩溃上报**：release 下 `AppLogger.error` 被静默吞掉确是现状，但 `pubspec` 无 sentry/crashlytics，属产品决策，本轮不扩范围。
> - 真机数据（启动毫秒、恢复耗时）：<待回填>

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
