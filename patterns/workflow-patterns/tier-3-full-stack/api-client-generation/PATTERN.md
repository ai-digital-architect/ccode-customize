# Pattern 17: API Client Generation

## Tier
**Tier 3** — Full Stack (Skill + Sub-agent + Hook + Settings)

## Component Inventory

| File | Purpose |
|------|---------|
| `SKILL.md` | Orchestrator: parse spec → generate clients → typecheck |
| `agents/client-generator.md` | Write-capable generator — one module per resource group |
| `hooks/typecheck-generated.sh` | PostToolUse: type-checks each generated client file immediately |
| `settings-fragment.json` | Hook registration + typecheck tool permissions |

## Security Model

`client-generator` has `disallowedTools: [Edit, MultiEdit]` to prevent it from
modifying existing non-generated source files. It can only write new client files.

The `typecheck-generated.sh` hook fires on every Write — it gates on the file path
pattern to target only generated client files. Type failures immediately block the
session, preventing broken clients from accumulating.

## Hook Behavior

### typecheck-generated.sh (PostToolUse)
- **Triggers**: Every Write tool call
- **Filter**: Only acts on `src/clients/*.ts`, `clients/*.py`, `clients/*.go`
- **TypeScript**: Runs `pnpm typecheck`
- **Python**: Runs `mypy <file>`
- **Go**: Runs `go vet ./clients/...`
- **On failure**: exit 2 — blocks and reports type error

## Installation

```bash
mkdir -p .claude/skills/generate-client .claude/agents .claude/hooks
cp SKILL.md .claude/skills/generate-client/SKILL.md
cp agents/client-generator.md .claude/agents/client-generator.md
cp hooks/typecheck-generated.sh .claude/hooks/typecheck-generated.sh
chmod +x .claude/hooks/typecheck-generated.sh
# Merge settings-fragment.json into .claude/settings.json
```
