# Database Schema Evolution -- User Guide

## Purpose

The database schema evolution pattern provides a gated pipeline for safely evolving database schemas. It walks through four stages -- diff, generate migration, compatibility check, and rollout planning -- with each stage validating before the next proceeds. Use this pattern whenever you need to add, modify, or remove database tables, columns, indexes, or constraints.

## Prerequisites

- Claude Code CLI installed and configured
- Sub-agents installed: `schema-differ`, `migration-generator`, `compat-checker`
- Hook installed: `require-reversible-migration.sh` (PreToolUse)
- Settings fragment merged into `.claude/settings.json`
- Directory `.claude/schema/` created for intermediate artifacts

## Architecture

| Component | Type | Role |
|-----------|------|------|
| `SKILL.md` | Skill | Orchestrates the four-stage pipeline |
| `schema-differ` | Sub-agent (read-only) | Compares current schema against requested change |
| `migration-generator` | Sub-agent (write) | Produces up/down SQL migration scripts |
| `compat-checker` | Sub-agent (read-only, claude-opus-4-5) | Validates backward compatibility and reversibility |
| `require-reversible-migration.sh` | Hook (PreToolUse) | Blocks rollout if migration is not reversible |

The `compat-checker` uses `claude-opus-4-5` for higher accuracy on this safety-critical validation step. Both `schema-differ` and `compat-checker` have `disallowedTools` set to prevent accidental schema modification during analysis.

## Usage

Invoke via the slash command:

```
/schema-evolve "Add a tags column to the posts table with a GIN index"
```

The argument should describe the desired schema change in plain language.

## Workflow

1. **Stage 1 -- Schema Diff**: The `schema-differ` sub-agent compares the current schema against the requested change. Output: `.claude/schema/diff.json`
2. **Stage 2 -- Generate Migration**: The `migration-generator` sub-agent produces up/down migration scripts. Output: `migrations/<timestamp>_<name>.sql`
3. **Stage 3 -- Compatibility Check**: The `compat-checker` sub-agent verifies backward compatibility and reversibility. Output: `.claude/schema/compat-report.json`. If the migration is NOT reversible, the pipeline stops here and reports the issue.
4. **Stage 4 -- Rollout Plan**: A deployment plan is created. Output: `.claude/schema/rollout-plan.md`. The plan is presented for human review.

The `require-reversible-migration.sh` hook fires on any Bash command containing "rollout". It reads the compat report and blocks (exit 2) if `reversible: false` or `blocking_issues` is non-empty.

## Example

```
/schema-evolve "Split the users table: extract address fields into a separate addresses table with a foreign key"
```

This produces:
- A diff showing the removed columns from `users` and the new `addresses` table
- An up migration creating `addresses` and a down migration restoring the original layout
- A compatibility report confirming reversibility
- A rollout plan with recommended deployment steps

## Output

| Artifact | Location |
|----------|----------|
| Schema diff | `.claude/schema/diff.json` |
| Migration scripts | `migrations/<timestamp>_<name>.sql` |
| Compatibility report | `.claude/schema/compat-report.json` |
| Rollout plan | `.claude/schema/rollout-plan.md` |

## Configuration

- **Hook trigger**: Customize the command pattern in `require-reversible-migration.sh` to match your deployment tool (default: "rollout")
- **Migration output path**: Adjust the `migrations/` directory in the skill to match your project structure
- **Model for compat-checker**: The agent uses `claude-opus-4-5` by default; adjust in the agent definition if needed

## Tips

- Always review the rollout plan before executing -- the pattern presents it for human approval
- For destructive changes (dropping columns/tables), consider a multi-phase approach: deprecate first, then remove
- Keep migration names descriptive so they are easy to identify in the migrations directory
- Run the pattern on a feature branch so migrations can be reviewed in a pull request

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Pipeline stops at Stage 3 with "not reversible" | Redesign the migration to be reversible, or split into smaller reversible steps |
| Hook blocks rollout unexpectedly | Check `.claude/schema/compat-report.json` for `blocking_issues` details |
| `schema-differ` cannot find current schema | Ensure your database schema is accessible (e.g., via a schema dump file or live connection) |
| Migration scripts have syntax errors | Verify the `migration-generator` agent has correct dialect context for your database (PostgreSQL, MySQL, etc.) |
