# 悬浮歌词冷启动状态恢复（异步绑定 race 重设计）

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：派生自 `docs/todos/active/20260515-fix-lyric-overlay-bg-start.md`

---

## 1. 目标（Goal）

> 让「上次会话开启了悬浮歌词」的状态在 App 冷启动后能真正自动恢复显示。

## 2. 范围（Scope）

**包含：**
- `LyricOverlayPlugin.kt`：解决 `bindService` 异步导致的 race —— `initialize`
  返回后 Dart 立即调用 `isShowing()` / `show()` 时 `service` 仍为 `null`。
- 方案二选一：
  - A. `initialize` 等到 `onServiceConnected` 后再 `result.success`；或
  - B. plugin 维护 pending 动作（pendingShow / pendingText），`onServiceConnected`
    时回放；`isShowing` 在 `service==null` 时回退读 `LyricOverlayService`
    的 SharedPrefs（`PREFS_NAME` / `KEY_SHOWING` 需从 `private const` 暴露为
    共享常量，保持单一数据源，勿在两文件重复字面量）。

**不包含：**
- 后台启动崩溃修复（已在 `20260515-fix-lyric-overlay-bg-start.md` 完成）。

## 3. 验收标准（Acceptance）

- [ ] 上次显示悬浮歌词 → 杀进程冷启动 → 悬浮歌词自动重新出现且能拖动。
- [ ] `isShowing()` 在 `service` 未连接时返回与持久化一致的值。
- [ ] 无新增后台启动异常；`flutter analyze` 通过。
- [ ] Codex 审查 PASS。

## 4. 拆解步骤（Steps）

- [ ] **Step 1**：选定方案 A / B（B 更稳，A 更简），记录决策。
- [ ] **Step 2**：实现 plugin 侧改动。
- [ ] **Step 3**：真机验证冷启动恢复。
- [ ] **Step 4**：Codex 审查。

## 5. 风险与回滚（Risks）

- **风险**：方案 A 阻塞 `initialize` 可能拖慢启动；方案 B 增加 plugin 状态机复杂度。
- **回滚方案**：`git revert`；不影响已落地的崩溃修复。

## 6. 备注 / 决策记录

> 拆分自崩溃修复任务：仅给 `isShowing` 加 prefs 兜底无法让随后的 `show()`
> 生效（service 未连接 → no-op），属半成品，故独立重设计为本任务。
