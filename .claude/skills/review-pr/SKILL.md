---
name: review-pr
description: >
  Runs a multi-specialist PR review pipeline: diff analysis, security review,
  style checking, coverage assessment, and unified summary. All read-only.
  Use for pull request reviews or pre-merge checks.
argument-hint: "[branch-name or commit-range]"
allowed-tools: Read, Bash
---

Review PR: $ARGUMENTS

## Steps

1. Run `git diff $ARGUMENTS` and save to `.claude/review/diff.txt`
2. Invoke `diff-analyzer` → `.claude/review/diff-analysis.json`
3. Invoke `security-reviewer` → `.claude/review/security.json`
4. Invoke `style-checker` → `.claude/review/style.json`
5. Invoke `coverage-checker` → `.claude/review/coverage.json`
6. Invoke `review-summarizer` to aggregate all findings → `.claude/review/review.md`
7. Present the unified review
