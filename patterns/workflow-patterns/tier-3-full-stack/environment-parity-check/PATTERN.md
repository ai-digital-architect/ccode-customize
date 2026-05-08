# Pattern 25: Environment Parity Check

## Tier
**Tier 3** — Full Stack (Skill + Sub-agent + Hook + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: invoke checker → present divergences → gate promotion |
| `agents/env-parity-checker.md` | Read-only config comparator — diffs against CLAUDE.md baseline |
| `hooks/block-promotion-on-drift.sh` | PreToolUse: blocks deploy/promote/release if parity fails |
| `settings-fragment.json` | Hook registration + env file read permissions |

## Security Model

`env-parity-checker` has `disallowedTools: [Write, Edit, MultiEdit]` — it can only
read environment files and write the report to `.claude/env/parity-report.json`.
It checks for key presence and pattern matching, not actual secret values.

The hook blocks on `parity_status == "fail"`. Acknowledgment requires resolving
the divergences and re-running the checker to get a passing report.

## Hook Behavior

### block-promotion-on-drift.sh (PreToolUse)
- **Triggers**: Bash commands containing "deploy", "promote", or "release"
- **Reads**: `.claude/env/parity-report.json`
- **If no report**: allows through (checker not run yet)
- **If `parity_status == "fail"`**: exit 2 — blocks with divergence count
- **If `parity_status == "pass"`**: exit 0 — allows promotion

## Installation

```bash
mkdir -p .claude/skills/env-parity .claude/agents .claude/hooks .claude/env
cp SKILL.md .claude/skills/env-parity/SKILL.md
cp agents/env-parity-checker.md .claude/agents/env-parity-checker.md
cp hooks/block-promotion-on-drift.sh .claude/hooks/block-promotion-on-drift.sh
chmod +x .claude/hooks/block-promotion-on-drift.sh
# Add Environment Baseline section to your CLAUDE.md
# Merge settings-fragment.json into .claude/settings.json
```
