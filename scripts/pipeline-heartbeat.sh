#!/bin/bash
# 任务流水线心跳检查脚本
# 每 5 分钟执行一次，检查任务状态并启动待执行任务

set -e

WORKSPACE="/path/to/workspace"
TASKS_DIR="$WORKSPACE/tasks"
ACTIVE_AGENTS_FILE="$TASKS_DIR/active-agents.md"
MAX_AGENTS=5
LOG_FILE="$WORKSPACE/heartbeat-log.md"

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

# 2. 如果数量 >= 5，跳过本次轮询
if [ "$CURRENT_AGENTS" -ge "$MAX_AGENTS" ]; then
    log "子代理已满 ($CURRENT_AGENTS >= $MAX_AGENTS)，跳过本次轮询"
    exit 0
fi

# 3. 扫描所有任务状态文件
AVAILABLE_SLOTS=$((MAX_AGENTS - CURRENT_AGENTS))
log "可用子代理槽位：$AVAILABLE_SLOTS"

STARTED_COUNT=0

# 遍历所有任务目录
for task_dir in "$TASKS_DIR"/task-*/; do
    if [ ! -d "$task_dir" ]; then
        continue
    fi
    
    STATUS_FILE="$task_dir/status.md"
    if [ ! -f "$STATUS_FILE" ]; then
        continue
    fi
    
    # 读取任务状态
    TASK_STATUS=$(grep "^**状态**:" "$STATUS_FILE" 2>/dev/null | sed 's/.*: //' || echo "")
    TASK_STAGE=$(grep "^**阶段**:" "$STATUS_FILE" 2>/dev/null | sed 's/.*: //' || echo "")
    TASK_ID=$(basename "$task_dir")
    
    # 跳过已结束的任务
    if [[ "$TASK_STATUS" == "complete" || "$TASK_STATUS" == "failed" || "$TASK_STATUS" == "abandoned" ]]; then
        log "任务 $TASK_ID 状态=$TASK_STATUS，已跳过"
        continue
    fi
    
    # 检查超时
    TIMEOUT_LINE=$(grep "^**超时时间**:" "$STATUS_FILE" 2>/dev/null || echo "")
    if [ -n "$TIMEOUT_LINE" ]; then
        TIMEOUT_STR=$(echo "$TIMEOUT_LINE" | sed 's/.*: //')
        # 简单超时检查（待完善）
        log "任务 $TASK_ID 超时检查：$TIMEOUT_STR"
    fi
    
    # 4. 处理待执行任务
    if [[ "$TASK_STATUS" == "pending" || "$TASK_STATUS" == "waiting_confirm" ]]; then
        log "发现待执行任务：$TASK_ID (状态=$TASK_STATUS, 阶段=$TASK_STAGE)"
        
        # waiting_confirm 需要用户确认，发送通知后跳过
        if [[ "$TASK_STATUS" == "waiting_confirm" ]]; then
            NOTIFIED_FILE="$task_dir/notified_waiting.md"
            
            # 检查是否已发送过通知
            if [ ! -f "$NOTIFIED_FILE" ]; then
                log "任务 $TASK_ID 等待用户确认，发送通知"
                # 发送通知 [已禁用 - 2026-03-06]
                # nanobot message --channel "discord" --chat_id "[DISCORD_CHAT_ID]" --content "⏳ **任务流水线**: 任务 \`$TASK_ID\` 等待确认 (阶段：$TASK_STAGE)\n请查看相关文件后回复\"OK\"继续"
                # 创建标记文件
                echo "notified at $CURRENT_TIME" > "$NOTIFIED_FILE"
            else
                log "任务 $TASK_ID 等待用户确认 (已通知过，跳过)"
            fi
            continue
        fi
        
        # 检查是否有可用槽位
        if [ "$STARTED_COUNT" -ge "$AVAILABLE_SLOTS" ]; then
            log "可用槽位已用尽，任务 $TASK_ID 等待下次轮询"
            break
        fi
        
        # 启动对应子代理
        log "启动任务 $TASK_ID 的子代理..."
        
        # 发送通知（有新任务时）[已禁用 - 2026-03-06]
        # nanobot message --channel "discord" --chat_id "[DISCORD_CHAT_ID]" --content "🚀 **任务流水线**: 发现新任务 \`$TASK_ID\` ($TASK_STAGE 阶段)，正在启动子代理..."
        
        # 根据阶段确定子代理类型
        AGENT_TYPE="unknown"
        case "$TASK_STAGE" in
            "todo"|"planning")
                AGENT_TYPE="todo"
                ;;
            "coding"|"development")
                AGENT_TYPE="coding"
                ;;
            "review"|"testing")
                AGENT_TYPE="review"
                ;;
            "pr"|"deployment")
                AGENT_TYPE="PR"
                ;;
            *)
                AGENT_TYPE="general"
                ;;
        esac
        
        # 创建子代理启动记录
        SPAWN_ID="spawn-$(printf '%03d' $((CURRENT_AGENTS + STARTED_COUNT + 1)))"
        
        # 更新 active-agents.md
        cat >> "$ACTIVE_AGENTS_FILE" << EOF
- $SPAWN_ID: $TASK_ID, stage=$TASK_STAGE, started=$CURRENT_TIME

EOF
        
        log "子代理 $SPAWN_ID 已启动 (类型=$AGENT_TYPE)"
        STARTED_COUNT=$((STARTED_COUNT + 1))
    fi
done

# 5. 更新活跃子代理数量
NEW_TOTAL=$((CURRENT_AGENTS + STARTED_COUNT))

# 重写 active-agents.md 头部
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE" << EOF
# 活跃子代理计数

**最后更新**: $CURRENT_TIME

---

## 当前活跃

**数量**: $NEW_TOTAL / $MAX_AGENTS

**子代理列表**:
EOF

# 保留原有的子代理列表（排除数量行）
grep -A100 "## 子代理列表" "$ACTIVE_AGENTS_FILE" | tail -n +2 >> "$TEMP_FILE"

# 添加更新规则
cat >> "$TEMP_FILE" << EOF

---

## 更新规则

- 子代理启动时：数量 +1，添加列表
- 子代理完成时：数量 -1，移除列表
- 心跳轮询时：检查并清理僵尸子代理

---
EOF

mv "$TEMP_FILE" "$ACTIVE_AGENTS_FILE"

log "=== 心跳检查完成 ==="
log "启动子代理数：$STARTED_COUNT, 当前总数：$NEW_TOTAL"
