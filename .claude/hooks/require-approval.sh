#!/usr/bin/env bash
# PreToolUse hook: blocks destructive Bash commands unless approval sentinel exists
# Fires before every Bash tool call
# Exit 0 = allow; Exit 2 = block

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // ""')
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Only gate on Bash tool
if [[ "$tool_name" != "Bash" ]]; then
  exit 0
fi

# Define destructive command patterns
destructive_patterns=(
  "deploy"
  "migrate"
  "kubectl apply"
  "terraform apply"
  "docker push"
  "npm publish"
  "pnpm publish"
)

is_destructive=false
for pattern in "${destructive_patterns[@]}"; do
  if echo "$command" | grep -qi "$pattern"; then
    is_destructive=true
    break
  fi
done

if [[ "$is_destructive" == "false" ]]; then
  exit 0
fi

# Check for approval sentinel
if [[ ! -f ".claude/approval/approved" ]]; then
  echo '{"decision": "block", "reason": "Destructive operation requires human approval. Write summary to .claude/approval/pending.md and wait for user to approve."}' >&2
  exit 2
fi

exit 0
