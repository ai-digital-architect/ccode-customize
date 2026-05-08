#!/usr/bin/env bash
# PostToolUse hook: runs type-checker after writing client files

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# Only check generated client files
case "$file_path" in
  src/clients/*.ts|clients/*.py|clients/*.go)
    ;;
  *)
    exit 0
    ;;
esac

# Run appropriate type-checker
case "$file_path" in
  *.ts)  pnpm typecheck 2>/dev/null || { echo '{"decision": "block", "reason": "TypeScript type-check failed"}' >&2; exit 2; } ;;
  *.py)  mypy "$file_path" 2>/dev/null || { echo '{"decision": "block", "reason": "mypy type-check failed"}' >&2; exit 2; } ;;
  *.go)  go vet ./clients/... 2>/dev/null || { echo '{"decision": "block", "reason": "go vet failed"}' >&2; exit 2; } ;;
esac

exit 0
