#!/usr/bin/env bash
# PostToolUse hook: runs lint + compile after each pattern replacement
# Fires after: Write, Edit, MultiEdit
# Exit 0 = allow; Exit 2 = block

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# Only gate on source files
if [[ "$file_path" != src/* ]] && [[ "$file_path" != packages/* ]]; then
  exit 0
fi

# Run prettier (non-blocking lint)
if command -v prettier &>/dev/null; then
  prettier --write "$file_path" --silent 2>/dev/null || true
fi

# Run compile check (blocking)
if ! pnpm build --silent 2>/dev/null; then
  echo "{\"reason\": \"Compile failed after replacing pattern in $file_path. Fix before continuing.\"}" >&2
  exit 2
fi

exit 0
