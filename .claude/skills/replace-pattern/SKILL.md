---
name: replace-pattern
description: >
  Finds all instances of an old code pattern across the codebase using a
  read-only discovery pass, then replaces each instance one at a time with
  lint and compile verification after each replacement. Use for large-scale
  refactors like API migrations, naming convention changes, or deprecated
  pattern elimination.
argument-hint: "[old-pattern description] [new-pattern description]"
allowed-tools: Read, Write, Edit, Bash
---

Replace pattern across codebase: $ARGUMENTS

## Phase 1: Discovery (read-only)

Invoke the `pattern-finder` sub-agent to:
1. Scan the entire codebase for instances of the old pattern
2. Produce a manifest of all instances with file paths and line numbers
3. Output: `.claude/refactor/instance-manifest.json`

Review the manifest before proceeding.

## Phase 2: Replacement (one at a time)

Invoke the `pattern-replacer` sub-agent to:
1. Read the instance manifest
2. Replace each instance one at a time
3. After each replacement: lint + compile verification runs automatically (via hook)
4. On verification failure: fix before moving to next instance
5. Output: `.claude/refactor/replacement-log.json`

## Phase 3: Final Verification

Run `pnpm build && pnpm test` to verify the complete replacement is clean.

Present a summary: instances found, replaced successfully, any failures.
