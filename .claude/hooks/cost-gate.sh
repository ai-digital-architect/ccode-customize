#!/usr/bin/env bash
# PreToolUse hook: estimates cost of tool call and blocks if over budget
# Fires before every tool call (matcher: *)
# Exit 0 = allow; Exit 2 = block

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // ""')

BUDGET_FILE=".claude/budget.json"
SPEND_LOG=".claude/spend.log"

# Initialize budget file if missing
if [[ ! -f "$BUDGET_FILE" ]]; then
  mkdir -p .claude
  echo '{"budget_tokens": 100000, "spent_tokens": 0}' > "$BUDGET_FILE"
fi

budget=$(jq -r '.budget_tokens' "$BUDGET_FILE")
spent=$(jq -r '.spent_tokens' "$BUDGET_FILE")

# Estimate cost by tool type (conservative estimates)
case "$tool_name" in
  "Write"|"Edit"|"MultiEdit")
    content_length=$(echo "$input" | jq -r '.tool_input | tostring | length')
    estimated_cost=$((content_length / 4))  # ~4 chars per token
    ;;
  "Bash")
    estimated_cost=50  # Fixed estimate for bash calls
    ;;
  "Read")
    estimated_cost=20
    ;;
  *)
    estimated_cost=30
    ;;
esac

new_total=$((spent + estimated_cost))

if [[ "$new_total" -gt "$budget" ]]; then
  remaining=$((budget - spent))
  echo "{\"decision\": \"block\", \"reason\": \"Cost gate: estimated spend ($new_total tokens) exceeds budget ($budget tokens). Remaining: $remaining tokens. Update .claude/budget.json to increase budget.\"}" >&2
  exit 2
fi

# Update spend tracker
jq --argjson spent "$new_total" '.spent_tokens = $spent' "$BUDGET_FILE" > "${BUDGET_FILE}.tmp" \
  && mv "${BUDGET_FILE}.tmp" "$BUDGET_FILE"

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "$timestamp | $tool_name | est:$estimated_cost | total:$new_total/$budget" >> "$SPEND_LOG"

exit 0
