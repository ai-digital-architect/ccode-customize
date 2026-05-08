# Explore-then-Implement User Guide

## Purpose

The explore-then-implement pattern separates code research from code modification into two distinct phases. A read-only researcher agent examines the codebase first, then an implementer agent makes changes based on the findings. Use this pattern for new features, refactors, or bug fixes where understanding existing code is important before making changes.

## Prerequisites

The following must be installed in your project:

- **Skill**: `.claude/skills/explore-implement/SKILL.md`
- **Agents**: `.claude/agents/researcher.md`, `.claude/agents/implementer.md`
- **Directory**: `.claude/research-output/` must exist
- **Permissions**: Build and test commands should be allowed in `.claude/settings.json`

## Architecture

| Component | Role |
|-----------|------|
| `explore-implement` skill | Orchestrates the two-phase workflow |
| `researcher` sub-agent | Scans the codebase read-only (Write/Edit physically disabled via `disallowedTools`) |
| `implementer` sub-agent | Applies changes based on the research output |

The researcher agent **cannot** write files regardless of instructions. This is enforced at the platform level, not by prompt instructions.

## Usage

Invoke from the Claude Code prompt:

```
/explore-implement Add pagination to the users API endpoint
```

The argument should describe the feature, refactor, or bug fix you want performed.

## Workflow

1. **Research phase** -- The `researcher` sub-agent is invoked with your task description. It reads relevant files, traces dependencies, and identifies patterns. It writes its findings to `.claude/research-output/research.md`.
2. **Implementation phase** -- The skill reads `research.md`, then invokes the `implementer` sub-agent with the original task plus the full research summary.
3. **Verification phase** -- The skill runs `pnpm build && pnpm test` and fixes any failures.
4. **Summary** -- A summary is presented showing what was implemented and how it follows existing patterns.

## Example

```
/explore-implement Refactor the auth middleware to support JWT refresh tokens
```

The researcher will scan the existing auth middleware, identify token handling patterns, note related files and tests, and document its findings. The implementer then reads those findings and applies the refactor, following the conventions the researcher identified.

## Output

- `.claude/research-output/research.md` -- Research findings including relevant files, patterns, dependencies, risks, and recommended approach
- Modified source files as determined by the implementation plan
- Passing build and test suite

## Tips

- Provide a clear, specific task description. Vague descriptions lead to broad, unfocused research.
- Review the research output at `.claude/research-output/research.md` if you want to understand what the researcher found before the implementer runs.
- This pattern works best for medium-to-large changes where understanding context matters. For trivial one-line fixes, direct editing is faster.
- The research phase costs 2,000-5,000 tokens; the implementation phase costs 5,000-15,000 tokens.
- The read-only enforcement on the researcher is physical (`disallowedTools`), not a prompt instruction. This means the researcher cannot accidentally modify files even if the task description is ambiguous.
- If you only need the research phase (e.g., to understand a module before making manual changes), you can read the research output and skip the implementation phase.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Researcher produces empty or thin research | The task description may be too vague. Provide more specific details about what you want changed. |
| Implementer ignores existing patterns | Check that the researcher's output in `research.md` actually captured the relevant conventions. Re-run with a more targeted description if needed. |
| `.claude/research-output/` does not exist | Run `mkdir -p .claude/research-output` or add the Bash permission for that command. |
| Build or test failures after implementation | The verification phase should catch these automatically. If failures persist, the implementer may need manual guidance on project-specific constraints. |
| Research output is stale from a previous run | Each invocation overwrites `.claude/research-output/research.md`. If you see stale content, the researcher may have failed silently -- check that the task description matches your intent. |
