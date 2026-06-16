#!/bin/bash
# Claude Code cost-tracking status line
# Shows: session cost | weekly spend vs budget | context % | velocity | session time
#
# Requires: jq, bc
# macOS only as-is — see "Linux" note at the bottom for the two lines to swap

BUDGET_LIMIT=167   # <-- your weekly budget in USD
COSTS_FILE="${HOME}/.claude/costs/costs.jsonl"
STATE_FILE="${HOME}/.claude/costs/session-state.json"
MIN_DELTA_THRESHOLD=1.00  # only write a cost entry when delta >= $1

# ── Read input ────────────────────────────────────────────────────────────────
input=$(cat)

CURRENT_COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input"  | jq -r '.cost.total_duration_ms // 0')
CONTEXT_PCT=$(echo "$input"  | jq -r '.context_window.used_percentage // 0')
SESSION_ID=$(echo "$input"   | jq -r '.session_id // ""')

DURATION_SEC=$(echo "scale=2; $DURATION_MS / 1000" | bc 2>/dev/null)
DURATION_SEC=${DURATION_SEC:-0}

mkdir -p "$(dirname "$COSTS_FILE")" 2>/dev/null

# ── Mutex lock ────────────────────────────────────────────────────────────────
# The status bar fires every 300ms; without a lock, concurrent invocations
# corrupt session-state.json.
LOCK_DIR="${STATE_FILE}.lock"

acquire_lock() {
  local deadline=$(($(date +%s) + 5))
  while ! mkdir "$LOCK_DIR" 2>/dev/null; do
    if [ "$(date +%s)" -ge "$deadline" ]; then
      rm -rf "$LOCK_DIR" 2>/dev/null
      mkdir "$LOCK_DIR" 2>/dev/null && return 0
      return 1
    fi
    sleep 0.1
  done
}

release_lock() { rm -rf "$LOCK_DIR" 2>/dev/null; }

# ── Persist incremental cost deltas ──────────────────────────────────────────
# Writes cost deltas to costs.jsonl when they exceed MIN_DELTA_THRESHOLD.
# Tracks last-known cost per session in session-state.json to compute deltas.
if acquire_lock; then
  trap release_lock EXIT

  LAST_KNOWN=0
  [ -f "$STATE_FILE" ] && [ -n "$SESSION_ID" ] && \
    LAST_KNOWN=$(jq -r --arg sid "$SESSION_ID" '.[$sid] // 0' "$STATE_FILE" 2>/dev/null)
  LAST_KNOWN=${LAST_KNOWN:-0}

  DELTA=$(echo "$CURRENT_COST - $LAST_KNOWN" | bc -l 2>/dev/null)
  DELTA=${DELTA:-0}

  if (( $(echo "$DELTA >= $MIN_DELTA_THRESHOLD" | bc -l 2>/dev/null) )); then
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\":\"$TIMESTAMP\",\"session_id\":\"$SESSION_ID\",\"source\":\"claude\",\"cost_usd\":$DELTA}" >> "$COSTS_FILE"

    if [ -f "$STATE_FILE" ]; then
      jq --arg sid "$SESSION_ID" --argjson cost "$CURRENT_COST" \
        '.[$sid] = $cost' "$STATE_FILE" > "${STATE_FILE}.tmp" \
        && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    else
      echo "{\"$SESSION_ID\": $CURRENT_COST}" > "$STATE_FILE"
    fi
  fi

  release_lock
  trap - EXIT
fi

# ── Weekly cost ───────────────────────────────────────────────────────────────
# Sums all delta entries from costs.jsonl since Monday 00:00,
# then adds any unwritten remainder from the current session.
calculate_weekly_cost() {
  # macOS BSD date — see Linux note below
  DOW=$(date +%u)
  WEEK_START=$(date -v-$((DOW - 1))d -v0H -v0M -v0S +%s 2>/dev/null)

  [ ! -f "$COSTS_FILE" ] || [ -z "$WEEK_START" ] && { echo "$CURRENT_COST"; return; }

  TOTAL=0
  while IFS= read -r line; do
    ts=$(echo "$line"   | jq -r '.timestamp' 2>/dev/null)
    cost=$(echo "$line" | jq -r '.cost_usd'  2>/dev/null)
    [ -z "$ts" ] || [ -z "$cost" ] && continue

    # macOS BSD date — see Linux note below
    entry_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" +%s 2>/dev/null)
    [ -z "$entry_epoch" ] && continue

    [ "$entry_epoch" -ge "$WEEK_START" ] && TOTAL=$(echo "$TOTAL + $cost" | bc -l)
  done < "$COSTS_FILE"

  # Add unwritten portion of current session (below the $1 threshold)
  STATE_KNOWN=0
  [ -f "$STATE_FILE" ] && [ -n "$SESSION_ID" ] && \
    STATE_KNOWN=$(jq -r --arg sid "$SESSION_ID" '.[$sid] // 0' "$STATE_FILE" 2>/dev/null)
  UNWRITTEN=$(echo "$CURRENT_COST - ${STATE_KNOWN:-0}" | bc -l 2>/dev/null)
  (( $(echo "${UNWRITTEN:-0} > 0" | bc -l) )) && TOTAL=$(echo "$TOTAL + $UNWRITTEN" | bc -l)

  echo "${TOTAL:-0}"
}

TOTAL_COST=$(calculate_weekly_cost)

# ── Budget indicator ──────────────────────────────────────────────────────────
BUDGET_PCT=$(echo "($TOTAL_COST / $BUDGET_LIMIT) * 100" | bc -l 2>/dev/null)
BUDGET_PCT=${BUDGET_PCT:-0}

(( $(echo "$BUDGET_PCT < 50" | bc -l) )) && COLOR="💚" \
  || (( $(echo "$BUDGET_PCT < 80" | bc -l) )) && COLOR="💛" \
  || COLOR="🔴"

# ── Cost velocity ─────────────────────────────────────────────────────────────
VELOCITY="--"
if (( $(echo "$DURATION_SEC > 0" | bc -l) )); then
  DURATION_MIN=$(echo "scale=4; $DURATION_SEC / 60" | bc)
  (( $(echo "$DURATION_MIN > 0" | bc -l) )) && \
    VELOCITY=$(printf "%.2f" "$(echo "scale=2; $CURRENT_COST / $DURATION_MIN" | bc)")
fi

# ── Session time ──────────────────────────────────────────────────────────────
SESSION_TIME="--"
if (( $(echo "$DURATION_SEC > 0" | bc -l) )); then
  TOTAL_MIN=$(echo "$DURATION_SEC / 60" | bc)
  [ "$TOTAL_MIN" -ge 60 ] 2>/dev/null \
    && SESSION_TIME="$((TOTAL_MIN / 60))h $((TOTAL_MIN % 60))m" \
    || SESSION_TIME="${TOTAL_MIN}m"
fi

# ── Output ────────────────────────────────────────────────────────────────────
BUDGET_INT=$(printf "%.0f" "$BUDGET_PCT" 2>/dev/null); BUDGET_INT=${BUDGET_INT:-0}
CONTEXT_INT=$(printf "%.0f" "$CONTEXT_PCT" 2>/dev/null); CONTEXT_INT=${CONTEXT_INT:-0}

printf "%s \$%.2f | \$%.2f / \$%d (%d%%) | 🪟 %d%% | ⚡ \$%s/min | ⏱ %s" \
  "$COLOR" "$CURRENT_COST" "$TOTAL_COST" "$BUDGET_LIMIT" \
  "$BUDGET_INT" "$CONTEXT_INT" "$VELOCITY" "$SESSION_TIME"
