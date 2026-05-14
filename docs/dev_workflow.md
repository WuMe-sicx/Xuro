# Xuro 开发工作流准则（强制）

> 本文档是 Xuro 项目所有新功能、重构、Bug 修复任务的**强制工作流**。
> 与 [`guidelines_zh.md`](guidelines_zh.md)（架构/代码规范）互补：本文档约束「做事的顺序」，guidelines 约束「做事的方式」。

---

## 核心规则（不可绕过）

任何项目级、功能级、模块级的开发任务，必须满足：

1. **开工前**：在 `docs/todos/` 目录下创建（或更新）该任务的 **TODO 文档**，并在其中固定目标、范围、验收标准与拆解步骤。
2. **开发中**：每完成一个子项，立即在 TODO 文档中勾选并补充实际产物的引用（文件路径、commit hash 等）。
3. **完成时**：在 TODO 文档底部追加完成标记 `/init`，并实际执行 `/init` 以刷新根目录 `CLAUDE.md`，使代码库文档与最新状态对齐。

> ❌ 跳过 TODO 文档直接写代码 = 违规。
> ❌ 完成功能但未标注并执行 `/init` = 任务未闭环。

---

## 1. 何时必须建 TODO 文档

| 场景 | 是否需要 TODO 文档 |
| :--- | :--- |
| 新增功能 / 新页面 / 新模块 | ✅ 必须 |
| 跨文件重构、架构调整 | ✅ 必须 |
| 影响公共接口的 Bug 修复 | ✅ 必须 |
| 涉及数据模型变更（freezed） | ✅ 必须 |
| 性能/缓存策略调整 | ✅ 必须 |
| 依赖升级（pubspec / Gradle / Pod） | ✅ 默认必须 |
| 单文件内的拼写、格式、注释修复 | ❌ 可省略 |
| 纯文档润色（无运行时 / 构建影响） | ❌ 可省略 |

判断标准：**改动跨过 1 个文件 _或_ 对运行时行为 / 构建产物 / 外部可观察行为有任何变化 → 必须 TODO**。
依赖升级默认归为「必须」：版本变更会影响生成代码、构建、运行时与安全面，仅当能确认是纯格式化、注释、文档润色等无任何运行时或构建影响时才可豁免。

---

## 2. TODO 文档规范

### 2.1 存放位置

```
docs/
└── todos/
    ├── README.md            # 模板与索引
    ├── _template.md         # 复制此模板新建
    ├── active/              # 进行中
    │   └── YYYYMMDD-<slug>.md
    ├── done/                # 已完成（已执行 /init）
    │   └── YYYYMMDD-<slug>.md
    └── cancelled/           # 中途取消（不执行 /init）
        └── YYYYMMDD-<slug>.md
```

### 2.2 命名

`YYYYMMDD-<kebab-case-slug>.md`

- 示例：`20260515-floating-lyric-color-picker.md`
- slug 必须用英文小写连字符，避免空格与中文。

### 2.3 必备字段（详见 `docs/todos/_template.md`）

每个 TODO 文档至少包含：

1. **目标（Goal）**：一句话说明做什么，为什么做。
2. **范围（Scope）**：明确包含 / 不包含哪些改动。
3. **验收标准（Acceptance）**：可验证的成功条件（测试、UI 表现、API 行为）。
4. **拆解步骤（Steps）**：带复选框的有序步骤，每步给出验证方法。
5. **风险与回滚（Risks）**：可能影响的现有功能、回滚方案。
6. **完成标记（Done Marker）**：`/init` 行 + 执行时间戳。

### 2.4 生命周期

```
草拟 → 移入 active/ → 开发 + 勾选 → 全部勾选 + /init → 移入 done/
                                   └─ 中途取消 → 移入 cancelled/
```

- **进行中（active）**：文件位于 `docs/todos/active/`。
- **完成（done）**：勾选全部步骤，填写「✅ 完成标记」块，**实际执行 `/init`** 刷新根 `CLAUDE.md`，将文件移入 `docs/todos/done/`。`done/` 的语义就是「已完成且已执行 /init」，不混入其他状态。
- **废弃（cancelled）**：任务中途取消，**不执行 `/init`，不需要填写完成标记块**。把模板里的 `状态：active` 改为 `状态：cancelled`，在文件末尾补写「取消原因」一段，然后将文件移入 `docs/todos/cancelled/`（保留可追溯性）。

---

## 3. `/init` 完成标记

`/init` 是 Claude Code 提供的代码库自描述刷新命令，会基于当前代码扫描并更新根目录 `CLAUDE.md`。

### 3.1 何时执行

**功能完成 = 全部验收标准通过 ⇒ 立即执行 `/init`**。

理由：
- `CLAUDE.md` 是 AI 协作的入口文档，落后会让后续会话基于过期信息做判断。
- TODO 文档关注「这次做了什么」，`CLAUDE.md` 关注「整个项目现在长什么样」，必须同步推进。

### 3.2 如何在 TODO 中标记

在 TODO 文档底部追加：

```markdown
---
## ✅ 完成标记

- 完成时间：2026-05-15 14:30
- 执行命令：`/init`
- CLAUDE.md 更新摘要：<一两句话说明 CLAUDE.md 的变化>
- 关联 commit：<commit hash>
```

### 3.3 执行后核对

- [ ] `CLAUDE.md` 中的目录树、模块描述与现状一致。
- [ ] 新增/重命名的服务、ViewModel、Screen 已被反映。
- [ ] 失效内容（已删除的文件、过期的命令）已被移除。

---

## 4. 与其他规范的关系

| 文档 | 约束什么 |
| :--- | :--- |
| **dev_workflow.md（本文）** | 任务流程：TODO → 开发 → /init |
| [`guidelines_zh.md`](guidelines_zh.md) | 架构、代码风格、命名、字符串管理 |
| [`ui-design-spec.md`](ui-design-spec.md) | 视觉设计令牌、动画、组件标准 |
| [`audio_architecture.md`](audio_architecture.md) | 音频子系统的事件驱动架构 |
| [`architecture.md`](architecture.md) | 早期架构草图（历史参考） |

冲突时的优先级：**dev_workflow > 项目子系统文档 > 通用 guidelines**。

### 4.1 与 CCG / Coder 工作流的对接

若全局 CCG 规则启用（`~/.ccg-mcp/config.toml` 中 `[coder].enabled = true`，或 `CCG_CODER_ENABLED=true`）：

- **同一变更集原则**：TODO 文档、本次代码改动、`/init` 生成的 `CLAUDE.md` diff 属于**同一变更集**，必须一起经过 Codex review 后才算闭环。
- **谁来执行**：当 Coder 启用且任务应走 Coder 时，TODO 内的实施步骤、`/init` 触发的 `CLAUDE.md` 更新均由 Coder 完成；Claude 仅做规划与快速验证，最终由 Codex review 出具 ✅ PASS 才能合入。
- **谁来执行 /init**：`/init` 本身是 Claude Code 的 slash 命令，由当前会话中持握指令的角色触发；产生的 `CLAUDE.md` 修改若 Coder 启用，仍需经过 Codex review。
- 若 Coder 未启用：按本文档默认流程执行，无需强制走 Coder/Codex。

---

## 5. 检查清单

清单分两段使用：**「开发中提交」**用于过程中阶段性 commit／PR；**「功能完成」**用于宣告任务闭环。

### 5.1 开发中提交（每次中间 commit / PR）

- [ ] 本次改动对应的 TODO 文档存在并位于 `docs/todos/active/`。
- [ ] TODO 文档的已完成步骤已勾选并附上对应文件路径或 commit hash。
- [ ] 已运行 `flutter analyze`；涉及 model 改动已运行 `dart run build_runner build --delete-conflicting-outputs`。
- [ ] 相关单元 / Widget 测试通过。
- [ ] commit message 引用了 TODO 文档路径（如 `feat(player): xxx (refs docs/todos/active/20260515-...)`）。

### 5.2 功能完成（任务闭环前最后一次提交）

- [ ] TODO 文档的全部步骤已勾选，全部验收标准已通过。
- [ ] 已实际执行 `/init` 并人工核对根目录 `CLAUDE.md`（参见 §3.3）。
- [ ] TODO 文档底部「✅ 完成标记」块已填写完整。
- [ ] TODO 文档已从 `docs/todos/active/` 移入 `docs/todos/done/`。
- [ ] commit message 引用了归档后的路径（如 `feat(player): xxx (closes docs/todos/done/20260515-...)`）。

> 任意一项未满足 → 任务未闭环，不可宣告完成。
