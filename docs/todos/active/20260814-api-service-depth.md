# 让 ApiService 变深——先可测，再消样板

- **创建时间**：2026-08-14
- **负责人**：Elvis Juan (thanhtran0606en@gmail.com)
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：架构评审候选 C

---

## 1. 目标（Goal）

`ApiService` 573 行 18 个成员，**248 行（43%）是逐字重复的样板**：15 处相同的 catch 三件套、12 处相同的状态码分支、5 段逐字节相同的信封拆解。它不是一个 module，是一袋函数。

但它**零测试**（唯一的测试只碰一个静态纯函数），且仓库里没有任何 mock 库。所以顺序是：**先让它可测 + 钉住现状，再动样板**。

## 2. 范围（Scope）

**第一阶段（本次，无行为变更）：**
- `Dio` 变成可注入（对齐 `DownloadService` 已有的 `Dio? dio` 写法）
- 补 `dispose()` —— `addListener` 至今没有配对的 `removeListener`
- `WorksResponse` 移出 `api_service.dart`（`core/cache` 目前为了拿一个 DTO 而 import 服务层）
- 用 `InterceptorsWrapper` 短路的方式（仓库里已有先例）写特征化测试，钉住现有解包与错误分类行为

**第二阶段（下一个 commit）：**
- 抽出「请求 → 拆信封 → 映射错误」的公共件，15 处 catch 三件套收敛为一处
- 统一三种列表解包策略、三种状态码检查形态、三种裸 catch 出口

**顺带修的三个真 bug（第一阶段一并做，它们不依赖重构）：**
- 取消被当成失败上屏
- 异常对象被 `Strings.operationFailed/markFailed` 原样上屏
- `DetailViewModel` 两处只取 `userMessageOf` 丢掉 `needsLogin`

**不包含：**
- `AuthService` / `UpdateService` 的 Dio 构造重复（三份超时三元组逐字相同）——邻近问题，单独一张票
- **HTTP 200 + 鉴权错误信封**这条路径。理论上 `?? []` 吞掉 works → `Pagination.fromJson(null)` 抛 TypeError → 裸 catch → 丢掉 `isAuthError`。但 asmr.one 是否真会在 200 里返回错误信封**代码里判定不了**，需要抓包确认，不基于猜测改。
- `getItemNeighbors` 收不到 `CancelToken`（`DetailViewModel` dispose 后仍在跑）——真问题，但属于 CancelToken 覆盖面的话题，单独处理。

## 3. 验收标准（Acceptance）

- [ ] `ApiService` 可以在测试里被构造并注入一个短路的 `Dio`
- [ ] 特征化测试覆盖至少：一个 `WorksResponse` 方法、一个 `List<T>` 方法、一个 `void` 方法、401 的错误分类、取消的错误分类
- [ ] `fvm flutter analyze` 保持 **No issues found**
- [ ] `fvm flutter test` 全绿
- [ ] 退出详情页不再闪「加载失败」
- [ ] 401 时收藏夹对话框不再显示 `NetworkException(...)` 的 dump

## 4. 拆解步骤（Steps）

- [x] **Step 1**：子代理逐方法清点（18 个成员、样板量化、12 条契约分歧、下游错误消费链）
- [ ] **Step 2**：注入 Dio + `dispose()` + 移出 `WorksResponse`（无行为变更）
- [ ] **Step 3**：特征化测试
- [ ] **Step 4**：三个真 bug
- [ ] **Step 5**：抽公共件消样板（有测试网之后）
- [ ] **Step 6**：对抗性复核

## 5. 风险与回滚（Risks）

- **风险**：无测试网的大改。缓解就是本任务的顺序本身——Step 5 之前必须有 Step 3。
- **风险**：统一信封策略会改变可见行为。**决定：保持现状语义**（缺 `pagination` → 抛），因为那已经是今天的实际行为（`?? []` 从不生效）。不改成「缺失即空列表」，那会把错误屏变成空状态屏。
- **回滚方案**：两阶段分别成 commit。

## 6. 备注 / 决策记录

- **状态码 throw 对 4xx/5xx 是死代码**：Dio 5.7.0 默认 `validateStatus` 为 200-299（`options.dart:656`），本仓库无覆写，所以 401/500 永远先被 Dio 抛成 `DioException`，走 `on DioException` 分支。那 12 个 `throw Exception('...失败: ${statusCode}')` 只在 2xx-非-200（201/204/206）时生效。**架构评审报告里把它写成「已经生出的契约分裂」，过强了**——它是死分支，不是活 bug。
  - 推论：候选 D 的登录态判断没有建在沙上，401 的 `isAuthError` 不会因这条路径丢失。
- **`UpdateService` 已经有 `ApiService` 缺的那层保护**：`on UpdateException { rethrow; }` 排在通用 catch 之前（`update_service.dart:80-92`）。同一个仓库里正确的写法就在隔壁。
- 本分支基于未合入的 PR #12（→ #11 → #10 → #9）。
