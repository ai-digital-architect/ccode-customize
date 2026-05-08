# Pattern 06: Cost-Threshold Gate

## Tier
**Tier 3** — Full Stack (Skill + Hooks + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Cost-aware task orchestrator |
| `hooks/cost-gate.sh` | PreToolUse: blocks all tools if over budget |
| `settings-fragment.json` | Hook registration (matcher: *) |

## Security Model

The `cost-gate.sh` hook fires before **every tool call** (matcher: `*`). It estimates
the cost of the call, adds it to the cumulative spend in `.claude/budget.json`,
and blocks if the total would exceed the budget ceiling.

The model cannot bypass this because the hook fires before the tool executes.
The budget file is the source of truth — the model could modify it, but doing so
would be explicitly visible in the conversation.

## Budget Configuration

Create `.claude/budget.json` before starting:
```json
{"budget_tokens": 100000, "spent_tokens": 0}
```

To increase budget mid-session, edit `.claude/budget.json` directly.

## Hook Behavior

### cost-gate.sh (PreToolUse)
- **Triggers**: ALL tool calls (matcher: `*`)
- **Estimates**: Cost by tool type (Write/Edit: content-length/4, Bash: 50, Read: 20)
- **On over-budget**: exit 2 — blocks the tool call
- **On under-budget**: updates `spent_tokens` in budget file, logs to spend.log

## Installation

```bash
mkdir -p .claude/skills/cost-aware-task .claude/hooks
cp SKILL.md .claude/skills/cost-aware-task/SKILL.md
cp hooks/cost-gate.sh .claude/hooks/cost-gate.sh
chmod +x .claude/hooks/cost-gate.sh
# Merge settings-fragment.json into .claude/settings.json
# Initialize budget: echo '{"budget_tokens":100000,"spent_tokens":0}' > .claude/budget.json
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| Skill overhead | ~100 tokens |
| Hook execution | 0 tokens (shell script) |
| Enforced limit | Configurable via budget.json |
