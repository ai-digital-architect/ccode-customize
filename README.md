# Claude Code Customization Patterns

A production-ready reference implementation of **33 workflow patterns** for
Claude Code, covering autonomous development loops, multi-agent pipelines,
safety gates, and operational workflows.

---

## Quick Start

### 1. Explore Available Skills

All workflow patterns are installed and ready to use as slash commands:

```
/dependency-audit          # Audit package dependencies
/explore-implement         # Research then implement changes
/review-pr                 # Multi-specialist PR review
/auto-fix                  # Language-aware error fixing
/sequential-pipeline       # Schema-to-tests pipeline
/self-reflect              # Quality loop with critic
```

See `.claude/CLAUDE.md` for the complete list of all available skills.

### 2. Install Additional Patterns

```
/install-pattern <pattern-name> <tier>
```

### 3. Run an Autonomous Build Loop

```bash
claude
> /plan-loop specs/
> /continuous-loop "Implement feature per specs/auth.md"
```

---

## Architecture

The project is organized around Claude Code's six customization primitives:

| Component | Location | Count |
|-----------|----------|-------|
| Skills | `.claude/skills/` | 41 |
| Sub-agents | `.claude/agents/` | 41 |
| Hooks | `.claude/hooks/` | 19 |
| Settings | `.claude/settings.json` | 1 |
| Memory | `.claude/CLAUDE.md` | 1 |
| Documentation | `AGENTS.md` | 1 |

For the full architecture specification, see:
- [Claude Code Customization Architecture](architecture/claude-code-customization-architecture.md)

---

## Workflow Pattern Tiers

### Tier 1 -- Pure Skills (11 patterns)

Single SKILL.md file, no agents or hooks. Read-only analysis patterns.

- Dependency Audit, Template Instantiation, Documentation Generation
- Build Failure Triage, Log Analysis, Compliance Audit
- Dead Code Detection, Infrastructure Drift Detection
- Postmortem Assistant, Test Failure Explainer, Code Archaeology

### Tier 2 -- Skill + Agents (7 patterns)

SKILL.md plus specialized sub-agent definitions.

- Explore-then-Implement, Competitive Analysis, Contract Testing
- Spec-First Verification, PR Review Pipeline
- Workflow Chaining (3 linked skills), Conditional Branching

### Tier 3 -- Full Stack (15 patterns)

SKILL.md, agents, hooks, and settings integration.

- Sequential Pipeline, Fan-out/Fan-in, Self-Reflection Loop
- Human-in-the-Loop Approval, Staged Rollout, Cost Threshold Gate
- Incremental Migration, Pattern Replacement, Schema Evolution
- Regression Sweep, API Client Generation, Watchdog Loop
- Environment Parity, Secret Rotation, Map-Reduce

---

## Agents

41 specialized sub-agents with scoped permissions. See [AGENTS.md](AGENTS.md)
for the complete inventory with roles, models, and invocation guidance.

---

## Documentation

| Resource | Description |
|----------|-------------|
| [User Guides](docs/user-guide/) | Per-pattern usage guides |
| [Architecture Spec](architecture/claude-code-customization-architecture.md) | Core architecture reference |
| `.claude/CLAUDE.md` | Project memory and skill index |
| `AGENTS.md` | Agent inventory and details |

---

## Safety

- Default-deny permission model for shell commands
- Sub-agents follow principle of least privilege
- PreToolUse hooks block dangerous operations
- PostToolUse hooks enforce build/lint/test gates
- No credentials in source files
