# :books: Workflow Pattern Library — User Guide

## :dart: Overview

The workflow pattern library provides 33 deployable Claude Code workflow patterns
organized into three tiers by component complexity. Each pattern is a complete,
production-ready set of Claude Code customization artifacts.

---

## :building_construction: Tier Classification

### :green_circle: Tier 1 — Pure Skills (11 patterns)

Single SKILL.md file. Read-heavy analysis tasks with no write operations or
agent isolation requirements.

| Pattern | Skill Name | Purpose |
|---------|-----------|---------|
| Dependency Audit | `dependency-audit` | Audit licenses and vulnerabilities |
| Template Instantiation | `instantiate-template` | Scaffold from canonical templates |
| Documentation Generation | `generate-docs` | Generate docs from source code |
| Build Failure Triage | `triage-build` | Diagnose CI/build failures |
| Log Analysis | `analyze-logs` | Parse and summarize log files |
| Compliance Audit | `compliance-audit` | OWASP, GDPR, license scanning |
| Dead Code Detection | `find-dead-code` | Find unused exports and orphans |
| Infrastructure Drift | `detect-drift` | Compare live infra vs IaC |
| Postmortem Assistant | `postmortem` | Generate 5-Why postmortems |
| Test Failure Explainer | `triage-build` | Explain test failures |
| Code Archaeology | `code-archaeology` | Trace code evolution history |

### :orange_circle: Tier 2 — Skill + Sub-agents (7 patterns)

SKILL.md plus agent definition files. Tasks requiring isolated contexts for
different roles (read-only research vs. write-capable implementation).

| Pattern | Skill Name | Purpose |
|---------|-----------|---------|
| Explore-then-Implement | `explore-implement` | Research first, implement second |
| Competitive Analysis | `competitive-analysis` | Parallel research + synthesis |
| Contract Testing | `contract-test` | Extract and verify API contracts |
| Spec-First Verification | `spec-first` | Tests before implementation |
| PR Review Pipeline | `review-pr` | Multi-perspective code review |
| Workflow Chaining | (multiple) | Chain plan → implement → review |
| Conditional Branching | `fix-lint` | Language-specific agent dispatch |

### :red_circle: Tier 3 — Full Stack (15 patterns)

SKILL.md plus agents, hooks, and settings. Tasks requiring deterministic
enforcement via lifecycle hooks.

| Pattern | Skill Name | Hook Type |
|---------|-----------|-----------|
| Sequential Pipeline | `sequential-pipeline` | PostToolUse |
| Parallel Fan-out/Fan-in | `fan-out-fan-in` | SubagentStop |
| Self-Reflection Loop | `self-reflect` | SubagentStop |
| Human-in-the-Loop | `approve-then-deploy` | PreToolUse |
| Staged Rollout Gate | `staged-rollout` | PreToolUse |
| Cost Threshold Gate | `cost-aware-task` | PreToolUse |
| Incremental Migration | `migrate-module` | PostToolUse |
| Pattern Replacement | `replace-pattern` | PostToolUse |
| Database Schema Evolution | `schema-evolve` | PreToolUse |
| Regression Sweep | `regression-sweep` | PreToolUse |
| API Client Generation | `generate-client` | PostToolUse |
| Watchdog Loop | `watchdog` | Stop |
| Environment Parity | `env-parity` | PreToolUse |
| Secret Rotation | `rotate-secret` | PreToolUse |
| Map-Reduce | `map-reduce` | SubagentStop |

---

## :package: Installing Patterns

### Quick Install (Recommended)

Use the install-pattern meta-skill:

```
/install-pattern sequential-pipeline
/install-pattern explore-then-implement
/install-pattern self-reflection-loop
```

### Manual Install

**Tier 1:**
```bash
mkdir -p .claude/skills/<skill-name>
cp patterns/workflow-patterns/tier-1-pure-skills/<pattern>/SKILL.md \
   .claude/skills/<skill-name>/SKILL.md
```

**Tier 2:**
```bash
mkdir -p .claude/skills/<skill-name> .claude/agents
cp patterns/workflow-patterns/tier-2-skill-plus-agents/<pattern>/SKILL.md \
   .claude/skills/<skill-name>/SKILL.md
cp patterns/workflow-patterns/tier-2-skill-plus-agents/<pattern>/agents/*.md \
   .claude/agents/
```

**Tier 3:**
```bash
mkdir -p .claude/skills/<skill-name> .claude/agents .claude/hooks
cp patterns/workflow-patterns/tier-3-full-stack/<pattern>/SKILL.md \
   .claude/skills/<skill-name>/SKILL.md
cp patterns/workflow-patterns/tier-3-full-stack/<pattern>/agents/*.md \
   .claude/agents/
cp patterns/workflow-patterns/tier-3-full-stack/<pattern>/hooks/*.sh \
   .claude/hooks/
chmod +x .claude/hooks/*.sh
# Merge settings-fragment.json into .claude/settings.json
```

---

## :mag: Choosing the Right Pattern

### Decision Flowchart

```
Is the task purely analytical (read, report, summarize)?
├── YES → Tier 1 (Pure Skill)
│   └── Does it need multiple specialized analysis passes?
│       ├── YES → Consider Tier 2 (add sub-agents)
│       └── NO → Tier 1 is sufficient
└── NO (involves writing/modifying code)
    └── Do you need to PREVENT certain operations automatically?
        ├── YES → Tier 3 (add hooks for enforcement)
        └── NO → Tier 2 (isolation via disallowedTools is enough)
```

### Hook Selection Guide

| Goal | Hook Event | Pattern Example |
|------|-----------|-----------------|
| Block dangerous operations | PreToolUse | Human approval, parity check |
| Validate output after write | PostToolUse | Type-check generated files |
| Gate on build success | PostToolUse | Sequential pipeline |
| Track parallel workers | SubagentStop | Map-reduce, fan-out |
| Gate on quality score | SubagentStop | Self-reflection loop |
| Send notifications | Stop | Watchdog |

---

## :warning: Anti-Patterns

| Anti-Pattern | Why It Fails | Correct Approach |
|-------------|-------------|-----------------|
| Enforcement in SKILL.md instructions | LLM may not follow | Use hooks |
| `disallowedTools` as only safety | Agent-scoped only | Combine with hooks |
| Multiple agents in one SKILL.md | No isolation | Use separate agent files |
| Hardcoded creds in hooks | Security risk | Use environment variables |
| Block hook that always exits 2 | Deadlocks agent | Provide bypass mechanism |

---

## :link: Related Resources

- [Continuous Loop Guide](continuous-loop-guide.md) — autonomous development loops
- [Architecture Reference](../architecture/) — Claude Code customization architecture
- Pattern decision matrix: `patterns/workflow-patterns/meta/pattern-decision-matrix.md`
