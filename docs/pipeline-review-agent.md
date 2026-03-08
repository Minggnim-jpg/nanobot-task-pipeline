# Review 子代理任务说明

**阶段**: Stage 3 - 代码审查

---

## 输入文件

- `/path/to/workspace/tasks/{task-id}/src/` (源代码)
- `/path/to/workspace/tasks/{task-id}/tests/` (测试代码)
- `/path/to/workspace/tasks/{task-id}/requirements.md` (需求文档)

## 输出文件

- `/path/to/workspace/tasks/{task-id}/review-report.md`

---

## 任务描述

你是一个代码审查工程师。请对已完成的代码进行审查，完成以下工作：

### 1. 代码审查

使用 Claude Code 的 `/code-review` 命令进行审查：

```bash
claude --code-review "审查 src/ 目录下的代码"
```

### 2. 审查报告 (review-report.md)

输出审查报告：

```markdown
# 代码审查报告

## 审查概要
- 审查时间：
- 审查范围：
- 问题总数：

## 问题分类

### 严重问题 (必须修复)
1. [问题描述]
   - 位置：
   - 建议：

### 重要问题 (建议修复)
1. [问题描述]
   - 位置：
   - 建议：

### 轻微问题 (可选修复)
1. [问题描述]
   - 位置：
   - 建议：

## 代码质量评估
- 可读性：⭐⭐⭐⭐⭐
- 可维护性：⭐⭐⭐⭐⭐
- 性能：⭐⭐⭐⭐⭐
- 安全性：⭐⭐⭐⭐⭐

## 测试覆盖
- 覆盖率：XX%
- 未覆盖模块：

## 审查结论
- [ ] 通过，可以提交
- [ ] 需要修复严重问题后重新审查
- [ ] 需要重构
```

---

## 执行方式

使用 Claude Code 的 `/code-review` 命令：

```bash
claude --code-review "审查代码并生成报告"
```

---

## 完成标准

1. review-report.md 包含完整的审查结果
2. 所有严重问题已识别
3. 代码质量评估完成

---

## 错误处理

如遇问题：
1. 记录到 `error-log.md`
2. 更新 `status.md` 状态为 failed
3. 更新 `active-agents.md` 移除自己

---
