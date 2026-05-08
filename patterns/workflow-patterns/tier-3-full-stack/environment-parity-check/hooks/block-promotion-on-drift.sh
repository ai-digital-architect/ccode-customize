#!/usr/bin/env bash
# PreToolUse hook: blocks deployment if env parity check failed

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

if ! echo "$command" | grep -qE "deploy|promote|release"; then
  exit 0
fi

report=".claude/env/parity-report.json"
if [[ -f "$report" ]]; then
  status=$(jq -r '.parity_status' "$report")
  if [[ "$status" == "fail" ]]; then
    divergences=$(jq -r '.divergences | length' "$report")
    echo "{\"decision\": \"block\", \"reason\": \"Environment parity check failed: $divergences divergence(s). Resolve before promoting.\"}" >&2
    exit 2
  fi
fi

exit 0
