---
name: task-pipeline
description: 任务流水线处理器。当收到"任务流水线触发"、"spawn-queue"、"待启动任务"等消息时，读取 spawn-queue.md 并使用 spawn 启动子代理。也处理用户的"OK"确认消息以推进等待确认的任务。
allowed-tools: Bash(read_file), Bash(write_file), Bash(edit_file), spawn, message
---

# Task Pipeline Skill - 任务流水线处理

## 触发条件

### 触发条件 1：heartbeat 触发
当收到包含以下关键词的消息时：
- "任务流水线触发"
- "spawn-queue"
- "待启动任务"

**操作**：读取 `tasks/spawn-queue.md` 并使用 spawn 启动子代理。

### 触发条件 2：用户确认
当用户在 Discord 回复"OK"、"确认"、"好的"、"继续"等肯定表达时：

**操作**：扫描 `tasks/task-*/status.md`，查找状态为 `waiting_confirm` 的任务，更新为下一阶段。

---

## 工作流程

### 流程 1：处理 heartbeat 触发

#### 步骤 1：读取 spawn 队列

```bash
read_file path="tasks/spawn-queue.md"
```

解析待启动任务列表，格式：
```markdown
### task-20260311220000-xxx
- **阶段**: brainstorming
- **启动 ID**: spawn-task-xxx-1234567890
```

#### 步骤 2：对每个任务启动子代理

根据任务阶段，使用 `spawn` 工具启动对应的子代理：

**brainstorming 阶段**：
```
spawn task="读取 tasks/{task-id}/original-task.md，使用 brainstorming 方法进行需求澄清。
要求：
1. 通过多轮问答探索用户真实意图（一次只问一个问题）
2. 输出独立的需求文档 requirements.md 到 tasks/{task-id}/
3. 需求文档不包含技术方案
4. 完成后更新 tasks/{task-id}/status.md：
   - 将 brainstorming 阶段状态设为 complete
   - 将整体状态设为 waiting_confirm
   - 阶段保持 brainstorming
5. 从 tasks/active-agents.md 中删除自己的记录（移除包含 {task-id} 的行）
6. 完成后报告结果"
```

**technical-spec 阶段**：
```
spawn task="读取 tasks/{task-id}/requirements.md，基于已确认的需求设计技术方案。
要求：
1. 输出技术方案文档 technical-spec.md 到 tasks/{task-id}/
2. 方案应包括：技术选型、架构设计、接口定义、数据模型等
3. 完成后更新 tasks/{task-id}/status.md：
   - technical-spec 阶段状态设为 complete
   - 整体状态设为 pending
   - 阶段设为 coding
4. 从 tasks/active-agents.md 中删除自己的记录
5. 完成后报告结果"
```

**coding 阶段**：
```
spawn task="读取 tasks/{task-id}/technical-spec.md 和 requirements.md，按照 TDD 原则实现代码。
要求：
1. 先写测试，再写实现
2. 测试覆盖率 ≥ 80%
3. 遵循不可变模式
4. 完成后更新 tasks/{task-id}/status.md：
   - coding 阶段状态设为 complete
   - 整体状态设为 pending
   - 阶段设为 review
5. 从 tasks/active-agents.md 中删除自己的记录
6. 完成后报告结果"
```

**review 阶段**：
```
spawn task="对 tasks/{task-id}/ 中的代码进行审查。
要求：
1. 输出审查报告 review-report.md 到 tasks/{task-id}/
2. 审查内容包括：代码质量、测试覆盖、安全性、性能等
3. 完成后更新 tasks/{task-id}/status.md：
   - review 阶段状态设为 complete
   - 整体状态设为 pending
   - 阶段设为 pr
4. 从 tasks/active-agents.md 中删除自己的记录
5. 完成后报告结果"
```

**pr 阶段**：
```
spawn task="创建 Pull Request，将代码提交到 GitHub。
要求：
1. 创建新分支（不要在 main 分支直接提交）
2. 提交代码并推送到 GitHub
3. 创建 Pull Request
4. 完成后更新 tasks/{task-id}/status.md：
   - pr 阶段状态设为 complete
   - 整体状态设为 complete
   - 阶段设为 complete
   - 记录 PR 链接到 status.md
5. 从 tasks/active-agents.md 中删除自己的记录
6. 完成后报告结果"
```

#### 步骤 3：清理 spawn 队列

所有任务启动完成后，更新 spawn-queue.md：

```markdown
# 子代理启动队列

**最后处理时间**: 2026-03-11 22:05
**状态**: 已处理

---

## 已启动任务

- task-xxx (brainstorming) - 已启动
- task-yyy (coding) - 已启动

```

---

### 流程 2：处理用户确认

#### 步骤 1：检测用户确认消息

当用户在 Discord 回复以下关键词时：
- "OK"
- "确认"
- "好的"
- "继续"
- "没问题"
- "可以"
- 其他肯定表达

#### 步骤 2：扫描 waiting_confirm 任务

```bash
# 扫描所有任务的 status.md
for task_dir in tasks/task-*/; do
    grep "waiting_confirm" "$task_dir/status.md"
done
```

#### 步骤 3：更新任务状态

对每个 waiting_confirm 任务：

1. **确定下一阶段**：
   - brainstorming → technical-spec
   - technical-spec → coding
   - coding → review
   - review → pr
   - pr → complete（不需要确认）

2. **更新 status.md**：
   - 状态：`pending`
   - 阶段：`下一阶段`
   - 最后更新：当前时间

3. **删除通知标记**：
   - 删除 `notified_waiting.md`
   - 删除 `discord_notified.md`

4. **通知用户**：
   ```
   ✅ 任务 {task-id} 已确认，进入 {下一阶段} 阶段
   ```

---

## 错误处理

### spawn 失败
- 记录错误到 `tasks/{task-id}/error.md`
- 更新 status.md 状态为 `failed`
- 从 active-agents.md 移除记录
- 通知用户

### 任务超时
- heartbeat.sh 负责检测超时（创建时间 + 1 小时）
- 超时任务状态更新为 `failed`
- 通知用户

### 无 waiting_confirm 任务
- 如果用户回复"OK"但没有 waiting_confirm 任务：
  - 回复用户："当前没有等待确认的任务"

---

## 状态流转图

```
pending (brainstorming)
    ↓ [heartbeat → spawn]
running (brainstorming)
    ↓ [子代理完成]
waiting_confirm (brainstorming) ← [用户回复 OK]
    ↓ [nanobot 更新]
pending (technical-spec)
    ↓ [heartbeat → spawn]
running (technical-spec)
    ↓ [子代理完成]
pending (coding)  ← 正式期自动，搭建期需确认
    ↓ [heartbeat → spawn]
running (coding)
    ↓ [子代理完成]
pending (review)
    ↓ [heartbeat → spawn]
running (review)
    ↓ [子代理完成]
pending (pr)
    ↓ [heartbeat → spawn]
running (pr)
    ↓ [子代理完成]
complete
```

---

## 示例对话

### 场景 1：heartbeat 触发

**heartbeat.sh**: `nanobot agent -m "【任务流水线触发】检测到 1 个待启动任务..."`

**nanobot**: 
1. 读取 tasks/spawn-queue.md
2. 发现 task-xxx (brainstorming)
3. spawn 启动 brainstorming 子代理
4. 回复："已启动 1 个子代理：task-xxx (brainstorming)"

### 场景 2：用户确认

**nanobot** (Discord): "📋 **任务等待确认** - 任务 task-xxx，请回复 OK 确认"

**用户**: "OK"

**nanobot**:
1. 扫描 waiting_confirm 任务
2. 发现 task-xxx (brainstorming)
3. 更新 status.md: pending, technical-spec
4. 回复："✅ 任务 task-xxx 已确认，进入 technical-spec 阶段"
