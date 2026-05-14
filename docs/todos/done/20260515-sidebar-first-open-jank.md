# 侧边栏首次打开 256ms 卡顿修复（删除多余 BackdropFilter）

- **创建时间**：2026-05-15
- **负责人**：claude
- **状态**：active
- **关联**：与 [`20260515-flutter-performance-optimization.md`](20260515-flutter-performance-optimization.md) 的 Phase 1（高频刷新降噪）相互独立，本任务针对真机 PerfDog 数据中观测到的具体单帧卡顿。

---

## 1. 目标（Goal）

消除「首次打开侧边栏一帧 256ms」的卡顿。该卡顿由 `sidebar_menu.dart` 中的 `BackdropFilter(blur 18)` 引起：首次绘制触发 Impeller offscreen layer 分配 + shader 编译，且**该模糊在视觉上对当前布局零贡献**——它下面的 `_DrawerBackground` 是完全不透明渐变。

## 2. 范围（Scope）

**包含：**
- `lib/widgets/sidebar/sidebar_menu.dart`：删除 `BackdropFilter` 与其包裹的 18% 黑色叠层；其余渐变背景、软光晕、右侧高光、半透明分组卡片、资料卡阴影一律保留。
- 视觉补偿：如删除后整体亮度偏亮（因为 18% 黑色 overlay 也一并去掉），**仅在必要时**把 `_DrawerBackground` 渐变首尾色加深一档（仍走 const，零运行时开销）。

**不包含：**
- 不动 `SidebarHeader` / `SidebarGroup` / `SidebarTile`。
- 不动抽屉宽度 / 圆角 / 屏幕断点。
- 不动深色 Theme 局部覆盖。
- 不引入预热、shader warmup、isolate 等复杂方案——它们对一个本来就该删除的视觉死层来说属于过度工程。

## 3. 验收标准（Acceptance）

- [ ] `BackdropFilter` 已从 `sidebar_menu.dart` 移除。
- [ ] 抽屉打开时视觉差异肉眼难以察觉（渐变 + 光晕 + 卡片仍在）。
- [ ] 用户在真机重录 PerfDog：首开侧边栏 Max FrameTime 应从 256ms 跌到 < 50ms 量级。
- [ ] `fvm flutter analyze lib/widgets/sidebar/` → `No issues found!`。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：删除 `Stack` 中的 `BackdropFilter` + 18% 黑色叠层；把 18% 压暗折算成 0.82 系数应用到 `_DrawerBackground` 渐变的三段颜色（`0x0E0B1F→0x0B0919`、`0x1A1136→0x150E2C`、`0x241445→0x1E1039`）。同时删掉 `dart:ui` 导入（ImageFilter 不再使用）。
- [x] **Step 2**：`fvm flutter analyze lib/widgets/sidebar/` → `No issues found!`。
- [ ] **Step 3**：用户真机重录 PerfDog（侧边栏首开场景，30s）→ 对比 Max FrameTime 与 UI/Raster 线程占用。

## 5. 风险与回滚（Risks）

- **风险**：删除后整体感觉偏亮 / 不够「玻璃」。
  - 缓解：渐变首尾色已偏深紫黑，半透明卡片仍提供层次。如确感不足，调整 `_DrawerBackground` 内 `LinearGradient` 的 stop 颜色，仍是 const，无运行时影响。
- **风险**：未来想加真正有效的模糊（例如让模糊作用于「滑出抽屉时主内容那一侧」），届时需重新设计。
  - 缓解：留 commit message 与本 TODO 作为决策记录。
- **回滚方案**：单文件 `git revert`。

## 6. 备注 / 决策记录

- **决策**：不做 shader warmup / `precacheImage` 类预热。理由：本质是「不该存在的视觉层」，删了就完事，预热是给真有用的特效用的。
- **数据依据**：`/Users/xiaoxuya/Downloads/Xuro 2026-05-15 06-32-56.csv` 第 14 行：FPS=89, JANK=1, BigJANK=1, Max FrameTime=256.00ms, GPU=84%。结合用户口头确认「256ms 帧里是侧边栏」。

---

## ✅ 完成标记

- 完成时间：2026-05-15
- 执行命令：`/init`
- CLAUDE.md 更新摘要：在 `widgets/sidebar/` 段落增加「不要给 drawer 加全屏 BackdropFilter」的反踩坑注记 + 数据来源引用。
- 关联 commit：（待提交）
- Codex 复审：SESSION_ID `019e2873-2990-72e2-bc68-ba47328971b7`，三轮 ⚠️→⚠️→✅ PASS。
- 运行时验收（Step 3）：仍待用户在真机重录 PerfDog 对比 Max FrameTime。

## 7. 复审 / Review

- **Round 1**（⚠️ OPTIMIZE）：注释「same final pixel values」对 `_SoftGlow` 不严格成立——18% 黑色 overlay 同时压暗了 glow，而我只压暗了渐变 → 修。
- **Round 2**（⚠️ OPTIMIZE）：把 0.82 缩到 alpha 不等价于「最终合成结果 × 0.82」（前者改变了 source-over blend 的混合权重，后者是均匀压暗）。正确做法是缩 glow 的 RGB 通道、保持 alpha 不变。数学：`final = 0.82*(glow.rgb*α + bg*(1-α))` 当且仅当 bg 已预先 *0.82 时。
- **Round 3**（✅ PASS）：RGB 缩放 + alpha 保留 + 渐变预压暗，三者组合严格满足上述等式。`dart:ui` 已删，BackdropFilter / ImageFilter 在源代码中均无残留。
