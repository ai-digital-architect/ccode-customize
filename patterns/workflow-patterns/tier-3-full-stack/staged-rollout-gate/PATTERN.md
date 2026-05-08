# Pattern 05: Staged Rollout Gate

## Tier
**Tier 3** — Full Stack (Skill + Sub-agents + Hooks + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: dev → staging → approval → production |
| `agents/env-deployer.md` | Read+Bash only deployer per environment |
| `hooks/rollout-gate.sh` | PreToolUse: enforces environment promotion order |
| `settings-fragment.json` | Hook registration + permissions |

## Security Model

The `rollout-gate.sh` hook enforces:
1. Staging deployment requires `dev-result.json` with `status: success`
2. Production deployment requires `staging-result.json` with `status: success`
3. Production deployment requires `production-approved` sentinel file

The `env-deployer` has `disallowedTools: [Write, Edit, MultiEdit]` — it executes
commands but cannot modify source files.

## Hook Behavior

### rollout-gate.sh (PreToolUse)
- **Triggers**: Every Bash call
- **Checks**: Command contains "staging" or "production"
- **For staging**: requires `dev-result.json` with `status: success`
- **For production**: requires `staging-result.json` + `production-approved` sentinel
- **On violation**: exit 2 with specific block reason

## Installation

```bash
mkdir -p .claude/skills/staged-rollout .claude/agents .claude/hooks .claude/rollout
cp SKILL.md .claude/skills/staged-rollout/SKILL.md
cp agents/env-deployer.md .claude/agents/env-deployer.md
cp hooks/rollout-gate.sh .claude/hooks/rollout-gate.sh
chmod +x .claude/hooks/rollout-gate.sh
# Merge settings-fragment.json into .claude/settings.json
```
