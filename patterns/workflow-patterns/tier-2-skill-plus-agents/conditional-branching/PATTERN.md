# Pattern 32: Conditional Branching

## Tier
**Tier 2** — Skill + Sub-agents

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Coordinator: detects project type, dispatches specialist |
| `agents/ts-fixer.md` | TypeScript specialist |
| `agents/py-fixer.md` | Python specialist |
| `agents/go-fixer.md` | Go specialist |

## Security Model

Each specialist runs in an isolated context so it focuses on its language
ecosystem without cross-contamination. All specialists are write-capable —
they need to apply fixes. The coordinator's role is detection and dispatch only.

No `disallowedTools` on specialists since they all need write access to apply fixes.

## Why Tier 2 (Not Tier 1)

Specialists need isolated contexts to stay focused on their language's patterns.
The coordinator's branching logic justifies the skill layer, and the specialist
sub-agents provide the focused execution with isolated tool sets per language.

## Adding New Language Specialists

To add a Ruby specialist:
1. Create `agents/rb-fixer.md` following the same pattern
2. Add a detection rule to `SKILL.md`: `if Gemfile exists → Ruby`
3. Add dispatch: `Invoke rb-fixer sub-agent`

## Installation

```bash
mkdir -p .claude/skills/auto-fix .claude/agents
cp SKILL.md .claude/skills/auto-fix/SKILL.md
cp agents/ts-fixer.md .claude/agents/ts-fixer.md
cp agents/py-fixer.md .claude/agents/py-fixer.md
cp agents/go-fixer.md .claude/agents/go-fixer.md
```

Add to `.claude/settings.json`:
```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm build:*)",
      "Bash(pnpm test:*)",
      "Bash(pytest:*)",
      "Bash(go build:*)",
      "Bash(go test:*)",
      "Bash(cat package.json)",
      "Bash(cat pyproject.toml)",
      "Bash(cat go.mod)",
      "Bash(ls *)"
    ]
  }
}
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| Skill (detection + dispatch) | ~200 tokens |
| Specialist sub-agent | ~3,000–10,000 tokens |
