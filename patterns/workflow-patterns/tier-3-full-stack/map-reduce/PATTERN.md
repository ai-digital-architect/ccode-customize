# Pattern 33: Map-Reduce

## Tier
**Tier 3** — Full Stack (Skill + Sub-agents + Hook + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Coordinator: enumerate → fan-out workers → reduce |
| `agents/mr-worker.md` | Write-capable per-item worker — isolated, single-item scope |
| `agents/mr-reducer.md` | Read-only aggregator — combines all worker results |
| `hooks/mr-track-completion.sh` | SubagentStop: logs each mr-worker completion to JSONL |
| `settings-fragment.json` | Hook registration + file system permissions |

## Security Model

`mr-reducer` has `disallowedTools: [Write, Edit, MultiEdit]` — it aggregates into
`aggregate.md` only (via Bash redirect or Write is blocked; uses Bash echo/tee).
Workers are isolated by explicit scope instructions: "do NOT process other items
or modify shared resources."

The SubagentStop hook fires on every sub-agent completion, filtered to `mr-worker`
by agent name. This provides an audit trail in `completion.jsonl`.

## Hook Behavior

### mr-track-completion.sh (SubagentStop)
- **Triggers**: Every sub-agent stop event
- **Filter**: Only acts on `agent_name == "mr-worker"`
- **Action**: Appends `{agent, completed_at}` to `.claude/map-reduce/completion.jsonl`
- **Exit**: Always 0 — tracking is non-blocking

## Installation

```bash
mkdir -p .claude/skills/map-reduce .claude/agents .claude/hooks .claude/map-reduce/results
cp SKILL.md .claude/skills/map-reduce/SKILL.md
cp agents/mr-worker.md .claude/agents/mr-worker.md
cp agents/mr-reducer.md .claude/agents/mr-reducer.md
cp hooks/mr-track-completion.sh .claude/hooks/mr-track-completion.sh
chmod +x .claude/hooks/mr-track-completion.sh
# Merge settings-fragment.json into .claude/settings.json
```
