# Pattern 08: Competitive Analysis

## Tier
**Tier 2** — Skill + Sub-agents

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: fan-out research, invoke synthesizer |
| `agents/source-researcher.md` | Read-only per-target research agent |
| `agents/analysis-synthesizer.md` | Read-only synthesis agent (claude-opus-4-5) |

## Security Model

Both `source-researcher` and `analysis-synthesizer` have `disallowedTools: [Write, Edit, MultiEdit]`.
Researchers cannot contaminate each other's output or modify project files.
The synthesizer uses `claude-opus-4-5` for stronger reasoning quality on the comparison.

## Why Tier 2 (Not Tier 3)

No deterministic enforcement is needed — the tool restrictions on researchers
are sufficient. The SubagentStop hook shown in the source pattern is optional
(for logging); the core security model is the `disallowedTools` enforcement.

## Installation

```bash
mkdir -p .claude/skills/competitive-analysis .claude/agents .claude/analysis
cp SKILL.md .claude/skills/competitive-analysis/SKILL.md
cp agents/source-researcher.md .claude/agents/source-researcher.md
cp agents/analysis-synthesizer.md .claude/agents/analysis-synthesizer.md
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| Skill | ~100 tokens |
| Each source-researcher | ~1,000–3,000 tokens (isolated per target) |
| analysis-synthesizer | ~2,000–5,000 tokens |
