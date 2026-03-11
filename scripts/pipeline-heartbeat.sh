#!/bin/bash
# 任务流水线心跳检查脚本
# 每 5 分钟执行一次，检查任务状态并标记待执行任务
# 
# 使用方法:
# 1. 复制此脚本到你的 nanobot workspace 目录
# 2. 修改 WORKSPACE 变量为你的实际路径
# 3. 修改 DISCORD_CHAT_ID 为你的 Discord 用户 ID
# 4. 添加到 crontab: */5 * * * * /path/to/pipeline-heartbeat.sh

set -e

# ============== 配置区域 ==============
# 修改为你的 nanobot workspace 路径
WORKSPACE="${NANOBOT_WORKSPACE:-$HOME/.nanobot/workspace}"
TASKS_DIR="$WORKSPACE/tasks"
ACTIVE_AGENTS_FILE="$TASKS_DIR/active-agents.md"
SPAWN_QUEUE_FILE="$TASKS_DIR/spawn-queue.md"
MAX_AGENTS=5
LOG_FILE="$WORKSPACE/heartbeat-log.md"

# 修改为你的 Discord 用户 ID (用于发送通知)
DISCORD_CHAT_ID="${DISCORD_CHAT_ID:-YOUR_DISCORD_CHAT_ID}"
# ======================================

# 获取当前时间
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M")
CURRENT_TIMESTAMP=$(date +%s)

log() {
    echo "[$CURRENT_TIME] $1" >> "$LOG_FILE"
    echo "[$CURRENT_TIME] $1"
}

log "=== 心跳检查开始 ==="

# 1. 读取当前活跃子代理数量
if [ ! -f "$ACTIVE_AGENTS_FILE" ]; then
    log "ERROR: active-agents.md 不存在"
    exit 1
fi

# 解析活跃子代理数量 (格式：**数量**: N / 5)
CURRENT_AGENTS=$(grep "^\*\*数量\*\*:" "$ACTIVE_AGENTS_FILE" | head -1 | sed 's/.*: \([0-9]*\) .*/\1/' || echo "0")
if [ -z "$CURRENT_AGENTS" ] || ! [[ "$CURRENT_AGENTS" =~ ^[0-9]+$ ]]; then
    CURRENT_AGENTS=0
fi

log "当前活跃子代理数量：$CURRENT_AGENTS / $MAX_AGENTS"

# 2. 清理已完成的子代理记录
log "清理已完成的子代理记录..."
for task_dir in "$TASKS_DIR"/task-*/; do
    if [ ! -d "$task_dir" ]; then
        continue
    fi
    
    STATUS_FILE="$task_dir/status.md"
    if [ ! -f "$STATUS_FILE" ]; then
        continue
    fi
    
    # 读取任务状态（格式：- **状态**: xxx）- 只匹配"## 当前状态"节下的
    TASK_STATUS=$(sed -n '/^## 当前状态$/,/^##/p' "$STATUS_FILE" 2>/dev/null | grep "\*\*状态\*\*" | head -1 | sed 's/.*: //' || echo "")
    TASK_ID=$(basename "$task_dir")
    
    # 如果任务已完成/失败/放弃，从 active-agents.md 中移除相关记录
    if [[ "$TASK_STATUS" == "complete" || "$TASK_STATUS" == "failed" || "$TASK_STATUS" == "abandoned" ]]; then
        if grep -q "$TASK_ID" "$ACTIVE_AGENTS_FILE" 2>/dev/null; then
            log "任务 $TASK_ID 已结束，清理活跃记录"
            grep -v "$TASK_ID" "$ACTIVE_AGENTS_FILE" > "$ACTIVE_AGENTS_FILE.tmp" || true
            mv "$ACTIVE_AGENTS_FILE.tmp" "$ACTIVE_AGENTS_FILE"
        fi
    fi
done

# 重新读取活跃子代理数量（清理后）
CURRENT_AGENTS=$(grep "^\*\*数量\*\*:" "$ACTIVE_AGENTS_FILE" | head -1 | sed 's/.*: \([0-9]*\) .*/\1/' || echo "0")
if [ -z "$CURRENT_AGENTS" ] || ! [[ "$CURRENT_AGENTS" =~ ^[0-9]+$ ]]; then
    CURRENT_AGENTS=0
fi

# 3. 如果数量 >= 5，跳过本次轮询
if [ "$CURRENT_AGENTS" -ge "$MAX_AGENTS" ]; then
    log "子代理已满 ($CURRENT_AGENTS >= $MAX_AGENTS)，跳过本次轮询"
    exit 0
fi

AVAILABLE_SLOTS=$((MAX_AGENTS - CURRENT_AGENTS))
log "可用子代理槽位：$AVAILABLE_SLOTS"

# 4. 初始化 spawn 队列
cat > "$SPAWN_QUEUE_FILE" << EOF
# 子代理启动队列

**生成时间**: $CURRENT_TIME
**可用槽位**: $AVAILABLE_SLOTS

---

## 待启动任务

EOF

STARTED_COUNT=0

# 5. 遍历所有任务目录
for task_dir in "$TASKS_DIR"/task-*/; do
    if [ ! -d "$task_dir" ]; then
        continue
    fi
    
    STATUS_FILE="$task_dir/status.md"
    if [ ! -f "$STATUS_FILE" ]; then
        continue
    fi
    
    # 读取任务状态（格式：- **状态**: xxx）- 只匹配"## 当前状态"节下的
    TASK_STATUS=$(sed -n '/^## 当前状态$/,/^##/p' "$STATUS_FILE" 2>/dev/null | grep "\*\*状态\*\*" | head -1 | sed 's/.*: //' || echo "")
    TASK_STAGE=$(sed -n '/^## 当前状态$/,/^##/p' "$STATUS_FILE" 2>/dev/null | grep "\*\*阶段\*\*" | head -1 | sed 's/.*: //' || echo "")
    TASK_ID=$(basename "$task_dir")
    
    # 跳过已结束的任务
    if [[ "$TASK_STATUS" == "complete" || "$TASK_STATUS" == "failed" || "$TASK_STATUS" == "abandoned" ]]; then
        continue
    fi
    
    # 跳过正在运行的任务
    if [[ "$TASK_STATUS" == "running" ]]; then
        continue
    fi
    
    # 6. 处理待执行任务 (pending)
    if [[ "$TASK_STATUS" == "pending" ]]; then
        # 检查是否有可用槽位
        if [ "$STARTED_COUNT" -ge "$AVAILABLE_SLOTS" ]; then
            log "可用槽位已用尽，任务 $TASK_ID 等待下次轮询"
            break
        fi
        
        log "发现待执行任务：$TASK_ID (阶段=$TASK_STAGE)"
        
        # 更新状态为 running
        sed -i "s/^- \*\*状态\*\*: pending/- **状态**: running/" "$STATUS_FILE"
        sed -i "s/^- \*\*最后更新\*\*: .*/- **最后更新**: $CURRENT_TIME/" "$STATUS_FILE"
        
        # 创建子代理启动记录
        SPAWN_ID="spawn-$TASK_ID-$CURRENT_TIMESTAMP"
        
        # 添加到 active-agents.md - 在"**子代理列表**:"后插入
        sed -i "/^\*\*子代理列表\*\*:/a\\
- $SPAWN_ID: $TASK_ID, stage=$TASK_STAGE, started=$CURRENT_TIME" "$ACTIVE_AGENTS_FILE"
        
        # 更新数量
        NEW_COUNT=$((CURRENT_AGENTS + STARTED_COUNT + 1))
        sed -i "s/^\*\*数量\*\*: .*/**数量**: $NEW_COUNT \/ $MAX_AGENTS/" "$ACTIVE_AGENTS_FILE"
        sed -i "s/^\*\*最后更新\*\*: .*/**最后更新**: $CURRENT_TIME/" "$ACTIVE_AGENTS_FILE"
        
        # 添加到 spawn 队列
        cat >> "$SPAWN_QUEUE_FILE" << EOF
### $TASK_ID
- **阶段**: $TASK_STAGE
- **启动 ID**: $SPAWN_ID
- **启动时间**: $CURRENT_TIME

EOF
        
        log "任务 $TASK_ID 已标记为 running，添加到 spawn 队列"
        STARTED_COUNT=$((STARTED_COUNT + 1))
    fi
    
    # 7. 处理 waiting_confirm 任务（需要用户确认）
    if [[ "$TASK_STATUS" == "waiting_confirm" ]]; then
        NOTIFIED_FILE="$task_dir/notified_waiting.md"
        
        if [ ! -f "$NOTIFIED_FILE" ]; then
            log "任务 $TASK_ID 等待用户确认，创建通知标记"
            cat > "$NOTIFIED_FILE" << EOF
# 等待用户确认

**任务**: $TASK_ID
**阶段**: $TASK_STAGE
**通知时间**: $CURRENT_TIME
**状态**: pending_user_confirm

请用户在 Discord 回复"OK"或表达肯定以继续。
EOF
        else
            log "任务 $TASK_ID 等待用户确认 (已通知过，跳过)"
        fi
    fi
done

# 8. 更新 spawn 队列尾部
cat >> "$SPAWN_QUEUE_FILE" << EOF

---

## 处理说明

nanobot 请读取此队列，对每个任务使用 spawn 启动对应的子代理。

**子代理任务描述**：
- **brainstorming**: 读取 original-task.md，进行需求澄清，输出 requirements.md，完成后更新 status.md 为 waiting_confirm
- **technical-spec**: 读取 requirements.md，设计技术方案，输出 technical-spec.md，完成后更新 status.md 为 pending/coding
- **coding**: 读取 technical-spec.md 和 requirements.md，TDD 实现代码，完成后更新 status.md 为 pending/review
- **review**: 审查代码，输出 review-report.md，完成后更新 status.md 为 pending/pr
- **pr**: 创建 Pull Request，完成后更新 status.md 为 complete

EOF

# 9. 更新活跃子代理数量
NEW_TOTAL=$((CURRENT_AGENTS + STARTED_COUNT))
sed -i "s/^\*\*数量\*\*: .*/**数量**: $NEW_TOTAL \/ $MAX_AGENTS/" "$ACTIVE_AGENTS_FILE"
sed -i "s/^\*\*最后更新\*\*: .*/**最后更新**: $CURRENT_TIME/" "$ACTIVE_AGENTS_FILE"

log "=== 心跳检查完成 ==="
log "标记任务数：$STARTED_COUNT, 当前活跃总数：$NEW_TOTAL"

# 10. 如果有待启动的任务，触发 nanobot 处理
if [ "$STARTED_COUNT" -gt 0 ]; then
    log "有待启动的任务，触发 nanobot 处理..."
    # 调用 nanobot agent 发送消息，触发处理
    nanobot agent -m "【任务流水线触发】检测到 $STARTED_COUNT 个待启动任务。请执行以下操作：1) 读取 tasks/spawn-queue.md 获取任务列表 2) 对每个任务使用 spawn 启动对应的子代理 3) 子代理任务描述参考 tasks/spawn-queue.md 中的说明" > /dev/null 2>&1 || true
    log "已触发 nanobot 处理"
fi

# 11. 发送等待确认任务的通知（如果有）
for task_dir in "$TASKS_DIR"/task-*/; do
    if [ ! -d "$task_dir" ]; then
        continue
    fi
    
    STATUS_FILE="$task_dir/status.md"
    if [ ! -f "$STATUS_FILE" ]; then
        continue
    fi
    
    # 读取任务状态（格式：- **状态**: xxx）- 只匹配"## 当前状态"节下的
    TASK_STATUS=$(sed -n '/^## 当前状态$/,/^##/p' "$STATUS_FILE" 2>/dev/null | grep "\*\*状态\*\*" | head -1 | sed 's/.*: //' || echo "")
    TASK_STAGE=$(sed -n '/^## 当前状态$/,/^##/p' "$STATUS_FILE" 2>/dev/null | grep "\*\*阶段\*\*" | head -1 | sed 's/.*: //' || echo "")
    TASK_ID=$(basename "$task_dir")
    NOTIFIED_FILE="$task_dir/notified_waiting.md"
    
    # 如果是 waiting_confirm 且刚创建通知文件（本轮心跳）
    if [[ "$TASK_STATUS" == "waiting_confirm" ]] && [ -f "$NOTIFIED_FILE" ]; then
        # 检查是否已发送过 Discord 通知
        DISCORD_NOTIFIED_FILE="$task_dir/discord_notified.md"
        if [ ! -f "$DISCORD_NOTIFIED_FILE" ]; then
            log "发送 Discord 通知：任务 $TASK_ID 等待用户确认"
            # 读取任务摘要
            TASK_SUMMARY=$(grep "^\*\*任务摘要\*\*:" "$STATUS_FILE" 2>/dev/null | sed 's/.*: //' || echo "未命名任务")
            # 发送 Discord 通知（如果配置了 DISCORD_CHAT_ID）
            if [ "$DISCORD_CHAT_ID" != "YOUR_DISCORD_CHAT_ID" ] && [ -n "$DISCORD_CHAT_ID" ]; then
                nanobot message --channel "discord" --chat_id "$DISCORD_CHAT_ID" --content "📋 **任务等待确认**

**任务**: \`$TASK_ID\`
**阶段**: $TASK_STAGE
**摘要**: $TASK_SUMMARY

需求文档已准备就绪，请回复 **OK** 确认以继续。" > /dev/null 2>&1 || true
            fi
            # 标记已通知
            echo "Discord notified at $CURRENT_TIME" > "$DISCORD_NOTIFIED_FILE"
        fi
    fi
done

log "=== 心跳检查结束 ==="
