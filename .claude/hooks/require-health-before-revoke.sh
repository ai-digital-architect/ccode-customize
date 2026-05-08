#!/usr/bin/env bash
# PreToolUse hook: blocks old credential revocation unless health check passed

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Only gate on revocation commands
if ! echo "$command" | grep -qE "revoke|delete.*key|remove.*secret"; then
  exit 0
fi

health_file=".claude/secrets/health-check.json"
if [[ ! -f "$health_file" ]]; then
  echo '{"decision": "block", "reason": "Health check not completed. Verify service works with new credential before revoking old one."}' >&2
  exit 2
fi

status=$(jq -r '.status' "$health_file")
if [[ "$status" != "healthy" ]]; then
  echo '{"decision": "block", "reason": "Service health check failed. Do not revoke old credential — rollback instead."}' >&2
  exit 2
fi

exit 0
