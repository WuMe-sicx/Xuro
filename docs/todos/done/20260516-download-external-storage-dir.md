# 下载落盘改到外部应用专属目录 Android/data/<pkg>/

- **创建时间**：2026-05-16
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：feature/perf-and-local-media-download

---

## 1. 目标（Goal）

把音频 / 视频 / 字幕的本地下载落盘位置从 App 内部私有目录
`getApplicationDocumentsDirectory()`（`/data/user/0/com.xuro/app_flutter/...`，
非 root 无法在文件管理器 / 其他 App 中访问）改为 **Android 外部应用专属目录**
`getExternalStorageDirectory()`（`/storage/emulated/0/Android/data/com.xuro/files/...`）。
该目录在任何 Android 版本均**无需声明存储权限**，且可经 USB/MTP 在电脑端访问。

## 2. 范围（Scope）

**包含：**
- 仅修改 `DownloadService._workDir`：Android 走 `getExternalStorageDirectory()`，
  返回 null 时回退 `getApplicationDocumentsDirectory()`；非 Android 平台维持原行为
  （`getExternalStorageDirectory()` 在 iOS 会抛 `UnsupportedError`）。
- 同步更新类文档注释（落盘位置 + “无需存储权限”理由）。

**不包含：**
- 不迁移已有内部目录下的旧下载（DB 存绝对路径，旧文件原地仍可被
  `findCompleted` 命中并离线播放，无害；新下载落到外部目录）。
- 不引入任何存储权限、不接 MediaStore（外部应用专属目录均不需要）。
- 不改 repository / DownloadEntry / 离线播放查找逻辑（均依赖 DB 绝对路径）。

## 3. 验收标准（Acceptance）

- [x] Android 新下载落到 `/storage/emulated/0/Android/data/com.xuro/files/downloads/<workId>/`。
- [x] 旧的内部目录下载仍能离线播放（DB 绝对路径命中，不回归——Codex 已确认）。
- [x] iOS / 桌面平台不调用 `getExternalStorageDirectory()`，行为不变。
- [x] `fvm flutter analyze lib/core/download/` 通过，无新增 warning。
- [x] 现有 `test/core/download/download_service_test.dart`（sanitize/fileKey/diskFileName）9 项全过。
- [x] Codex 审查：⚠️ OPTIMIZE（可合入），已按建议修正 `download()` 方法注释。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：改 `lib/core/download/download_service.dart` 的 `_workDir`
  - 涉及文件：`lib/core/download/download_service.dart`
  - 验证：`flutter analyze lib/core/download/` 无问题；真机下载验证落在 `Android/data/...`（待用户真机确认）
- [x] **Step 2**：更新类文档注释（类文档 + `download()` 方法注释）
  - 验证：注释与实际落盘位置一致
- [x] **Step 3**：Codex 审查改动
  - 验证：⚠️ OPTIMIZE（可合入），已按建议修正方法注释

## 5. 风险与回滚（Risks）

- **风险**：外部应用专属目录与 App 内部目录不在同一卷时，原子写 `tmp.rename(destPath)`
  仍成立（tmp/dest 都在 `_workDir` 同目录下，同卷），无跨卷 rename 隐患。
- **风险**：旧的内部目录下载与新外部目录下载并存，DB 绝对路径各自命中——
  Codex 已确认 `findCompleted` / `localPathIfDownloaded` / `enforceCapacity` 均按
  DB 绝对路径工作，不回归、不重复下载。
- **回滚方案**：单文件 `git revert`（仅 `download_service.dart` 一处逻辑改动）；
  回滚后新下载回到内部目录，已落到外部目录的旧下载因 DB 存绝对路径仍可命中播放。

## 6. 备注 / 决策记录

- **决策**：不迁移已有内部目录下载。理由：DB 存绝对路径，旧文件原地仍被命中、
  离线播放不回归，迁移属无收益的额外风险。
- **决策**：用 `getExternalStorageDirectory()`（外部应用专属目录）而非公共
  `Music/`+MediaStore。理由：前者所有 Android 版本免权限、规避 scoped storage、
  卸载自清理，且已满足"电脑可见"诉求；后者需权限 + MediaStore + SAF 适配，成本不成比例。
- **范围澄清**：用户手动导入字幕（`SubtitleImportService` → `user_subtitles/`）
  是独立流程，不在本次"下载"范围内，仍在内部目录。

---

## ✅ 完成标记

- 完成时间：2026-05-16
- 执行命令：`/init`
- CLAUDE.md 更新摘要：更新 `lib/core/download/` 段落，说明落盘位置改为 Android
  外部应用专属目录（免权限、电脑可见）+ 非 Android 回退内部目录的不变量。
- 关联 commit：（待提交）
- Codex 复审：SESSION_ID `019e2ce9-97ab-7e01-98fb-8a2c3bb3ea63`，⚠️ OPTIMIZE → 已按建议修正方法注释。
- 运行时验收（Step 1）：仍待用户在真机下载一条音频，确认路径落在 `/storage/emulated/0/Android/data/com.xuro/files/downloads/...`。

## 7. 复审 / Review

- **Round 1**（⚠️ OPTIMIZE，可合入）：核心行为经 Codex 只读核验无回归——
  旧下载不丢（`findCompleted` 按 DB 绝对路径校验）、离线播放不回归
  （`PlaylistBuilder` 用 DB 绝对路径构造 `Uri.file()`）、LRU 仍走全表
  `listAllOldestFirst()` 而非扫某根目录、Android-only 降级回退合理。
  唯一建议：`download()` 方法注释「下载到 App 私有目录」过时 → 已改为
  「下载到本地下载目录（Android 为外部应用专属目录）」。`flutter analyze` 复测通过。
