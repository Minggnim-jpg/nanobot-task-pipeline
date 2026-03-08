# 贡献指南 (Contributing Guidelines)

感谢你考虑为 **nanobot-task-pipeline** 做出贡献！🎉

## 📋 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
- [开发环境设置](#开发环境设置)
- [提交规范](#提交规范)
- [Pull Request 流程](#pull-request-流程)

---

## 行为准则

本项目采用 [Contributor Covenant](https://www.contributor-covenant.org/) 行为准则。请保持友好、尊重的沟通氛围。

---

## 如何贡献

### 报告问题

发现 Bug 或有功能建议？请创建 [Issue](https://github.com/Minggnim-jpg/nanobot-task-pipeline/issues)：

- **Bug 报告**：包含复现步骤、预期行为、实际行为
- **功能建议**：说明使用场景和期望效果

### 提交代码

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

---

## 开发环境设置

### 前置要求

- [nanobot](https://github.com/nanobot-ai/nanobot) v1.0+
- [Claude Code](https://code.claude.com/) (可选，用于编码任务)
- Bash shell
- Git

### 安装步骤

```bash
# 1. Clone 仓库
git clone https://github.com/Minggnim-jpg/nanobot-task-pipeline.git
cd nanobot-task-pipeline

# 2. 配置工作目录
# 编辑 scripts/pipeline-heartbeat.sh，设置 WORKSPACE 路径

# 3. 配置 nanobot Gateway
# 将 heartbeat.jsonl 放入 nanobot 会话目录
```

### 运行测试

```bash
# 检查脚本语法
bash -n scripts/pipeline-heartbeat.sh

# 手动执行心跳（测试环境）
bash scripts/pipeline-heartbeat.sh
```

---

## 提交规范

我们遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Type 类型

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 文档更新 |
| `style` | 代码格式（不影响功能） |
| `refactor` | 重构 |
| `test` | 测试相关 |
| `chore` | 构建/工具/配置 |
| `security` | 安全相关 |

### 示例

```bash
feat(todo): 添加任务超时检测功能
fix(heartbeat): 修复子代理计数错误
docs: 更新 README 安装说明
security: 脱敏处理敏感信息
```

---

## Pull Request 流程

### PR 检查清单

提交 PR 前，请确认：

- [ ] 代码通过语法检查
- [ ] 更新了相关文档
- [ ] 遵循提交规范
- [ ] 无敏感信息（API Key、密码等）
- [ ] 已测试基本功能

### 审查流程

1. **自动检查**：GitHub Actions 运行（如配置）
2. **代码审查**：维护者审查代码质量和规范
3. **测试验证**：在测试环境验证功能
4. **合并**：审查通过后合并到 main 分支

### 响应时间

- Bug 修复：1-3 个工作日
- 功能建议：3-7 个工作日
- PR 审查：3-5 个工作日

---

## 📚 资源

- [nanobot 文档](https://github.com/nanobot-ai/nanobot)
- [Claude Code 最佳实践](https://code.claude.com/docs/en/best-practices)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## 🙏 致谢

感谢所有贡献者！你们的让这个项目变得更好。
