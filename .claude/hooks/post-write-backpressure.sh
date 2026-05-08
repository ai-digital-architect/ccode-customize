#!/usr/bin/env bash
# =============================================================================
# post-write-backpressure.sh — PostToolUse Hook: Lint & Format After Writes
# =============================================================================
# Runs the appropriate linter/formatter after every file write operation.
# This provides deterministic backpressure for the continuous loop — the agent
# does not decide if formatting is correct; the tools decide.
#
# Exit codes:
#   0 — Formatting/linting succeeded or file type not recognized
#   2 — Linting failed (blocks the operation)
#
# Supports: TypeScript, JavaScript, Python, Go, Rust, Markdown
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Read tool call payload from stdin
# -----------------------------------------------------------------------------
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.filePath // ""')

# Skip if no file path provided
if [ -z "$file_path" ] || [ "$file_path" = "null" ]; then
  exit 0
fi

# Skip non-source files
case "$file_path" in
  *.json|*.lock|*.log|*.map|*.min.js|*.min.css)
    exit 0
    ;;
  .claude/*|node_modules/*|dist/*|build/*)
    exit 0
    ;;
esac

# -----------------------------------------------------------------------------
# Run appropriate formatter/linter based on file extension
# -----------------------------------------------------------------------------
case "$file_path" in
  *.ts|*.tsx|*.js|*.jsx)
    # TypeScript/JavaScript: Prettier + ESLint
    if command -v npx >/dev/null 2>&1; then
      npx prettier --write "$file_path" 2>/dev/null || true
      npx eslint --fix "$file_path" 2>/dev/null || true
    fi
    ;;
  *.py)
    # Python: ruff format + ruff check
    if command -v ruff >/dev/null 2>&1; then
      ruff format "$file_path" 2>/dev/null || true
      ruff check --fix "$file_path" 2>/dev/null || true
    fi
    ;;
  *.go)
    # Go: gofmt + go vet
    if command -v gofmt >/dev/null 2>&1; then
      gofmt -w "$file_path" 2>/dev/null || true
    fi
    ;;
  *.rs)
    # Rust: rustfmt
    if command -v rustfmt >/dev/null 2>&1; then
      rustfmt "$file_path" 2>/dev/null || true
    fi
    ;;
  *.md)
    # Markdown: Prettier
    if command -v npx >/dev/null 2>&1; then
      npx prettier --write "$file_path" 2>/dev/null || true
    fi
    ;;
esac

exit 0
