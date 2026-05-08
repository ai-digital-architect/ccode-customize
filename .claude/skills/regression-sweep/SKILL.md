---
name: regression-sweep
description: >
  Captures test results before and after a code change, then diffs to identify
  any regressions introduced by the change. Use after any non-trivial edit
  to verify no existing tests were broken.
argument-hint: "[description of change made]"
allowed-tools: Read, Bash
---

Run regression sweep: $ARGUMENTS

1. Capture baseline: `pnpm test --reporter=json > .claude/regression/baseline.json`
2. (Changes should already be made at this point)
3. Capture post-change: `pnpm test --reporter=json > .claude/regression/post.json`
4. Invoke `regression-differ` sub-agent to compare results
5. Present: newly failing tests, newly passing tests, unchanged failures

Note: The `capture-baseline.sh` PreToolUse hook automatically captures the baseline
before the first source file edit — you do not need to capture it manually if the
hook is installed.
