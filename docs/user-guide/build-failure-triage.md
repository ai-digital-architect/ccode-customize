# Build Failure Triage

## Purpose

The build failure triage skill diagnoses CI and build failures by analyzing error logs, recent commits, and test output. It produces a structured triage report identifying the root cause and proposing a fix. The skill operates in read-only mode and does not modify any code.

Use this skill:
- When a CI pipeline or local build fails unexpectedly
- To quickly identify which commit introduced a regression
- To get a structured diagnosis before starting manual debugging

## Prerequisites

- A failure log file, or a build command that can reproduce the failure (e.g., `pnpm test`)
- A git repository with recent commit history
- Recommended permissions configured in `.claude/settings.json`

## Usage

Invoke the skill with a slash command:

```
/triage-build [failure-log-path or 'latest']
```

Arguments:
- A file path to a specific failure log, OR
- `latest` to have the skill run `pnpm test 2>&1` and capture the current failure output

## Example

```
/triage-build latest
```

This runs `pnpm test`, captures the error output, identifies failing tests, correlates them with recent git commits, and produces a triage report pinpointing the causal commit.

```
/triage-build ci-output/build-2025-01-15.log
```

This reads the specified log file and performs the same analysis against it.

## Output

The skill writes a triage report to `.claude/triage/report.md` containing:

- **Failure Type** -- compile error, test failure, or runtime error
- **Error Message** -- the exact error from the log
- **Failing Files** -- file paths with line numbers
- **Root Cause** -- plain-language description of what went wrong
- **Causal Commit** -- hash, author, and commit message of the likely cause
- **Proposed Fix** -- specific code change needed to resolve the issue
- **Severity** -- critical, high, medium, or low
- **Confidence** -- high, medium, or low

## Tips

- Use `latest` when the failure is reproducible locally for the most accurate diagnosis.
- The skill can be enhanced with a Notification hook to auto-trigger on CI failure events.
- Add recommended permissions to avoid interactive prompts:
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
- Review the proposed fix carefully -- it is a suggestion, not an automated patch.

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| "No failing tests found" | The failure is a compile error, not a test failure | The skill still reports compile errors; check the Failure Type field |
| Low confidence result | The causal commit is ambiguous or the error spans many files | Narrow scope by providing the specific failing test file path |
| Empty triage report | Log file path is incorrect or file is empty | Verify the log file exists and contains error output |
| Cannot reproduce with `latest` | The failure is environment-specific (CI only) | Provide the CI log file path instead of using `latest` |
