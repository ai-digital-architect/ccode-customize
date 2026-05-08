# Pattern 26: Secret Rotation

## Tier
**Tier 3** — Full Stack (Skill + Sub-agent + Hook + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: discover → update → verify → revoke |
| `agents/secret-finder.md` | Read-only reference discoverer — maps all credential locations |
| `hooks/require-health-before-revoke.sh` | PreToolUse: blocks revocation unless health check passed |
| `settings-fragment.json` | Hook registration + search permissions + deny list |

## Security Model

`secret-finder` has `disallowedTools: [Write, Edit, MultiEdit]` — it can only
search and report, never modify. The hook enforces the invariant that revocation
cannot happen unless `.claude/secrets/health-check.json` exists with `status: "healthy"`.

Credentials are never written to tracked files. The deny list blocks pipe-to-bash
and rm -rf / patterns.

## Hook Behavior

### require-health-before-revoke.sh (PreToolUse)
- **Triggers**: Bash commands matching `revoke`, `delete.*key`, or `remove.*secret`
- **If no health file**: exit 2 — blocks revocation
- **If `status != "healthy"`**: exit 2 — blocks revocation, instructs rollback
- **If `status == "healthy"`**: exit 0 — allows revocation

## Installation

```bash
mkdir -p .claude/skills/rotate-secret .claude/agents .claude/hooks .claude/secrets
cp SKILL.md .claude/skills/rotate-secret/SKILL.md
cp agents/secret-finder.md .claude/agents/secret-finder.md
cp hooks/require-health-before-revoke.sh .claude/hooks/require-health-before-revoke.sh
chmod +x .claude/hooks/require-health-before-revoke.sh
# Merge settings-fragment.json into .claude/settings.json
```
