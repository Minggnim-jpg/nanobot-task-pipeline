# 需求澄清子代理 (Brainstorming Agent)

**任务**: 使用 brainstorming skill 澄清用户需求，输出确认后的 requirements.md

---

## 输入

- `tasks/{task-id}/original-task.md` - 用户原始任务描述

## 输出

- `tasks/{task-id}/requirements.md` - 确认后的需求文档
- `tasks/{task-id}/status.md` - 状态更新为 `waiting_confirm`（等待用户确认需求）

## 执行步骤

### 1. 读取原始任务

```bash
cat tasks/{task-id}/original-task.md
```

### 2. 调用 Claude Code 进行需求澄清

```bash
cd /root/.nanobot/workspace

claude "
你是一个需求分析师。请使用 brainstorming skill 澄清这个任务的需求。

任务文件：tasks/{task-id}/original-task.md

请遵循以下原则：
1. 一次只问一个问题，不要堆砌
2. 优先使用选择题（A/B/C），必要时开放问题
3. 聚焦于：目的、约束、成功标准
4. 记录用户的重要决策

最终输出：
- tasks/{task-id}/requirements.md（需求文档）

<HARD-GATE>
在需求文档获得用户确认之前，禁止：
- 调用任何实现类 skill
- 编写任何代码
- 搭建任何项目结构
- 采取任何实现行动
</HARD-GATE>
"
```

### 3. 更新状态

需求文档创建后，更新状态文件：

```markdown
# 任务状态

**任务 ID**: {task-id}
**当前阶段**: brainstorming
**状态**: waiting_confirm
**等待内容**: 用户确认需求文档
**创建时间**: YYYY-MM-DD HH:MM
**更新时间**: YYYY-MM-DD HH:MM
```

### 4. 通知用户（搭建期）

在搭建期，需要通知用户确认需求：

```
📋 需求文档已创建，请确认

任务：{task-name}
文档：tasks/{task-id}/requirements.md

请回复：
- "OK" 或 "确认" → 进入技术方案阶段
- 修改意见 → 更新需求文档后重新确认
```

---

## 注意事项

1. **不要跳过**：即使用户需求看起来很清楚，也要进行基本的澄清确认
2. **记录决策**：用户的重要决策要记录在需求文档的变更记录中
3. **边界清晰**：需求确认后，超出范围的新需求需要重新评估
4. **简单任务简化**：对于非常简单的任务，可以简化流程，但不能跳过确认环节
