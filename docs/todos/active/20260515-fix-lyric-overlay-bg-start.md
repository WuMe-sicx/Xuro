# 修复悬浮歌词服务后台启动崩溃（BackgroundServiceStartNotAllowedException）

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：无（启动日志报错）

---

## 1. 目标（Goal）

> 修复应用冷启动时 `LyricOverlayService` 因 Android 12+ 后台启动限制抛出
> `BackgroundServiceStartNotAllowedException`，导致悬浮歌词绑定失败、功能静默失效的问题。

## 2. 范围（Scope）

**包含：**
- `android/.../lyric/LyricOverlayPlugin.kt`：移除 `initialize` 中冗余的
  `context.startService(serviceIntent)`，以及 `dispose` 中与之配对的
  `context.stopService(serviceIntent)`，仅保留 `bindService(BIND_AUTO_CREATE)`。
- 经 Codex 审查追加（均为「移除 started-service 后绑定成为唯一生命周期锚点」的
  直接后果，单文件内、各自完整）：
  - 新增 `isBound` 标记，记录 `bindService` 返回值；`dispose` 仅在 `isBound`
    时 `unbindService`，避免绑定失败 / 重复 dispose 抛 `IllegalArgumentException`。
  - `MainActivity`：`LyricOverlayPlugin(this)` → `LyricOverlayPlugin(applicationContext)`，
    使 overlay 服务生命周期与 Activity 解耦（Activity 重建不再影响绑定）。

**不包含：**
- 不改动 Dart 侧初始化时序（`service_locator` / `LyricOverlayManager`）。
- **冷启动状态恢复（`KEY_SHOWING`）不在本次修复**：Codex 指出 `bindService`
  异步，`initialize` 返回后 Dart 立即 `isShowing()`/`show()` 时 `service` 仍为
  `null`。仅给 `isShowing` 加 prefs 兜底无法让随后的 `show()` 生效（service 未
  连接 → no-op），属半成品。正确做法需 plugin 引入「待连接后回放 pending
  动作」或 `initialize` 等待 `onServiceConnected` 的重设计，独立成任务。
  注：该恢复在本次修复前已不可用（旧代码在 `startService` 即抛异常、
  `bindService` 从未执行），本次修复不构成回归。后续指向：
  `docs/todos/active/20260515-lyric-overlay-startup-restore.md`。
- 不把服务改造为前台服务（overlay 不需要，过度设计）。

## 3. 验收标准（Acceptance）

- [ ] 冷启动日志不再出现 `SERVICE_START_ERROR` / `BackgroundServiceStartNotAllowedException`。
- [ ] 进入播放器，长按歌词图标可正常显示/拖动悬浮歌词（绑定成功）。
- [ ] 上次显示状态（`KEY_SHOWING`）在重启后仍能恢复。
- [ ] `flutter analyze` 通过，无新增 warning（仅改 Kotlin，不影响 Dart 分析）。
- [ ] Codex 审查 PASS。

## 4. 拆解步骤（Steps）

- [ ] **Step 1**：移除 `LyricOverlayPlugin.onMethodCall` `"initialize"` 分支中的
  `context.startService(serviceIntent)`，保留 `bindService(... BIND_AUTO_CREATE)`。
  - 涉及文件：`android/app/src/main/kotlin/com/xuro/lyric/LyricOverlayPlugin.kt`
  - 验证：冷启动无后台启动异常。
- [ ] **Step 2**：移除 `"dispose"` 分支中配对的 `context.stopService(serviceIntent)`
  （清理本次改动产生的孤儿调用；bind-only 服务由 `unbindService` 负责销毁）。
  - 验证：退出/销毁悬浮窗后服务正常释放，无泄漏。
- [ ] **Step 3**：Codex 审查 diff。
  - 验证：PASS。

## 5. 风险与回滚（Risks）

- **风险**：若某设备上 `bindService(BIND_AUTO_CREATE)` 后台调用受限，服务可能延迟创建；
  但绑定自身服务不受 Android 12 后台启动限制，风险低。
- **回滚方案**：`git revert` 该 commit 即恢复 `startService`/`stopService`。

## 6. 备注 / 决策记录

> `LyricOverlayService` 为纯绑定服务（无 `startForeground`/通知，仅
> `WindowManager` overlay）。`startService()` 是该用法下唯一受 Android 12 后台
> 启动限制约束、且完全冗余的调用。`bindService(BIND_AUTO_CREATE)` 即可懒创建、
> 随绑定存活、随 `unbindService` 销毁，行为等价且不丢状态恢复能力。
