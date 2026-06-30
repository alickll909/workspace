#!/usr/bin/env bash
# ============================================================
# shared-memory.sh — Agent Team 共享记忆 Hook
# 每个 agent 完成任务后调用此脚本写入摘要
# 每个 agent 启动时调用此脚本读取上下文
#
# 用法：
#   bash shared-memory.sh write <role> <task> <status> [artifacts...]
#   bash shared-memory.sh read [count=5]
#   bash shared-memory.sh escalate <target> <score1,score2,score3> <reason>
# ============================================================
set -e

MEMORY_DIR="docs/team-memory"
ACTION="${1:-read}"

case "$ACTION" in
  write)
    # bash shared-memory.sh write <role> <task> <status> [artifacts...]
    ROLE="$2"
    TASK="$3"
    STATUS="$4"
    shift 4
    ARTIFACTS="$*"
    TIMESTAMP=$(date +%Y-%m-%d_%H%M)
    FILENAME="${MEMORY_DIR}/${TIMESTAMP}_${ROLE}_$(echo "$TASK" | tr ' ' '_' | cut -c1-40).md"

    mkdir -p "$MEMORY_DIR"

    cat > "$FILENAME" <<EOF
---
role: ${ROLE}
task: "${TASK}"
status: "${STATUS}"
timestamp: $(date +%Y-%m-%dT%H:%M:%S)
artifacts: [${ARTIFACTS}]
---

## 完成摘要

**角色**: ${ROLE}
**任务**: ${TASK}
**状态**: ${STATUS}
**产出**: ${ARTIFACTS:-无}
EOF

    echo "MEMORY:$FILENAME"
    ;;

  read)
    # bash shared-memory.sh read [count=5]
    COUNT="${2:-5}"
    mkdir -p "$MEMORY_DIR"
    echo "=== 最近的 ${COUNT} 条共享记忆 ==="
    ls -t "$MEMORY_DIR"/*.md 2>/dev/null | head -"$COUNT" | while read -r f; do
      echo "--- $(basename "$f") ---"
      head -10 "$f"
      echo ""
    done | head -200
    ;;

  escalate)
    # bash shared-memory.sh escalate <target> <scores> <reason>
    TARGET="$2"
    SCORES="$3"
    REASON="$4"
    TIMESTAMP=$(date +%Y-%m-%d_%H%M)
    mkdir -p "$MEMORY_DIR"
    cat > "${MEMORY_DIR}/ESCALATION_${TARGET}_${TIMESTAMP}.md" <<EOF
---
type: escalation
target: ${TARGET}
scores: "${SCORES}"
reason: "${REASON}"
timestamp: $(date +%Y-%m-%dT%H:%M:%S)
---

## ⚠️ 人工介入通知

**目标**: ${TARGET}
**连续 3 次不及格，分数**: ${SCORES}
**核心问题**: ${REASON}

**需要人工介入处理。**
EOF
    echo "ESCALATION:${MEMORY_DIR}/ESCALATION_${TARGET}_${TIMESTAMP}.md"
    ;;

  *)
    echo "用法: bash shared-memory.sh {write|read|escalate} [...]"
    exit 1
    ;;
esac
