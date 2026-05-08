# Pattern 10: Incremental Migration

## Tier
**Tier 3** — Full Stack (Skill + Sub-agents + Hooks + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: sequential module-by-module migration |
| `agents/module-migrator.md` | Write-capable single-module migrator |
| `hooks/migration-gate.sh` | PostToolUse: blocks on build failure |
| `settings-fragment.json` | Hook registration + permissions |

## Security Model

The `migration-gate.sh` hook runs `pnpm build` after every source file write.
If the build fails, it exits 2 — blocking the result and forcing a fix before
proceeding to the next module. This prevents a broken build from propagating
through the migration.

## Hook Behavior

### migration-gate.sh (PostToolUse)
- **Triggers**: Write, Edit, MultiEdit to `src/*` or `packages/*`
- **Action**: Runs `pnpm build --silent`
- **On failure**: exit 2 — forces fix before next module
- **On success**: exit 0

## Installation

```bash
mkdir -p .claude/skills/incremental-migrate .claude/agents .claude/hooks
cp SKILL.md .claude/skills/incremental-migrate/SKILL.md
cp agents/module-migrator.md .claude/agents/module-migrator.md
cp hooks/migration-gate.sh .claude/hooks/migration-gate.sh
chmod +x .claude/hooks/migration-gate.sh
# Merge settings-fragment.json into .claude/settings.json
```
