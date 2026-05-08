#!/usr/bin/env bash
# =============================================================================
# stop-loop.sh — Stop Hook: Continuous Loop Iteration Controller
# =============================================================================
# Intercepts session exit, checks for completion conditions, and either
# allows clean exit or blocks and re-injects the prompt for the next iteration.
#
# Exit codes:
#   0 — Allow exit (loop complete, cancelled, or max iterations reached)
#   2 — Block exit (re-inject prompt for next iteration)
#
# State file: .claude/loop-state.json
# =============================================================================

set -euo pipefail

STATE_FILE=".claude/loop-state.json"
LOG_FILE=".claude/loop-log.txt"

# -----------------------------------------------------------------------------
# Logging helper
# -----------------------------------------------------------------------------
log() {
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "[$timestamp] [stop-loop] $*" >> "$LOG_FILE"
}

# -----------------------------------------------------------------------------
# Read agent output from stdin
# -----------------------------------------------------------------------------
input=$(cat)

# -----------------------------------------------------------------------------
# Check if loop state exists
# -----------------------------------------------------------------------------
if [ ! -f "$STATE_FILE" ]; then
  log "No loop state file found — allowing exit (not in a loop)"
  exit 0
fi

# -----------------------------------------------------------------------------
# Read current state
# -----------------------------------------------------------------------------
status=$(echo "$STATE_FILE" | xargs cat | jq -r '.status // "unknown"')
iteration=$(echo "$STATE_FILE" | xargs cat | jq -r '.iteration // 0')
max_iterations=$(echo "$STATE_FILE" | xargs cat | jq -r '.max_iterations // 50')
completion_promise=$(echo "$STATE_FILE" | xargs cat | jq -r '.completion_promise // "LOOP_COMPLETE"')
task=$(echo "$STATE_FILE" | xargs cat | jq -r '.task // ""')

log "Current state: status=$status iteration=$iteration max=$max_iterations"

# -----------------------------------------------------------------------------
# Check if loop was cancelled
# -----------------------------------------------------------------------------
if [ "$status" = "cancelled" ] || [ "$status" = "complete" ]; then
  log "Loop status is '$status' — allowing exit"
  exit 0
fi

# -----------------------------------------------------------------------------
# Check if completion promise was emitted
# -----------------------------------------------------------------------------
if echo "$input" | grep -qF "$completion_promise"; then
  log "Completion promise '$completion_promise' detected — marking complete"

  # Update state to complete
  tmp=$(mktemp)
  cat "$STATE_FILE" | jq \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '.status = "complete" | .completed_at = $ts' > "$tmp"
  mv "$tmp" "$STATE_FILE"

  exit 0
fi

# -----------------------------------------------------------------------------
# Check iteration limit
# -----------------------------------------------------------------------------
next_iteration=$((iteration + 1))

if [ "$next_iteration" -gt "$max_iterations" ]; then
  log "Max iterations reached ($max_iterations) — allowing exit"

  # Update state
  tmp=$(mktemp)
  cat "$STATE_FILE" | jq \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '.status = "max_iterations_reached" | .stopped_at = $ts' > "$tmp"
  mv "$tmp" "$STATE_FILE"

  exit 0
fi

# -----------------------------------------------------------------------------
# Continue loop: increment iteration and block exit
# -----------------------------------------------------------------------------
log "Iteration $next_iteration/$max_iterations — blocking exit for next iteration"

# Update iteration count
tmp=$(mktemp)
cat "$STATE_FILE" | jq \
  --argjson iter "$next_iteration" \
  --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  '.iteration = $iter | .last_iteration_at = $ts' > "$tmp"
mv "$tmp" "$STATE_FILE"

# Block exit — Claude Code will re-inject the prompt
echo "{\"decision\": \"block\", \"reason\": \"Continuous loop iteration $next_iteration/$max_iterations — continuing\"}" >&2
exit 2
