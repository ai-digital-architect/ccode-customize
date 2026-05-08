#!/usr/bin/env bash
# PreToolUse hook: captures test baseline before first source file edit

baseline=".claude/regression/baseline.json"

# Only capture once per session (if baseline doesn't exist yet)
if [[ -f "$baseline" ]]; then
  exit 0
fi

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // ""')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# Trigger on first source file write
if [[ "$tool_name" =~ ^(Write|Edit|MultiEdit)$ ]] && [[ "$file_path" == src/* ]]; then
  mkdir -p .claude/regression
  pnpm test --reporter=json > "$baseline" 2>/dev/null || true
fi

exit 0
