# 抽出「文件种类」module——把散落在 ~20 处的分类规则收成一处

- **创建时间**：2026-08-13
- **负责人**：Elvis Juan (thanhtran0606en@gmail.com)
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：架构评审候选 A（`/improve-codebase-architecture` 报告，top recommendation）

---

## 1. 目标（Goal）

「这是什么文件」这条规则目前没有 module，只有约 20 份彼此不同的手写副本。把它收进一个 module，让新增一种格式只需改一处，并消除副本之间已经发生的分歧。

## 2. 范围（Scope）

**包含（阶段一：分类归位，零行为变更）：**
- 新建文件种类判定 module，纯数据入参、无 DI、可直接单测
- 归位「是音频 / 是视频 / 是字幕 / 是文件夹」的所有判定点
- 消除 `_videoExtensions`、`_subtitleExtensions` 的逐字重复副本
- 统一字幕格式的四套定义（`{vtt,lrc,srt,txt}` / `{vtt,lrc}` ×3 / 内容嗅探）
- 统一 `'folder'` 判定的大小写敏感差异

**包含（阶段二：可播格式闸门，有行为变更）：**
- `playback_context.dart:82` 的 `mp3 || wav` 硬闸门改为跟随统一的可播格式表
- 修复 `.flac/.opus/.m4a/.aac` 「设置里承诺、详情页可点、播放时报播放列表为空」

**不包含：**
- 架构评审的其余候选（B 播放列表 seam、C ApiService、D 登录态不变量、E 分页 seam、F 原子落盘、G 字幕三连）——各自独立成票
- 播放管线、DI、事件流的任何改动
- 新增音频格式的**解码**支持（just_audio 能不能放是另一回事，本任务只负责「不要在能放的时候拦下来」）

## 3. 验收标准（Acceptance）

- [ ] 全库 grep 不到第二份 `{'mp4','mkv','mov','avi','webm','m4v'}` 或 `{'vtt','lrc','srt','txt'}` 字面量
- [ ] 新 module 有单测，覆盖：扩展名压过 API `type`、大小写、无扩展名、`title == null`、四套字幕定义合并后的边界
- [ ] `fvm flutter analyze` 保持 **No issues found**
- [ ] `fvm flutter test` 全绿，且既有断言全部保留——特别是 `detail_viewmodel_collect_test.dart` 里「`.mp4` 被 API 错标成 `type:audio` 时不得收进音频」这条
- [ ] 阶段一提交后手动回归：详情页文件树的图标/可点性/下载按钮与改动前逐项一致
- [ ] 阶段二提交后手动回归：`.flac` 作品可以正常播放，不再报「播放失败」

## 4. 拆解步骤（Steps）

- [ ] **Step 1**：产出全部判定点的核验清单（子代理 inventory）
  - 验证：每个 `file:line` 能对上，且按目录分成互不冲突的编辑集
- [ ] **Step 2**：写新 module + 单测（先测后码）
  - 验证：单测通过，且断言的是规则本身而非某个调用点
- [ ] **Step 3**：按互不冲突的编辑集并行迁移调用点（子代理）
  - 涉及文件：`lib/presentation/viewmodels/`、`lib/widgets/detail/`、`lib/screens/`、`lib/core/subtitle/`
  - 验证：`analyze` 归零 + `test` 全绿 + 详情页手动回归
- [ ] **Step 4**（阶段二，需先拍板）：可播格式闸门
  - 涉及文件：`lib/core/audio/models/playback_context.dart`、`file_path.dart`
  - 验证：`.flac` 作品可播

## 5. 风险与回滚（Risks）

- **风险**：判定点漏改一个，症状是运行时才出现（图标错、文件不可点、或最坏——回到「播放列表为空」）。缓解：Step 1 的清单必须核验到 `file:line`，Step 3 后做详情页逐项手动回归。
- **风险（阶段二）**：放开可播格式后，just_audio 在某些设备上解不了 `.opus`/`.aac`，失败点从「点不动」变成「播放中途报错」。这是**换了一种失败**，不是消除失败——需要确认错误路径可接受。
- **回滚方案**：阶段一、阶段二分别独立 commit，`git revert` 即可。

## 6. 备注 / 决策记录

- 本任务基于 `chore/dead-code-sweep`（PR #9）分出，该分支已删除约 2900 行死代码。PR #9 合入前不要合本分支。
- **阶段二有一个待拍板的产品决策**：`_getPlaylistFromSameDirectory` 现在只把**同扩展名**的同级文件收进播放列表。放开格式后，一个混装 mp3 + flac 的目录应该组成一个播放列表，还是两个？这会改变用户可见的「下一曲」行为，不由本任务单方面决定。
