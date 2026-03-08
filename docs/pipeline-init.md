# 任务初始化模块

**功能**: 接收用户新任务，创建任务文件夹和初始文件

---

## 输入

- 用户原始任务描述 (来自[CHANNEL_NAME]频道)
- 项目名 (用户指定或确认后获得)

---

## 处理流程

### 1. 记录原始任务

创建 `original-task.md`:
```markdown
# 原始任务描述

## 用户原文
[用户下发的完整任务消息]

## 任务元数据
- 接收时间：2026-03-05 15:08
- 频道：[CHANNEL_NAME] ([DISCORD_CHAT_ID])
- 用户确认的项目：[项目名]
- 项目确认方式：用户明确指定 / 后续确认

## 任务摘要
[简短摘要，用于汇报]
```

### 2. 生成任务 ID

格式：`task-{YYYYMMDDHHmmss}-{6 位随机码}`

示例：`task-20260305150800-x7y8z9`

### 3. 创建任务文件夹

路径：`/path/to/workspace/tasks/{task-id}/`

### 4. 创建状态文件

创建 `status.md`:
- 阶段：todo
- 状态：pending
- 超时时间：创建时间 + 1 小时

创建 `history.md`:
- 记录任务创建事件

### 5. 更新 INDEX.md

在对应项目下添加任务记录

### 6. 发送确认通知

**搭建期**:
```
📋 任务已接收

【原始任务】[摘要]
【项目】[项目名]
【任务 ID】[task-id]
【运行模式】搭建期

开始需求分析 (todo 阶段)，完成后将向您汇报。
```

**正式期**:
```
✅ 任务已接收

【原始任务】[摘要]
【项目】[项目名]
【任务 ID】[task-id]
【运行模式】正式期

任务已进入流水线，PR 完成后将向您汇报。
```

---

## 输出

- 任务文件夹：`/path/to/workspace/tasks/{task-id}/`
- 初始文件：`original-task.md`, `status.md`, `history.md`
- INDEX.md 更新

---

## 项目确认逻辑

```
1. 检查用户消息是否包含项目关键词
   ├─→ example-project
   ├─→ another-example
   └─→ 其他已知项目

2. 如包含明确项目名
   └─→ 使用该项目

3. 如未包含
   └─→ 发送[CHANNEL_NAME]询问：
       "请确认任务所属项目：
        1. example-project
        2. another-example
        3. 其他 (请指定)"
   └─→ 等待用户回复
```

---

## 代码实现 (伪代码)

```python
def initialize_task(user_message, project=None):
    # 1. 生成任务 ID
    task_id = generate_task_id()
    
    # 2. 创建文件夹
    task_dir = f"/path/to/workspace/tasks/{task_id}"
    os.makedirs(task_dir)
    
    # 3. 创建 original-task.md
    write_original_task(task_dir, user_message, project)
    
    # 4. 创建 status.md
    write_status(task_dir, task_id, project)
    
    # 5. 创建 history.md
    write_history(task_dir, user_message, project)
    
    # 6. 更新 INDEX.md
    update_index(task_id, project)
    
    # 7. 发送通知
    send_notification(task_id, project, mode)
    
    return task_id
```

---
