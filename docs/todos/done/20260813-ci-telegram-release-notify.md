# 正式版发布后自动推送 Telegram 频道

- **创建时间**：2026-08-13
- **负责人**：WuMe-sicx
- **状态**：done <!-- active | done | cancelled -->
- **关联 Issue / PR**：无

---

## 1. 目标（Goal）

v1.2.0 的发版公告是人工 `curl` 发到 @XuroAsmr 的。把这一步挪进 CI，正式版 tag 推上去之后自动发，省掉每次发版的手工动作。

## 2. 范围（Scope）

**包含：**
- `.github/workflows/build.yml` 的 `upload` job 里，`Create Release` 之后加一步 `Notify Telegram`。
- 正文复用已有的 `steps.commits.outputs.commits`（commit message 列表）。

**不包含：**
- 手写版本亮点文案。CI 里没人会去写，需要精修文案时仍然手动发。
- 预发布（`-rc` / `-beta` 后缀 tag）不推送。
- 不做失败重试、不做多频道、不做消息模板抽象。

## 3. 验收标准（Acceptance）

- [x] YAML 能被解析，`Notify Telegram` 步骤的 `if` / `env` / `run` 三项符合预期。
- [x] commit message 含 `"` / `$` / 反引号时不会被 shell 展开或截断（本地 dry-run 验证）。
- [x] `secrets.TELEGRAM_BOT_TOKEN` 缺失时不会让构建变红。
- [x] 不涉及 Dart 代码，无需 `flutter analyze` / `build_runner` / 单测。

## 4. 拆解步骤（Steps）

- [x] **Step 1**：在 `Create Release` 与 `Upload artifacts if not release` 之间插入 `Notify Telegram`
  - 涉及文件：`.github/workflows/build.yml`
  - 验证：`python3 -c "import yaml; ..."` 打印该步骤的 `if` / `env` / `run`，与预期逐字一致。
- [x] **Step 2**：确认注入安全
  - 验证：把含 `"` / `$HOME` / 反引号的假 `COMMITS` 喂进同一段 shell，输出逐字保留、无展开。
- [x] **Step 3**：仓库 Settings → Secrets 添加 `TELEGRAM_BOT_TOKEN`
  - 验证：下一次正式版 tag 推送后频道收到消息。**此步需人工完成，尚未做。**

## 5. 风险与回滚（Risks）

- **风险**：token 泄露 → 任何人都能以 bot 身份在频道发言。v1.2.0 那次的 token 是在对话里明文给出的，**必须 revoke 后再把新 token 写进 secret**。
- **风险**：bot 被移出频道 / 权限被撤 → 推送 403。`continue-on-error: true` 保证这只是漏一条通知，不会把一次成功的发布标成失败。
- **回滚方案**：删掉该步骤即可，与构建产物、release 创建完全解耦。

## 6. 备注 / 决策记录

- **为什么一律走 `env` 而不是把 `${{ }}` 直接插进 `run`**：commit message 是任何提交者都能写的内容，直接插值等于把它当 shell 代码执行（GitHub Actions script injection）。经 `env` 传值后 shell 只做一次变量展开，不会重新解析内容。
- **为什么判据是「tag 含 `-`」**：与上一步 `prerelease: ${{ contains(github.ref_name, '-') }}` 用的是同一条规则。两处必须保持一致，否则会出现「标成预发布却推了频道」。
- **频道 id 直接写 `@XuroAsmr`**：公开频道用 username 即可，不必存数字 id，也就不必再加一个 secret。

---

## ✅ 完成标记

- 完成时间：2026-08-13 21:00
- 执行命令：未跑 `/init`（见下）
- CLAUDE.md 更新摘要：仅 CI/CD 一节补了「正式版 tag 额外推送 Telegram 频道，需 `TELEGRAM_BOT_TOKEN` secret」，改动范围只有一行，做了定点编辑而非整篇重生成。需要完整刷新时再单独跑 `/init`。
- 关联 commit：未提交（工作区改动）
