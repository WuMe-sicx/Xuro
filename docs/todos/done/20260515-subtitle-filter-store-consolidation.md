# 字幕筛选状态收敛到单一 store——消除 dispose 回写陈旧值

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：本地持久化优化清单第 2 项（Codex SESSION 019e2c0c…2962 分析 C5）

---

## 1. 目标（Goal）

共享 `subtitle_filter` bool 被 4 个 ViewModel（Recommend / Popular / Home / SimilarWorks）各自 `SharedPreferences.getInstance()` 读写并在 `dispose()` 回写本地缓存值——后销毁的 VM 会用**旧值覆盖**另一个 VM 刚写入的新值，造成跨页筛选状态不一致。收敛到单一注入式 store（复用既有 `AppSettingsService` 同步范式），移除 VM 内 `getInstance()` 与所有 `dispose()` 回写。

## 2. 范围（Scope）

**包含：**
- `AppSettingsService` 新增 `hasSubtitleFilter`（构造同步读 `subtitle_filter`，getter + `setHasSubtitleFilter()` 持久化 + `notifyListeners()`，仅变更时写），完全沿用现有 `setServerUrl` 范式。
- `RecommendViewModel` / `PopularViewModel` / `SimilarWorksViewModel` / `HomeViewModel`：删除本地 `_hasSubtitle` 缓存、`_subtitleFilterKey`、`SharedPreferences` 字幕读写与 `_load/_saveFilterState`(subtitle 部分)；`hasSubtitle` getter 改委托 `getIt<AppSettingsService>().hasSubtitleFilter`；toggle/update 改调 `setHasSubtitleFilter()`。
- **删除 4 个 VM 中所有 `dispose()` 的筛选回写**（Recommend/Popular/SimilarWorks 的 `dispose` override 整体移除；Home 的 `dispose` 移除 `_saveFilterState()` 回写）。
- 公共 API 不变：`hasSubtitle` getter、`toggleSubtitleFilter()`/`updateSubtitle()`、`filterState` 签名保持，widget/Provider 层零改动。

**不包含：**
- `home_filter_state`（排序 `FilterState` JSON）是 **Home 私有、单写者**，不存在跨 VM 竞态，**保留其现有 prefs 持久化与 onInit 一次性加载**；仅移除其 dispose 冗余回写。不把 `FilterState`（presentation 模型）塞进 `AppSettingsService`（core 层），避免 core→presentation 反向依赖。
- 不引入跨屏实时联动（VM 不监听 `AppSettingsService`）：保持各屏在自身 init 时读共享值、在自身 refresh 应用——行为与现状等价，仅去除 bug。
- 不动 `SearchViewModel` 等不共享该 key 的 VM。

## 3. 验收标准（Acceptance）

- [x] 任一屏 toggle 字幕筛选后切到另一屏再返回，值不被旧 VM dispose 回写覆盖（核心 bug 消除——Codex 确认单写者）。
- [x] 4 个 VM 内不再出现 `SharedPreferences.getInstance()` 读写 `subtitle_filter`；无 `dispose()` 回写该状态。
- [x] `subtitle_filter` 仍持久化（杀进程重启后保留），由 `AppSettingsService` 单点负责。
- [x] widget/screen 层无改动即可编译通过（公共 getter/方法签名不变）。
- [x] `home_filter_state` 排序持久化行为不变（更新即存、重启恢复），仅去掉 dispose 冗余写。
- [x] `flutter analyze lib/presentation/viewmodels/ lib/core/settings/` = No issues found（无新增 warning）。
- [x] 相关单元 / Widget 测试通过（31 通过；`test/widget_test.dart` 既有 stale 模板测试无关）。
- [x] Codex review ✅ PASS（SESSION 019e2c0c…2962，首轮通过）。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：`AppSettingsService` 新增 `hasSubtitleFilter` getter/setter + ctor 同步读
- [x] **Step 2**：`RecommendViewModel` 改委托 + 删 dispose 回写 + 构造直接触发首载
- [x] **Step 3**：`PopularViewModel` 改委托 + 删 dispose/onInit 异步加载（顺带清理无用 logger import）
- [x] **Step 4**：`SimilarWorksViewModel` 改委托 + 删 dispose 回写
- [x] **Step 5**：`HomeViewModel` subtitle 改委托；保留 `home_filter_state` 持久化，仅删 dispose 回写
- [x] **Step 6**：`flutter analyze`（No issues found）+ `flutter test`（31 通过，1 既有 stale 无关）全量回归
- [x] **Step 7**：Codex review —— 首轮 ✅ PASS（确认单写者、行为等价、无分层反向依赖）

## 5. 风险与回滚（Risks）

- **风险**：4 VM 初始筛选加载由「异步 getInstance 后触发列表」改为「同步读 settings 后触发」，需确认首载时机不回退（PaginatedWorks 基类在 onInit 后才 loadPage(1)，Recommend/Similar 在构造体显式触发）。
- **回滚方案**：revert 本次 commit（纯逻辑改动，无 model/生成产物）。

## 6. 备注 / 决策记录

- 选 `AppSettingsService` 而非新建 store：它已是 prefs-backed 单例 + ChangeNotifier + 构造同步读 + setter 持久化范式，零新增 DI 注册，最小改动面（constraint.md：Simplicity > Over-engineering）。
- `home_filter_state` 不收口进 core：`FilterState` 属 presentation 层，core 导入它构成分层反向依赖（constraint.md：No circular dependencies）。其单写者特性也无竞态，保留即可。

---

## ✅ 完成标记

- 完成时间：2026-05-15 17:05
- 执行命令：`/init`
- CLAUDE.md 更新摘要：补充 `AppSettingsService` 持有共享 `subtitle_filter`（`hasSubtitleFilter`）单点收口的说明，记录 4 个列表 VM 经它委托、不再各自 `getInstance()`/dispose 回写；`home_filter_state` 仍为 Home 私有 prefs。
- 关联 commit：未提交（用户未要求提交，待统一提交时机）
