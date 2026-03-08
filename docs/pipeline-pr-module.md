# PR 提交模块说明

**阶段**: Stage 4 - PR 提交

---

## 输入文件

- `/path/to/workspace/tasks/{task-id}/src/` (源代码)
- `/path/to/workspace/tasks/{task-id}/tests/` (测试代码)
- `/path/to/workspace/tasks/{task-id}/review-report.md` (审查报告)

## 输出

- GitHub PR 链接
- 更新 `status.md` 状态为 complete

---

## 任务描述

你是一个发布工程师。请将已审查通过的代码提交到 GitHub，完成以下工作：

### 1. 准备工作

```bash
# 进入任务目录
cd /path/to/workspace/tasks/{task-id}/

# 检查审查报告
cat review-report.md

# 确认无严重问题
```

### 2. Git 操作

```bash
# 配置 Git
git config --global user.name "nanobot"
git config --global user.email "[YOUR_EMAIL]"

# 进入项目仓库 (根据任务所属项目)
cd /path/to/{project}/

# 创建功能分支
git checkout -b feature/{task-id}

# 复制源代码
cp /path/to/workspace/tasks/{task-id}/src/* ./

# 提交代码
git add .
git commit -m "feat: [任务摘要]

- 任务 ID: {task-id}
- 详见：review-report.md"

# 推送到 GitHub
git push origin feature/{task-id}
```

### 3. 创建 PR

使用 GitHub API 或 `gh` 命令：

```bash
# 使用 gh 命令
gh pr create \
  --title "feat: [任务摘要]" \
  --body "## 任务描述
[来自 original-task.md]

## 任务 ID
{task-id}

## 审查报告
详见：review-report.md

## 测试
- [ ] 单元测试通过
- [ ] 集成测试通过" \
  --base main \
  --head feature/{task-id}
```

---

## 完成标准

1. 代码已推送到 GitHub
2. PR 已创建
3. PR 链接已记录到 `status.md`

---

## 错误处理

如遇问题：
1. 记录到 `error-log.md`
2. 更新 `status.md` 状态为 failed
3. 发送[CHANNEL_NAME]通知

---

## 通知模板

**正式期完成**:
```
✅ 任务完成

【原始任务】[摘要]
【项目】[项目名]
【任务 ID】[task-id]
【运行模式】正式期

【PR 链接】
https://github.com/{owner}/{repo}/pull/{number}

【执行摘要】
- todo: 完成 (时间)
- coding: 完成 (时间)
- review: 完成 (时间)
- PR: 完成 (时间)

请查看 PR 并确认是否合并。
```

---
