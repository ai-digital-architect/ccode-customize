# Pattern 22: PR Review Pipeline

## Tier
**Tier 2** — Skill + Sub-agents

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: sequential specialist chain |
| `agents/diff-analyzer.md` | Categorizes diff changes |
| `agents/security-reviewer.md` | Security analysis (claude-opus-4-5) |
| `agents/style-checker.md` | Convention compliance |
| `agents/coverage-checker.md` | Test coverage assessment |
| `agents/review-summarizer.md` | Aggregates all findings (claude-opus-4-5) |

## Security Model

All five sub-agents have `disallowedTools: [Write, Edit, MultiEdit]`. None can
modify the code they are reviewing. Each runs in an isolated context so each
specialist focuses only on its domain without cross-contamination.

`security-reviewer` and `review-summarizer` use `claude-opus-4-5` for higher
accuracy on the most critical analysis tasks.

## Why Tier 2 (Not Tier 3)

The tool restrictions (`disallowedTools`) on all agents are sufficient enforcement.
No hook is needed — the security model is entirely provided by tool isolation.

## Installation

```bash
mkdir -p .claude/skills/review-pr .claude/agents .claude/review
cp SKILL.md .claude/skills/review-pr/SKILL.md
for agent in diff-analyzer security-reviewer style-checker coverage-checker review-summarizer; do
  cp agents/${agent}.md .claude/agents/${agent}.md
done
```

Add to `.claude/settings.json`:
```json
{
  "permissions": {
    "allow": [
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git show:*)",
      "Bash(pnpm test:*)",
      "Bash(grep -rn *)",
      "Bash(mkdir -p .claude/review)"
    ]
  }
}
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| Skill | ~100 tokens |
| diff-analyzer | ~1,000–2,000 tokens |
| security-reviewer | ~2,000–4,000 tokens (opus) |
| style-checker | ~1,000–2,000 tokens |
| coverage-checker | ~1,000–2,000 tokens |
| review-summarizer | ~2,000–3,000 tokens (opus) |
