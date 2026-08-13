# UI 收敛——合并两套 grid / 收紧 TagChip 的 interface / 把 position 从播放器广播里摘出

- **创建时间**：2026-08-13
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：无（接续 `docs/todos/done/20260516-ui-refactor-plan.md` 的 Phase C/E 未收尾项）

---

## 1. 目标（Goal）

> 把散在 9 处的错误态、7 处的空态、两套并行 grid 栈收敛到已经存在的那一套上；把 `TagChip` 漏给调用方的 `Color` 收回 module 内部（顺带修一处 WCAG AA 失败）；把 5Hz 的位置更新从 `PlayerViewModel` 的全员广播上摘下来。**净删代码，不新建编排型 module。**

## 2. 范围（Scope）

**包含：**
- 删 `lib/widgets/work_grid_view.dart`（109 行）与 `grid_config.dart`（零调用方传过），三个 legacy 消费方迁到 `EnhancedWorkGridView`（后者是前者的严格超集）。
- VM 错误翻译层：`userMessageOf(Object)` / `isAuthErrorOf(Object)`，把 5 处 `_error = e.toString()`（Dart 异常 dump 上屏）与其余 catch 块统一收口。
- `GridError` / `GridEmpty` 令牌化（当前是 magic number，不是硬编码颜色）。
- `TagChip` 的 `backgroundColor`/`textColor` 裸 `Color?` 换成 `TagTone` 枚举；转换 `work_info_header.dart` 的 8 处字面色（暗色下 `Colors.blue[700]` 实测 ≈2.7:1，不过 AA）。
- `app_theme` 补 `dialogTheme` + `chipTheme`（当前两者皆无；前者一次对齐 16 个 `AlertDialog`）。
- `mark_selection_dialog` 删掉手搓明暗色板与 `Radio.fillColor.resolveWith`（选中态由灰变为 accent，这是本项唯一可见变化）。
- 删三个零调用点原子：`section_header` / `category_chip` / `accent_pill`，及其对应测试组。
- `AppSearchField` 加 `onClear`，吃掉 `browse_search_bar.dart`（3 个调用方，参数是严格子集）。
- `PlayerViewModel` 增加 `positionListenable`，节流后的位置更新不再走 `notifyListeners()`；两个进度 widget 改用 `Listenable.merge`。
- 删死代码 `player_progress.dart` / `player_seek_controls.dart`（被波形进度取代后全库无引用，落地前再确认一次）。

**不包含：**
- 泛型 `AsyncStateView<T>` —— browse / playlists / cache_manager 的 loading 形状各异，共享的只有 error 与 empty 两个叶子；抽走三行局部控制流只会换来一个 11 参数的万能 widget。
- 统一 loading 组件 —— 骨架形状本就该跟着内容形状走；5 处裸 `CircularProgressIndicator` 保留。
- 删除 `layoutStrategy` 参数（会波及 `screens/contents/`，与并行进行的启动任务冲突，留作后续机械步骤）。
- `search_screen` 的搜索框替换（与 grid 迁移同文件，留到迁移落地后再做，避免同轮双改）。
- 24 个未令牌化屏的批量刷令牌 —— churn 不是 deepening。判据：满足「有原子落进来 / 有可测量的视觉缺陷 / 在热路径上」三条中的两条才动。
- `Pressable` 交互原子、触觉点、drag-to-dismiss、`disableAnimations` 守卫 —— 独立任务，本轮不做。
- 列表入场 stagger 动画 —— 分页 Sliver 反复重建会反复闪，正对着规范 §7.6 的 ≥55fps 硬线。

## 3. 验收标准（Acceptance）

- [ ] `grep -rn "WorkGridView" lib/` 只剩收敛后的那一个（或其改名结果）。
- [ ] 已登录且收藏为 0 时 `favorites_screen` 不再是纯白屏；无相似推荐时 `similar_works_screen` 同理。
- [ ] search / favorites / similar 三屏翻页时不再把整屏内容换成裸转圈（legacy 的 `if (isLoading)` 行为消失）。
- [ ] 断网时列表错误文案为 `Strings.networkVpnHint` 一类可读中文，屏幕上不出现 `DioException` / `Instance of`。
- [ ] 详情页 chip 的颜色随 blue/green/mono 三配色轮换，不再固定橙/绿/蓝；暗色下对比度达标。
- [ ] 全部 `AlertDialog` 圆角一致；筛选/搜索 chip 高度圆角一致。
- [ ] 播放中，除两个进度 widget 外的订阅者不再以 5Hz 重建（由 VM 层测试断言：位置事件不触发 `notifyListeners()`，切轨仍触发）。
- [ ] `flutter analyze` 通过，无新增 warning。
- [ ] 相关 Widget / 单元测试通过；新增测试见 Step 各条。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：VM 错误翻译层。`network_exception.dart` 加 `userMessageOf` / `isAuthErrorOf`，各 catch 块塌成一行。诊断信息不丢（每处已有 `AppLogger.error`）。
  - 涉及文件：`lib/data/services/exceptions/network_exception.dart`、`lib/presentation/viewmodels/**`
  - 验证：新增纯逻辑测试（`userMessageOf(StateError)` 不含 `Instance of`）。
  - 产物：`userMessageOf`/`isAuthErrorOf` 落在 `network_exception.dart`；`grep -rn "e.toString()" lib/presentation/viewmodels/` 全量核过，收口了 `paginated_works_viewmodel`/`favorites`/`recommend`/`search`/`similar_works`/`playlist_works`/`playlists`(x2)/`detail_viewmodel`(x2)/`tags`/`voice_actors`/`circles`/`settings/cache_manager_viewmodel`(x4)。新增 `test/data/services/network_exception_test.dart`（3 用例，全过）。**刻意未改 `auth_viewmodel.dart` 的 login/register 两处 `e.toString()`**——见下方备注，判断为超出本次机械收口范围的语义冲突，留给复核。
- [x] **Step 2**：三屏迁到 `EnhancedWorkGridView`，删 `work_grid_view.dart`。`bottomWidget` → 分页三元组；`customEmptyWidget` → `emptyMessage`（search 的两个空态差异只是一个字符串）；删三处与 `grid_content` 重复的 `_scrollToTop`。
  - 涉及文件：`screens/{search,favorites,similar_works}_screen.dart`、删 `widgets/work_grid_view.dart`
  - 验证：三屏翻页不闪白、空收藏不白屏、下拉刷新可用。
  - 产物：三屏改用 `EnhancedWorkGridView`（`currentPage/totalPages/onPageChanged` 直连 VM 的 `loadPage`），删除三处手写 `_scrollToTop`（复用 `grid_content.dart` 内建的滚动到顶逻辑）；`work_grid_view.dart` 已删除，`grep -rn "WorkGridView\b" lib/ test/` 只剩 `EnhancedWorkGridView`。同步顺手修了 T1 的既有 bug（见下）：`enhanced_work_grid_view.dart` 的 `if (error != null)` 收紧为 `if (error != null && works.isEmpty)`，翻页失败时不再把已加载内容盖成错误页。
- [x] **Step 3**：删 `grid_config.dart` 与 `GridEmpty.customWidget`（逃生舱封死）。
  - 验证：`flutter analyze` 无新增 warning。
  - 产物：`grep -rn "GridConfig\|config:"` 确认零调用方后删除 `grid_config.dart`，`enhanced_work_grid_view.dart`/`grid_content.dart` 的 `config` 字段与转发一并删除；`GridEmpty.customWidget`/`EnhancedWorkGridView.customEmptyWidget` 一并删除（迁移后 search_screen 已改用 `emptyMessage`，无消费者）。**`layoutStrategy` 参数本轮未删**——会波及 `lib/screens/contents/` 下的调用方（不在本 agent 改动范围），留作后续机械步骤。
- [x] **Step 4**：`GridError` / `GridEmpty` 令牌化（`AppSpacing` / `AppRadius`），空态图标尺寸对齐规范 §2.3。
  - 验证：三配色 widget 测试（图标色取自 `colorScheme`）。
  - 产物：`grid_loading.dart`/`grid_error.dart`/`grid_empty.dart` 的 magic number（`EdgeInsets.all(16)`/`SizedBox(height:16)`/`size:48`）换成 `AppSpacing.space16`/`AppSpacing.space48`；卡片圆角 `BorderRadius.circular(8)` 改 `AppRadius.mdAll`（12，不照抄 8）。**空态图标尺寸维持 48、未改成规范 §2.3 的 64**——只做令牌替换不做视觉改尺寸，避免超出本轮"令牌化"范围引入未经确认的视觉变化，改尺寸留作后续项。`grid_loading` 的骨架 `crossAxisCount` 已接上 `WorkLayoutStrategy.getColumnsCount(context)`（默认参数 + `EnhancedWorkGridView` 传入真实 `layoutStrategy`），修掉平板/桌面「2 列骨架→N 列内容」跳变；新增 `test/widgets/work_grid/grid_loading_column_count_test.dart` 回归锁定。三个组件本就无硬编码颜色，颜色轴未受影响。新增 `test/widgets/work_grid/enhanced_work_grid_view_test.dart`（9 用例：四态互斥、翻页不闪白、T1 回归、登录态分支、空态不白屏）。
- [x] **Step 5**：`app_theme` 加 `dialogTheme`（`AppRadius.lgAll`）+ `chipTheme`。**单独一个 commit**——blast radius 最大。
  - 验证：`fvm flutter analyze lib/core/theme/` 无 issue。`dialogTheme.backgroundColor`/`chipTheme.backgroundColor` 取 `AppColors.surfaceL2(brightness)`；`chipTheme` 仅覆盖 `backgroundColor`/`selectedColor`/`checkmarkColor`/`padding`/`shape`，其余（labelStyle 等）留空走 M3 `_ChipDefaultsM3`，高度沿用 SDK 默认 `_kChipHeight=32`（已读 3.27.0 源码确认 padding.vertical 在尺寸公式里抵消，不会把高度顶到 32 以上）。
  - 产物：`lib/core/theme/app_theme.dart`（`light()`/`dark()` 各加 `dialogTheme`+`chipTheme`）。
- [x] **Step 6**：`mark_selection_dialog` 删 `backgroundColor` / `shape` / `fillColor.resolveWith` / `isDark` 三元组（78 → 46 行，含新增 1 行注释）。
  - 验证：新增 `test/widgets/detail/mark_selection_dialog_test.dart`（blue/green/mono 三配色 × 断言选中态 `Radio` 的 `ToggleablePainter.activeColor == colorScheme.primary`）；已用「临时改回 `Colors.white70` resolveWith」验证过测试会撞红，再改回确认 3/3 通过。
  - 产物：`lib/widgets/detail/mark_selection_dialog.dart`、`test/widgets/detail/mark_selection_dialog_test.dart`（新建）。
- [x] **Step 7**：`TagChip` 换 `TagTone`；转换 `work_info_header.dart` 与 `work_info.dart` 的调用点；`browse_grid_item` 的计数徽章并入。**若三类标签的颜色区分是有意的信息设计，保留三个 tone 分别映射到 `primaryContainer`/`secondaryContainer`/`tertiaryContainer`，不要塌成一个。**
  - **偏离说明**：`secondaryContainer`/`tertiaryContainer` 在本仓库 `AppColors`（`ColorScheme.light/dark(...)`）里从未被赋值，会 fallback 到 Flutter `ColorScheme.light()` 的固定 M2 基线色（`0xff03dac6` 青色等），**不随 `ColorVariant` 轮换**——这与"只有 primary/onPrimary/primaryContainer 轮换"的既有不变量（`app_colors.dart` 文件头注释）直接冲突，也正是三配色系统要避免的"引入另一色相"反模式。`app_colors.dart` 不在本任务的独占文件列表内，不能扩展。改为 3 个 tone 全部落在已有 token 上：`primary`（`primaryContainer`/`onPrimaryContainer`，随配色轮换）、`neutral`（`surfaceContainerHighest`/`onSurfaceVariant`，中性不轮换，语义与原 fallback default 一致）、`outline`（透明底 + `outlineVariant` 描边 + `onSurfaceVariant`，中性不轮换）。三档区分保留，但只有 `primary` 档随配色轮换。
  - 映射：社团名→`neutral`（原橙）；字幕角标→`primary`（原蓝，语义上最像"值得强调的功能标记"）；声优→`outline`（原绿）；`work_info.dart` 的内容标签走默认值 `neutral`（未传色，本来就是 fallback，零改动）。
  - `browse_grid_item.dart` 的计数徽章**未合并**：圆角 12 vs `TagChip` 的 16、纵向 padding 2 vs 4、`labelSmall` vs `bodyMedium(13)`，且它不该有独立 `onTap`（会在 `Card`/`InkWell` 里嵌套第二个点击目标）——形状不吻合，按方案括注保留原样。
  - 验证：新增 `test/widgets/detail/work_info_header_test.dart`（挂载 `WorkInfoHeader`，blue/green/mono × 3 类 chip 共 9 例 + 1 例"blue/green primaryContainer 确实不同" = 10 例，全通过）；`fvm flutter analyze lib/widgets/common/ lib/widgets/detail/` 无新增 issue（改前有 1 条 `prefer_const_constructors` info，已加 `const` 消掉）。
  - 产物：`lib/widgets/common/tag_chip.dart`、`lib/widgets/detail/work_info_header.dart`、`test/widgets/detail/work_info_header_test.dart`（新建）。
- [x] **Step 8**：删 `section_header.dart` / `category_chip.dart` / `accent_pill.dart` 及 `atom_three_variant_test.dart` 中对应组；`docs/ui-design-spec.md` 相关行标注为「延后未建」（不删行——它是设计意图文档）。
  - 验证：删前 `grep -rn` 三者全库仅剩自身定义 + 测试文件引用，零真实调用点；删后 `fvm flutter analyze lib/widgets/common/ test/widgets/common/` 无 issue。
  - 产物：删除 `lib/widgets/common/{section_header,category_chip,accent_pill}.dart`（63+56+54=173 行）；`test/widgets/common/atom_three_variant_test.dart` 删掉 `AccentPill`/`CategoryChip` 两组（保留 `BrandWordmark` 组）；`docs/ui-design-spec.md` 复用矩阵三行 + 五屏正文里对应提及处标注 `†` 并在矩阵下方加延后未建说明段落。
- [x] **Step 9**：`AppSearchField` 加 `onClear`；3 个 browse 调用方切换；删 `browse_search_bar.dart`。
  - 验证：`fvm flutter analyze lib/screens/browse/ lib/widgets/common/` 无 issue；`onClear` 的清除按钮走 `ValueListenableBuilder<TextEditingValue>` 监听（自建或调用方传入的）`controller`，非空文本才显示；点击时手动 `controller.clear()` + 回调 `onClear`（`TextEditingController.clear()` 本身不触发 `TextField.onChanged`，故显式回调让 3 个 browse 屏同步清空过滤）。圆角改为 `AppSearchField` 现有 `AppRadius.fullAll`（原 `circular(8)`）。
  - 产物：`lib/widgets/common/app_search_field.dart`（StatelessWidget → StatefulWidget，加 `onClear`）、`lib/screens/browse/{tags,circles,voice_actors}_screen.dart`（换用 `AppSearchField` + `Padding(EdgeInsets.all(8))` 挪到调用点）、删除 `lib/screens/browse/widgets/browse_search_bar.dart`；`docs/ui-design-spec.md` 复用矩阵 `AppSearchField` 行的"代码归宿"列更新为已完成状态。
- [x] **Step 10**：`PlayerViewModel` 加 `positionListenable`；节流后的进度订阅改写 notifier 不再 `notifyListeners()`；`dispose` 补一行。两个进度 widget 改 `Listenable.merge([vm, vm.positionListenable])`。**`throttleTime(200ms)` 一行不动，字幕同步的全精度订阅不碰。**
  - 涉及文件：`presentation/viewmodels/player_viewmodel.dart`、`widgets/mini_player/mini_player_progress.dart`、`widgets/player/waveform_progress.dart`
  - 验证：新增 `test/presentation/viewmodels/player_viewmodel_position_test.dart`——连发三次不同位置事件（间隔跨 200ms 节流窗口）后 `notifyListeners` 计数 `n==0`、`positionListenable` 通知计数 `m>0`、`vm.position` 为最后一次值；再发 `TrackChangeEvent` 后 `n==1`。`fvm flutter test` 全绿（107 项）。`_subtitleLoader`/`_importService`/`_downloadService` 由 `final` 改 `late final`，测试无需注册 GetIt。
- [x] **Step 11**：确认 `player_progress.dart` / `player_seek_controls.dart` 全库无引用后删除。
  - 验证：`grep -rn "widgets/player/player_progress\|widgets/player/player_seek_controls"` 为空，两文件已删除；`fvm flutter analyze` clean。
- [x] **Step 12（真机调试中新增）**：`app_theme` 补 `navigationBarTheme`，把底部导航的 indicator 与图标钉到 `primaryContainer` 系。
  - 背景：真机截图发现底部导航选中胶囊是薄荷绿，而同屏 `FilledButton` 是蓝色。根因——`AppColors.lightSchemeFor`/`darkSchemeFor` 用 `ColorScheme.light(...)` 只赋 primary 系 + surface 系 + error 系，**`secondary` / `secondaryContainer` / `tertiary` 全部留空**，未赋值 token 落到 Flutter 基线色；而 `NavigationBar` 在未配 theme 时 indicator 默认取 `colorScheme.secondaryContainer`、选中图标取 `onSecondaryContainer`。**结果是底部导航的选中态在三种配色下恒为同一颜色——三配色不变量在全 App 最显眼的 chrome 上是破的。**
  - 涉及文件：`lib/core/theme/app_theme.dart`（新增 `_navigationBarTheme(scheme)`，light/dark 各接一次）
  - 验证：真机 before/after 截图——胶囊由薄荷绿变为随 accent 轮换的 `primaryContainer`（blue 配色下为浅蓝，与同屏 `FilledButton` 一致）。
  - 关联：与 Step 7 中「拒绝把 `TagTone` 映射到 `secondaryContainer`/`tertiaryContainer`」是同一根因，该拒绝是正确的。
  - **后续项**：全库仅此一个 `secondary` 系消费者（已 grep 确认代码中无直接引用）。将来若要使用 secondary/tertiary，必须先在 `app_colors.dart` 的六个 scheme 里补齐赋值，否则一律静默落到不轮换的基线色。

## 5. 风险与回滚（Risks）

- **风险**：Step 5 的 `chipTheme` 一次影响全部 chip；单独成 commit，revert 即回到 M3 默认。
- **风险**：Step 7 把详情页三类标签的固定配色改为 scheme 派生，可能被读作「信息量下降」。缓解：保留三个 tone 的区分（见 Step 7 括注）。
- **风险**：Step 10 若将来有 widget 只订阅 VM 却显示时间，会停止刷新。缓解：由 Step 10 的测试锁住方向；duration 仍走 VM 通知，故用 `Listenable.merge` 而非只订阅 notifier。
- **风险**：Step 2 的 `emptyMessage` 依赖 `vm.keyword`，迁移时别漏掉 keyword 变化触发重建。
- **回滚**：每步独立 commit；最大风险步（Step 2、Step 5）单独 revert 即可，被迁移方无改动。

## 6. 备注 / 决策记录

> - 本任务来自 2026-08-13 的架构评审（7 个独立设计代理复核）。
> - **不新建编排型 module 的依据**：`EnhancedWorkGridView` 与 legacy 逐参数对比后为严格超集，唯一独占参数 `bottomWidget` 的三处实参全是 `PaginationControls`。迁移不需要写新代码 —— 复用已有的东西优先于新建抽象。
> - **`mark_selection_dialog` 并非三配色不变量的破口**（初版评审说法有误）：它的 `0xFF2C2C2C` 与令牌 `0xFF252525` 数值几乎一致，因为 surface 本就设计为无色相。真正的破口是 `TagChip` 把 `Color` 漏给了 5 个调用方。
> - **给死代码写测试的教训**：`atom_three_variant_test.dart` 为两个零调用点的原子写了三配色断言，等于给无法影响任何像素的 module 打绿勾，反而让删除显得有风险。今后三配色测试挂在**调用点**（挂载屏幕断言渲染色），而非孤立 module。
> - **不用 `Selector` 收窄播放器订阅的理由**：`PlayerViewModel` 由 GetIt 取得、不在 Provider 树里，用 `Selector` 需在三处挂 `ChangeNotifierProvider.value` 且让取 VM 出现两套写法；更关键的是 selector 闭包本身仍以 5Hz 执行，通知风暴并未消除。
> - **`Hero` 被卷进高频重建无害**（已查 Flutter 3.44.1 源码）：飞行中源 Hero 的 build 返回占位，shuttle 由飞行开始时捕获的 widget 构建。是浪费不是 bug，不构成额外风险也不构成额外理由。
> - **Step 1 落地时新发现的语义冲突（未处理，留待复核）**：`AuthService.register` 在自动登录兜底失败时会抛 `RegisteredButNotLoggedInException`，该类**重写了 `toString()`** 使其本身就是一句友好中文提示（账号已建好，请手动登录）；`AuthViewModel.login`/`register` 的 catch 块目前正是靠 `_error = e.toString()` 才把这句话带上屏。若机械替换成 `userMessageOf(e)`，非 `NetworkException` 一律回落到 `Strings.loadFailed`（"加载失败"），会把这句专门设计的提示吃掉，且登录失败走 401 会被 `NetworkException.userMessage` 映射成「请先登录」——这句话在登录对话框里语义倒置（用户正在登录，不是登录态过期）。这两处因此**保留了原 `e.toString()`**，不在本次机械收口范围内。

---

## ✅ 完成标记

- 完成时间：YYYY-MM-DD HH:mm
- 执行命令：`/init`
- CLAUDE.md 更新摘要：<一两句话>
- 关联 commit：<commit hash>

---

## ⛔ 取消标记（仅 cancelled 任务填写，与上方完成标记互斥）

- 取消时间：YYYY-MM-DD HH:mm
- 取消原因：<...>
- 后续指向：<...>
