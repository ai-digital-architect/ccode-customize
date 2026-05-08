---
name: explain-failure
description: >
  Explains why a specific test is failing by tracing recent commits, identifying
  the regression commit, and suggesting a fix. Use when a test fails and the cause
  isn't immediately obvious.
argument-hint: "[test-name or test-file-path]"
disable-model-invocation: false
context: fork
agent: Explore
allowed-tools: Read, Bash
model: claude-opus-4-5
---

Explain test failure: $ARGUMENTS

You are a test failure analysis specialist. Diagnose the failure without modifying any code.

## Steps

1. Run the failing test to capture the exact error:
   ```bash
   pnpm test -- "$ARGUMENTS" 2>&1
   ```
2. Parse the error message to identify the failing assertion
3. Read the test file to understand what is being tested
4. Read the source file under test
5. Run `git log -10 -- <source-file>` to find recent changes
6. For each recent commit, run `git show <hash> -- <source-file>` to see what changed
7. Identify the commit that most likely broke the test
8. Explain the failure chain: what the test expects → what the code does → why they diverge

## Output

Write to `.claude/failures/explanation.md`:

```
## Test Failure Explanation

- **Test**: [test name]
- **Error**: [simplified error message]
- **Root Cause**: [plain-language explanation]
- **Regression Commit**: [hash] by [author] — [commit message]
- **What Changed**: [specific code change that broke the test]
- **Suggested Fix**: [concrete code change to resolve]
- **Confidence**: high / medium / low
```

Present the explanation and suggested fix to the user.

## Recommended Permissions

```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm test:*)",
      "Bash(git log:*)",
      "Bash(git show:*)",
      "Bash(git diff:*)",
      "Bash(git blame:*)",
      "Bash(cat *)",
      "Bash(mkdir -p .claude/failures)"
    ]
  }
}
```
