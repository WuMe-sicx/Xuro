# 修复进详情页封面闪白：用网格已解码的低清图打底

- **创建时间**：2026-08-13
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：<待补>

---

## 1. 目标（Goal）

从列表点进作品详情、退回、再点进，封面会闪一下白。成因已测实：

1. 网格封面按卡片宽度解码（两列约 **570px**），详情页按整宽解码（约 **1170px**），
   `memCacheWidth` 不同即 `ResizeImage` 的 key 不同——**同一张图在 ImageCache 里
   是两个独立条目**，进详情必然要重新解码一份，无法命中网格那份。
2. `lib/widgets/detail/work_cover.dart` 的 `CachedNetworkImage` **既无
   `placeholder` 也无 `errorWidget`**，解码那段窗口里画的是空白。

Hero 把网格的图飞过去、落地后详情自己那份还在解码 → 空白闪一下 → 淡入。

让详情页在高清图解码期间显示**网格那份已在缓存里的低清图**（同 key 即同步命中，
无空窗），高清解码完再淡入。

## 2. 范围（Scope）

**包含：**
- `lib/presentation/layouts/work_layout_config.dart`：新增网格封面解码宽度的
  纯函数，供详情页算出与网格完全一致的 key。
- `lib/widgets/detail/work_cover.dart`：加 placeholder（低清打底）。
- 回归测试：挂真实网格，断言实际 `memCacheWidth` 与该纯函数一致。

**不包含：**
- 播放器页「封面↔歌词」`AnimatedSwitcher` 切换时封面子树被销毁重建
  （已测实存在，但用户确认不是本次报的现象，另立）。
- 四个封面调用点共 4 个缓存条目的整体收敛（播放器 960px / 迷你 144px 两份
  不参与本次修复）。
- `WorkRow` 硬编码两列、`WorkLayoutConfig.getColumnsCount` 对它无效
  （既有问题，本次只依赖「恒为两列」这一事实，不修改它）。

## 3. 验收标准（Acceptance）

- [ ] 详情页封面在高清图就绪前显示低清图，**不出现空白帧**。
- [ ] 低清 placeholder 的解码宽度与网格封面**完全相等**（否则命不中缓存，
      修复静默失效）——由测试断言，不靠手推公式。
- [ ] `fvm flutter analyze` 通过，无新增 warning（基线 4 条）。
- [ ] `fvm flutter test` 全绿。
- [ ] 真机验证：列表→详情→退回→再进，反复多次不再闪白。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：测量缓存 key 分裂
  - 涉及文件：`test/widgets/work_card/cover_cache_key_measure_test.dart`
  - 验证：已测出 4/4 独立条目，网格 570 / 详情 1170。
- [x] **Step 2**：`WorkLayoutConfig.gridCoverCacheWidth(screenWidth, dpr)`
  - 验证：测试挂真实 `WorkRow`/`WorkCard`，读出 `WorkCoverImage` 实际用的
    `memCacheWidth`，断言与该函数返回值相等。**手机 / 平板 / 桌面三档全部吻合。**
- [x] **Step 3**：`WorkCover` 加低清 placeholder（并复用为 `errorWidget`，
      高清图失败时保留低清而非回到空白）
  - 验证：改动前该断言为红（详情页只有 1080px 一份），改动后通过。
- [x] **Step 4a**：`flutter analyze` 4 条基线无新增；`flutter test` 179 项全绿。
- [ ] **Step 4b**：真机复验——列表→详情→退回→再进，反复多次不再闪白。

## 5. 风险与回滚（Risks）

- **风险**：布局若改动（内边距/间距/Card margin/列数），纯函数会与网格实际
  宽度脱钩，placeholder 命不中缓存 → 修复静默失效且无人察觉。
  **对策**：Step 2 的测试直接对真实网格断言，布局一改测试就红。
- **风险**：低清图放大显示会有一瞬间偏虚。这是刻意取舍（用户在两种方案中
  明确选了「不要空窗」）。
- **回滚方案**：改动集中在两个文件，revert 即可。

## 6. 备注 / 决策记录

- 排查中被**证伪**并因此没有采纳的三条假设，记下来避免重复走：
  - 「切轨导致封面重建过多」→ 多次 notify 同帧合并，实测只重建 1 次。
  - 「切轨导致封面重新解码」→ `CachedNetworkImage` 元素复用，`identical == true`。
  - 「封面 URL 逐轨变化」→ `coverUrl` 取 `work.mainCoverUrl`，作品级，同作品内不变。
- 真机第一轮探针为**无效数据**：日志里 12 次全是
  `NetworkErrorType.cancelled`（来自 `DetailViewModel.dispose` 的 `CancelToken`），
  播放事件 0 次，播放器页从未渲染 → 探针不可达。零打印不等于结论。
- 解码宽度不手推公式而由测试对真实网格断言，理由见上方风险项。

---

## ✅ 完成标记

- 完成时间：YYYY-MM-DD HH:mm
- 执行命令：`/init`
- CLAUDE.md 更新摘要：<待补>
- 关联 commit：<待补>
