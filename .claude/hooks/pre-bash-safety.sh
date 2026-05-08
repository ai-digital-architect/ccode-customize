#!/usr/bin/env bash
# =============================================================================
# pre-bash-safety.sh — PreToolUse Hook: Block Dangerous Shell Commands
# =============================================================================
# Validates Bash tool calls against a set of dangerous patterns and blocks
# operations that could cause irreversible damage to the repository or system.
#
# Exit codes:
#   0 — Command is safe, allow execution
#   2 — Command is dangerous, block execution
#
# Blocked patterns:
#   - rm -rf / (recursive delete from root)
#   - sudo rm (privileged deletion)
#   - git push --force (non-fast-forward push)
#   - git reset --hard on main/master (destructive reset on default branch)
#   - chmod 777 (world-writable permissions)
#   - curl | bash or wget | bash (remote code execution)
#   - >> /etc/* (system file modification)
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Read tool call payload from stdin
# -----------------------------------------------------------------------------
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Skip if no command provided
if [ -z "$command" ] || [ "$command" = "null" ]; then
  exit 0
fi

# -----------------------------------------------------------------------------
# Dangerous pattern detection
# -----------------------------------------------------------------------------

# Block recursive deletion from root or home
if echo "$command" | grep -qE 'rm\s+-rf\s+/|rm\s+-rf\s+~|rm\s+-rf\s+\$HOME'; then
  echo '{"decision": "block", "reason": "Blocked: recursive deletion from root or home directory"}' >&2
  exit 2
fi

# Block privileged deletion
if echo "$command" | grep -qE 'sudo\s+rm'; then
  echo '{"decision": "block", "reason": "Blocked: privileged deletion (sudo rm)"}' >&2
  exit 2
fi

# Block force pushes
if echo "$command" | grep -qE 'git\s+push\s+.*--force|git\s+push\s+.*-f\b'; then
  echo '{"decision": "block", "reason": "Blocked: git force push is not permitted"}' >&2
  exit 2
fi

# Block destructive reset on main/master
if echo "$command" | grep -qE 'git\s+reset\s+--hard.*main|git\s+reset\s+--hard.*master'; then
  echo '{"decision": "block", "reason": "Blocked: destructive git reset on main/master branch"}' >&2
  exit 2
fi

# Block world-writable permissions
if echo "$command" | grep -qE 'chmod\s+777'; then
  echo '{"decision": "block", "reason": "Blocked: world-writable permissions (chmod 777)"}' >&2
  exit 2
fi

# Block remote code execution via pipe
if echo "$command" | grep -qE 'curl\s+.*\|\s*(ba)?sh|wget\s+.*\|\s*(ba)?sh'; then
  echo '{"decision": "block", "reason": "Blocked: remote code execution via pipe to shell"}' >&2
  exit 2
fi

# Block system file modification
if echo "$command" | grep -qE '>>\s*/etc/'; then
  echo '{"decision": "block", "reason": "Blocked: system file modification (/etc/)"}' >&2
  exit 2
fi

# All checks passed — allow the command
exit 0
