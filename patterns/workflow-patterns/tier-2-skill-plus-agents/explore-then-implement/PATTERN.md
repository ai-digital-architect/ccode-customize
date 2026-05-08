# Pattern 07: Explore-then-Implement

## Tier
**Tier 2** — Skill + Sub-agents

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: two-phase research→implement workflow |
| `agents/researcher.md` | Read-only research agent (physically cannot write) |
| `agents/implementer.md` | Write-capable implementation agent |

## Security Model

The `researcher` sub-agent has `disallowedTools: [Write, Edit, MultiEdit]` in its frontmatter.
This is a physical enforcement — not a prompt instruction. The agent cannot write files
regardless of what it is told to do. This is the core security guarantee of this pattern.

The `implementer` sub-agent is write-capable and works from the research output.

## Why Tier 2 (Not Tier 1)

A single skill saying "now be read-only during research" is a prompt instruction,
not an enforcement. The researcher sub-agent's `disallowedTools` means the
enforcement happens at the platform level, not at the model level.

## Installation

```bash
# Copy skill
mkdir -p .claude/skills/explore-implement
cp SKILL.md .claude/skills/explore-implement/SKILL.md

# Copy agents
cp agents/researcher.md .claude/agents/researcher.md
cp agents/implementer.md .claude/agents/implementer.md

# Create research output directory
mkdir -p .claude/research-output
```

Add to `.claude/settings.json`:
```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm build:*)",
      "Bash(pnpm test:*)",
      "Bash(find * -name *.ts)",
      "Bash(grep -rn * src/)",
      "Bash(git log:*)",
      "Bash(mkdir -p .claude/research-output)"
    ]
  }
}
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| Skill invocation | ~100 tokens |
| Researcher sub-agent | ~2,000–5,000 tokens (isolated) |
| Implementer sub-agent | ~5,000–15,000 tokens (isolated) |
| Hooks | 0 tokens |
