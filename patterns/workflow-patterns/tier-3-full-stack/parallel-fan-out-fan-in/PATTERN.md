# Pattern 02: Parallel Fan-out / Fan-in

## Tier
**Tier 3** — Full Stack (Skill + Sub-agents + Hooks + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Coordinator: fan-out and fan-in logic |
| `agents/parallel-worker.md` | Scoped worker for one module |
| `agents/result-merger.md` | Read-only merger and reconciler |
| `hooks/track-worker-completion.sh` | SubagentStop: completion logging |
| `settings-fragment.json` | Hook registration + permissions |

## Security Model

The `result-merger` has `disallowedTools: [Edit, MultiEdit]` — it reads and
summarizes, never modifies source files. Workers are scoped to their assigned
module by instruction (add a PostToolUse path-validation hook for strict enforcement).

## Hook Behavior

### track-worker-completion.sh (SubagentStop)
- **Triggers**: Any sub-agent stops
- **Action**: Appends JSON record to `completion-log.jsonl`
- **Never blocks**: always exits 0
- **Purpose**: Reliable completion tracking even if coordinator crashes

## Installation

```bash
mkdir -p .claude/skills/fan-out-fan-in .claude/agents .claude/hooks
cp SKILL.md .claude/skills/fan-out-fan-in/SKILL.md
cp agents/parallel-worker.md .claude/agents/parallel-worker.md
cp agents/result-merger.md .claude/agents/result-merger.md
cp hooks/track-worker-completion.sh .claude/hooks/track-worker-completion.sh
chmod +x .claude/hooks/track-worker-completion.sh
# Merge settings-fragment.json into .claude/settings.json
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| Skill | ~200 tokens |
| Each parallel-worker | ~1,000–3,000 tokens (isolated, N workers) |
| result-merger | ~1,000–2,000 tokens |
| Hook | 0 tokens |
