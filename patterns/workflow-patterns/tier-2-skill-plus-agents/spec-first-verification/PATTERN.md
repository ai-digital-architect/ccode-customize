# Pattern 14: Spec-First Verification

## Tier
**Tier 2** — Skill + Sub-agents

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: generate tests → verify |
| `agents/spec-test-generator.md` | Write-capable test generator |
| `agents/spec-verifier.md` | Read-only verifier (cannot fix source) |

## Security Model

The `spec-verifier` has `disallowedTools: [Write, Edit, MultiEdit]`. It can run
tests and read files, but it **cannot modify source code to make tests pass**.
This is the core guarantee — the verifier reports the gap between spec and
implementation, it cannot paper over it.

The `spec-test-generator` is write-capable (it creates test files), but it
writes only to `tests/spec-verification/`, not to production source.

## Why Tier 2 (Not Tier 1)

If a single agent generated tests AND verified, it could silently modify the
implementation to make tests pass, defeating the spec-first approach.
The verifier's `disallowedTools` enforces the separation physically.

## Installation

```bash
mkdir -p .claude/skills/spec-verify .claude/agents .claude/spec
cp SKILL.md .claude/skills/spec-verify/SKILL.md
cp agents/spec-test-generator.md .claude/agents/spec-test-generator.md
cp agents/spec-verifier.md .claude/agents/spec-verifier.md
```

## Token Cost Estimate

| Component | Cost |
|-----------|------|
| Skill | ~80 tokens |
| spec-test-generator | ~3,000–8,000 tokens |
| spec-verifier | ~1,000–2,000 tokens |
