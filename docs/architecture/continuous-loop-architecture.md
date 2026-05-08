# :building_construction: Continuous Agent Loop — Architecture Reference

## :dart: Overview

The continuous agent loop is implemented as a **Tier 3 Full Stack** pattern
within the Claude Code Customization Architecture. It composes skills,
sub-agents, hooks, and settings into an autonomous development system.

---

## :jigsaw: Component Map

```
┌──────────────────────────────────────────────────────────────────────┐
│  CLAUDE.md / AGENTS.md (Always-On Context — Layer 0)                 │
│  :white_check_mark: Tech stack, coding standards, build commands     │
│  :white_check_mark: Backpressure instructions, subagent rules        │
│  :x: NOT: loop orchestration logic                                   │
├──────────────────────────────────────────────────────────────────────┤
│  Skills (Workflow Layer — On-Demand)                                  │
│  :rocket: /continuous-loop — starts build loop                       │
│  :mag: /plan-loop — runs planning iteration                          │
│  :no_entry_sign: /cancel-loop — cancels active loop                  │
│  :package: /install-pattern — installs patterns from catalog         │
├──────────────────────────────────────────────────────────────────────┤
│  Sub-agents (Role Layer — Delegated)                                  │
│  :mag: loop-planner — read-only, produces fix_plan.md                │
│  :hammer: loop-implementer — write-capable, implements plan items    │
│  :shield: loop-reviewer — read-only, quality gate with scoring       │
├──────────────────────────────────────────────────────────────────────┤
│  Hooks (Safety Layer — Zero Tokens)                                   │
│  :arrows_counterclockwise: stop-loop.sh — iteration control          │
│  :test_tube: post-write-backpressure.sh — lint/format after writes   │
│  :lock: pre-bash-safety.sh — block dangerous commands                │
├──────────────────────────────────────────────────────────────────────┤
│  Settings (Configuration Layer)                                       │
│  :shield: Default-deny permissions with explicit allowlist            │
│  :gear: Hook registration for all lifecycle events                   │
└──────────────────────────────────────────────────────────────────────┘
```

---

## :page_facing_up: File Inventory

| File | Type | Purpose |
|------|------|---------|
| `.claude/skills/continuous-loop/SKILL.md` | Skill | Build loop entry point |
| `.claude/skills/plan-loop/SKILL.md` | Skill | Planning mode entry point |
| `.claude/skills/cancel-loop/SKILL.md` | Skill | Loop cancellation |
| `.claude/skills/install-pattern/SKILL.md` | Skill | Pattern installation meta-skill |
| `.claude/agents/loop-planner.md` | Agent | Read-only planner |
| `.claude/agents/loop-implementer.md` | Agent | Write-capable builder |
| `.claude/agents/loop-reviewer.md` | Agent | Read-only quality reviewer |
| `.claude/hooks/stop-loop.sh` | Hook | Stop hook for iteration control |
| `.claude/hooks/post-write-backpressure.sh` | Hook | PostToolUse lint/format |
| `.claude/hooks/pre-bash-safety.sh` | Hook | PreToolUse safety gate |
| `.claude/settings.json` | Config | Permissions + hook registration |
| `PROMPT.md` | Template | Build mode iteration prompt |
| `PROMPT-PLAN.md` | Template | Planning mode prompt |
| `loop.sh` | Script | Model B bash loop runner |
| `AGENTS.md` | Memory | Cross-platform agent instructions |

---

## :arrows_counterclockwise: Execution Flow

### Model A — Stop Hook Loop

```
User invokes /continuous-loop "task"
    │
    ▼
Skill initializes loop-state.json
    │
    ▼
Agent reads fix_plan.md → selects item → implements → tests → commits
    │
    ▼
Agent attempts to stop
    │
    ▼
stop-loop.sh fires ──── complete? ──── YES → exit 0 (done)
    │                                    
    NO (iteration < max, no completion promise)
    │
    ▼
exit 2 → blocks stop → re-injects prompt → next iteration
```

### Model B — Bash Loop

```
./loop.sh 50 PROMPT.md
    │
    ▼
while iteration < max_iterations:
    │
    ├── pipe PROMPT.md to claude -p
    ├── agent reads fix_plan.md → implements → tests → commits
    ├── check output for LOOP_COMPLETE
    │   ├── found → break
    │   └── not found → continue
    └── sleep 2 → next iteration
```

---

## :shield: Security Architecture

### Permission Model (Default-Deny)

```json
{
  "permissions": {
    "allow": ["Bash(git log:*)", "Bash(pnpm test:*)", ...],
    "deny": ["Bash(rm -rf /:*)", "Bash(sudo:*)", ...]
  }
}
```

### Sub-agent Least Privilege

| Agent | Read | Write | Edit | Bash | Rationale |
|-------|------|-------|------|------|-----------|
| loop-planner | :white_check_mark: | :x: | :x: | :white_check_mark: | Read-only analysis |
| loop-implementer | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | Needs full write access |
| loop-reviewer | :white_check_mark: | :x: | :x: | :white_check_mark: | Read-only review |

### Hook Chain (Execution Order)

1. **PreToolUse** → `pre-bash-safety.sh` fires BEFORE each Bash command
2. **PostToolUse** → `post-write-backpressure.sh` fires AFTER each file write
3. **Stop** → `stop-loop.sh` fires when the agent tries to exit

---

## :bar_chart: Token Cost Analysis

| Component | Token Cost | Frequency |
|-----------|-----------|-----------|
| CLAUDE.md (always-on) | 300–600 | Every iteration |
| AGENTS.md (always-on) | 200–400 | Every iteration |
| Skill descriptions (idle) | **0** | `disable-model-invocation: true` |
| Skill body (invoked) | 200–400 | Once per session |
| Sub-agent (per call) | 100–300 | Isolated context |
| Hooks | **0** | Zero tokens always |
| Specs (per iteration) | 200–2000 | Read via tool |
| fix_plan.md (per iteration) | 100–500 | Read via tool |
| **Per-iteration total** | **~1000–4000** | Plus tool call costs |

---

## :link: Pattern Composition

The continuous loop composes these existing workflow patterns:

| Component | Pattern | Tier |
|-----------|---------|------|
| Inner quality gate | Self-reflection loop (#03) | 3 |
| Planning mode | Explore-then-implement (#07) | 2 |
| Backpressure | Sequential pipeline hooks (#01) | 3 |
| Safety blocking | Human-in-the-loop PreToolUse (#04) | 3 |
| Cost control | Cost-threshold gate (#06) | 3 |
| Mode switching | Workflow chaining (#31) | 2 |
| Parallel search | Parallel fan-out/fan-in (#02) | 3 |
