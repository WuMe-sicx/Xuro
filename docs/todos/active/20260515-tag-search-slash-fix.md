# 标签搜索：`/` 不被编码导致 404（Issue #2）

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active
- **关联 Issue / PR**：https://github.com/WuMe-sicx/Xuro/issues/2

---

## 1. 目标（Goal）

修复部分标签（例如 "巨乳/爆乳"）点击后 404 的问题：当 `tag.name` 包含 `/`（ASMR.ONE 把别名 / 合并标签写成 `主名/别名`）时，`/search/${...}` 路径中的斜杠被服务器解释为路径分隔符，路由匹配不到 → 404 → 用户看到"乱码错误"。

## 2. 范围（Scope）

**包含：**
- `lib/data/services/api_service.dart::searchWorks` 路径构造方式调整，确保 keyword 中所有保留字符（含 `/`）都被 percent-encode 且不被 Dio 还原。
- 新增一个最小单元测试，验证 keyword 含 `/` 时构造出的 URL 含 `%2F` 且只有一个 search 路径段。

**不包含：**
- 其他 API 端点（暂未发现同类问题；其他端点都把含 `/` 字符的内容当作 query param，不走路径段）。
- 标签详情接口 `/tags/`（这是无参列表，不受影响）。
- 用户输入框手动键入的搜索词（已经在工作；本次只针对标签 chip 跳转的路径段）。

## 3. 验收标准（Acceptance）

- [x] 点击标签 "巨乳/爆乳"（tag.name 含 `/`）能返回 20 条结果，无 404。
- [x] 点击标签 "哦吼淫叫" / "啊嘿颜" 等无斜杠 tag 仍然正常。
- [x] 单元测试通过：构造 `searchWorks` URL 时含斜杠的 keyword 在最终 path 里只产生一个 search segment（即 keyword 段中的 `/` 必须保持 `%2F`）。
- [x] `flutter analyze` 通过，无新增 warning。
- [ ] 真机烟测（留给项目维护者）：标签界面点击两个含 `/` 的标签，搜索界面成功显示结果。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：改 `lib/data/services/api_service.dart::searchWorks`
  - 用 `Uri.parse(baseUrl)` + `replace(pathSegments: ..., queryParameters: ...)` 构造完整 URI；调用 `_dio.getUri(uri)` 而不是 `_dio.get(path)`，避免任何字符串拼接的二次解码风险。
  - 验证：日志或单测确认 outgoing URL 的 path 包含 `%2F`，且 `pathSegments.length == baseSegments + 2`。
- [x] **Step 2**：新增 `test/data/services/api_service_url_test.dart`
  - 不依赖实际 HTTP，只测 URL 构造逻辑：keyword 含 `/` 时 URI 的 path 含 `%2F`。
  - 验证：`fvm flutter test test/data/services/api_service_url_test.dart` PASS。
- [x] **Step 3**：`fvm flutter analyze`、`fvm flutter test`、`git diff` 给 Codex review。
  - 验证：analyze 干净 + Codex ✅ PASS。

## 5. 风险与回滚（Risks）

- **风险**：`Uri.replace(pathSegments: [...])` 会替换全部 path 段，若 `baseUrl` 自带前缀 `/api`，要保留进段列表。
  - **缓解**：用 `baseUri.pathSegments` 拼接，已在代码里处理。
- **风险**：Dio 的 `getUri` 与 `get` 在拦截器、重试、查询合并上是否一致。
  - **缓解**：阅读 Dio 5.x 文档；二者只是入口不同，拦截器/重试均生效，无差别。

## 6. 备注 / 决策记录

- 实测证据（curl 主站 + 三个镜像节点）：
  - `https://api.asmr.one/api/search/%24tag%3A%E5%B7%A8%E4%B9%B3%2F%E7%88%86%E4%B9%B3%24?...` → 200, 20 条结果。
  - 相同 URL 中 `%2F` 还原为 `/` → 404。
  - 所以服务端是正确的，bug 在 Dart 侧字符串拼接的 URL 经过 Dio 时 `%2F` 被还原。
- 选 `Uri.pathSegments` + `getUri` 是因为这是 Dart 官方推荐的"显式路径段"构造方式，每段都自动 percent-encode，且 Dio 接收 `Uri` 后不会再做字符串再解析。
- Codex 一轮 ⚠️ OPTIMIZE → 二轮 ✅ PASS（SESSION_ID `019e2a9d-bde0-7053-a53d-1bd5d4dd0ea8`），新增 wire-level Dio 拦截器测试 + 保留字符 table cases + 注释精修。共 10 个 test passed。
- 用户报告的"哦吼淫叫"在我的 curl 实测下能 200（tag 524 主名为 "啊哦淫叫"，无 `/`）。可能是用户在旧版本上遇到的或网络瞬时问题。本次修复直接覆盖根因（含 `/` 的 tag），不再单独追跟 524。

---

## ✅ 完成标记

- 完成时间：2026-05-15
- 执行命令：`/init`（待项目维护者执行）
- CLAUDE.md 更新摘要：补充 `ApiService.searchWorks` 的 URI 构造方式说明，及 `buildSearchUri` 为单测入口的备注。
- 关联 commit：（待 commit）

---
