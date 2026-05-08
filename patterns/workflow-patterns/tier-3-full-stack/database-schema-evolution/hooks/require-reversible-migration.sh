#!/usr/bin/env bash
# PreToolUse hook: blocks rollout plan generation if migration is not reversible
# Fires before every Bash call
# Exit 0 = allow; Exit 2 = block

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Only gate on rollout-related operations
if ! echo "$command" | grep -q "rollout"; then
  exit 0
fi

report=".claude/schema/compat-report.json"
if [[ ! -f "$report" ]]; then
  echo '{"decision": "block", "reason": "Compatibility report not found. Run compat-checker first."}' >&2
  exit 2
fi

reversible=$(jq -r '.reversible' "$report")
blocking=$(jq -r '.blocking_issues | length' "$report")

if [[ "$reversible" != "true" ]] || [[ "$blocking" -gt 0 ]]; then
  echo '{"decision": "block", "reason": "Migration is not reversible or has blocking issues. Cannot proceed to rollout."}' >&2
  exit 2
fi

exit 0
