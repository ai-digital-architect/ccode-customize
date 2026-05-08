#!/usr/bin/env bash
# PostToolUse hook: runs build after every Write/Edit to enforce pipeline gates
# Fires after: Write, Edit, MultiEdit
# Exit 0 = allow; Exit 2 = block

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // ""')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# Only gate on source file writes (not config or test-only files)
if [[ "$file_path" != src/* ]]; then
  exit 0
fi

# Run build check
if ! pnpm build --silent 2>/dev/null; then
  echo "{\"reason\": \"Build failed after writing $file_path. Fix compilation errors before proceeding to next pipeline stage.\"}" >&2
  exit 2
fi

exit 0
