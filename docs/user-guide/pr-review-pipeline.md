# PR Review Pipeline User Guide

## Purpose

The pr-review-pipeline pattern runs a multi-specialist review on a pull request or branch diff. Five specialist agents each analyze a different aspect (diff categorization, security, style, coverage, summary), and a final summarizer produces a unified review. Use this for pull request reviews or pre-merge quality checks.

## Prerequisites

The following must be installed in your project:

- **Skill**: `.claude/skills/review-pr/SKILL.md`
- **Agents**: `.claude/agents/diff-analyzer.md`, `.claude/agents/security-reviewer.md`, `.claude/agents/style-checker.md`, `.claude/agents/coverage-checker.md`, `.claude/agents/review-summarizer.md`
- **Directory**: `.claude/review/` must exist
- **Permissions**: Git commands (`git diff`, `git log`, `git show`) and test commands in `.claude/settings.json`

## Architecture

| Component | Role |
|-----------|------|
| `review-pr` skill | Orchestrates the sequential specialist chain |
| `diff-analyzer` sub-agent | Categorizes changes (new features, refactors, fixes, config) |
| `security-reviewer` sub-agent | Identifies security concerns (uses `claude-opus-4-5`) |
| `style-checker` sub-agent | Checks convention and style compliance |
| `coverage-checker` sub-agent | Assesses test coverage for changed code |
| `review-summarizer` sub-agent | Aggregates all findings into a unified review (uses `claude-opus-4-5`) |

All five sub-agents have `disallowedTools: [Write, Edit, MultiEdit]`. None can modify the code they are reviewing.

## Usage

Invoke from the Claude Code prompt:

```
/review-pr feature/add-auth
```

Or with a commit range:

```
/review-pr main..HEAD
```

The argument is a branch name or commit range for `git diff`.

## Workflow

1. **Capture diff** -- The skill runs `git diff` with your argument and saves output to `.claude/review/diff.txt`.
2. **Diff analysis** -- The `diff-analyzer` categorizes changes and writes to `.claude/review/diff-analysis.json`.
3. **Security review** -- The `security-reviewer` scans for vulnerabilities and writes to `.claude/review/security.json`.
4. **Style check** -- The `style-checker` evaluates convention compliance and writes to `.claude/review/style.json`.
5. **Coverage check** -- The `coverage-checker` assesses test coverage and writes to `.claude/review/coverage.json`.
6. **Synthesis** -- The `review-summarizer` reads all four specialist reports and produces `.claude/review/review.md`.
7. **Presentation** -- The unified review is displayed.

## Example

```
/review-pr feature/user-profiles
```

The pipeline produces a review that might include:
- **Diff analysis**: 3 new files (feature), 2 modified files (refactor)
- **Security**: Warning -- user input passed to SQL query without parameterization in `src/db/users.ts:45`
- **Style**: 2 naming convention violations in test files
- **Coverage**: New `UserProfile` class has no unit tests
- **Summary**: Request changes -- address SQL injection risk and add unit tests

## Output

- `.claude/review/diff.txt` -- Raw diff output
- `.claude/review/diff-analysis.json` -- Change categorization
- `.claude/review/security.json` -- Security findings
- `.claude/review/style.json` -- Style compliance report
- `.claude/review/coverage.json` -- Coverage assessment
- `.claude/review/review.md` -- Unified review summary with recommendation

## Tips

- The `security-reviewer` and `review-summarizer` use `claude-opus-4-5` for higher accuracy on critical analysis. This increases token cost but improves quality.
- Total token cost ranges from 7,000-13,000 tokens across all agents.
- Each specialist runs in isolation, so findings are independent and not influenced by other agents.
- Use this pattern as a pre-merge gate to catch issues before human review.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Empty diff output | Ensure the branch name or commit range is correct. Run `git diff <argument>` manually to verify. |
| `.claude/review/` directory missing | Run `mkdir -p .claude/review` or add the Bash permission for that command. |
| Security reviewer misses obvious issues | The reviewer focuses on the diff, not the entire codebase. Known vulnerabilities outside the diff are not in scope. |
| Git permission errors | Add the required git commands to `permissions.allow` in `.claude/settings.json`. |
