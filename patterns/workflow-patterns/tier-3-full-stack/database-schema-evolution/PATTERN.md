# Pattern 12: Database Schema Evolution

## Tier
**Tier 3** — Full Stack (Skill + Sub-agents + Hooks + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: diff → generate → compat → plan |
| `agents/schema-differ.md` | Read-only schema diff producer |
| `agents/migration-generator.md` | Write-capable SQL migration generator |
| `agents/compat-checker.md` | Read-only reversibility validator (claude-opus-4-5) |
| `hooks/require-reversible-migration.sh` | PreToolUse: blocks rollout if not reversible |
| `settings-fragment.json` | Hook registration + deny list |

## Security Model

The `require-reversible-migration.sh` hook reads `.claude/schema/compat-report.json`
and blocks any rollout command if `reversible: false` or `blocking_issues` is non-empty.

`compat-checker` uses `claude-opus-4-5` for higher accuracy on this safety-critical check.
Both `schema-differ` and `compat-checker` have `disallowedTools` to prevent any
accidental schema modification during analysis.

## Hook Behavior

### require-reversible-migration.sh (PreToolUse)
- **Triggers**: Bash calls containing "rollout"
- **Reads**: `.claude/schema/compat-report.json`
- **On not reversible or blocking issues**: exit 2 — stops rollout
- **On reversible + no blocking issues**: exit 0

## Installation

```bash
mkdir -p .claude/skills/schema-evolve .claude/agents .claude/hooks .claude/schema
cp SKILL.md .claude/skills/schema-evolve/SKILL.md
for agent in schema-differ migration-generator compat-checker; do
  cp agents/${agent}.md .claude/agents/${agent}.md
done
cp hooks/require-reversible-migration.sh .claude/hooks/require-reversible-migration.sh
chmod +x .claude/hooks/require-reversible-migration.sh
# Merge settings-fragment.json into .claude/settings.json
```
