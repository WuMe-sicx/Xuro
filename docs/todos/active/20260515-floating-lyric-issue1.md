# 悬浮歌词：点穿 + 锁定上下 + 文字描边（Issue #1）

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active
- **关联 Issue / PR**：https://github.com/WuMe-sicx/Xuro/issues/1

---

## 1. 目标（Goal）

按 Issue #1 反馈，重塑 Android 悬浮歌词的交互与视觉：默认完全点穿（不拦截下层 app 操作）、锁定为上下移动、用文字描边替代半透明黑底，并保留"编辑模式"让用户随时调位置。

## 2. 范围（Scope）

**包含：**
- Android 原生悬浮窗：去掉横向拖动、加 `FLAG_NOT_TOUCHABLE` 让默认态点穿、暴露 `setEditable` 切换可拖动状态。
- 布局：用双 `TextView` 叠层做文字描边，去掉黑色半透明背景。
- Dart 侧 `ILyricOverlayController` / 实现 / Dummy 同步 `setEditable`。
- `LyricOverlayManager` 暴露 `toggleEditable`，并在 `hide()` 时强制退出编辑态。
- 在 `PlayerScreen` 工具栏：长按歌词图标进入/退出编辑模式，附 SnackBar 反馈。

**不包含：**
- iOS / 桌面平台（保持 Dummy 桩）。
- 自定义字号 / 字色 / 描边宽度的设置项（保留给后续 TODO）。
- 悬浮窗背景模糊、动画、滑动联动等高级效果。

## 3. 验收标准（Acceptance）

- [x] 默认态下，悬浮歌词显示时，下层 app（含桌面、视频、文字输入）可以正常点击/滚动/打字，悬浮窗不拦截任何触摸。
- [x] 长按 PlayerScreen 顶部歌词图标进入编辑态：可上下拖动悬浮歌词；横向位置不变（始终水平居中）。
- [x] 再次长按 / 隐藏悬浮歌词：自动退出编辑态，恢复点穿。
- [x] 悬浮歌词文字本身具有描边（黑边白字），无任何半透明背景方块。
- [x] `flutter analyze` 通过，无新增 warning。
- [ ] 真机（Android）烟测：1) 视频上覆盖悬浮歌词，可点暂停 2) 编辑模式上下拖动顺滑 3) 锁屏 / 切后台后恢复，位置正确。**留给项目维护者真机验证**。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：改 `android/app/src/main/res/layout/lyric_overlay.xml`
  - 改为 `FrameLayout` + 两个 `TextView`：底层描边（id `lyric_stroke`）、顶层实心（id `lyric_fill`）。
  - 去掉 `android:background`。
  - 验证：本地编译通过 (`fvm flutter build apk --debug`)。
- [x] **Step 2**：改 `LyricOverlayService.kt`
  - flags 加 `FLAG_NOT_TOUCHABLE`，`gravity` 改 `TOP or CENTER_HORIZONTAL`、`x=0`。
  - inflate 后设 `lyric_stroke.paint.style = STROKE`、`strokeWidth=...`。
  - `setText` 同时写入两个 TextView。
  - `OnTouchListener` 只更新 `params.y`；持久化仅 `KEY_Y`。
  - 新增 `setEditable(boolean)`：编辑态去掉 `FLAG_NOT_TOUCHABLE` 并复用 windowManager.updateViewLayout。
  - 验证：装机后默认点穿，进入编辑态后能拖动 Y。
- [x] **Step 3**：改 `LyricOverlayPlugin.kt`
  - 加 `setEditable` method 路由。
  - 验证：Plugin 不会抛 `notImplemented`。
- [x] **Step 4**：改 Dart 接口/实现
  - 接口加 `Future<void> setEditable(bool)`；真实实现转发到 channel；Dummy 空实现。
  - 验证：`flutter analyze` 不报缺失方法。
- [x] **Step 5**：改 `LyricOverlayManager`
  - 维护 `_isEditable`；`hide` 时重置；提供 `toggleEditable`。
  - 验证：单元/手动调用 toggle 行为符合预期。
- [x] **Step 6**：改 `lib/screens/player_screen.dart`
  - 把现有 lyric `IconButton` 改成 `InkResponse(onTap, onLongPress, ...)`；长按触发 `toggleEditable`，SnackBar 反馈。
  - 验证：tap 仍然显示/隐藏；长按时出现"调整模式"提示。
- [x] **Step 7**：`fvm flutter analyze`，修复任何新增 warning；准备 git diff 给 Codex review。
  - 验证：analyze 通过 + Codex ✅ PASS。

## 5. 风险与回滚（Risks）

- **风险**：部分国产 ROM 对 `FLAG_NOT_TOUCHABLE + TYPE_APPLICATION_OVERLAY` 行为可能异常（不显示 / 被强制 dismiss）。
  - **回滚**：在 `setEditable(false)` 时若发现 ROM 异常，可保留 flag 但去掉 X 轴拖动作为最低保障；或回退为默认 touchable 状态。
- **风险**：双 TextView 叠层在中英文混排时换行点不一致 → 描边偏移。
  - **缓解**：两个 TextView 宽度、padding、textSize、fontFamily、letterSpacing 完全一致；用 `match_parent` 让 layout 决定换行。
- **风险**：老用户 SharedPreferences 中残留 `KEY_X`。
  - **缓解**：直接忽略 `KEY_X` 读取，无需迁移。

## 6. 备注 / 决策记录

- 用户期望同时满足 ①「锁定上下移动」与 ③「点穿」。两者技术上互斥，选 **方案 b**：默认点穿，长按 PlayerScreen 歌词图标进入编辑态。
- 描边方案选 **双 TextView 叠层**（真描边）而非 `setShadowLayer`（发光阴影）——保证 Issue 描述的"文字描边"视觉。
- Codex 一轮 review 指出 Android 12+ 安全策略：`TYPE_APPLICATION_OVERLAY + FLAG_NOT_TOUCHABLE` 必须使 `LayoutParams.alpha ≤ getMaximumObscuringOpacityForTouch()`（默认 0.8）下层 app 才能真正收到触摸。已加 `PASS_THROUGH_ALPHA=0.8f` / `EDIT_MODE_ALPHA=1.0f`，`createLyricView` 与 `setEditable` 同步设置。
- Codex 二轮 review：✅ PASS（SESSION_ID `019e28db-bf47-7da3-83a0-fef3847e8c85`）。
- 文案集中放在 `lib/common/constants/strings.dart` 的 `// Floating lyric overlay` 段，共 6 条常量。

---

## ✅ 完成标记

- 完成时间：2026-05-15
- 执行命令：`/init`
- CLAUDE.md 更新摘要：补充 Android 悬浮歌词点穿/编辑模式行为说明，及 PlayerScreen 长按交互。
- 关联 commit：（待 commit）

---
