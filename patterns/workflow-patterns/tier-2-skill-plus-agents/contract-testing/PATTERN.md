# Pattern 13: Contract Testing

## Tier
**Tier 2** — Skill + Sub-agents

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: extract → verify workflow |
| `agents/contract-extractor.md` | Read-only frontend API scanner |
| `agents/contract-verifier.md` | Read-only backend verifier |

## Security Model

Both agents have `disallowedTools: [Write, Edit, MultiEdit]`. Neither can
modify the code they are analyzing. Extractor and verifier run in separate
contexts so each focuses only on its domain (frontend vs backend).

The verifier cannot "fix" backend code to pass contracts — it can only report.

## Why Tier 2 (Not Tier 1)

Extractor and verifier need separate contexts with separate tool restrictions.
A single agent analyzing both frontend and backend simultaneously would mix
concerns and reduce focus.

## Installation

```bash
mkdir -p .claude/skills/contract-test .claude/agents .claude/contracts
cp SKILL.md .claude/skills/contract-test/SKILL.md
cp agents/contract-extractor.md .claude/agents/contract-extractor.md
cp agents/contract-verifier.md .claude/agents/contract-verifier.md
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| Skill | ~80 tokens |
| contract-extractor | ~2,000–4,000 tokens |
| contract-verifier | ~2,000–4,000 tokens |
