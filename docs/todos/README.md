# Xuro TODO 文档目录

本目录承载 Xuro 项目所有功能、重构、Bug 修复任务的 **TODO 文档**。
工作流详见 [`../dev_workflow.md`](../dev_workflow.md)。

---

## 目录结构

```
docs/todos/
├── README.md        # 你正在看的索引
├── _template.md     # 新建 TODO 时复制此文件
├── active/          # 进行中（每个文件 = 一个未完成任务）
├── done/            # 已完成（执行过 /init 之后归档）
└── cancelled/       # 中途取消（不执行 /init，仅留可追溯记录）
```

## 工作流摘要

1. **开工前**：复制 `_template.md` → `active/YYYYMMDD-<slug>.md`，填好目标、范围、验收标准、拆解步骤。
2. **开发中**：每完成一步立即勾选 `[ ]` → `[x]`，并附上对应的文件路径或 commit hash。
3. **完成时**：
   - 全部步骤勾选完毕。
   - 在文件底部填写「✅ 完成标记」块，写上 `/init` 与时间戳。
   - 实际执行 `/init` 刷新根目录 `CLAUDE.md`。
   - 把文件从 `active/` 移到 `done/`。

> 任何跨文件 / 改变外部行为的改动都必须先有 TODO 文档。详见 [`../dev_workflow.md` §1](../dev_workflow.md#1-何时必须建-todo-文档)。

## 命名约定

`YYYYMMDD-<kebab-case-slug>.md`

- 日期：开工当天。
- slug：英文小写连字符，无空格无中文。
- 示例：
  - `20260515-floating-lyric-color-picker.md`
  - `20260520-fix-vtt-parser-utf16-bom.md`
  - `20260601-refactor-paginated-viewmodel.md`

## 索引（可选）

如果同时进行多项任务，可在此处列出 `active/` 下的文件以便概览。空着也无妨——查目录即可。

| 日期 | 文件 | 状态 | 负责人 |
| :--- | :--- | :--- | :--- |
| 2026-05-16 | `active/20260516-startup-loading-performance.md` | active | WuMe-sicx |
| 2026-05-16 | `active/20260516-local-media-download-and-video.md` | active | WuMe-sicx |
