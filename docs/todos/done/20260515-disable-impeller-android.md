# Android 上禁用 Impeller，回退到 Skia 渲染器

- **创建时间**：2026-05-15
- **负责人**：claude
- **状态**：active
- **关联**：与 [`20260515-upgrade-flutter-sdk.md`](20260515-upgrade-flutter-sdk.md) 是配套——本任务为应急止血，SDK 升级是后续根治。

---

## 1. 目标（Goal）

止血 Adreno + Vulkan + Impeller 在小米 HyperOS 3 / Android 16 真机上的 `ErrorDeviceLost` → `SIGSEGV in CmdEndRenderPass+4` 长会话型崩溃。通过 AndroidManifest meta-data 在构建产物中关闭 Impeller，让 Flutter 回退到 Skia 渲染器，绕开 Vulkan 路径上的驱动 bug。

## 2. 范围（Scope）

**包含：**
- `android/app/src/main/AndroidManifest.xml`：`<application>` 节点下新增
  ```xml
  <meta-data
      android:name="io.flutter.embedding.android.EnableImpeller"
      android:value="false" />
  ```
- 在 manifest 注释中标注「为何禁用」+ 关联 issue / 数据 / TODO 路径。

**不包含：**
- 不动 `profile/AndroidManifest.xml`、`debug/AndroidManifest.xml`（这两个是 Flutter 工具自动合并的 stub，配置写在 main 即可继承）。
- 不改 iOS（iOS 上 Impeller 默认开启且稳定，不动）。
- 不升级 Flutter SDK（另起 [`20260515-upgrade-flutter-sdk.md`](20260515-upgrade-flutter-sdk.md)）。
- 不改 Dart 代码——本次纯 build 配置。

## 3. 验收标准（Acceptance）

- [ ] `android/app/src/main/AndroidManifest.xml` 新增 `EnableImpeller=false` meta-data。
- [ ] `fvm flutter build apk --debug` 或 `fvm flutter run` 启动时日志包含 `Using the Skia backend` / `Impeller is disabled`（或不出现 `Vulkan` 相关启动日志）。
- [ ] 真机重跑长会话（10+ 分钟，含侧边栏开关 / 列表滚动 / 播放器切歌）—— `1.raster` 线程不再触发 `ErrorDeviceLost` SIGSEGV。
- [ ] 视觉无明显回归（Skia ↔ Impeller 在阴影、模糊、渐变细节上偶有差异，但本项目已无 BackdropFilter，差异面应很小）。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：在 `AndroidManifest.xml` `<application>` 节点添加 `EnableImpeller=false` meta-data + 详细注释。
- [x] **Step 2**：`fvm flutter analyze` 仅返回 33 条预存 `withOpacity` deprecation；`xmllint --noout` 返回 MANIFEST_OK。
- [ ] **Step 3**：用户真机重装并跑长会话（10+ 分钟）验证 `1.raster` 线程不再触发 `ErrorDeviceLost` SIGSEGV。

## 5. 风险与回滚（Risks）

- **风险 1**：Skia 在 Adreno 上首帧 shader 编译可能引入新的小卡顿（理论上几十 ms 量级，远低于 256ms 级别的 Vulkan 崩溃成本）。
  - 缓解：项目已经清理了 BackdropFilter 等首帧爆发源，shader pre-cache 在 release 构建里有缺省覆盖。
- **风险 2**：未来某些用 Impeller 专属优化的第三方包行为变化（本项目目前未观察到）。
  - 缓解：Skia 是 Flutter 长期主路径，第三方生态默认兼容。
- **回滚方案**：删除 manifest 里那段 meta-data 即可恢复 Impeller。一行 git revert。
- **长期方案**：[`20260515-upgrade-flutter-sdk.md`](20260515-upgrade-flutter-sdk.md) 升级到更新版 Flutter（Impeller-on-Android 在 3.29+ 修了大量 Adreno 兼容问题），届时可考虑切回 Impeller 验证。

## 6. 备注 / 决策记录

- **崩溃数据**：用户提供的真机日志，进程 uptime 820s，崩溃栈 `libvulkan.so::CmdEndRenderPass+4` → `libflutter.so` Impeller raster 路径，零 Dart 帧。
- **设备**：小米 houji（OS3.0.302.0.WNCCNXM / Android 16）+ Adreno GPU。
- **Flutter 版本**：3.27.0（FVM-pinned）——Impeller-on-Android 在该版本仍有多个 open issue。
- **决策依据**：方案 C「不改」=不可接受（用户大概率反复触发）；方案 B「升 SDK」=大动作另起 TODO；方案 A「禁 Impeller」=一行配置，立即止血。

---

## ✅ 完成标记

- 完成时间：2026-05-15
- 执行命令：`/init`
- CLAUDE.md 更新摘要：在「Build & Development Commands」附近增加注记——Android 构建强制使用 Skia 渲染器（Impeller 因 Adreno + HyperOS 3 上 ErrorDeviceLost 长会话崩溃而禁用），并指向 follow-up TODO。
- 关联 commit：（待提交）
- Codex 复审：SESSION_ID `019e2873-2990-72e2-bc68-ba47328971b7`，一轮 ✅ PASS（Codex 还直接对照本地 Flutter 3.27.0 源码确认了 `io.flutter.embedding.android.EnableImpeller=false` key/value 正确，且 main manifest 自动合并到 debug/profile，无需重复写）。
- 运行时验收（Step 3）：仍待用户真机重装验证。
