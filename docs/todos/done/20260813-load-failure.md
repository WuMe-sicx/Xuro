# 让「加载失败」成为一个值——修好 8 个屏幕给错恢复动作的问题

- **创建时间**：2026-08-13
- **负责人**：Elvis Juan (thanhtran0606en@gmail.com)
- **状态**：done <!-- active | done | cancelled -->
- **关联 Issue / PR**：架构评审候选 D（`/improve-codebase-architecture` 报告）

---

## 1. 目标（Goal）

加载失败要给用户**正确的恢复动作**，而不是笼统的「出错了 + 重试」。这条不变量目前靠一个布尔被人手运过 5 个文件 8 个执行点，且每个默认值都指向错误的那一边——11 个屏幕里 8 个已经掉队。把失败态合成一个值，让恢复动作跟着失败本身走。

## 2. 范围（Scope）

**包含：**
- 新增 `LoadFailure` 值类型（文案 + 是否需要登录，由同一个异常一次算出）
- 10 个列表 ViewModel 的失败态字段合一
- `EnhancedWorkGridView` / `GridError` 接收 `LoadFailure`
- 11 个屏幕接上正确的恢复动作
- 三个浏览页从硬编码「加载失败」改为渲染真实文案 + 接登录入口
- `NetworkException.userMessage` 的 `default` 分支不再回落到技术 message

**不包含：**
- `playlist_selection_dialog`（弹窗里的列表，必鉴权）。加登录入口意味着**弹窗叠弹窗**，是三处现有 `_promptLogin` 都没面对过的场景——单独一张票。
- `EnhancedWorkGridView` 的 `works.isEmpty` 守卫（「陈旧内容优先于错误页」）。它被测试与 CLAUDE.md 双重固定，本次不动。
- 三个 `_promptLogin` 的手抄重复（收藏内容页 / 收藏屏 / 推荐页各一份）。抽公共件是另一件事。
- `AuthInterceptor` 的无路径白名单问题（见备注）。
- 架构评审其余候选：C ApiService、E 分页 seam、F 原子落盘、G 字幕三连。

## 3. 验收标准（Acceptance）

- [x] 全库 grep 不到 `isLoginError` 与列表 VM 上的 `String? error`
- [x] `fvm flutter analyze` 回到 **No issues found**
- [x] `fvm flutter test` 全绿，`enhanced_work_grid_view_test.dart` 的 9 条断言语义不变
- [x] 新增断言：`needsLogin` 为真但未传 `onLogin` 时，图标与按钮一致（不再是 🔒 配「重试」）
- [x] 11 个屏幕在 401 下均给出「去登录」而非「重试」

## 4. 拆解步骤（Steps）

- [x] **Step 1**：子代理清点 11 屏的当前渲染行为 + 各端点的鉴权性质
- [x] **Step 2**：写 `LoadFailure` 值类型 + 9 条测试
- [x] **Step 3**（第一波，并行）：共享机件（异常兜底文案 + 基类 VM + grid 组件 + 其测试）／七个自建状态机的 VM
- [x] **Step 4**（第二波，并行）：`contents/` 与 `screens/` 顶层的 7 屏／`browse/` 三屏
- [x] **Step 5**：对抗性复核
- [ ] **Step 6**：手动回归——用过期 token 依次进 11 屏，确认都给「去登录」（待真机验证）

## 5. 风险与回滚（Rists）

- **风险**：第一波会让 7 个屏幕的调用点暂时编译不过（签名已变、调用点未改）。这是预期的中间态，第二波修复；合并前必须确认 `analyze` 归零。
- **风险**：`userMessage` 兜底改通用文案后，现有 8 屏在 500 时的文案从「服务器错误: 500」变成「加载失败」，用户不再能从屏幕上报出状态码。诊断信息仍在 `AppLogger`。**已获产品决策。**
- **风险**：推荐页登出后清空列表是用户可见变化。**已获产品决策。**
- **回滚方案**：分两个 commit（机件+VM / 屏幕），`git revert` 即可。

## 6. 备注 / 决策记录

- **为什么三个浏览页也需要「去登录」**：不是因为 `/tags/`、`/circles/`、`/vas/` 要鉴权（它们是公开端点），而是因为 `AuthInterceptor` **没有路径白名单**，只要本地有 token 就给每一个请求挂 `Authorization` 头。一个过期 token 就能让这三个公开端点返回 401，而 `RetryInterceptor` 不重试 401——今天这三屏把它渲染成「加载失败 + 重试」，重试带着同一个坏 token 再撞一次，**永远出不去**。
- **发现的两个真 bug（顺带修）**：
  - 收藏页与推荐页的未登录早返回既不进 `finally` 也不复位 `_isLoading`，若早返回前 `_isLoading` 为真则永久卡住。
  - `loadFavorites` / `loadRecommendations` / `loadSimilarWorks` 的 `refresh` 参数接收后从不读取，六个调用点传 `refresh: true` 以为它有意义。
- **`GridError` 的图标错配**：`isLoginError ? 🔒 : ⚠` 不看 `onLogin` 是否为空，于是「需要登录但没接入口」时是锁图标配「重试」按钮——图标承诺登录、按钮给重试。合并两字段时一并修掉。
- 本分支基于未合入的 PR #11（→ #10 → #9）。

## 7. 对抗性复核的三个真发现（均已修）

复核没能推翻 A/B 两条主攻方向——`promptLogin` 里 `await` 之后的 `context.mounted`
守卫对「回调捕获已 dispose 的 VM」是**可证明的覆盖**而非侥幸：Flutter 卸载是先子
后父，Consumer 的 context 变 defunct 严格早于所有者 `State.dispose()`，不存在
「context 还活着但 VM 已销毁」的窗口。但它挖出三处真问题：

1. **`CLAUDE.md` / `AGENTS.md` 的契约没跟着改。** 这是最讽刺的一处：本次全部论点
   是「这条不变量靠人手运过五个文件所以走样了」，然后把那份**指导人手运的说明书**
   原样留着、指向已删除的 API。下一个照做的人会写出编译不过的代码，或更糟——把
   `isLoginError` 加回某个新 VM。也直接违反本文档第 33 行的验收标准。
   已重写 `CLAUDE.md`；`AGENTS.md` 改为**指向**它而不是再存一份副本——两个文件
   各存一份同样的契约，本身就是这次要治的病在文档层的翻版。

2. **搜索页的「去登录」可以点了没用。** `_onSearch` 读的是 `_searchController.text`，
   而 `onChanged` 只 `setState` 不碰 VM。用户撞到 401 后手动删空输入框 → 错误页与
   按钮都还在 → 点「去登录」→ 登录成功 → `_onSearch` 因 keyword 为空静默返回 →
   屏幕纹丝不动。改为从 `viewModel.keyword` 取（`onRetry` 同一个洞，一并修）。

3. **commit message 里认领的「三个真 bug」有一个是误诊。** 「未登录早返回不复位
   `_isLoading` 会永久卡住」不可达：`if (_isLoading) return;` 是 `loadPage` 首句，
   到早返回之间没有任何 await，所以那里 `_isLoading` 恒为 false。我加的那行是死
   代码，`_onAuthReady` 里的手动置 false 补的是另一个洞（`!isAuthReady` 分支故意
   置 true 后返回）。已删掉两行死代码并改正 commit message。

另补一条测试：正向分支此前只断言了文案，没断言 🔒 图标——把图标写死成
`error_outline` 时两条断言都还是绿的。现在两半都钉住了。

## 8. 遗留（另开票）

- `similar_works_screen.dart` 的 `dispose()` 漏了 `_viewModel.dispose()`，
  `SimilarWorksViewModel` 随每次进「相关推荐」累积。既存泄漏，本次未触碰。
- **`recommenderUuid` 为 null 时推荐页可能死循环**：清空列表 →「去登录」→
  `promptLogin` 复查 `isLoggedIn` 为真 → 又撞 uuid==null → 出不去。改动前是
  「至少还看得见陈旧列表」。是否可命中取决于 asmr.one 是否对所有账号都下发
  `recommenderUuid`——**代码里判定不了，需要真机确认**。若可能为 null，正解不是
  「去登录」而是一条「该账号无推荐资格」的文案。
- `GridError` 现在被三个 `browse/` 屏直接使用，但它仍住在
  `lib/widgets/work_grid/components/`——文件位置成了谎言，搬到 `widgets/common/`
  更诚实（纯搬家，无行为）。
- 同一个 `GridError` 在两套相反的规则下被调用：网格侧要 `works.isEmpty` 才切错误
  页（「陈旧内容优先」），浏览页侧无条件切。是既存差异，但组件复用之后从「两个
  组件行为不同」升级成了「一个组件两种语义」。
- `playlist_selection_dialog` 的失败态未迁移（弹窗叠弹窗，单独设计）。
- 架构评审其余候选：C ApiService、E 分页 seam、F 原子落盘、G 字幕三连。

---

## ✅ 完成标记

- 完成时间：2026-08-13 21:30
- 执行命令：**未执行 `/init`** —— 本分支基于未合入的 PR #11（→ #10 → #9）。
  改为**重写** `CLAUDE.md` 的 Error-prompt UX 小节（四层手工传递 → 五层，以
  `LoadFailure` + `promptLogin` + `GridError` 为骨架），并把 `AGENTS.md` 的重复
  副本改为指向。四个 PR 全部合入后由负责人补跑一次。
- CLAUDE.md 更新摘要：Error-prompt UX 整节重写；写明 `userMessage` 的 default
  分支不再回落技术串、`LoadFailure` 是唯一载体、图标跟 `showLogin` 而非
  `needsLogin`、`promptLogin` 的三处静默失败细节、以及「重载回调不得从用户可改的
  widget 取输入」。
- 关联 commit：`b860ce8`（已修订）
