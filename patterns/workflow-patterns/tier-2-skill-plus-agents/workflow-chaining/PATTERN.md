# Pattern 31: Workflow Chaining

## Tier
**Tier 2** — Skill + Sub-agents (variant: multiple linked skills, no agents directory)

## Component Inventory

| File | Purpose |
|------|---------|
| `plan-feature/SKILL.md` | Step 1: research and planning |
| `implement-feature/SKILL.md` | Step 2: implementation from plan |
| `review-feature/SKILL.md` | Step 3: review against plan |

## Chain Convention

Chain artifacts are stored in `.claude/chain/`:
- `plan.md` — output of `plan-feature`, input to `implement-feature`
- `result.md` — output of `implement-feature`, input to `review-feature`

Each skill checks for its prerequisite file and guides the user if missing.
`plan-feature` always cleans the chain directory before writing to prevent stale data.

## Security Model

No special tool isolation is needed. The chain convention is the architectural
pattern — each skill reads the previous skill's output from the filesystem.
The linking is documented in CLAUDE.md so all agents understand the convention.

## Why Tier 2 (Not Tier 1)

Three separate skills linked by filesystem artifacts. The pattern is the
linking convention, not a single self-contained skill. No `agents/` directory
is needed — this is a valid Tier 2 variant using multiple skills.

## Installation

```bash
mkdir -p .claude/skills/plan-feature .claude/skills/implement-feature .claude/skills/review-feature
cp plan-feature/SKILL.md .claude/skills/plan-feature/SKILL.md
cp implement-feature/SKILL.md .claude/skills/implement-feature/SKILL.md
cp review-feature/SKILL.md .claude/skills/review-feature/SKILL.md
mkdir -p .claude/chain
```

Add to `CLAUDE.md`:
```markdown
## Workflow Chaining Convention
- Chain artifacts are stored in `.claude/chain/`
- `plan-feature` → writes `plan.md`; `implement-feature` reads it
- `implement-feature` → writes `result.md`; `review-feature` reads it
- `plan-feature` cleans the chain directory before each new feature
```

Add to `.claude/settings.json`:
```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm build:*)",
      "Bash(pnpm test:*)",
      "Bash(cat .claude/chain/*)",
      "Bash(mkdir -p .claude/chain)",
      "Bash(rm -f .claude/chain/*)"
    ]
  }
}
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| plan-feature | ~2,000–5,000 tokens |
| implement-feature | ~5,000–15,000 tokens |
| review-feature | ~1,000–2,000 tokens |
