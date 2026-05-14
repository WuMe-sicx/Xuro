# [任务标题——一句话讲清楚]

- **创建时间**：YYYY-MM-DD
- **负责人**：<github 用户名>
- **状态**：active <!-- active | done | cancelled -->
- **关联 Issue / PR**：<链接或编号，可留空>

---

## 1. 目标（Goal）

> 一句话：做什么 + 为什么做。
> 例：「为悬浮歌词窗口增加颜色选择器，让用户在不同壁纸下保持可读性。」

## 2. 范围（Scope）

**包含：**
- ...

**不包含：**
- ...（明确划出本次不做的部分，避免范围蔓延）

## 3. 验收标准（Acceptance）

可验证的成功条件。每条都要能被 UI、测试或日志证伪。

- [ ] ...
- [ ] ...
- [ ] `flutter analyze` 通过，无新增 warning。
- [ ] 涉及 `lib/data/models/` 下 Freezed/json_serializable 改动时，已运行 `dart run build_runner build --delete-conflicting-outputs` 且生成产物已纳入提交。
- [ ] 相关单元 / Widget 测试通过。

## 4. 拆解步骤（Steps）

按依赖顺序排列，每步注明「验证方法」。

- [ ] **Step 1**：<做什么>
  - 涉及文件：`lib/...`
  - 验证：<怎么知道这一步对了>
- [ ] **Step 2**：<做什么>
  - 涉及文件：`lib/...`
  - 验证：...
- [ ] **Step 3**：...

## 5. 风险与回滚（Risks）

- **风险**：<可能影响的现有功能 / 性能 / 兼容性>
- **回滚方案**：<怎么撤回，例如 revert commit 或保留 feature flag>

## 6. 备注 / 决策记录

> 开发过程中的关键决策、踩坑记录写在这里，供未来回看。

---

## ✅ 完成标记

> 全部步骤勾选完毕后填写此块，并实际执行 `/init` 刷新根目录 `CLAUDE.md`，然后把本文件移入 `docs/todos/done/`。

- 完成时间：YYYY-MM-DD HH:mm
- 执行命令：`/init`
- CLAUDE.md 更新摘要：<一两句话说明 CLAUDE.md 的变化>
- 关联 commit：<commit hash>

---

## ⛔ 取消标记（仅 cancelled 任务填写，与上方完成标记互斥）

> 任务取消时填写此块，**不需要执行 `/init`**，将文件移入 `docs/todos/cancelled/`。

- 取消时间：YYYY-MM-DD HH:mm
- 取消原因：<例如：方案被替换为 XYZ / 优先级下调 / 上游接口取消>
- 后续指向：<如有继任任务，写明对应的 TODO 路径；否则留空>
