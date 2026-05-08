# Regression Sweep -- User Guide

## Purpose

The regression sweep pattern captures test results before and after a code change, then diffs them to identify regressions. Use this pattern after any non-trivial edit to verify that no existing tests were broken by the change. It provides a clear report of newly failing tests, newly passing tests, and unchanged failures.

## Prerequisites

- Claude Code CLI installed and configured
- Sub-agent installed: `regression-differ`
- Hook installed: `capture-baseline.sh` (PreToolUse)
- Settings fragment merged into `.claude/settings.json`
- Directory `.claude/regression/` created for result files
- A working test suite runnable via `pnpm test`

## Architecture

| Component | Type | Role |
|-----------|------|------|
| `SKILL.md` | Skill | Orchestrates baseline capture, post-change capture, and diff |
| `regression-differ` | Sub-agent (read-only) | Compares baseline and post-change test result sets |
| `capture-baseline.sh` | Hook (PreToolUse) | Automatically captures test baseline before first source edit |

The `regression-differ` agent has `disallowedTools: [Write, Edit, MultiEdit]` to enforce strict separation between analysis and implementation -- it cannot modify source code to "fix" regressions.

## Usage

Invoke via the slash command after making changes:

```
/regression-sweep "Refactored the authentication middleware to use async/await"
```

The argument should describe the change that was made.

## Workflow

1. **Baseline capture**: If the `capture-baseline.sh` hook is installed, it automatically runs `pnpm test --reporter=json` and saves results to `.claude/regression/baseline.json` before the first source file edit. This happens transparently.
2. **Code changes**: You (or another skill) make the code changes.
3. **Post-change capture**: The skill runs `pnpm test --reporter=json` and saves results to `.claude/regression/post.json`.
4. **Diff analysis**: The `regression-differ` sub-agent compares baseline and post-change results.
5. **Report**: The skill presents newly failing tests, newly passing tests, and unchanged failures.

### Hook Behavior

The `capture-baseline.sh` hook triggers on Write, Edit, or MultiEdit calls targeting `src/*` files. It runs only once -- if a baseline file already exists, it exits immediately. This ensures the baseline always reflects the pre-change state.

## Example

```
/regression-sweep "Added input validation to the user registration endpoint"
```

Output report might show:
- 2 newly failing tests: `auth.test.ts > registration > allows empty email` (intentional -- validation now rejects this)
- 1 newly passing test: `auth.test.ts > registration > validates email format` (previously skipped)
- 3 unchanged failures: pre-existing failures unrelated to the change

## Output

| Artifact | Location |
|----------|----------|
| Baseline test results | `.claude/regression/baseline.json` |
| Post-change test results | `.claude/regression/post.json` |
| Diff report | Presented in the session |

## Configuration

- **Test command**: Change `pnpm test --reporter=json` in the skill and hook to match your test runner (e.g., `pytest --json-report`, `go test -json`)
- **Source file pattern**: Adjust the `src/*` trigger pattern in the hook to match your project layout
- **Baseline path**: Modify `.claude/regression/baseline.json` if you need multiple baselines

## Tips

- Run the sweep after each logical change, not after a batch of unrelated changes -- smaller diffs are easier to interpret
- Delete `.claude/regression/baseline.json` before starting a new change to ensure a fresh baseline
- Newly passing tests are worth investigating -- they may indicate a test that was accidentally broken before
- Pair this pattern with the continuous loop pattern for automated regression checking on each iteration

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Baseline not captured automatically | Verify the hook is installed and the file edit targets `src/*`; check that `.claude/regression/` directory exists |
| Baseline reflects mid-change state | Delete `baseline.json` and re-run the sweep; ensure the hook fires before edits |
| Test runner output not parseable | Verify your test runner supports JSON output; adjust the reporter flag as needed |
| Too many unchanged failures | These are pre-existing; address them separately or filter them in the diff report |
