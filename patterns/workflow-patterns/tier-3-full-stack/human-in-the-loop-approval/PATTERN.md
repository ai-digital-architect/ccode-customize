# Pattern 04: Human-in-the-Loop Approval

## Tier
**Tier 3** — Full Stack (Skill + Hooks + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Two-phase workflow: prepare → pause → execute |
| `hooks/require-approval.sh` | PreToolUse: blocks destructive commands |
| `settings-fragment.json` | Hook registration + permissions |

## Security Model

The `require-approval.sh` hook intercepts every Bash tool call. When the command
matches a destructive pattern (deploy, migrate, kubectl apply, etc.), it checks
for `.claude/approval/approved`. If the sentinel is absent, it blocks with exit 2.

This is deterministic enforcement — the model cannot execute a destructive operation
without the sentinel file being present. Prompt instructions alone ("wait for approval")
are insufficient because the model could forget or be instructed otherwise.

## Hook Behavior

### require-approval.sh (PreToolUse)
- **Triggers**: Every Bash call
- **Checks**: Command matches destructive patterns list
- **Requires**: `.claude/approval/approved` sentinel file
- **On missing sentinel**: exit 2 — blocks execution
- **On sentinel present**: exit 0 — allows execution

## Customizing Destructive Patterns

Edit the `destructive_patterns` array in `require-approval.sh` to add patterns:
```bash
destructive_patterns=(
  "deploy"
  "migrate"
  "kubectl apply"
  "terraform apply"
  "docker push"
  "npm publish"
  "pnpm publish"
  "your-custom-command"  # Add here
)
```

## Installation

```bash
mkdir -p .claude/skills/approve-then-deploy .claude/hooks .claude/approval
cp SKILL.md .claude/skills/approve-then-deploy/SKILL.md
cp hooks/require-approval.sh .claude/hooks/require-approval.sh
chmod +x .claude/hooks/require-approval.sh
# Merge settings-fragment.json into .claude/settings.json
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| Skill (prepare phase) | ~2,000–5,000 tokens |
| Skill (execute phase) | ~1,000–3,000 tokens |
| Hook | 0 tokens |
