# Pattern 03: Self-Reflection Loop

## Tier
**Tier 3** — Full Stack (Skill + Sub-agents + Hooks + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: generate → critique → revise loop |
| `agents/code-critic.md` | Read-only quality scorer (claude-opus-4-5) |
| `hooks/check-review-score.sh` | SubagentStop: blocks if score < 4 |
| `settings-fragment.json` | Hook registration + permissions |

## Security Model

The `code-critic` has `disallowedTools: [Write, Edit, MultiEdit]` — it cannot
modify the code it reviews, preventing self-grading bias.

The `check-review-score.sh` hook reads the score JSON deterministically.
If score < 4, it exits 2, blocking the stop. The parent agent must iterate.
This is the enforcement — the model cannot accept a low-quality result and move on.

## Hook Behavior

### check-review-score.sh (SubagentStop)
- **Triggers**: Any sub-agent stops
- **Filters**: Only acts when `agent_name == "code-critic"`
- **Reads**: `.claude/review-score.json`
- **On score < 4**: exit 2 with reason — forces another revision pass
- **On score >= 4**: exit 0 — allows completion

## Installation

```bash
mkdir -p .claude/skills/self-reflect .claude/agents .claude/hooks
cp SKILL.md .claude/skills/self-reflect/SKILL.md
cp agents/code-critic.md .claude/agents/code-critic.md
cp hooks/check-review-score.sh .claude/hooks/check-review-score.sh
chmod +x .claude/hooks/check-review-score.sh
# Merge settings-fragment.json into .claude/settings.json
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| Skill + generator | ~5,000–15,000 tokens |
| code-critic (per iteration) | ~2,000–4,000 tokens (opus) |
| Hook | 0 tokens |
| Max 3 iterations | ~6,000–12,000 tokens total for critic |
