# 🎉 Release Notes - v1.0.0

**发布日期**: 2026-03-08  
**版本类型**: 稳定版 (Stable)  
**GitHub Release**: [v1.0.0](https://github.com/Minggnim-jpg/nanobot-task-pipeline/releases/tag/v1.0.0)

---

## 📦 概述

**nanobot-task-pipeline v1.0.0** 是一个基于 nanobot + Claude Code 的自动化任务执行引擎，通过心跳轮询机制调度多个子代理，按阶段完成编码任务。

这是首个公开版本，经过生产环境验证，已稳定运行 3+ 天。

---

## ✨ 核心功能

### 🔄 多阶段流水线

```
todo → coding → review → PR
```

| 阶段 | 功能 | 输出 |
|------|------|------|
| **todo** | 需求分析 | `requirements.md`, `technical-spec.md` |
| **coding** | 代码实现 | `src/`, `tests/` |
| **review** | 代码审查 | `review-report.md` |
| **PR** | 提交 PR | GitHub Pull Request |

### ⏱️ 心跳轮询

- **间隔**: 每 5 分钟自动检查任务状态
- **并发限制**: 最多 5 个活跃子代理
- **超时保护**: 1 小时超时，自动清理僵尸任务

### 🎯 双运行模式

| 模式 | 适用场景 | 特点 |
|------|----------|------|
| **搭建期** | 系统调试 | 每阶段等待用户确认 |
| **正式期** | 生产使用 | 自动流转，仅关键节点通知 |

---

## 📁 目录结构

```
nanobot-task-pipeline/
├── README.md                     # 项目说明
├── LICENSE                       # MIT 许可证
├── CONTRIBUTING.md               # 贡献指南
├── SECURITY.md                   # 安全策略
├── INDEX.md                      # 任务索引
├── docs/                         # 设计文档
│   ├── pipeline-architecture.md  # 系统架构
│   ├── pipeline-init.md          # 初始化模块
│   ├── pipeline-todo-agent.md    # todo 子代理
│   ├── pipeline-coding-agent.md  # coding 子代理
│   ├── pipeline-review-agent.md  # review 子代理
│   └── pipeline-pr-module.md     # PR 提交模块
├── scripts/                      # 可执行脚本
│   └── pipeline-heartbeat.sh     # 心跳轮询脚本
├── config/                       # 配置文件
│   └── pipeline-mode.md          # 运行模式配置
├── tasks-templates/              # 任务文件模板
└── examples/                     # 示例任务
```

---

## 🚀 快速开始

### 前置要求

- [nanobot](https://github.com/nanobot-ai/nanobot) v1.0+
- Bash shell
- Git

### 安装步骤

```bash
# 1. Clone 仓库
git clone https://github.com/Minggnim-jpg/nanobot-task-pipeline.git
cd nanobot-task-pipeline

# 2. 配置工作目录
# 编辑 scripts/pipeline-heartbeat.sh
WORKSPACE="/your/workspace/path"

# 3. 配置通知（可选）
# 替换 [DISCORD_CHAT_ID] 为你的 Discord 频道 ID

# 4. 设置执行权限
chmod +x scripts/pipeline-heartbeat.sh

# 5. 配置 nanobot Gateway
# 将 heartbeat.jsonl 放入 nanobot 会话目录
```

### 创建第一个任务

```bash
# 创建任务目录
mkdir -p /your/workspace/tasks/task-$(date +%Y%m%d%H%M%S)-abc123

# 使用模板创建任务文件
cp tasks-templates/*.md.template /your/workspace/tasks/task-*/

# 编辑 original-task.md 添加任务描述
# 等待心跳轮询自动启动子代理
```

---

## 📊 运行统计

| 指标 | 数值 |
|------|------|
| 累计心跳检查 | 150+ 次 |
| 完成任务 | 1 个 |
| 平均心跳间隔 | 5 分钟 |
| 系统正常运行时间 | 3 天+ |
| 并发子代理上限 | 5 个 |

---

## 🔧 配置说明

### 心跳调度器

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

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `enabled` | `true` | 是否启用心跳 |
| `intervalS` | `1800` | 心跳间隔（秒） |

### 任务超时

| 阶段 | 超时时间 |
|------|----------|
| todo | 1 小时 |
| coding | 1 小时 |
| review | 1 小时 |
| PR | 1 小时 |

---

## 🐛 已知问题

| 问题 | 影响 | 状态 |
|------|------|------|
| 无 | - | ✅ 无已知问题 |

---

## 📝 更新日志

### v1.0.0 (2026-03-08)

**🎉 首次公开发布**

#### 新增功能

- ✅ 多阶段任务流水线系统
- ✅ 心跳轮询调度器
- ✅ 子代理并发控制
- ✅ 任务超时保护
- ✅ 双运行模式（搭建期/正式期）
- ✅ 完整任务审计日志

#### 文档

- ✅ README.md - 项目说明
- ✅ CONTRIBUTING.md - 贡献指南
- ✅ SECURITY.md - 安全策略
- ✅ 系统架构设计文档
- ✅ 各模块详细设计文档

#### 安全

- ✅ 敏感信息脱敏处理
- ✅ Git 历史清理
- ✅ MIT 许可证

---

## 🔮 路线图

### v1.1.0 (计划中)

- [ ] Web 管理界面
- [ ] 任务优先级队列
- [ ] 自定义通知渠道
- [ ] 任务依赖关系

### v2.0.0 (未来)

- [ ] 多项目并行支持
- [ ] 插件系统
- [ ] 性能分析和优化建议
- [ ] 与更多 AI 工具集成

---

## 🤝 贡献

我们欢迎各种形式的贡献！

- 🐛 报告 Bug: [创建 Issue](https://github.com/Minggnim-jpg/nanobot-task-pipeline/issues/new?template=bug_report.md)
- 💡 功能建议: [创建 Issue](https://github.com/Minggnim-jpg/nanobot-task-pipeline/issues/new?template=feature_request.md)
- 🔧 提交代码: [查看贡献指南](CONTRIBUTING.md)

---

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE)。

---

## 🙏 致谢

感谢以下项目和工具：

- [nanobot](https://github.com/nanobot-ai/nanobot) - AI 助手框架
- [Claude Code](https://code.claude.com/) - AI 编码助手
- [Exa MCP](https://exa.ai/) - 网络搜索工具

---

## 📬 联系方式

- **作者**: Minggnim-jpg
- **Issues**: [GitHub Issues](https://github.com/Minggnim-jpg/nanobot-task-pipeline/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Minggnim-jpg/nanobot-task-pipeline/discussions)

---

**🌟 如果这个项目对你有帮助，请给个 Star！**

---

*Release Notes 最后更新：2026-03-08 20:15 (CST)*
