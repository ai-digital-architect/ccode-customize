---
name: triage-build
description: >
  Diagnoses a CI/build failure by analyzing error logs, recent commits, and test
  output. Produces a triage report with root cause and proposed fix. Use when a
  build or CI pipeline fails.
argument-hint: "[failure-log-path or 'latest']"
disable-model-invocation: false
context: fork
agent: Explore
allowed-tools: Read, Bash
---

Triage build failure: $ARGUMENTS

You are a build failure specialist. Diagnose the failure without modifying any code.

## Steps

1. Read the failure log (provided path, or run `pnpm test 2>&1` to capture latest)
2. Extract the specific error messages and failing test names
3. Run `git log --oneline -10` to see recent commits
4. For each failing test, find the corresponding source file
5. Run `git log -5 -- <failing-file>` to identify recent changes
6. For key commits, run `git show <hash> -- <file>` to see what changed
7. Correlate the error to the most likely causal commit

## Output

Write triage report to `.claude/triage/report.md`:

```
## Triage Report
- **Failure Type**: compile error / test failure / runtime error
- **Error Message**: exact message
- **Failing Files**: list with line numbers
- **Root Cause**: description of what went wrong
- **Causal Commit**: hash, author, message
- **Proposed Fix**: specific code change needed
- **Severity**: critical / high / medium / low
- **Confidence**: high / medium / low
```

## Enhancement

Add a Notification hook to auto-trigger this skill on CI failure notifications:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "*",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/on-ci-failure.sh"}]
      }
    ]
  }
}
```

## Recommended Permissions

```json
{
  "permissions": {
    "allow": [
      "Bash(git log:*)",
      "Bash(git diff:*)",
      "Bash(git show:*)",
      "Bash(pnpm test:*)",
      "Bash(grep -rn *)",
      "Bash(mkdir -p .claude/triage)"
    ]
  }
}
```
