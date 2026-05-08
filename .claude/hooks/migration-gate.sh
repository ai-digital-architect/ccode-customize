#!/usr/bin/env bash
# PostToolUse hook: runs build after file modifications during migration
# Fires after: Write, Edit, MultiEdit
# Exit 0 = allow; Exit 2 = block

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# Only gate on source file changes
if [[ "$file_path" != src/* ]] && [[ "$file_path" != packages/* ]]; then
  exit 0
fi

# Run build check
if ! pnpm build --silent 2>/dev/null; then
  echo "{\"reason\": \"Build failed after modifying $file_path. Fix before continuing migration.\"}" >&2
  exit 2
fi

exit 0
