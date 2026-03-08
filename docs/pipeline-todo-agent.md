# Todo 子代理任务说明

**阶段**: Stage 1 - 需求分析

---

## 输入文件

- `/path/to/workspace/tasks/{task-id}/original-task.md`

## 输出文件

- `/path/to/workspace/tasks/{task-id}/requirements.md`
- `/path/to/workspace/tasks/{task-id}/technical-spec.md`

---

## 任务描述

你是一个需求分析师。请根据用户的原始任务描述，完成以下工作：

### 1. 需求分析 (requirements.md)

分析用户原始任务，输出详细的需求文档：

```markdown
# 需求文档

## 任务背景
[为什么要做这个功能]

## 功能需求
### 功能 1
- 描述
- 输入
- 输出
- 边界条件

### 功能 2
...

## 非功能需求
- 性能要求
- 安全要求
- 兼容性要求

## 验收标准
- [ ] 标准 1
- [ ] 标准 2
...
```

### 2. 技术方案 (technical-spec.md)

根据需求文档，设计技术方案：

```markdown
# 技术方案

## 技术选型
- 语言：
- 框架：
- 依赖库：

## 架构设计
[架构图/说明]

## 模块划分
### 模块 1
- 职责
- 接口

### 模块 2
...

## 数据结构
[关键数据结构]

## 算法设计
[关键算法]

## 测试策略
- 单元测试
- 集成测试
- 边界测试

## 实施计划
1. 步骤 1
2. 步骤 2
...
```

---

## 执行方式

使用 Claude Code 的 `/plan` 命令进行规划：

```bash
claude --plan "根据 original-task.md 进行需求分析和技术方案设计"
```

---

## 完成标准

1. requirements.md 包含完整的功能和非功能需求
2. technical-spec.md 包含清晰的技术方案
3. 两个文档都经过自检，无明显遗漏

---

## 错误处理

如遇问题：
1. 记录到 `error-log.md`
2. 更新 `status.md` 状态为 failed
3. 更新 `active-agents.md` 移除自己

---
