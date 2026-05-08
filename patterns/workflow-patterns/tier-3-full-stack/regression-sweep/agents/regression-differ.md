---
name: regression-differ
description: >
  Compares two test result sets (before/after) and identifies regressions.
  Read-only.
model: claude-sonnet-4-6
tools:
  - Read
  - Bash
disallowedTools:
  - Write
  - Edit
  - MultiEdit
maxTurns: 8
---

Compare test results in `.claude/regression/baseline.json` vs `.claude/regression/post.json`.

Produce a report:
1. **New Failures** — tests that passed before but fail now (REGRESSIONS)
2. **New Passes** — tests that failed before but pass now (FIXES)
3. **Unchanged Failures** — tests that failed both before and after (PRE-EXISTING)
4. **Summary** — total regressions count, attribution to changed files

Write to `.claude/regression/diff-report.md`.
