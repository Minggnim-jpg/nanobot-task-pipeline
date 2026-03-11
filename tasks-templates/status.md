# 任务状态

## 基本信息
- **任务 ID**: [待填充]
- **项目**: [待填充]
- **创建时间**: [待填充]
- **任务摘要**: [待填充]
- **运行模式**: 搭建期 / 正式期

## 当前状态
- **阶段**: brainstorming / technical-spec / coding / review / pr / complete
- **状态**: pending / running / complete / failed / waiting_confirm / abandoned
- **最后更新**: [待填充]
- **超时时间**: [待填充，创建时间 + 1 小时]

## 阶段详情

### Stage 0: brainstorming (需求澄清)
- **状态**: pending / running / complete / failed
- **开始时间**: -
- **完成时间**: -
- **超时时间**: -
- **输出文件**: requirements.md
- **子代理**: brainstorming-agent
- **确认要求**: 用户确认需求文档后进入下一阶段

### Stage 1: technical-spec (技术方案)
- **状态**: pending / running / complete / failed
- **开始时间**: -
- **完成时间**: -
- **超时时间**: -
- **输出文件**: technical-spec.md
- **子代理**: technical-spec-agent
- **确认要求**: 搭建期需用户确认，正式期自动进入 coding

### Stage 2: coding
- **状态**: pending / running / complete / failed
- **开始时间**: -
- **完成时间**: -
- **超时时间**: -
- **输出文件**: src/, tests/
- **子代理**: coding-agent

### Stage 3: review
- **状态**: pending / running / complete / failed
- **开始时间**: -
- **完成时间**: -
- **超时时间**: -
- **输出文件**: review-report.md
- **子代理**: review-agent

### Stage 4: PR
- **状态**: pending / running / complete / failed
- **开始时间**: -
- **完成时间**: -
- **超时时间**: -
- **PR 链接**: -
- **子代理**: PR-agent

## 错误记录
(如有错误，记录在此)
