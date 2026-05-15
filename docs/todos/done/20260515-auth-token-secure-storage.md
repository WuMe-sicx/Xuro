# 认证 token 迁移安全存储 + AuthRepository 内存缓存（防御式降级）

- **创建时间**：2026-05-15
- **负责人**：WuMe-sicx
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：本地持久化优化清单第 6 项（Codex SESSION 019e2c0c…2962 分析 C7）

---

## 1. 目标（Goal）

`AuthRepository` 把含 bearer `token` 的 `AuthResp` 以**明文 JSON** 存在 SharedPreferences（`auth_data`），且 `AuthInterceptor.onRequest` **每个 HTTP 请求**都 `getAuthData()`（prefs 读 + `json.decode` + `AuthResp.fromJson`）。本任务：(1) token 迁 `flutter_secure_storage`（Android EncryptedSharedPrefs / iOS Keychain），(2) `AuthRepository` 加内存缓存使拦截器零存储开销，(3) 一次性迁移既有明文 `auth_data`，(4) **防御式降级**：安全存储读写失败时回退 prefs，绝不因 Keystore 故障登出用户。

> 用户已知悉并接受：新增原生依赖、本环境无法真机验证 Android Keystore，故强制防御式降级。

## 2. 范围（Scope）

**包含：**
- `pubspec.yaml` 新增 `flutter_secure_storage`（`pub get` 解析）。
- 重写 `AuthRepository`：注入 `SharedPreferences` + `FlutterSecureStorage`（后者可选命名参数，默认 `const FlutterSecureStorage()`，DI 调用零改动）；`_cached`/`_loaded` 内存缓存 + 并发去重 `_loadFuture`（`??=`，DatabaseService 同款原子模式）。
- `getAuthData()`：已加载→返回内存；否则 secure 优先→空则迁移旧 prefs（迁移成功才清明文，失败保留明文+不登出）→空则 null。
- `saveAuthData()`：写 secure 成功→清残留明文；secure 失败→降级写 prefs（保住登录态）。
- `clearAuthData()`：secure + prefs 双清 + 清内存（各自吞错不互相阻断）。
- 整个 `AuthResp` JSON blob 存 secure（token 是敏感位，blob 很小，不拆模型——避免 model 知识泄漏与拆分复杂度，且 prefs 不再留任何敏感数据）。

**不包含：**
- 不拆 `AuthResp` 为敏感/非敏感分别存储（blob 整体进 secure 更简单且更安全）。
- 不改 `AuthInterceptor`/`AuthViewModel`/`AuthService` 调用契约（`getAuthData/saveAuthData/clearAuthData` 签名不变；拦截器自动获益于内存缓存）。
- 不做安全存储平台特定加固配置（用默认 Android EncryptedSharedPreferences / iOS Keychain），不加生物识别。
- 无法真机验证 Keystore——以防御式降级覆盖故障设备（项目对小米 HyperOS 等原生层问题敏感）。

## 3. 验收标准（Acceptance）

- [x] `flutter_secure_storage: ^9.2.2` 入 `pubspec.yaml`，`fvm flutter pub get` 成功（Changed 7 deps）。
- [x] `AuthInterceptor` 经内存缓存：首次后 `getAuthData()` 走 `_cached`，不再读 prefs/secure、不再 `json.decode`。
- [x] 既有明文 `auth_data` 升级后成功迁移到 secure 并清明文；迁移失败保留明文且不登出（防御式降级，Codex 确认）。
- [x] 新登录 token 写 secure；secure 写失败降级写 prefs，登录态不丢。
- [x] 登出双清 secure+prefs+内存，各自吞错不互阻。
- [x] 并发首次 `getAuthData()` 只触发一次加载/迁移（`_loadFuture ??=` 无 await 挂起点，Codex 确认）。
- [x] `flutter analyze lib/data/repositories/` = No issues found（无新增 warning）；测试 31 通过（1 既有 stale 无关）。
- [x] Codex review ✅ PASS（SESSION 019e2c0c…2962；首轮 ✅ → 自查发现并加并发 guard → 二轮 ❌ secure 旧值复活 → 串行化修复 → 三轮 PASS）。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：`pubspec.yaml` 加 `flutter_secure_storage: ^9.2.2`；`fvm flutter pub get` 成功
- [x] **Step 2**：重写 `AuthRepository`（secure+prefs 双后端、`_cached`/`_loaded` 内存缓存、`_loadFuture ??=` 并发去重、一次性迁移、防御降级）
- [x] **Step 2b**：自查补并发 guard（各提交点 `if(_loaded)return _cached`）+ 持久化串行化 `_writeLock`/`_serialize`（迁移/save/clear 落盘有序，杜绝 secure 旧值复活）
- [x] **Step 3**：`flutter analyze`（No issues found）+ `flutter test`（31 通过，1 既有 stale）全量回归
- [x] **Step 4**：Codex review —— 首轮 ✅ → 自查并发窗口加 guard → 二轮 ❌（secure 旧 token 平台层乱序复活）→ 串行化修复 → 三轮 ✅ PASS

## 5. 风险与回滚（Risks）

- **风险**：新增原生依赖 `pub get` 解析/构建未在本环境验证（用户已接受）。Android Keystore 在部分 OEM ROM 有失败史——以防御式降级（读写失败回退 prefs、迁移失败不清明文不登出）兜底，最坏退化为现状（明文 prefs），不会登出或崩溃。内存缓存若与多实例不一致——`AuthRepository` 为 DI 单例，唯一写入口，cache 与存储同写，安全。
- **回滚方案**：revert 本次 commit + `pubspec.yaml`/`pubspec.lock` 回退后 `pub get`。

## 6. 备注 / 决策记录

- 防御式降级是本任务硬约束：安全收益不得以「故障设备登出/崩溃」为代价。迁移成功才清明文是关键不变量（清明文 + 迁移失败 = 登出）。
- 并发去重复用 DatabaseService 的「缓存 Future、`??=` 间无 await」模式，拦截器并行请求下只加载一次。
- Codex 二轮发现并修复的深层并发：仅靠内存 `_loaded` guard 保护不了「legacy 迁移的 `_secure.write(legacy)` 与并发 save/clear 的 secure 写在平台层乱序完成 ⇒ 旧 token 在 secure 复活」。修复=持久化串行化 `_serialize`（迁移/save/clear 的 secure+prefs 写各为一个串行 action，发起序==落盘序，最后发起者胜）+ 入链前 `if(_loaded)return` 守卫（无 save/clear 时迁移才入链）。复用优化1的 chain 思路。

---

## ✅ 完成标记

- 完成时间：2026-05-15 21:10
- 执行命令：`/init`
- CLAUDE.md 更新摘要：新增 `AuthRepository` 安全/并发不变量——token blob 存 flutter_secure_storage、`_cached`/`_loaded` 内存缓存使拦截器零每请求开销、`_loadFuture ??=` 并发去重、旧明文一次性迁移（成功才清明文）、防御式降级回 prefs（Keystore 故障不登出/不崩）、所有 secure/prefs 写经 `_serialize` 串行化防旧值复活。
- 关联 commit：未提交（用户未要求提交，待统一提交时机）
