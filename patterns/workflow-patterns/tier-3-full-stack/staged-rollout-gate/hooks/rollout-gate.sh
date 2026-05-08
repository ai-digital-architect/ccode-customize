#!/usr/bin/env bash
# PreToolUse hook: blocks deployment to next env unless previous env passed
# Fires before every Bash call
# Exit 0 = allow; Exit 2 = block

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Detect which environment is being targeted
if echo "$command" | grep -q "staging"; then
  # Must have dev success
  if [[ ! -f ".claude/rollout/dev-result.json" ]]; then
    echo '{"decision": "block", "reason": "Cannot deploy to staging: dev deployment result not found."}' >&2
    exit 2
  fi
  dev_status=$(jq -r '.status' .claude/rollout/dev-result.json)
  if [[ "$dev_status" != "success" ]]; then
    echo '{"decision": "block", "reason": "Cannot deploy to staging: dev deployment failed."}' >&2
    exit 2
  fi
fi

if echo "$command" | grep -q "production"; then
  if [[ ! -f ".claude/rollout/staging-result.json" ]]; then
    echo '{"decision": "block", "reason": "Cannot deploy to production: staging result not found."}' >&2
    exit 2
  fi
  staging_status=$(jq -r '.status' .claude/rollout/staging-result.json)
  if [[ "$staging_status" != "success" ]]; then
    echo '{"decision": "block", "reason": "Cannot deploy to production: staging failed."}' >&2
    exit 2
  fi
  # Also require approval sentinel
  if [[ ! -f ".claude/rollout/production-approved" ]]; then
    echo '{"decision": "block", "reason": "Cannot deploy to production: human approval required. Create .claude/rollout/production-approved to proceed."}' >&2
    exit 2
  fi
fi

exit 0
