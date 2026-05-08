# Pattern 11: Pattern Replacement

## Tier
**Tier 3** — Full Stack (Skill + Sub-agents + Hooks + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: discover → replace |
| `agents/pattern-finder.md` | Read-only discovery agent |
| `agents/pattern-replacer.md` | Write-capable replacement agent |
| `hooks/refactor-lint.sh` | PostToolUse: lint + compile after each edit |
| `settings-fragment.json` | Hook registration + permissions |

## Security Model

The `pattern-finder` has `disallowedTools: [Write, Edit, MultiEdit]` — it cannot
modify any files during discovery. This is the read-only guarantee for the discovery phase.

The `refactor-lint.sh` hook catches compile errors immediately after each individual
replacement, rather than discovering them after 50 replacements. This is the
per-instance gate that makes the replacement safe.

## Hook Behavior

### refactor-lint.sh (PostToolUse)
- **Triggers**: Write, Edit, MultiEdit to `src/*` or `packages/*`
- **Action 1**: Runs `prettier --write` (non-blocking)
- **Action 2**: Runs `pnpm build --silent` (blocking)
- **On compile failure**: exit 2 — forces fix before next instance
- **On success**: exit 0

## Installation

```bash
mkdir -p .claude/skills/replace-pattern .claude/agents .claude/hooks .claude/refactor
cp SKILL.md .claude/skills/replace-pattern/SKILL.md
cp agents/pattern-finder.md .claude/agents/pattern-finder.md
cp agents/pattern-replacer.md .claude/agents/pattern-replacer.md
cp hooks/refactor-lint.sh .claude/hooks/refactor-lint.sh
chmod +x .claude/hooks/refactor-lint.sh
# Merge settings-fragment.json into .claude/settings.json
```
