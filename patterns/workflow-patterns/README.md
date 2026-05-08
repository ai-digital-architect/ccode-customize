# Workflow Pattern Library

Deployable Claude Code artifacts for 33 workflow patterns, organized by component complexity.

## Tier Classification

| # | Pattern Name | Tier | Rationale |
|---|-------------|------|-----------|
| 01 | Sequential Pipeline | **3** | PostToolUse hook gates each stage on compile/test pass |
| 02 | Parallel Fan-out / Fan-in | **3** | SubagentStop hook tracks worker completion; workers need isolated contexts |
| 03 | Self-Reflection Loop | **3** | SubagentStop hook reads critic score JSON and blocks stop if below threshold |
| 04 | Human-in-the-Loop Approval | **3** | PreToolUse hook blocks destructive operations unless sentinel file exists |
| 05 | Staged Rollout Gate | **3** | PreToolUse hook enforces environment promotion order |
| 06 | Cost-Threshold Gate | **3** | PreToolUse hook estimates cost and blocks if over budget |
| 07 | Explore-then-Implement | **2** | Researcher must be physically prevented from writing (`disallowedTools`) |
| 08 | Competitive Analysis | **2** | Parallel researchers need isolated contexts; synthesizer reads all outputs |
| 09 | Dependency Audit | **1** | Single read-only analysis — one agent reads manifests, runs audit, produces report |
| 10 | Incremental Migration | **3** | PostToolUse hook runs test suite after each module migration |
| 11 | Pattern Replacement | **3** | PostToolUse hook runs lint + compile after each replacement |
| 12 | Database Schema Evolution | **3** | PreToolUse hook blocks rollout if migration is not reversible |
| 13 | Contract Testing | **2** | Extractor and verifier need separate contexts; both must be read-only |
| 14 | Spec-First Verification | **2** | Test generator (write) and verifier (read-only) need isolation |
| 15 | Regression Sweep | **3** | PreToolUse hook captures test baseline BEFORE first source edit |
| 16 | Template Instantiation | **1** | Single agent reads conventions and creates files |
| 17 | API Client Generation | **3** | PostToolUse hook runs type-checker after each generated file |
| 18 | Documentation Generation | **1** | Single read-only analysis — reads source, tests, git log |
| 19 | Watchdog Loop | **3** | Stop hook fires notification on threshold violation |
| 20 | Build Failure Triage | **1** | Single read-only analysis of failure logs and git history |
| 21 | Log Analysis | **1** | Single read-only analysis using Bash preprocessing tools |
| 22 | PR Review Pipeline | **2** | Five specialist sub-agents, each read-only with isolated context |
| 23 | Compliance Audit | **1** | Single read-only scan against ruleset |
| 24 | Dead Code Detection | **1** | Single read-only analysis using grep/find and code reading |
| 25 | Environment Parity Check | **3** | PreToolUse hook blocks deployment if parity report shows drift |
| 26 | Secret Rotation | **3** | PreToolUse hook blocks credential revocation unless health check passed |
| 27 | Infrastructure Drift Detection | **1** | Single read-only analysis; deny list in permissions fragment |
| 28 | Postmortem Assistant | **1** | Single read-only analysis of incident data |
| 29 | Test Failure Explainer | **1** | Single read-only analysis — git log + error output → explanation |
| 30 | Code Archaeology | **1** | Single read-only analysis — git history → narrative |
| 31 | Workflow Chaining | **2** | Three linked skills sharing artifacts via filesystem |
| 32 | Conditional Branching | **2** | Coordinator skill + language-specific specialist sub-agents |
| 33 | Map-Reduce | **3** | SubagentStop hook tracks worker completions; reducer is read-only |

## Summary

| Tier | Count | Patterns |
|------|-------|----------|
| **Tier 1** — Pure Skill | **11** | 09, 16, 18, 20, 21, 23, 24, 27, 28, 29, 30 |
| **Tier 2** — Skill + Sub-agents | **7** | 07, 08, 13, 14, 22, 31, 32 |
| **Tier 3** — Full Stack | **15** | 01, 02, 03, 04, 05, 06, 10, 11, 12, 15, 17, 19, 25, 26, 33 |

## Directory Structure

```
patterns/workflow-patterns/
├── README.md                        ← This file
├── tier-1-pure-skills/              ← Single SKILL.md per pattern
│   ├── dependency-audit/SKILL.md
│   ├── template-instantiation/SKILL.md
│   ├── documentation-generation/SKILL.md
│   ├── build-failure-triage/SKILL.md
│   ├── log-analysis/SKILL.md
│   ├── compliance-audit/SKILL.md
│   ├── dead-code-detection/SKILL.md
│   ├── infrastructure-drift-detection/SKILL.md
│   ├── postmortem-assistant/SKILL.md
│   ├── test-failure-explainer/SKILL.md
│   └── code-archaeology/SKILL.md
├── tier-2-skill-plus-agents/        ← SKILL.md + agents/*.md per pattern
│   ├── explore-then-implement/
│   ├── competitive-analysis/
│   ├── contract-testing/
│   ├── spec-first-verification/
│   ├── pr-review-pipeline/
│   ├── workflow-chaining/
│   └── conditional-branching/
├── tier-3-full-stack/               ← SKILL.md + agents + hooks + settings-fragment.json
│   ├── sequential-pipeline/
│   ├── parallel-fan-out-fan-in/
│   ├── self-reflection-loop/
│   ├── human-in-the-loop-approval/
│   ├── staged-rollout-gate/
│   ├── cost-threshold-gate/
│   ├── incremental-migration/
│   ├── pattern-replacement/
│   ├── database-schema-evolution/
│   ├── regression-sweep/
│   ├── api-client-generation/
│   ├── watchdog-loop/
│   ├── environment-parity-check/
│   ├── secret-rotation/
│   └── map-reduce/
└── meta/
    ├── install-pattern/SKILL.md     ← Meta-skill: installs any pattern
    └── pattern-decision-matrix.md   ← Choosing the right pattern
```

## Installation

### Quick Install (any pattern)

Use the meta-skill to install a pattern into your project:

```
/install-pattern sequential-pipeline
```

### Manual Install

**Tier 1 patterns:**
```bash
cp patterns/workflow-patterns/tier-1-pure-skills/<pattern>/SKILL.md .claude/skills/<pattern>/SKILL.md
```

**Tier 2 patterns:**
```bash
cp patterns/workflow-patterns/tier-2-skill-plus-agents/<pattern>/SKILL.md .claude/skills/<pattern>/SKILL.md
cp patterns/workflow-patterns/tier-2-skill-plus-agents/<pattern>/agents/*.md .claude/agents/
```

**Tier 3 patterns:**
```bash
cp patterns/workflow-patterns/tier-3-full-stack/<pattern>/SKILL.md .claude/skills/<pattern>/SKILL.md
cp patterns/workflow-patterns/tier-3-full-stack/<pattern>/agents/*.md .claude/agents/
cp patterns/workflow-patterns/tier-3-full-stack/<pattern>/hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
# Merge settings-fragment.json into .claude/settings.json manually
```

See `meta/pattern-decision-matrix.md` to choose the right pattern.
