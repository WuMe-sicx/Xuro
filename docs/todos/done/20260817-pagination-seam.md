# 分页 seam 换个开法——状态机收敛成 mixin，三样真变化留在外面

- **创建时间**：2026-08-17
- **负责人**：Elvis Juan (thanhtran0606en@gmail.com)
- **状态**：done <!-- active | done | cancelled -->
- **关联 Issue / PR**：架构评审候选 E（承接 `docs/handoff-20260814-architecture-refactor.md` §3）

---

## 1. 目标（Goal）

`PaginatedWorksViewModel`（94 行）**只有 2 个子类**，而另外 5 个列表 VM 各自抄了一份
同样的 25 行状态机。`fetchPage(int page)` 是为「一次 await」开的 seam，它从不结构性
变化；真正会变的三样东西一个 seam 都没有。

代价已经付过一次：候选 D 给 11 个列表加 `LoadFailure` 时，**8 屏抄错了**。

目标是让下一次横切改动落在一处，而不是七处。

## 2. 范围（Scope）

把状态机抽成 `mixin PagedWorks on ChangeNotifier`，**与基类同文件**（不新增文件）：
5 个字段 + 6 个 getter + `loadPage` / `runFetch` / `canLoad`，以及**四个**「子类够不着
私有字段所以必须由 mixin 提供」的状态迁移：`markAuthPending` / `reloadAfterAuthReady` /
`markLoginRequired` / `resetPagedState`。

**故意留在 mixin 外面的三样东西**（它们才是各 VM 真正不同的地方，不要为它们开钩子）：

| 变化点 | 谁有 | 留在哪 |
| :--- | :--- | :--- |
| 前置条件 | 收藏（`isLoggedIn`）、推荐（`recommenderUuid != null`） | 各 VM 覆写 `loadPage` |
| 空闲态 | 只有搜索（`clear()`） | `SearchViewModel` |
| 构造形状 | 相关推荐构造即加载；主页/热门走 `ensureFirstLoad` | 各 VM 构造函数 / 基类 |

改造 4 个 VM：`favorites` / `recommend` / `similar_works` / `search`。
`home` / `popular` **零改动**（它们已经在基类上）。

**顺带修一个真缺陷**：`similar_works_screen.dart` 的 `dispose()` 漏了
`_viewModel.dispose()`（`ChangeNotifierProvider.value` 不负责 dispose），每进一次
「相关推荐」累积一个 VM。它正好在本次改造的爆炸半径里。

**不包含：**
- `circles` / `tags` / `voice_actors` 三个 VM——它们是**另一个**复制族（无分页、
  客户端过滤、屏幕无条件分支 `isLoading`），与分页 seam 无关。
- `favorites_content.dart:51` 传裸 `totalPages` 而 `favorites_screen.dart:69` 传
  `?? 1`——**同一个 VM 的两个视图不一致**，是真问题，但两个方向的统一都会改变
  可见行为（收藏 tab 凭空多出 `1/1` 分页器，或抽屉页丢掉分页器）。单独一张票。
- 让 VM 监听 `AppSettingsService`。今天在热门页切字幕筛选不会让主页重载；
  「修好」它会让一次切换引发 N 次重新取数。
- 把 `recommend` / `favorites` 的首载改成 `ensureFirstLoad()`。今天靠
  `AutomaticKeepAliveClientMixin` 达到同样效果，改了是行为变化，收益为零。

## 3. 验收标准（Acceptance）

- [x] 5 个 VM 共用一份状态机；`totalPages` 公式从 5 份降到 1 份（+ 搜索页 1 行覆写）
- [x] 边界守卫 `page < 1 || page > totalPages` 从 4 份降到 1 份
- [x] **每个既有公开成员的类型与可空性逐字不变**——7 个屏幕零改动
      （`similar_works_screen` 的 dispose 修复除外）。注意公开面是**变宽了**的：
      4 个 VM 新得到 `pageName` / `fetchPage`（后者已标 `@protected`），
      3 个新得到 `pagination`。没有屏幕因此改动，但「逐字不变」的说法不成立。
      六个 `@protected` 成员只是分析器约束，运行时仍可从任意处调用。
- [x] 新增 `test/presentation/viewmodels/paged_works_test.dart` 钉住 mixin 的
      状态机，**外加针对 `SearchViewModel` 本体的两条**——它那两条风险（R1 的
      非空 `totalPages`、B8 的无 in-flight 守卫）恰恰**不能**由 mixin 的测试覆盖，
      因为 mixin 上钉住的是相反的一面（见 §6 最后一条）
- [x] `fvm flutter analyze` 保持 **No issues found**
- [x] `fvm flutter test` 全绿

## 4. 拆解步骤（Steps）

- [x] **Step 1**：清点子代理（read-only）——10 个 VM、23 条行为分歧、16 条可见风险
- [x] **Step 2**：共享 API（`PagedWorks` mixin + 瘦身后的基类）——**由主代理亲手写**，
      不外包；并行代理各自发明一套是这套方法上一轮踩过的坑
- [x] **Step 3**：G2 实现子代理（`favorites` + `recommend`，鉴权门那一对）
- [x] **Step 4**：G3 实现子代理（`similar_works` + `search`，构造/空闲态那一对）
- [x] **Step 5**：测试子代理（`test/`，与 G2/G3 文件互不重叠，可并行）
- [x] **Step 6**：对抗性复核子代理（立场「这个重构有问题」）

## 5. 风险与回滚（Risks）

清点代理给出 16 条可见风险，其中 7 条今天**只靠读代码保证**、无任何测试。
本次补上其中 6 条；**R4 没补，理由见 §8**——不要把这张表读成「七条全覆盖」：

| 编号 | 一旦被抹平 | 用户会看到 |
| :--- | :--- | :--- |
| R3 | `_onAuthReady` 里的 `_isLoading = false` | 收藏/推荐**冷启动永远转圈**（补载被 in-flight 守卫吞掉） |
| R4 | 鉴权未就绪分支的 `_isLoading = true` 哨兵 | 冷启动**先闪「请先登录」再翻转成列表** |
| R6 | 未登录早返回里的 `_works = []` | **「去登录」按钮被旧列表挡住**（网格的 `works.isEmpty` 守卫） |
| R7 | 往 `catch` 里加 `_works = []` | 翻第 2 页失败会**抹掉第 1 页**、整屏错误页 |
| R1 | 搜索页 `totalPages` 改成可空 | 搜索页**分页器消失** |
| B4 | `loadPage(_currentPage)` 改成 `loadPage(1)` | 鉴权补载**跳回第 1 页**而不是停在原页 |
| B8 | 给搜索加 in-flight 守卫 | 搜索途中点字幕/排序**静默无反应** |

- **风险**：mixin 的私有字段对子类不可见（Dart 库级私有），子类改不了状态。
  **这是要的**——四个状态迁移只能走 mixin 提供的方法，抄错的机会被语言堵死。
- **回滚方案**：单一 commit，`git revert` 即可。基类与 mixin 同文件，无孤儿文件。

## 6. 备注 / 决策记录

- **为什么是 mixin 不是组合。** 组合（VM 持有一个 `PagedWorks` 对象）要给 6 个 getter
  各写一行转发 × 5 个 VM = 30 行纯转发——正是候选 G 里 `SubtitleService`「10 个成员
  9 个逐行转发」被判死刑的那个形状。mixin 的字段就是 VM 的字段，`notifyListeners()`
  直接可用，转发行数为 0。
- **为什么保留基类而不是全并进 mixin。** 基类剩下的只有首载协议
  （`ensureFirstLoad` / `onInit` / `_firstLoadTriggered` / `refresh` / `apiService`），
  只有主页和热门需要。并进 mixin 会让另外 4 个 VM 白拿一个永不调用的
  `ensureFirstLoad`——用死代码换少一个类，不划算。
- **搜索页故意不走 `canLoad`。** 它没有 in-flight 守卫是行为不是疏漏：筛选/排序在
  请求途中被点击时要能立刻重发，最后一次写入生效。加上守卫会让那两个按钮静默失效。
- **`runFetch` 与 `loadPage` 分成两个入口**，因为搜索要跳过守卫而其余四个要经过。
  两个入口各有真实调用方，不是预留的灵活性。

## 7. 对抗性复核挖出来的东西

复核代理的立场是「这个重构有问题」，10 条攻击线里 7 条有货。三条真问题：

1. **补上的 `dispose()` 反而打开了一个崩溃。** `SimilarWorksViewModel` 构造即发请求，
   进页面立刻返回 → 响应落地时 `runFetch` 的 `finally` 对着已 dispose 的
   `ChangeNotifier` 发通知 → debug 下踩 assert。**修法不是撤回 dispose**（泄漏是真的），
   而是把守卫装到根上：mixin 现在是全部 6 个 VM 唯一的通知出口，`_disposed` +
   `_safeNotify()` 装一处覆盖全部。仓库为同一件事付过一次代价（`UpdateViewModel`）。
2. **`recommenderUuid!` 的注释论证是错的。** 它说「同步路径所以安全」——但
   `runFetch` 在门禁与读取之间调了 `notifyListeners()`，那会**同步**派发任意监听器
   代码。旧代码把 `final uuid` 捕获进局部变量，结构上免疫；新代码退化成隔着一个
   重入点重读可变字段。改成显式判空 + `StateError`，`!` 去掉。
   **今天不可达，但这正是本次重构声称要消灭的那类「靠人手运的不变量」，而且是重构
   自己新加的。**
3. **一行 pre-fetch 日志被静悄悄删掉了**（主页/热门的 `加载$pageName: 第$page页`）。
   已恢复。

以及一条方法论上的：**mixin 的测试证明不了搜索页的两条风险，反而钉住了相反的一面。**
R1（搜索页 `totalPages` 非空）与 B8（搜索页无 in-flight 守卫）在 mixin 上的正确行为
分别是「可空」和「有守卫」——七条 mixin 测试全绿的同时，把搜索页「统一」进 mixin
就能同时踩中这两条。所以这两条必须对着 `SearchViewModel` 本体测，不能靠 mixin。

## 8. 明确的欠账

- **`FavoritesViewModel` / `RecommendViewModel` 的分支顺序没有测试。** 真正的不变量是
  「`isAuthReady` 判在 `isLoggedIn`/`uuid` 之前」（顺序调换 → 冷启动闪「请先登录」），
  而本次重写的正是这两个方法。测它需要一个 `AuthViewModel` 替身，而 `AuthViewModel`
  要真的 `AuthService` + `AuthRepository`（后者走 flutter_secure_storage 平台通道）。
  仓库有明确的 no-full-DI 测试政策，本次不破例。**这条是已知缺口，不是已覆盖。**
- `favorites_content.dart:51` 传裸 `totalPages` 而 `favorites_screen.dart:69` 传 `?? 1`
  的不一致仍在（见 §2「不包含」）。

---

## ✅ 完成标记

- 完成时间：2026-08-18
- 执行命令：**未执行 `/init`** —— 本分支基于未合入的 PR #13（→ #12 → #11 → #10 → #9）。
  改用定点修改 `CLAUDE.md` / `AGENTS.md`（`viewmodels/` 条目改写为 `PagedWorks` mixin，
  并修掉 App Initialization Flow 里两条本就写错的话）。六个 PR 全部合入后由负责人补跑一次。
- 验证：`fvm flutter analyze` → No issues found；`fvm flutter test` → 252 项全绿
  （本候选之前是 240 项）。
