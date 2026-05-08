# Pattern 19: Watchdog Loop

## Tier
**Tier 3** — Full Stack (Skill + Sub-agent + Hook + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Polling loop orchestrator — invoke checker, compare, sleep |
| `agents/health-checker.md` | Read-only metric checker — bundle size, test health, deps |
| `hooks/watchdog-notify.sh` | Stop: sends notification if violations were logged this session |
| `settings-fragment.json` | Hook registration + monitoring tool permissions |

## Security Model

`health-checker` has `disallowedTools: [Write, Edit, MultiEdit]` — it can run
`pnpm build`, `pnpm test`, and `pnpm audit` but cannot modify code. It writes
only to `.claude/watchdog/latest-check.json`.

The Slack webhook URL is passed via `${SLACK_WEBHOOK_URL}` environment variable,
never hardcoded.

## Hook Behavior

### watchdog-notify.sh (Stop)
- **Triggers**: When the Claude session ends
- **Reads**: `.claude/watchdog/violations.log`
- **If violations exist**: Logs to `~/.claude/notifications.log`; optionally POSTs to Slack
- **Always**: exit 0 — Stop hooks are informational, not blocking

## Installation

```bash
mkdir -p .claude/skills/watchdog .claude/agents .claude/hooks .claude/watchdog
cp SKILL.md .claude/skills/watchdog/SKILL.md
cp agents/health-checker.md .claude/agents/health-checker.md
cp hooks/watchdog-notify.sh .claude/hooks/watchdog-notify.sh
chmod +x .claude/hooks/watchdog-notify.sh
# Configure SLACK_WEBHOOK_URL in your environment or .env file
# Merge settings-fragment.json into .claude/settings.json
```
