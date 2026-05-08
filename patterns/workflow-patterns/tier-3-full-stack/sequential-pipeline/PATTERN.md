# Pattern 01: Sequential Pipeline

## Tier
**Tier 3** — Full Stack (Skill + Sub-agents + Hooks + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: stage-by-stage execution |
| `agents/schema-designer.md` | Stage 1: DB schema |
| `agents/entity-builder.md` | Stage 2: Entity + repository layer |
| `agents/service-builder.md` | Stage 3: Business logic service |
| `agents/route-builder.md` | Stage 4: API route handlers |
| `agents/test-writer.md` | Stage 5: Integration tests |
| `hooks/pipeline-gate.sh` | PostToolUse: blocks on build failure |
| `hooks/notify-pipeline-complete.sh` | Stop: logs/notifies on completion |
| `settings-fragment.json` | Hook registration + permissions |

## Security Model

The `pipeline-gate.sh` PostToolUse hook runs `pnpm build` after every write to
a source file. If the build fails, it exits 2 — blocking the tool call result
from being processed. This forces the model to fix compilation errors before
moving to the next stage.

This enforcement is **deterministic** — it does not rely on the model following
instructions. Without the hook, the model can proceed to Stage 3 even if Stage 2
broke the build.

## Hook Behavior

### pipeline-gate.sh (PostToolUse)
- **Triggers**: Write, Edit, MultiEdit to `src/*` files
- **Action**: Runs `pnpm build --silent`
- **On failure**: exit 2 with reason — blocks next stage
- **On success**: exit 0

### notify-pipeline-complete.sh (Stop)
- **Triggers**: Session end
- **Action**: Logs timestamp; optional Slack notification via `${SLACK_WEBHOOK_URL}`
- **Never blocks**: always exits 0

## Installation

```bash
# Copy skill
mkdir -p .claude/skills/sequential-pipeline
cp SKILL.md .claude/skills/sequential-pipeline/SKILL.md

# Copy agents
for agent in schema-designer entity-builder service-builder route-builder test-writer; do
  cp agents/${agent}.md .claude/agents/${agent}.md
done

# Copy and make hooks executable
cp hooks/pipeline-gate.sh .claude/hooks/pipeline-gate.sh
cp hooks/notify-pipeline-complete.sh .claude/hooks/notify-pipeline-complete.sh
chmod +x .claude/hooks/pipeline-gate.sh .claude/hooks/notify-pipeline-complete.sh

# Merge settings-fragment.json into .claude/settings.json
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| Skill | ~200 tokens |
| Each sub-agent | ~1,000–3,000 tokens (isolated) |
| Hooks | 0 tokens |
