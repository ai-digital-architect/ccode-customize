# Claude Code Customization Patterns

## Scope

This project is a self-contained workspace for applying the Claude Code Customization Architecture to concrete architectural patterns to any project with any technology stack. 

## Architecture Guide

The authoritative reference for all work in this folder is:

- architecture/claude-code-customization-architecture.md

Read this file before implementing any pattern. It defines the six core components (Memory, Sub-agents, Hooks, MCP Servers, Slash Commands, Skills) and their correct placement, configuration, and composition rules.

## Patterns

Each subfolder under patterns/ contains a distinct architectural pattern to be implemented using Claude Code customization primitives:

- patterns/cell-baased-architecture/ : Cell-based architecture pattern
- patterns/component-based-design/ : Component-based design pattern
- patterns/hexagonal-architecture/ : Hexagonal (ports and adapters) architecture pattern
- patterns/memory-implementation/ : Memory system implementation pattern
- patterns/workflow-patterns/ : Workflow orchestration patterns (see below)

### Workflow Patterns (Special Role)

patterns/workflow-patterns/ does not produce its own standalone reference architecture. Instead, it augments claude-code-customization-architecture.md to describe how workflows (Skills, Slash Commands, Hooks, Sub-agent orchestration) are composed when implementing the other four patterns. Reference workflow patterns when building out cell-based, component-based, hexagonal, or memory-implementation artifacts.

## Output: Reference Architecture Artifacts

For each pattern (except workflow-patterns), generate a complete reference architecture under:

    architecture/reference-architecture/<pattern-name>/

Each pattern folder should contain the Claude Code customization artifacts that implement that pattern, for example CLAUDE.md, AGENTS.md, sub-agent definitions, hook configurations, skill definitions, MCP server configs, and a README explaining the mapping from architectural pattern to Claude Code primitives.

## Workflow

1. Read architecture/claude-code-customization-architecture.md for component definitions and rules
2. Read the relevant patterns/<pattern>/ folder for pattern-specific guidance
3. Consult patterns/workflow-patterns/ for orchestration and workflow composition
4. Create artifacts under architecture/reference-architecture/<pattern-name>/
5. Stay within this folder and do not modify files elsewhere in the repository

## Installed Workflow Patterns

All 33 workflow patterns from `patterns/workflow-patterns/` are installed into `.claude/`.
See `specs/install-patterns-plan.md` for the installation plan and pattern-to-skill mapping.

### Available Skills

#### Tier 1 — Pure Skills (single SKILL.md, no agents)

| Skill | Command | Purpose |
|-------|---------|---------|
| Dependency Audit | `/dependency-audit` | Audit package dependencies for vulnerabilities |
| Template Instantiation | `/template-instantiation` | Scaffold new modules from templates |
| Documentation Generation | `/documentation-generation` | Generate docs from source code |
| Build Failure Triage | `/build-failure-triage` | Diagnose CI/build failures |
| Log Analysis | `/log-analysis` | Analyze application logs |
| Compliance Audit | `/compliance-audit` | Audit code against rulesets |
| Dead Code Detection | `/dead-code-detection` | Find unused code |
| Infrastructure Drift Detection | `/infrastructure-drift-detection` | Detect IaC drift |
| Postmortem Assistant | `/postmortem-assistant` | Generate incident postmortems |
| Test Failure Explainer | `/test-failure-explainer` | Explain test failures |
| Code Archaeology | `/code-archaeology` | Trace code evolution via git history |

#### Tier 2 — Skill + Agents (SKILL.md + agent definitions)

| Skill | Command | Agents |
|-------|---------|--------|
| Explore-Implement | `/explore-implement` | researcher, implementer |
| Competitive Analysis | `/competitive-analysis` | source-researcher, analysis-synthesizer |
| Contract Test | `/contract-test` | contract-extractor, contract-verifier |
| Spec Verify | `/spec-verify` | spec-test-generator, spec-verifier |
| Review PR | `/review-pr` | diff-analyzer, security-reviewer, style-checker, coverage-checker, review-summarizer |
| Workflow Chain | `/plan-feature` `/implement-feature` `/review-feature` | (3 linked skills) |
| Auto-Fix | `/auto-fix` | ts-fixer, py-fixer, go-fixer |

#### Tier 3 — Full Stack (SKILL.md + agents + hooks + settings)

| Skill | Command | Key Hook |
|-------|---------|----------|
| Sequential Pipeline | `/sequential-pipeline` | pipeline-gate.sh (PostToolUse) |
| Fan-out/Fan-in | `/fan-out-fan-in` | track-worker-completion.sh (SubagentStop) |
| Self-Reflect | `/self-reflect` | check-review-score.sh (SubagentStop) |
| Approve then Deploy | `/approve-then-deploy` | require-approval.sh (PreToolUse) |
| Staged Rollout | `/staged-rollout` | rollout-gate.sh (PreToolUse) |
| Cost-Aware Task | `/cost-aware-task` | cost-gate.sh (PreToolUse) |
| Incremental Migrate | `/incremental-migrate` | migration-gate.sh (PostToolUse) |
| Replace Pattern | `/replace-pattern` | refactor-lint.sh (PostToolUse) |
| Schema Evolve | `/schema-evolve` | require-reversible-migration.sh (PreToolUse) |
| Regression Sweep | `/regression-sweep` | capture-baseline.sh (PreToolUse) |
| Generate Client | `/generate-client` | typecheck-generated.sh (PostToolUse) |
| Watchdog | `/watchdog` | watchdog-notify.sh (Stop) |
| Env Parity | `/env-parity` | block-promotion-on-drift.sh (PreToolUse) |
| Rotate Secret | `/rotate-secret` | require-health-before-revoke.sh (PreToolUse) |
| Map-Reduce | `/map-reduce` | mr-track-completion.sh (SubagentStop) |

#### Utility Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| Continuous Loop | `/continuous-loop` | Start autonomous build loop |
| Plan Loop | `/plan-loop` | Run planning iteration |
| Cancel Loop | `/cancel-loop` | Cancel active loop |
| Install Pattern | `/install-pattern` | Install workflow pattern from catalog |
| Markdown Formatting | `/markdown-formatting` | Validate markdown format |

### Installed Agents

All agent definitions reside in `.claude/agents/`. See `AGENTS.md` for the full inventory with roles, models, tools, and invocation guidance.

### Installed Hooks

All hook scripts reside in `.claude/hooks/`. Hooks are registered in `.claude/settings.json`.

| Hook | Event | Purpose |
|------|-------|---------|
| pre-bash-safety.sh | PreToolUse (Bash) | Block dangerous shell commands |
| require-approval.sh | PreToolUse (Bash) | Block destructive ops without approval sentinel |
| rollout-gate.sh | PreToolUse (Bash) | Enforce environment promotion order |
| cost-gate.sh | PreToolUse (*) | Budget enforcement (requires jq) |
| require-reversible-migration.sh | PreToolUse (Bash) | Block non-reversible migrations |
| capture-baseline.sh | PreToolUse (Write/Edit) | Capture test baseline before first edit |
| block-promotion-on-drift.sh | PreToolUse (Bash) | Block deploy if env parity fails |
| require-health-before-revoke.sh | PreToolUse (Bash) | Require health check before secret revocation |
| post-write-backpressure.sh | PostToolUse (Write/Edit) | Lint/format after file writes |
| pipeline-gate.sh | PostToolUse (Write/Edit) | Build gate between pipeline stages |
| migration-gate.sh | PostToolUse (Write/Edit) | Build gate after migration edits |
| refactor-lint.sh | PostToolUse (Write/Edit) | Lint + build after refactoring |
| typecheck-generated.sh | PostToolUse (Write) | Type-check generated client code |
| check-review-score.sh | SubagentStop (*) | Gate on quality score >= 4 |
| track-worker-completion.sh | SubagentStop (*) | Log fan-out worker completions |
| mr-track-completion.sh | SubagentStop (*) | Log map-reduce worker completions |
| stop-loop.sh | Stop (*) | Loop iteration control |
| notify-pipeline-complete.sh | Stop (*) | Pipeline completion notification |
| watchdog-notify.sh | Stop (*) | Watchdog violation notification |

### Workflow Chaining Convention

The workflow chaining pattern uses `.claude/chain/` for artifact exchange:
- `/plan-feature` writes `plan.md` and cleans the chain directory
- `/implement-feature` reads `plan.md` and writes `result.md`
- `/review-feature` reads both and produces a review

### Environment Baseline

For the env-parity pattern, define your environment baseline here:

```
Required Variables:
- DATABASE_URL
- API_KEY
- NODE_ENV
- PORT

Environments:
- .env.dev
- .env.staging
- .env.production
```
