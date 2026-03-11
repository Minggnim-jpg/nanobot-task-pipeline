# v2.0.0 - 完整流水线系统 (2026-03-12)

## 🎉 重大更新

本次更新完成了任务流水线系统的完整实现和测试，支持从需求澄清到 PR 提交的全自动化流程。

---

## ✨ 新增功能

### 核心功能

- **5 阶段流水线**: brainstorming → technical-spec → coding → review → PR
- **心跳轮询**: 每 5 分钟自动检查并启动待执行任务
- **子代理管理**: 同时活跃子代理 ≤ 5 个，防止资源耗尽
- **双运行模式**: 搭建期 (每阶段确认) / 正式期 (自动流转)
- **用户确认**: Discord 回复"OK"即可推进任务
- **超时保护**: 1 小时超时自动抛弃僵尸任务
- **异常处理**: 非 Git 仓库自动跳过 PR 步骤

### 状态流转

```
pending → [heartbeat] → running → [完成] → waiting_confirm → [用户确认] → 下一阶段
```

---

## 📁 新增文件

### Skills

- `skills/task-pipeline.md` - 核心流水线处理器 skill

### Scripts

- `scripts/pipeline-heartbeat.sh` - 心跳轮询脚本 (每 5 分钟执行)

### Templates

- `tasks-templates/status.md` - 任务状态跟踪模板
- `tasks-templates/original-task.md` - 原始任务记录模板
- `tasks-templates/requirements.md` - 需求文档模板
- `tasks-templates/technical-spec.md` - 技术方案模板

### Docs

- `docs/TEST_REPORT.md` - v2.0 完整测试报告

---

## 🧪 测试验证

| 阶段 | 状态 |
|------|------|
| Brainstorming | ✅ 通过 |
| Technical-Spec | ✅ 通过 |
| Coding | ✅ 通过 |
| Review | ✅ 通过 |
| PR | ✅ 通过 |

**核心功能验证**:
- ✅ 子代理启动/完成机制正常
- ✅ 状态跟踪和计数更新准确
- ✅ 用户确认等待机制正常
- ✅ 异常处理逻辑正确

---

## 🔧 配置说明

### 环境变量

```bash
# nanobot workspace 路径
export NANOBOT_WORKSPACE="$HOME/.nanobot/workspace"

# Discord 用户 ID (用于通知)
export DISCORD_CHAT_ID="YOUR_DISCORD_CHAT_ID"
```

### Crontab 配置

```bash
# 每 5 分钟执行心跳检查
*/5 * * * * /path/to/pipeline-heartbeat.sh
```

---

## 📋 使用示例

### 1. 创建任务

```bash
mkdir -p tasks/task-20260312000000-abc123
cp tasks-templates/status.md tasks/task-20260312000000-abc123/
cp tasks-templates/original-task.md tasks/task-20260312000000-abc123/
```

### 2. 编辑任务信息

编辑 `status.md`:
```markdown
## 基本信息
- **任务 ID**: task-20260312000000-abc123
- **项目**: my-project
- **任务摘要**: 实现 XXX 功能
- **运行模式**: 搭建期
```

### 3. 等待心跳触发

心跳脚本会自动：
1. 检测 pending 状态的任务
2. 更新状态为 running
3. 添加到 spawn 队列
4. 触发 nanobot 处理

### 4. 用户确认

当任务进入 `waiting_confirm` 状态时，在 Discord 回复"OK"继续。

---

## ⚠️ 注意事项

1. **首次使用**: 修改 `pipeline-heartbeat.sh` 中的 `WORKSPACE` 和 `DISCORD_CHAT_ID`
2. **测试覆盖率**: coding 阶段要求 ≥80% 测试覆盖率
3. **超时时间**: 每个阶段 1 小时超时，超时任务会被标记为 failed
4. **子代理限制**: 同时活跃子代理 ≤ 5 个，超出会等待

---

## 🐛 已知问题

- coding 子代理可能因任务复杂度超时而失败
- 测试覆盖率不足时 review 阶段会报告但不会阻止流转

---

## 📝 升级指南

从 v1.x 升级到 v2.0:

1. 备份现有任务目录
2. 复制新的 `scripts/pipeline-heartbeat.sh`
3. 复制新的 `skills/task-pipeline.md`
4. 复制 `tasks-templates/` 目录
5. 更新 crontab 配置
6. 重启 nanobot 服务
