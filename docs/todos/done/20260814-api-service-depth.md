# 让 ApiService 变深——先可测，再消样板

- **创建时间**：2026-08-14
- **负责人**：Elvis Juan (thanhtran0606en@gmail.com)
- **状态**：done <!-- active | done | cancelled -->
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

- [x] `ApiService` 可以在测试里被构造并注入一个短路的 `Dio`
- [x] 特征化测试覆盖至少：一个 `WorksResponse` 方法、一个 `List<T>` 方法、一个 `void` 方法、401 的错误分类、取消的错误分类
- [x] `fvm flutter analyze` 保持 **No issues found**
- [x] `fvm flutter test` 全绿
- [x] 退出详情页不再闪「加载失败」
- [x] 401 时收藏夹对话框不再显示 `NetworkException(...)` 的 dump

## 4. 拆解步骤（Steps）

- [x] **Step 1**：子代理逐方法清点（18 个成员、样板量化、12 条契约分歧、下游错误消费链）
- [x] **Step 2**：注入 Dio + `dispose()` + 移出 `WorksResponse`（无行为变更）
- [x] **Step 3**：特征化测试
- [x] **Step 4**：三个真 bug
- [x] **Step 5**：抽公共件消样板（有测试网之后）
- [x] **Step 6**：对抗性复核

## 5. 风险与回滚（Risks）

- **风险**：无测试网的大改。缓解就是本任务的顺序本身——Step 5 之前必须有 Step 3。
- **风险**：统一信封策略会改变可见行为。**决定：保持现状语义**（缺 `pagination` → 抛），因为那已经是今天的实际行为（`?? []` 从不生效）。不改成「缺失即空列表」，那会把错误屏变成空状态屏。
- **回滚方案**：两阶段分别成 commit。

## 6. 备注 / 决策记录

- **状态码 throw 对 4xx/5xx 是死代码**：Dio 5.7.0 默认 `validateStatus` 为 200-299（`options.dart:656`），本仓库无覆写，所以 401/500 永远先被 Dio 抛成 `DioException`，走 `on DioException` 分支。那 12 个 `throw Exception('...失败: ${statusCode}')` 只在 2xx-非-200（201/204/206）时生效。**架构评审报告里把它写成「已经生出的契约分裂」，过强了**——它是死分支，不是活 bug。
  - 推论：候选 D 的登录态判断没有建在沙上，401 的 `isAuthError` 不会因这条路径丢失。
- **`UpdateService` 已经有 `ApiService` 缺的那层保护**：`on UpdateException { rethrow; }` 排在通用 catch 之前（`update_service.dart:80-92`）。同一个仓库里正确的写法就在隔壁。
- 本分支基于未合入的 PR #12（→ #11 → #10 → #9）。

## 7. 第二阶段结果

`api_service.dart` **583 → 460 行**。样板残留自检：`on DioException` 15 处 → 2、
`解析数据失败` 12 处 → 2、`response.statusCode` 判断 12 处 → **0**。

抽出 `_request<T>({label, send, parse})` 一条通路 + 两个解包器
（`_parseWorksResponse` 收敛 5 处逐字节相同的信封块、`_parseList<T>` 收敛
tags/circles/voice_actors）。15 个 HTTP 方法全部改走它。

### 一处比原方案更好的结论：状态码闸门整个删掉，不是收敛成一份

我给子代理的方案是「留一份闸门兜住 2xx-非-200，此前是 12 份」。子代理执行后
撞上一条**我自己指令里的自相矛盾**——它一边被要求「两个 void 方法现在会经过
闸门（期望的行为变化）」，一边被要求「其余测试变红就停下来报告」，而会变红的
那条测试正是我上一轮亲手写的、注释里还写着「用于保证后续重构若给它补上检查，
这条会红」。它没有自行裁决，把冲突报了上来。**这是对的做法。**

顺着这个矛盾往下想，发现两个选项都不对：

`POST /playlist/add-works-to-playlist` 返回 **201 Created** 是完全正常的 REST
响应。加上 `statusCode != 200` 的闸门会让合法的 201 变成抛异常——**这是真回归**。
仓库里已有证据：`AuthService.register` 明确接受 `200 || 201`。

再推一层：Dio 默认 `validateStatus` 已经拦掉 200-299 之外的一切
（`dio_mixin.dart` 的 `_dispatchRequest`），而 2xx 之内唯一的失败模式是「响应体
不是预期形状」——那件事 `parse` 闭包自己会抛。所以这道闸门**除了误杀合法的
201/204 之外什么都没做**。

结论：删掉全部 12 份，一份都不留，连带删掉刚建的 `ApiStatusException`。
201 那条测试从「断言双层包裹」改成「断言正常解析」。

### 特征化测试起作用的两次

1. 修掉双层包裹让 201 那条变红 → 逼我明确判断这是修复还是回归。
2. 加闸门让 500-resolve 那条变红 → 顺着它发现闸门本身就是错的。

第二次尤其说明这套测试值钱：它没有阻止我改，而是让我在改错的方向上**及时撞墙**。

## 8. 遗留（另开票）

- `AuthService` / `UpdateService` 的 Dio 构造重复：三份 15s/30s/15s 超时三元组
  逐字相同，`_onSettingsChanged` 两份逐字相同，且都没有 `removeListener`。
- `searchWorks` 的解包故意与其它端点不同（裸 `as List`，不兜底 `?? []`）——
  本次原样保留，缺 works 键时的报错形状不在范围内。
- `pagination` 无兜底：畸形响应下抛错。加兜底会把「抛错」变成「空列表」，
  是可见行为变化，未做。
- `getItemNeighbors` 收不到 `CancelToken`，`DetailViewModel` dispose 后仍在跑。
- HTTP 200 + 鉴权错误信封这条路径是否真实存在，需抓包确认，不基于猜测改。

---

## ✅ 完成标记

- 完成时间：2026-08-14 01:10
- 执行命令：**未执行 `/init`** —— 本分支基于未合入的 PR #12（→ #11 → #10 → #9）。
  五个 PR 全部合入后由负责人补跑一次。
- 关联 commit：`ca39419`（第一阶段）+ 本次
