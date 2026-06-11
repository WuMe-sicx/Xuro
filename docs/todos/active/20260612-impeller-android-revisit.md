# Flutter 3.44 升级落地后，重启 Impeller 在 Android Adreno 上的兼容性评估

- **创建时间**：2026-06-12
- **负责人**：（待分配）
- **状态**：active
- **关联**：
  - 前置：[`docs/todos/done/20260515-disable-impeller-android.md`](../done/20260515-disable-impeller-android.md)（应急止血，禁用 Impeller）
  - 前置：`docs/todos/active/20260515-upgrade-flutter-sdk.md`（SDK 升至 3.44.1）

---

## 1. 目标（Goal）

Flutter 3.27.0 → 3.44.1 升级合入主干后，重新评估能否在 Android 上启用 Impeller：删除 `android/app/src/main/AndroidManifest.xml` 里的 `io.flutter.embedding.android.EnableImpeller=false` meta-data，在 HyperOS 3 / Android 16 + Adreno 真机上跑 ≥ 30 分钟长会话，确认 `Vulkan: ErrorDeviceLost` → `SIGSEGV libvulkan.so` 是否仍出现。

## 2. 范围（Scope）

**包含：**
- `android/app/src/main/AndroidManifest.xml`：删除 `EnableImpeller=false` meta-data 进行验证。
- 真机长会话冒烟（≥ 30 min 持续播放 + 滚动）。
- 多设备覆盖：HyperOS 3 / Android 16 + Adreno 是首要目标；如有其他 Adreno < 640 / 早期型号设备亦同步测试。
- CLAUDE.md 渲染器章节同步更新（无论结论是切回 Impeller 还是继续禁用）。

**不包含：**
- iOS 端 Impeller 状态不变（默认开启、稳定，不在本任务范围）。
- 不重构现有动画或视觉效果（仅渲染后端切换）。

## 3. 验收标准（Acceptance）

- [ ] 真机长会话 ≥ 30 min 不出现 `Vulkan: ErrorDeviceLost` 或 `libvulkan` SIGSEGV。
- [ ] 关键场景（列表滚动、详情、播放、字幕、悬浮歌词）在 Impeller 下渲染无回归。
- [ ] 决策落地：
  - 若稳定 → 删除 manifest meta-data，CLAUDE.md 渲染器段更新为「Android 已切回 Impeller」。
  - 若仍崩 → 保留禁用，CLAUDE.md 渲染器段更新为「3.44.1 上 Adreno 仍崩，继续禁用」+ 再开 follow-up。

## 4. 拆解步骤（Steps）

- [ ] **Step 1**：在 SDK 升级合入主干后，本地分支 `chore/impeller-revisit-android`。
  - 涉及文件：`android/app/src/main/AndroidManifest.xml`
  - 验证：`fvm flutter build apk --debug` 通过。
- [ ] **Step 2**：装到真机跑长会话冒烟矩阵。
  - 验证：30 min 不崩；`adb logcat` 无 `ErrorDeviceLost` / `libvulkan` SIGSEGV。
- [ ] **Step 3**：根据结果决策（切回 / 保留禁用），更新 `CLAUDE.md` 渲染器段。
- [ ] **Step 4**：commit + `/init` + 归档。

## 5. 风险与回滚（Risks）

- **风险**：Flutter 3.44.1 调研显示 Adreno + Vulkan 长会话崩溃仍有 open issue（#176211 / #176528 / #160941），社区未公认修复。
  - 缓解：本任务的前提是「跑跑看再说」，不是「假定已修」；若仍崩立即 revert，与禁用方案不冲突。
- **回滚方案**：本任务的 manifest 改动是单条 meta-data，revert 一行即可。

## 6. 备注 / 决策记录

- 启动时机：等 SDK 升级 PR 合入 main、CI 全绿 ≥ 1 周后；不要与 SDK 升级揉成同一个 PR（变量太多，崩了不好定位是 SDK 还是 Impeller）。
- 若用户在 Skia 后端长期使用反馈良好、且 Adreno 兼容性 issue 在 3.45+ 才被官方修复，本任务可一直挂 active 等版本。

---

## ✅ 完成标记

- 完成时间：
- 执行命令：`/init`
- CLAUDE.md 更新摘要：
- 关联 commit：
