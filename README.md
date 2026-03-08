# 任务流水线系统 (Task Pipeline System)

> 🤖 基于 nanobot + Claude Code 的自动化任务执行引擎

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/Minggnim-jpg/nanobot-task-pipeline/releases)
[![Status](https://img.shields.io/badge/status-stable-green.svg)](https://github.com/Minggnim-jpg/nanobot-task-pipeline)

**版本**: v1.0.0  
**创建时间**: 2026-03-05  
**最后更新**: 2026-03-08  
**状态**: 🟢 生产就绪 / 已开源

---

## 📋 系统概述

任务流水线系统是一个自动化的任务执行引擎，通过心跳轮询机制调度多个子代理，按阶段完成编码任务。

### 核心特性

| 特性 | 描述 |
|------|------|
| **多阶段流水线** | todo → coding → review → PR 四阶段自动流转 |
| **心跳轮询** | 每 5 分钟检查任务状态，自动启动待执行任务 |
| **子代理限制** | 同时活跃子代理 ≤ 5 个，防止资源耗尽 |
| **超时保护** | 所有阶段统一 1 小时超时，自动抛弃僵尸任务 |
| **双运行模式** | 搭建期（每阶段确认）/ 正式期（自动流转） |
| **完整审计** | 每个任务保留完整执行历史和输出文件 |

---

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        nanobot Gateway                          │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              心跳调度器 (interval: 30 分钟)                │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │           心跳 Agent (heartbeat.jsonl 会话)              │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │         pipeline-heartbeat.sh (每 5 分钟执行)             │    │
│  │  - 读取活跃子代理数量                                    │    │
│  │  - 扫描任务状态文件                                      │    │
│  │  - 检查超时任务 → 标记 abandoned                         │    │
│  │  - 启动待执行任务的子代理                                │    │
│  │  - 更新 active-agents.md                                 │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      任务目录 (/tasks/)                         │
│  ├── INDEX.md              ← 任务索引（按项目/状态分类）         │
│  ├── pipeline-mode.md      ← 运行模式配置                       │
│  ├── active-agents.md      ← 活跃子代理计数                     │
│  ├── templates/            ← 任务文件模板                       │
│  └── task-{task-id}/       ← 具体任务目录                       │
│      ├── original-task.md  ← 用户原始任务描述                   │
│      ├── status.md         ← 当前状态                           │
│      ├── history.md        ← 执行历史                           │
│      ├── requirements.md   ← 需求文档                           │
│      ├── technical-spec.md ← 技术方案                           │
│      ├── review-report.md  ← 审查报告                           │
│      └── pr-info.md        ← PR 信息                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 目录结构

```
pipeline-archive/
├── README.md                     # 本文件
├── INDEX.md                      # 任务索引
├── docs/                         # 设计文档
│   ├── pipeline-architecture.md  # 系统架构设计
│   ├── pipeline-init.md          # 初始化模块
│   ├── pipeline-todo-agent.md    # todo 子代理
│   ├── pipeline-coding-agent.md  # coding 子代理
│   ├── pipeline-review-agent.md  # review 子代理
│   └── pipeline-pr-module.md     # PR 提交模块
├── scripts/                      # 可执行脚本
│   └── pipeline-heartbeat.sh     # 心跳轮询脚本
├── config/                       # 配置文件
│   ├── pipeline-mode.md          # 运行模式
│   └── active-agents.md          # 活跃子代理计数
├── tasks-templates/              # 任务文件模板
│   ├── history.md.template
│   ├── original-task.md.template
│   └── status.md.template
└── examples/                     # 示例任务
    └── task-20260305152600-k9m2n7/  # 扑克牌比较工具（已完成）
```

---

## 🔄 流水线阶段

| 阶段 | 输入 | 输出 | 子代理 |
|------|------|------|--------|
| **1. todo** | 用户原始任务 | `requirements.md`, `technical-spec.md` | todo-agent |
| **2. coding** | 技术方案 | `src/`, `tests/` | coding-agent |
| **3. review** | 源代码 + 测试 | `review-report.md` | review-agent |
| **4. PR** | 审查通过的代码 | GitHub Pull Request | pr-module |

---

## 🎯 运行模式

### 搭建期 (Development Mode)

- 每个阶段完成后等待用户回复 "OK" 确认
- 每阶段发送详细通知
- 适合系统调试和流程验证

### 正式期 (Production Mode)

- 自动流转，无需阶段确认
- 只在 PR 完成/失败时发送通知
- 适合日常生产使用

**切换命令**:
```
切换到正式期 / pipeline-mode formal
切换到搭建期 / pipeline-mode dev
```

---

## ⏱️ 心跳轮询逻辑

```bash
1. 读取 active-agents.md → 获取活跃子代理数量
2. 如数量 ≥ 5 → 跳过本次轮询
3. 扫描 /tasks/*/status.md
   ├─→ 检查超时 → 状态=abandoned
   ├─→ 状态=failed/complete/abandoned → 跳过
   └─→ 状态=pending/waiting_confirm → 检查阶段
4. 对于每个待执行任务：
   ├─→ [搭建期] waiting_confirm → 等待用户"OK"，跳过
   └─→ [正式期] pending → 活跃子代理<5 → 启动子代理
5. 更新 active-agents.md
```

---

## 📊 任务状态机

```
                    ┌─────────────┐
                    │   pending   │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
         ┌─────────│   running   │─────────┐
         │         └──────┬──────┘         │
         │                │                │
         │                ▼                │
         │         ┌─────────────┐         │
         │         │  complete   │         │
         │         └─────────────┘         │
         │                                 │
         ▼                                 ▼
┌─────────────┐                   ┌─────────────┐
│   failed    │                   │  abandoned  │
│ (错误/超时)  │                   │   (超时)    │
└─────────────┘                   └─────────────┘
```

---

## 🔧 配置说明

### nanobot Gateway 心跳

```json
{
  "gateway": {
    "heartbeat": {
      "enabled": true,
      "intervalS": 1800
    }
  }
}
```

- `enabled`: 是否启用内置心跳调度器
- `intervalS`: 心跳间隔（秒），默认 1800 秒（30 分钟）

### 心跳脚本配置

```bash
# pipeline-heartbeat.sh 头部配置
WORKSPACE="/path/to/workspace"
TASKS_DIR="$WORKSPACE/tasks"
ACTIVE_AGENTS_FILE="$TASKS_DIR/active-agents.md"
MAX_AGENTS=5
LOG_FILE="$WORKSPACE/heartbeat-log.md"
```

---

## 📝 任务 ID 规则

格式：`task-{YYYYMMDDHHmmss}-{6 位随机码}`

示例：`task-20260305152600-k9m2n7`

- `20260305152600`: 2026 年 3 月 5 日 15:26:00
- `k9m2n7`: 6 位随机字符（小写字母 + 数字）

---

## 📢 通知策略

| 模式 | 阶段 | 通知 |
|------|------|------|
| 搭建期 | 每阶段完成 | ✅ 发送，等待"OK"确认 |
| 搭建期 | 失败 | ✅ 立即发送 |
| 正式期 | PR 完成 | ✅ 发送 |
| 正式期 | 失败 | ✅ 立即发送 |
| 正式期 | 其他阶段 | ❌ 不发送 |

---

## 🚀 使用示例

### 创建新任务

```bash
# 1. 创建任务目录
mkdir -p /path/to/workspace/tasks/task-20260308105200-abc123

# 2. 创建 original-task.md
cat > /path/to/workspace/tasks/task-20260308105200-abc123/original-task.md << EOF
# 原始任务描述

## 用户原文
[用户任务描述]

## 任务元数据
- 接收时间：2026-03-08 10:52
- 频道：discord
- 用户确认的项目：example-project
- 项目确认方式：用户明确指定

## 任务摘要
[简短摘要]
EOF

# 3. 创建 status.md
cat > /path/to/workspace/tasks/task-20260308105200-abc123/status.md << EOF
# 任务状态

## 基本信息
- 任务 ID: task-20260308105200-abc123
- 项目：example-project
- 创建时间：2026-03-08 10:52
- 任务摘要：[摘要]
- 运行模式：正式期

## 当前状态
- 阶段：todo
- 状态：pending
- 最后更新：2026-03-08 10:52
- 超时时间：2026-03-08 11:52
EOF

# 4. 等待心跳轮询自动启动子代理
```

### 查看任务状态

```bash
# 查看所有任务索引
cat /path/to/workspace/tasks/INDEX.md

# 查看具体任务状态
cat /path/to/workspace/tasks/task-{task-id}/status.md

# 查看活跃子代理
cat /path/to/workspace/tasks/active-agents.md
```

---

## 🐛 已知问题与解决

| 问题 | 日期 | 状态 | 解决方案 |
|------|------|------|----------|
| 心跳通知重复发送 | 2026-03-05 | ✅ 已解决 | 删除 cron job + 会话文件 |
| 心跳通知持续出现 | 2026-03-06 | ✅ 已解决 | 修改 heartbeat.jsonl 禁止通知 |
| gateway 内存缓存旧配置 | 2026-03-06 | ✅ 已解决 | 重启 gateway 服务 |

---

## 📈 运行统计

| 指标 | 数值 |
|------|------|
| 累计心跳检查 | 150+ 次 |
| 完成任务 | 1 个 (task-20260305152600-k9m2n7) |
| 平均心跳间隔 | 5 分钟 |
| 系统正常运行时间 | 3 天+ |

---

## 🔒 脱敏说明

> ⚠️ **重要**: 本仓库已进行脱敏处理，所有敏感信息已替换为占位符。

### 已脱敏的内容

| 类型 | 占位符 | 说明 |
|------|--------|------|
| Discord Chat ID | `[DISCORD_CHAT_ID]` | Discord 频道/用户 ID |
| 本地文件路径 | `/path/to/workspace` | 实际工作目录路径 |
| 项目名称 | `example-project`, `another-example` | 实际项目名 |
| Git 提交哈希 | `[COMMIT_HASH]` | 实际提交记录 |
| 频道名称 | `[CHANNEL_NAME]` | 实际频道名 |
| 邮箱地址 | `[YOUR_EMAIL]` | 实际 Git 邮箱 |

### 使用前需要替换

如果你要部署此系统，请在以下文件中替换占位符：

| 文件 | 需要替换的内容 |
|------|----------------|
| `scripts/pipeline-heartbeat.sh` | `[DISCORD_CHAT_ID]` → 你的 Discord 频道 ID |
| `docs/pipeline-*.md` | `/path/to/workspace` → 你的实际工作目录 |
| `examples/` 目录 | 仅作为参考，可删除或替换为你的示例 |

### 示例：配置通知

```bash
# 编辑 pipeline-heartbeat.sh
sed -i 's/\[DISCORD_CHAT_ID\]/1234567890/g' scripts/pipeline-heartbeat.sh

# 编辑工作目录路径
sed -i 's|/path/to/workspace|/home/user/nanobot/workspace|g' scripts/pipeline-heartbeat.sh
```

---

## 🔗 相关资源

- [nanobot 文档](https://github.com/nanobot-ai/nanobot)
- [Claude Code 最佳实践](https://code.claude.com/docs/en/best-practices)
- [Evolver 自我进化引擎](./docs/evolver.md)
- [贡献指南](./CONTRIBUTING.md)
- [安全策略](./SECURITY.md)

---

## 🤝 贡献

我们欢迎各种形式的贡献！请查看 [贡献指南](./CONTRIBUTING.md) 了解如何参与。

---

## 📄 许可证

本项目采用 [MIT 许可证](./LICENSE)。

简单来说：
- ✅ 你可以自由使用、修改、分发
- ✅ 商业项目也可以使用
- ⚠️ 请保留原作者版权声明
- ❌ 不提供任何担保

---

## 📬 联系方式

- **作者**: Minggnim-jpg
- **Issues**: [提交 Issue](https://github.com/Minggnim-jpg/nanobot-task-pipeline/issues)
- **Discussions**: [参与讨论](https://github.com/Minggnim-jpg/nanobot-task-pipeline/discussions)

---

*最后更新：2026-03-08 20:15 (CST)*

**🌟 如果这个项目对你有帮助，请给个 Star！**
