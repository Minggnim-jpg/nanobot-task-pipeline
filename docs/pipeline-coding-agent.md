# Coding 子代理任务说明

**阶段**: Stage 2 - 开发编码

---

## 输入文件

- `/path/to/workspace/tasks/{task-id}/requirements.md`
- `/path/to/workspace/tasks/{task-id}/technical-spec.md`

## 输出文件

- `/path/to/workspace/tasks/{task-id}/src/` (源代码目录)
- `/path/to/workspace/tasks/{task-id}/tests/` (测试代码目录)

---

## 任务描述

你是一个开发工程师。请根据需求文档和技术方案，完成以下工作：

### 1. 编码实现

按照技术方案中的模块划分，实现所有功能模块：

- 遵循最佳实践文档 (`/root/.claude/BEST_PRACTICES.md`)
- 使用 `/tdd` 命令进行测试驱动开发
- 测试覆盖率 ≥ 80%
- 遵循不可变模式
- 代码审查前安全检查

### 2. 编写测试

为所有功能模块编写单元测试：

- 正常路径测试
- 边界条件测试
- 异常处理测试

---

## 执行方式

使用 Claude Code 的 `/tdd` 命令进行开发：

```bash
claude --tdd "根据 requirements.md 和 technical-spec.md 实现功能"
```

---

## 完成标准

1. 所有功能模块已实现
2. 测试覆盖率 ≥ 80%
3. 所有测试通过
4. 代码符合最佳实践

---

## 超时处理

- 超时时间：1 小时 (从阶段开始时间计算)
- 超时后自动抛弃任务
- 记录 `error-log.md`

---

## 错误处理

如遇问题：
1. 记录到 `error-log.md`
2. 更新 `status.md` 状态为 failed
3. 更新 `active-agents.md` 移除自己

---
