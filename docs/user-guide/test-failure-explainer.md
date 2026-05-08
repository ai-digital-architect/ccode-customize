# Test Failure Explainer

## Purpose

The test failure explainer skill diagnoses why a specific test is failing by tracing recent commits, identifying the regression commit, and suggesting a fix. It provides a clear explanation of the failure chain: what the test expects, what the code does, and why they diverge.

Use this skill:
- When a test fails and the cause is not immediately obvious
- To identify which commit introduced a regression
- To get a structured explanation before starting manual debugging

## Prerequisites

- A test runner configured (e.g., `pnpm test`)
- A git repository with recent commit history
- The failing test must be reproducible locally
- This skill uses the `claude-opus-4-5` model for deeper analysis

## Usage

Invoke the skill with a slash command:

```
/explain-failure [test-name or test-file-path]
```

Arguments:
- The name of a specific failing test, OR
- The file path to a test file

## Example

```
/explain-failure src/routes/invoice.routes.test.ts
```

This runs the specified test file, captures the error output, reads both the test and the source file under test, traces recent git commits to the source file, and identifies the commit that most likely broke the test.

```
/explain-failure "should return 404 for missing invoice"
```

This searches for the test by name, runs it, and performs the same regression analysis.

## Output

The skill writes an explanation to `.claude/failures/explanation.md` containing:

- **Test** -- the full test name
- **Error** -- simplified error message
- **Root Cause** -- plain-language explanation of why the test fails
- **Regression Commit** -- hash, author, and commit message of the causal commit
- **What Changed** -- the specific code change that broke the test
- **Suggested Fix** -- a concrete code change to resolve the failure
- **Confidence** -- high, medium, or low

The explanation and suggested fix are also presented directly in the conversation.

## Tips

- Provide the full test file path for the most reliable results.
- The skill does not modify code -- apply the suggested fix manually after reviewing it.
- Add recommended permissions to `.claude/settings.json`:
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
- If the suggested fix has low confidence, use the regression commit information to investigate manually.

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Test passes when skill runs it | The failure is flaky or environment-dependent | Run the test multiple times to confirm flakiness; provide the original error log |
| No regression commit found | The test was always failing, or the change is too old | Expand the git log range or check if the test is newly added |
| Wrong source file identified | Test imports from an unexpected location | Provide the source file path explicitly alongside the test |
| Suggested fix is incomplete | The failure involves multiple interacting changes | Use the regression commit as a starting point for deeper manual investigation |
