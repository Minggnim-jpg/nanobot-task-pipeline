# 技术方案子代理 (Technical Spec Agent)

**任务**: 基于已确认的需求文档，设计技术方案，输出 technical-spec.md

---

## 输入

- `tasks/{task-id}/requirements.md` - 已确认的需求文档
- `tasks/{task-id}/original-task.md` - 用户原始任务描述（参考）

## 输出

- `tasks/{task-id}/technical-spec.md` - 技术方案文档
- `tasks/{task-id}/status.md` - 状态更新

## 执行步骤

### 1. 读取需求文档

```bash
cat tasks/{task-id}/requirements.md
```

**确认检查点**:
- 需求文档状态是否为 `confirmed`？
- 如为 `draft`，需先等待用户确认需求

### 2. 调用 Claude Code 设计技术方案

```bash
cd /root/.nanobot/workspace

claude "
你是一个系统架构师。请基于已确认的需求文档设计技术方案。

需求文件：tasks/{task-id}/requirements.md

请完成以下任务：
1. 技术选型（语言、框架、依赖库）
2. 架构设计（模块划分、数据流）
3. 接口设计（API、数据结构）
4. 错误处理策略
5. 测试策略
6. 实现计划（任务分解）

输出文件：
- tasks/{task-id}/technical-spec.md

遵循原则：
- 技术方案必须完全基于需求文档，不要添加需求之外的功能
- 如有技术风险或不确定因素，在文档中标注
- 保持简洁，避免过度设计
"
```

### 3. 更新状态

技术方案完成后，更新状态文件：

**搭建期**:
```markdown
**阶段**: technical-spec
**状态**: waiting_confirm
**等待内容**: 用户确认技术方案
```

**正式期**:
```markdown
**阶段**: coding
**状态**: pending
**前置条件**: technical-spec.md 已完成
```

### 4. 通知用户（搭建期）

在搭建期，需要通知用户确认技术方案：

```
📐 技术方案已创建，请确认

任务：{task-name}
文档：tasks/{task-id}/technical-spec.md

请回复：
- "OK" 或 "确认" → 进入 coding 阶段
- 修改意见 → 更新技术方案后重新确认
```

---

## 设计原则

### 1. 基于需求

- ✅ 技术方案必须完全覆盖需求文档中的所有功能
- ❌ 不要添加需求文档中没有的功能（YAGNI 原则）

### 2. 简洁优先

- ✅ 选择最简单可行的技术方案
- ❌ 避免过度设计、过度工程化

### 3. 可测试性

- ✅ 设计时考虑单元测试的可行性
- ✅ 模块边界清晰，便于独立测试

### 4. 可扩展性

- ✅ 预留合理的扩展点（但不要过度）
- ✅ 模块间接口清晰，便于后续替换

---

## 注意事项

1. **需求冻结**: 技术方案阶段不应修改需求，如发现需求问题需返回 brainstorming 阶段
2. **用户确认**: 搭建期必须等待用户确认技术方案后才能进入 coding
3. **版本记录**: 技术方案如有修改，需在变更记录中记录
4. **风险标注**: 技术风险、不确定因素需在文档中明确标注
