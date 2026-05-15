# 下载重构：文件夹批量下载 + 音频字幕配对 + 字幕预览

- **创建时间**：2026-05-16
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：feature/perf-and-local-media-download

---

## 1. 目标（Goal）

下载功能从"只能逐个点文件"重构为：①文件夹/整部"下载全部"；②下载音频自动
带匹配字幕、离线播放优先用已下载字幕；③文件树里点字幕文件可只读时间轴预览。
解决用户反馈的"单独下载很繁琐 + 字幕不能一起下 + 字幕无法预览"。

## 2. 范围（Scope）

**包含：**
- `DetailViewModel`：递归收集子树下 (音频, 匹配字幕?) 对；`downloadFolder` 顺序
  批量下载（聚合进度 + 取消）；单文件 `downloadFile` 改为"音频+匹配字幕"。
- UI：`WorkFilesList` 头部加"下载全部(整部)"按钮；`WorkFolderItem` 标题行加
  文件夹"下载全部"按钮；新增 `BatchDownloadDialog`（确认→聚合进度→结果汇总）。
- 离线字幕：`PlayerViewModel._loadSubtitleIfAvailable` 自动匹配那一档，若该字幕
  `Child` 已下载到本地则读本地文件，否则维持原 URL 加载。
- 字幕预览：`WorkFileItem` 让 .vtt/.lrc/.srt/.txt 可点；新增
  `SubtitlePreviewScreen`（已下载读本地、否则拉 `mediaDownloadUrl`，解析后按
  时间轴只读列出；不可解析则显示原始文本）。
- `strings.dart` 新增相关文案（无硬编码）。

**不包含：**
- 不做多选模式（用户已选"文件夹/整部按钮"方案）。
- 不做并发下载（顺序，复用现有原子写/LRU 不变量）。
- 不改 `DownloadService` 落盘/`fileKey`/原子写逻辑（上一 TODO 已闭环）。
- 字幕预览不提供"设为某音频字幕"（用户选只读预览）。
- 不接 MediaStore、不引入存储权限。

## 3. 验收标准（Acceptance）

- [ ] 文件夹行有"下载全部"按钮，点击顺序下载该子树下所有音频（含匹配字幕），
      显示 `i/N + 文件名 + 进度`，可取消，结束有成功/跳过/失败汇总。
- [ ] 文件列表头部"下载全部"对整部作品同样生效。
- [ ] 单个音频下载按钮：音频下完后其匹配字幕也被下载（字幕失败不影响音频结果）。
- [ ] 离线（断网/VPN 关）播放已下载音频时，若其字幕已下载，字幕正常显示。
- [ ] 文件树点 .vtt/.lrc/.srt/.txt → 打开只读预览，按时间轴列出；解析失败显示原文。
- [ ] 已下载的字幕预览不依赖网络。
- [ ] `fvm flutter analyze` 通过，无新增 warning。
- [ ] 新增纯逻辑（递归收集音频+配对、字幕本地优先选择）有单测。
- [ ] Codex 审查通过。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：`strings.dart` 新增批量/预览文案（含 3 个动态 `static String`）
- [x] **Step 2**：`DetailViewModel` 纯静态 `collectAudioWithSubtitles` + `downloadFolder`
  + `downloadFile` 配对 + 单测 3 例（嵌套展平/同级配对/跨目录不配对）
- [x] **Step 3**：`BatchDownloadDialog` + `onFolderDownload` 线缆（列表头"下载全部" +
  文件夹标题行 IconButton）+ `detail_screen.runBatch` + 结果 snackbar
- [x] **Step 4**：`downloadFile` 改 async，音频下完 best-effort 下匹配字幕
- [x] **Step 5**：`PlayerViewModel._loadSubtitleIfAvailable` 优先级
  用户导入 > 已下载本地 > 在线 URL（保留 `_loadVersion` 守卫）
- [x] **Step 6**：`SubtitlePreviewScreen` + `WorkFileItem` 字幕可点 + screen 路由 +
  `SubtitleLoader.loadRawContent`/`parseOrNull`
- [x] **Step 7**：`flutter analyze` 仅剩 unrelated 既有 withOpacity；`flutter test`
  全量 50 项全过；Codex 审查 ❌→✅ PASS
- [x] **Step 8**：`/init` 刷新 CLAUDE.md（`download/` 条目扩充批量/配对/离线/预览
  不变量），归档 done/

## 8. 复审 / Review

- **Round 4**（❌ CHANGE）：3 个 medium——①`downloadFolder` 末项音频在字幕
  best-effort 阶段被取消时漏标 `cancelled`（误报"完成"）②`parseOrNull` 解析
  抛错冒泡到预览页误报"加载失败"，未原文兜底 ③`BatchDownloadDialog` 无
  `dispose` 兜底、页面被程序化移除时批量仍后台写盘。
- **Round 5**（✅ PASS）：①捕获字幕 `sr`，cancelled 即 break + 每轮尾兜底取消
  检查；②`parseOrNull` 全包 try/catch 返回 null；③`dialog.dispose()` cancel
  token（确认阶段 null 安全、重复取消无害、token 驱动循环顶/尾+dio 取消）。
  确认用户导入优先级/找不到清字幕语义未变，best-effort 不污染音频结果。

---

## ✅ 完成标记

- 完成时间：2026-05-16
- 执行命令：`/init`（直接刷新 `download/` 条目，含批量/配对/离线/预览不变量）
- CLAUDE.md 更新摘要：`lib/core/download/` 条目扩充——`DetailViewModel` 纯静态
  收集+配对、顺序批量+取消传播、单文件配对、`PlayerViewModel` 离线字幕优先级
  （导入>已下载本地>在线）、`SubtitlePreviewScreen`/`parseOrNull` 原文兜底。
- 关联 commit：（待提交）
- Codex 复审：SESSION_ID `019e2ce9-97ab-7e01-98fb-8a2c3bb3ea63`，Round 4 ❌ →
  Round 5 ✅ PASS。
- 运行时验收（待用户真机）：①文件夹/整部"下载全部"顺序下载+取消+汇总；
  ②单音频下载后其字幕也在；③断网播放已下载音频字幕正常；④点 .vtt/.lrc/
  .srt/.txt 打开只读时间轴预览、不支持格式显原文。

## 5. 风险与回滚（Risks）

- **风险**：批量下载长任务期间 ViewModel dispose（用户退出详情页）。
  缓解：批量走独立 CancelToken，dispose 时取消；进度回调走 `_disposed` 守卫。
- **风险**：离线字幕新增"本地优先"档可能与用户导入档优先级冲突。
  缓解：保持「用户导入 > 已下载本地 > 在线 URL」顺序，不动导入档逻辑。
- **风险**：.srt/.txt 解析器可能不支持。缓解：解析失败回退显示原始文本，不报错。
- **回滚**：UI 按钮 + 新增 dialog/screen 可单独 revert；离线字幕档为加法、
  revert 不影响既有在线/导入路径。

## 6. 备注 / 决策记录

- 决策（用户确认）：文件夹+整部按钮方案，非多选；字幕只读时间轴预览；
  下载音频自动带匹配字幕 + 离线优先用已下载字幕。
- 复用：`FilePath.getSiblings` + `SubtitleMatcher.findMatchingSubtitle` 做配对；
  `SubtitleParserFactory` 做预览解析；`DownloadService.download` 幂等去重。
