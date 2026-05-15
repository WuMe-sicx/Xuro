# 音频缓存改真 LRU + 启动清理延后首帧——消除 statSync 卡顿与错误淘汰

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：本地持久化优化清单第 3 项（Codex SESSION 019e2c0c…2962 分析 B2/C1）

---

## 1. 目标（Goal）

`AudioCacheManager.cleanCache()` 当前在 `files.sort` 的 comparator 里对每次比较同步 `statSync()`（O(N log N) 次阻塞文件系统调用，卡主隔离区帧）；且淘汰逻辑错误——按 modified 升序累计 `totalSize`，超限时删的是**当前（较新）**文件、删除后 `totalSize` 不回退，结果保留旧文件、误删新文件且把后续文件全删。再加上启动即在首帧期间触发清理。本任务把它改为**真 LRU + 一次性异步收集 stat**，并把启动清理**延后到首帧之后**。

## 2. 范围（Scope）

**包含：**
- 重写 `AudioCacheManager.cleanCache()`：一次性异步 `await file.stat()` 收集 `(file, stat)`；先删过期；再按 modified 升序从**最旧**开始删，直到 `totalSize ≤ _maxCacheSize`，**每删一个回退 totalSize**；单文件删除失败（占用中）跳过而非中止整轮。
- `CacheLifecycleManager.initialize()`：启动清理由同步 `_triggerCleanup()` 改为 `WidgetsBinding.instance.addPostFrameCallback` 延后到首帧之后；resume 路径保持即时（不变）。

**不包含：**
- 不在 `createAudioSource`（每次起播）前做容量扫描保护：每曲一次全目录扫描本身会拖慢起播（与流畅性目标冲突）。周期性正确 LRU + 30 天过期 + 6h 节流已足以约束增长。记为后续可选项。
- 不动 `getCacheSize()`/`clearAllCache()`/`_isCacheValid()`（非热路径或已正确）。
- 不改缓存上限（1024MB）、过期（30 天）、目录位置（app support `audio_cache/`）。
- 不动图片/字幕缓存（flutter_cache_manager 内置策略，属清单后续项）。

## 3. 验收标准（Acceptance）

- [x] `cleanCache()` 内不再出现 `statSync()`；stat 一次性 `await` 收集后再排序（Codex 核对 :52/:79）。
- [x] 淘汰为真 LRU：删最旧直到总量 ≤ 上限，`totalSize` 删除后回退；不再误删较新文件。
- [x] 过期文件先删；删除失败（占用中）的过期文件**加回 live**（计入容量 + LRU 队首重试），不中止整轮清理。
- [x] 启动清理延后到首帧之后触发（`addPostFrameCallback`），resume 即时清理行为不变。
- [x] `flutter analyze lib/core/audio/cache/` = No issues found（既有无关 warning 在未改的 `recommendation_cache_manager.dart:1`）。
- [x] 相关单元 / Widget 测试通过（31 通过；`test/widget_test.dart` 既有 stale 无关）。
- [x] Codex review ✅ PASS（SESSION 019e2c0c…2962，首轮 ❌ 容量低估 → 修复 → 二轮 PASS）。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：重写 `cleanCache()`（异步收集 stat + 过期优先 + 真 LRU + 占用跳过；过期删除失败加回 live）
- [x] **Step 2**：`CacheLifecycleManager.initialize()` 启动清理延后首帧（`addPostFrameCallback`）
- [x] **Step 3**：`flutter analyze`（改动文件无 warning）+ `flutter test`（31 通过，1 既有 stale）全量回归
- [x] **Step 4**：Codex review —— 首轮 ❌（过期删除失败丢出容量统计致低估）→ 修复（失败 entry 加回 live）→ 二轮 ✅ PASS

## 5. 风险与回滚（Risks）

- **风险**：LRU 用 `modified` 作「最近使用」近似（`LockCachingAudioSource` 边下边写，modified ≈ 最近缓存时刻）——非严格 atime，但平台 atime 不可靠，modified 是可用代理，行为可接受。删除失败跳过可能导致大量文件被占用时未达上限（优于整轮中止）。延后首帧使极端情况下首次清理稍晚——可接受（有 6h 节流与 30 天过期兜底）。
- **回滚方案**：revert 本次 commit（纯逻辑改动，无 model/生成产物）。

## 6. 备注 / 决策记录

- 触发链：`main.dart:21 CacheLifecycleManager().initialize()` →（原）同步 `_triggerCleanup()` → `CacheCoordinator().cleanAll()` → `AudioCacheManager.cleanCache()`。`cleanAll` 是 fire-and-forget（`.then`），不阻塞 `main()` 到 `runApp()`，但其内部 stat-heavy 扫描以异步续体在首帧期间争抢主隔离区——故延后到首帧后。
- Codex 首轮发现并修复的边界：过期文件 `delete()` 失败若直接丢弃，文件仍占盘却不计入 `live.fold` 容量统计，极端下（大过期文件占用 + 未过期文件 / 全过期全删不掉）实际占用远超 1GB 上限。修复为失败 entry 加回 `live`：既正确计入容量，又因 modified 最旧排到队首在 LRU 阶段优先重试删除。

---

## ✅ 完成标记

- 完成时间：2026-05-15 18:00
- 执行命令：`/init`
- CLAUDE.md 更新摘要：补充音频缓存清理不变量——`cleanCache()` 一次性异步收集 stat（杜绝 sort comparator 同步 statSync）、真 LRU 删最旧到 ≤1GB 且 totalSize 回退、过期优先且删除失败的过期文件须加回容量集合；启动清理经 `CacheLifecycleManager` 延后到首帧后。
- 关联 commit：未提交（用户未要求提交，待统一提交时机）
