# 修复：API 把视频错标 type=audio 导致点击播放失败

- **创建时间**：2026-05-16
- **负责人**：WuMe-sicx
- **状态**：active
- **关联 Issue / PR**：feature/perf-and-local-media-download

---

## 1. 目标（Goal）

asmr.one API 对某些视频（如"介绍视频.mp4"）下发 `type: "audio"`。当前
`isAudioFile` 只看 `type=='audio'`，导致这类 mp4 被当音频送进播放管线，
播放列表按扩展名过滤后为空 → `PlaybackContext.validate` 抛"播放列表为空"
→ 点击只报"播放失败"，既不能播也不能下。改为**已知视频扩展名优先于不
可靠的 API `type` 字段**，让这类文件走"下载到本地用外部播放器"的既有视频
流程。

## 2. 范围（Scope）

**包含：**
- `DetailViewModel`：抽出静态 `_hasVideoExtension`；`isAudioFile` 排除视频
  扩展名；`collectAudioWithSubtitles` 同步排除（批量不把视频当音频）；
  `playFile` 守卫改用 `isAudioFile`（防御性，给清晰错误而非空列表）。
- `WorkFileItem`：视频扩展名优先 → 错标 mp4 显示视频图标、走视频下载流程。
- `detail_screen` onFileTap：视频判断前置于音频判断（路由稳健）。
- 单测：错标 `intro.mp4 (type=audio)` 不被 `collectAudioWithSubtitles` 收为音频。

**不包含：**
- 不改播放管线 / `PlaybackContext` / playlist_builder（根因在分类与路由）。
- 不改 API 解析（`type` 字段保留，仅在分类时让扩展名优先）。
- 不处理"无扩展名但实为视频"等 API 无法判别的极端情形。

## 3. 验收标准（Acceptance）

- [ ] 点击被错标 type=audio 的 `.mp4` → 走视频"下载到本地播放"确认弹窗，
      不再出现"播放列表为空 / 播放失败"。
- [ ] 正常音频（mp3/flac…type=audio）行为不变，仍正常播放。
- [ ] 真实视频（type=video 或视频扩展名）行为不变。
- [ ] 批量"下载全部"不再把视频文件当音频收集。
- [ ] `fvm flutter analyze` 通过；新增单测通过；`fvm flutter test` 全过。
- [ ] Codex 审查通过。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：`DetailViewModel` 分类修复（静态 `_hasVideoExtension` +
      `_isAudioChild`/`isAudioFile`/`collectAudioWithSubtitles`/`playFile` 守卫）+ 单测
- [x] **Step 2**：`WorkFileItem` 视频扩展名优先（`isAudio=_isAudio&&!isVideo`，图标/可点/路由一致）
- [x] **Step 3**：`detail_screen` onFileTap 视频判断前置于音频
- [x] **Step 4**：`flutter analyze` 无问题；`flutter test` 全量 51 项全过；Codex ✅ PASS
- [x] **Step 5**：`/init` 刷新 CLAUDE.md（`download/` 条目新增"扩展名优先于 API
      type"分类不变量），归档 done/

## 7. 复审 / Review

- **Round 6**（✅ PASS，可直接合入）：Codex 只读核验——根因闭合（错标 `.mp4`
  不再进音频管线、改走下载+外部播放），真实音频(type=audio,非视频扩展名)/
  真实视频(type=video 或视频扩展名)均不回归；`_hasVideoExtension` 边界
  （多点名/大小写/`m4a` 不误判）正确；VM 分类、`WorkFileItem` 图标&可点、
  screen 路由三处一致；全局无残留"按 type==audio 直判进播放/批量"路径；
  `playFile` 守卫不改变合法音频错误语义。SESSION `019e2ce9-...`。

---

## ✅ 完成标记

- 完成时间：2026-05-16
- 执行命令：`/init`（直接刷新 `download/` 条目，新增文件分类不变量段）
- CLAUDE.md 更新摘要：`lib/core/download/` 条目新增"文件类型分类——扩展名
  优先于不可靠 API `type`"：asmr.one 把视频错标 audio 会致空播放列表，已知
  视频扩展名一律按视频走下载+外部播放；`isAudioFile`/`_isAudioChild` 为唯一
  入口，`detail_screen` 先判 `isVideoFile`。
- 关联 commit：（待提交）
- Codex 复审：SESSION_ID `019e2ce9-97ab-7e01-98fb-8a2c3bb3ea63`，Round 6 ✅ PASS。
- 运行时验收（待用户真机）：点击被错标 type=audio 的 `.mp4` → 出现视频
  "下载到本地播放"确认弹窗、可下载并外部打开，不再"播放失败/播放列表为空"；
  正常音频、真实视频行为不变。

## 5. 风险与回滚（Risks）

- **风险**：把合法音频误判为视频。缓解：仅当扩展名属已知视频集
  `{mp4,mkv,mov,avi,webm,m4v}`（不含 m4a 等音频）才视为视频；音频扩展名
  不在该集内，不受影响。
- **回滚**：单点逻辑改动，可单文件 revert，不涉及数据/持久化。

## 6. 备注 / 决策记录

- 决策：扩展名是比 API `type` 更可靠的视频判据（API 实测会把介绍视频标
  audio）。仅"视频扩展名优先"，未反向用扩展名覆盖音频判断（避免过度收紧）。
