# Pattern 15: Regression Sweep

## Tier
**Tier 3** — Full Stack (Skill + Sub-agent + Hook + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: baseline → change → post-capture → diff |
| `agents/regression-differ.md` | Read-only diff producer — compares test result sets |
| `hooks/capture-baseline.sh` | PreToolUse: captures test baseline before first source edit |
| `settings-fragment.json` | Hook registration + test permissions |

## Security Model

`regression-differ` has `disallowedTools: [Write, Edit, MultiEdit]` — it can only
read the result files and write the diff report. It cannot modify source code to "fix"
regressions, ensuring separation between analysis and implementation.

## Hook Behavior

### capture-baseline.sh (PreToolUse)
- **Triggers**: Write, Edit, or MultiEdit on `src/*` files
- **Guard**: Only runs once — exits immediately if baseline already exists
- **Action**: Runs `pnpm test --reporter=json` and saves to `.claude/regression/baseline.json`
- **Timing**: Fires BEFORE the first edit, ensuring the baseline reflects pre-change state

## Installation

```bash
mkdir -p .claude/skills/regression-sweep .claude/agents .claude/hooks .claude/regression
cp SKILL.md .claude/skills/regression-sweep/SKILL.md
cp agents/regression-differ.md .claude/agents/regression-differ.md
cp hooks/capture-baseline.sh .claude/hooks/capture-baseline.sh
chmod +x .claude/hooks/capture-baseline.sh
# Merge settings-fragment.json into .claude/settings.json
```
