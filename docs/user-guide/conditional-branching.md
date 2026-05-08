# Conditional Branching User Guide

## Purpose

The conditional-branching pattern automatically detects the project's primary language and dispatches the fix to a language-specific specialist sub-agent. It currently supports TypeScript, Python, and Go projects. Use this when you need a fix applied and the correct approach depends on the project's technology stack.

## Prerequisites

The following must be installed in your project:

- **Skill**: `.claude/skills/auto-fix/SKILL.md`
- **Agents**: `.claude/agents/ts-fixer.md`, `.claude/agents/py-fixer.md`, `.claude/agents/go-fixer.md`
- **Permissions**: Build and test commands for all supported languages in `.claude/settings.json`

## Architecture

| Component | Role |
|-----------|------|
| `auto-fix` skill | Detects project type and dispatches to the correct specialist |
| `ts-fixer` sub-agent | TypeScript specialist (write-capable) |
| `py-fixer` sub-agent | Python specialist (write-capable) |
| `go-fixer` sub-agent | Go specialist (write-capable) |

All specialists are write-capable since they need to apply fixes. Each runs in an isolated context focused on its language ecosystem.

## Usage

Invoke from the Claude Code prompt:

```
/auto-fix Fix the failing unit tests in the user service module
```

You do not need to specify the project type -- it is detected automatically.

## Workflow

1. **Detect project type** -- The skill inspects the repository for language markers:
   - `package.json` + `tsconfig.json` present --> TypeScript
   - `requirements.txt` or `pyproject.toml` present --> Python
   - `go.mod` present --> Go
   - If multiple markers match, the most recently modified manifest wins.
2. **Dispatch** -- Based on the detected type, the matching specialist sub-agent is invoked with the issue description.
3. **Apply fix** -- The specialist analyzes the issue in the context of its language's patterns, conventions, and tooling, then applies the fix.
4. **Verify** -- The project's test suite is run to confirm the fix works.

## Example

```
/auto-fix The API handler returns 500 instead of 404 for missing resources
```

In a TypeScript project, the skill detects `package.json` and `tsconfig.json`, then dispatches to `ts-fixer`. The TypeScript specialist examines Express/Fastify route handlers, identifies the missing error handling, adds the proper 404 response, and runs `pnpm test` to verify.

In a Python project with `pyproject.toml`, the same command would dispatch to `py-fixer`, which would examine FastAPI/Flask route handlers and apply Python-idiomatic error handling.

## Output

- Modified source files with the applied fix
- Passing test suite confirming the fix
- Console summary of what was changed

## Tips

- The detection phase costs only about 200 tokens. The specialist agent costs 3,000-10,000 tokens depending on the fix complexity.
- Each specialist runs in an isolated context, so it stays focused on its language's idioms and tooling.
- To add a new language specialist (e.g., Ruby), create `agents/rb-fixer.md`, add a detection rule to `SKILL.md` (`if Gemfile exists --> Ruby`), and add a dispatch entry.
- The skill handles monorepos with multiple languages by checking the most recently modified manifest file.
- Unlike other Tier 2 patterns, the specialists here are write-capable because their purpose is to apply fixes, not just analyze.
- You only need to install the specialist agents for languages your project actually uses. Unused specialists will never be invoked.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Wrong language detected | If your project has multiple language manifests, ensure the correct one has the most recent modification time. Or modify the detection logic in `SKILL.md` to prioritize your primary language. |
| No project type detected | The project must have one of the recognized manifest files (`package.json`+`tsconfig.json`, `requirements.txt`, `pyproject.toml`, or `go.mod`). |
| Specialist fix does not pass tests | The specialist may need more context. Re-run with a more detailed issue description, or apply the fix manually using the specialist's analysis as guidance. |
| Permission errors running tests | Add the relevant test commands to `permissions.allow` in `.claude/settings.json` (e.g., `Bash(pytest:*)`, `Bash(go test:*)`). |
| Specialist modifies unrelated files | Each specialist runs in an isolated context, but it has full write access. Review the changes after the fix is applied to confirm scope. |
