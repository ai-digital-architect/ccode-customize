#!/usr/bin/env bash
# =============================================================================
# loop.sh — Bash Loop Runner (Model B: Fresh Context Per Iteration)
# =============================================================================
# Runs Claude Code in a while loop, piping the prompt file on each iteration.
# Each iteration spawns a fresh Claude Code process with clean context.
#
# Usage:
#   ./loop.sh [max-iterations] [prompt-file]
#   ./loop.sh 50 PROMPT.md
#   nohup ./loop.sh 50 PROMPT.md &    # for overnight runs
#
# Arguments:
#   max-iterations  Maximum number of loop iterations (default: 50)
#   prompt-file     Path to the prompt file (default: PROMPT.md)
#
# Outputs:
#   .claude/loop-log.txt              Per-iteration log
#   .claude/loop-state.json           Loop state (iteration count, status)
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
MAX_ITERATIONS="${1:-50}"
PROMPT_FILE="${2:-PROMPT.md}"
STATE_FILE=".claude/loop-state.json"
LOG_FILE=".claude/loop-log.txt"
COMPLETION_PROMISE="${3:-LOOP_COMPLETE}"

# -----------------------------------------------------------------------------
# Logging
# -----------------------------------------------------------------------------
log() {
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "[$timestamp] [loop.sh] $*" | tee -a "$LOG_FILE"
}

# -----------------------------------------------------------------------------
# Validation
# -----------------------------------------------------------------------------
if [ ! -f "$PROMPT_FILE" ]; then
  echo "Error: Prompt file '$PROMPT_FILE' not found"
  exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "Error: 'claude' command not found — install Claude Code CLI"
  exit 1
fi

# -----------------------------------------------------------------------------
# Initialize state
# -----------------------------------------------------------------------------
mkdir -p .claude

cat > "$STATE_FILE" << EOF
{
  "iteration": 0,
  "max_iterations": $MAX_ITERATIONS,
  "completion_promise": "$COMPLETION_PROMISE",
  "task": "$(head -1 "$PROMPT_FILE" | tr -d '#' | xargs)",
  "status": "running",
  "started_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "last_iteration_at": null,
  "model": "bash-loop"
}
EOF

log "Starting loop: max=$MAX_ITERATIONS prompt=$PROMPT_FILE"
log "Completion promise: $COMPLETION_PROMISE"

# -----------------------------------------------------------------------------
# Main loop
# -----------------------------------------------------------------------------
iteration=0

while [ "$iteration" -lt "$MAX_ITERATIONS" ]; do
  iteration=$((iteration + 1))

  log "--- Iteration $iteration/$MAX_ITERATIONS ---"
  start_time=$(date +%s)

  # Update state
  tmp=$(mktemp)
  cat "$STATE_FILE" | jq \
    --argjson iter "$iteration" \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '.iteration = $iter | .last_iteration_at = $ts' > "$tmp"
  mv "$tmp" "$STATE_FILE"

  # Run Claude Code with the prompt
  output=$(cat "$PROMPT_FILE" | claude -p --output-format text 2>&1) || true

  end_time=$(date +%s)
  duration=$((end_time - start_time))
  log "Iteration $iteration completed in ${duration}s"

  # Check for completion promise
  if echo "$output" | grep -qF "$COMPLETION_PROMISE"; then
    log "Completion promise detected — loop complete!"

    tmp=$(mktemp)
    cat "$STATE_FILE" | jq \
      --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
      '.status = "complete" | .completed_at = $ts' > "$tmp"
    mv "$tmp" "$STATE_FILE"

    break
  fi

  # Check for cancellation
  if [ -f "$STATE_FILE" ]; then
    status=$(cat "$STATE_FILE" | jq -r '.status // "running"')
    if [ "$status" = "cancelled" ]; then
      log "Loop cancelled by user"
      break
    fi
  fi

  # Brief pause between iterations to avoid rate limiting
  sleep 2
done

# -----------------------------------------------------------------------------
# Final status
# -----------------------------------------------------------------------------
if [ "$iteration" -ge "$MAX_ITERATIONS" ]; then
  log "Max iterations reached ($MAX_ITERATIONS)"
  tmp=$(mktemp)
  cat "$STATE_FILE" | jq \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '.status = "max_iterations_reached" | .stopped_at = $ts' > "$tmp"
  mv "$tmp" "$STATE_FILE"
fi

log "Loop finished. Final state:"
cat "$STATE_FILE" | jq '.' | tee -a "$LOG_FILE"
log "Review: git log --oneline | head -20"
