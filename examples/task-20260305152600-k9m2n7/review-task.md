# 代码审查任务

## 任务信息
- **任务 ID**: task-20260305152600-k9m2n7
- **阶段**: review
- **项目**: example-project
- **项目路径**: /path/to/workspace/projects/example-project

## 审查目标
对已完成的扑克牌牌型比较工具函数进行代码审查。

## 审查范围
- `src/poker/comparator.py` - 牌型比较核心模块
- `src/poker/hand_ranker.py` - 牌型评级模块
- `src/poker/hand.py` - 手牌模块
- `src/poker/card.py` - 卡牌模块
- `tests/test_poker/test_card.py` - 单元测试

## 审查要求

### 1. 代码质量
- [ ] 代码风格符合 Python 最佳实践
- [ ] 类型注解完整
- [ ] 文档字符串清晰
- [ ] 错误处理适当

### 2. 功能完整性
- [ ] compare_hands 函数正确比较两手牌
- [ ] 支持所有标准扑克牌型
- [ ] 边界情况处理正确

### 3. 测试覆盖
- [ ] 单元测试覆盖核心功能
- [ ] 测试用例包含边界情况
- [ ] 测试可执行且通过

### 4. 安全性
- [ ] 输入验证充分
- [ ] 异常处理合理
- [ ] 无潜在的安全问题

## 输出要求
生成 `review-report.md` 文件，包含：
1. 审查总结
2. 发现的问题（如有）
3. 改进建议
4. 审查结论（通过/需要修改/不通过）

## 执行命令
使用 Claude Code 的 `/code-review` 命令进行审查。
