# AGENTS.md

## Project Overview

This project is a Claude Code customization reference implementation providing
**33 installable workflow patterns** covering autonomous development loops,
multi-agent pipelines, safety gates, and operational workflows. All patterns
are composed from Claude Code's six customization primitives: Memory, Sub-agents,
Hooks, MCP Servers, Slash Commands, and Skills.

## Tech Stack

- Runtime: Claude Code CLI (terminal-first)
- Configuration: YAML frontmatter + Markdown + JSON + Bash
- Version Control: Git (checkpoint-based recovery)
- Architecture: Claude Code Customization Architecture (6 components)

## Build & Test Commands

- Start build loop: `/continuous-loop "task description"`
- Planning mode: `/plan-loop specs/`
- Cancel loop: `/cancel-loop "reason"`
- Install a pattern: `/install-pattern <pattern-name> <tier>`
- Explore then implement: `/explore-implement`
- Review a PR: `/review-pr`
- Auto-fix errors: `/auto-fix`
- Validate settings: `cat .claude/settings.json | jq '.'`

## Code Style

- SKILL.md files use YAML frontmatter per the Agent Skills standard
- Agent definitions follow Claude Code sub-agent format with YAML frontmatter
- Hook scripts use `#!/usr/bin/env bash`, `set -euo pipefail`, and structured JSON I/O
- Settings use the `.claude/settings.json` schema with permission patterns

## Agent Inventory

| Agent | Model | Access | Workflow Pattern |
|-------|-------|--------|-----------------|
| loop-planner | claude-opus-4-5 | Read-only | Continuous Loop |
| loop-implementer | claude-sonnet-4-6 | Full write | Continuous Loop |
| loop-reviewer | claude-opus-4-5 | Read-only | Continuous Loop |
| researcher | claude-sonnet-4-6 | Read-only | Explore-then-Implement |
| implementer | claude-sonnet-4-6 | Full write | Explore-then-Implement |
| source-researcher | claude-sonnet-4-6 | Read-only | Competitive Analysis |
| analysis-synthesizer | claude-opus-4-5 | Read-only | Competitive Analysis |
| contract-extractor | claude-sonnet-4-6 | Read-only | Contract Testing |
| contract-verifier | claude-sonnet-4-6 | Read-only | Contract Testing |
| spec-test-generator | claude-sonnet-4-6 | Write (tests only) | Spec-First Verification |
| spec-verifier | claude-sonnet-4-6 | Read-only | Spec-First Verification |
| diff-analyzer | claude-sonnet-4-6 | Read-only | PR Review Pipeline |
| security-reviewer | claude-opus-4-5 | Read-only | PR Review Pipeline |
| style-checker | claude-sonnet-4-6 | Read-only | PR Review Pipeline |
| coverage-checker | claude-sonnet-4-6 | Read-only | PR Review Pipeline |
| review-summarizer | claude-opus-4-5 | Read-only | PR Review Pipeline |
| ts-fixer | claude-sonnet-4-6 | Full write | Conditional Branching |
| py-fixer | claude-sonnet-4-6 | Full write | Conditional Branching |
| go-fixer | claude-sonnet-4-6 | Full write | Conditional Branching |
| schema-designer | claude-sonnet-4-6 | Write (schema) | Sequential Pipeline |
| entity-builder | claude-sonnet-4-6 | Write (entities) | Sequential Pipeline |
| service-builder | claude-sonnet-4-6 | Write (services) | Sequential Pipeline |
| route-builder | claude-sonnet-4-6 | Write (routes) | Sequential Pipeline |
| test-writer | claude-sonnet-4-6 | Write (tests) | Sequential Pipeline |
| parallel-worker | claude-sonnet-4-6 | Scoped write | Fan-out/Fan-in |
| result-merger | claude-sonnet-4-6 | Write (summary) | Fan-out/Fan-in |
| code-critic | claude-opus-4-5 | Read-only | Self-Reflection Loop |
| env-deployer | claude-sonnet-4-6 | Bash-only | Staged Rollout |
| module-migrator | claude-sonnet-4-6 | Full write | Incremental Migration |
| pattern-finder | claude-sonnet-4-6 | Read-only | Pattern Replacement |
| pattern-replacer | claude-sonnet-4-6 | Full write | Pattern Replacement |
| schema-differ | claude-sonnet-4-6 | Read-only | Database Schema Evolution |
| migration-generator | claude-sonnet-4-6 | Write (migrations) | Database Schema Evolution |
| compat-checker | claude-opus-4-5 | Read-only | Database Schema Evolution |
| regression-differ | claude-sonnet-4-6 | Read-only | Regression Sweep |
| client-generator | claude-sonnet-4-6 | Write (clients) | API Client Generation |
| health-checker | claude-sonnet-4-6 | Read-only | Watchdog Loop |
| env-parity-checker | claude-sonnet-4-6 | Read-only | Environment Parity |
| secret-finder | claude-sonnet-4-6 | Read-only | Secret Rotation |
| mr-worker | claude-sonnet-4-6 | Scoped write | Map-Reduce |
| mr-reducer | claude-sonnet-4-6 | Read-only | Map-Reduce |

## Agent Details

### loop-planner

- **Role**: Read-only codebase analyst for planning iterations
- **Model**: claude-opus-4-5
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 20
- **Invoke when**: Starting a build loop or when plan is stale
- **Output**: `fix_plan.md` with prioritized implementation plan

### loop-implementer

- **Role**: Write-capable implementation agent for build iterations
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, MultiEdit, Bash
- **Max Turns**: 30
- **Invoke when**: Each build iteration to implement one plan item
- **Output**: Implemented code, tests, and updated plan

### loop-reviewer

- **Role**: Read-only quality gate reviewer
- **Model**: claude-opus-4-5
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 10
- **Invoke when**: After implementation to score quality
- **Output**: `.claude/review-score.json`

### researcher

- **Role**: Read-only codebase researcher for explore-then-implement
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 15
- **Invoke when**: Before implementing features to understand existing code
- **Output**: `.claude/research-output/research.md`

### implementer

- **Role**: Write-capable implementer using research findings
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, MultiEdit, Bash
- **Max Turns**: 30
- **Invoke when**: After researcher completes, to implement changes
- **Output**: Implemented code changes

### source-researcher

- **Role**: Researches a single target for competitive analysis
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 12
- **Invoke when**: In parallel for each research target
- **Output**: `.claude/analysis/<target-name>.json`

### analysis-synthesizer

- **Role**: Synthesizes research from all source-researchers
- **Model**: claude-opus-4-5
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 8
- **Invoke when**: After all source-researchers complete
- **Output**: Unified comparison report

### contract-extractor

- **Role**: Scans frontend code to extract API consumer contracts
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 12
- **Invoke when**: To discover API contracts from frontend code
- **Output**: `.claude/contracts/consumer-contracts.json`

### contract-verifier

- **Role**: Verifies backend endpoints against consumer contracts
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 12
- **Invoke when**: After contract extraction to check for drift
- **Output**: Contract verification report

### spec-test-generator

- **Role**: Generates test cases from OpenAPI/GraphQL specs
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Bash
- **Max Turns**: 20
- **Invoke when**: After an API spec is written or updated
- **Output**: `tests/spec-verification/` test files

### spec-verifier

- **Role**: Runs spec-generated tests and reports results
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 10
- **Invoke when**: After spec-test-generator creates tests
- **Output**: Pass/fail/missing endpoint report

### diff-analyzer

- **Role**: Categorizes git diff changes and flags risks
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 8
- **Invoke when**: First stage of PR review pipeline
- **Output**: `.claude/review/diff-analysis.json`

### security-reviewer

- **Role**: Reviews code for security vulnerabilities
- **Model**: claude-opus-4-5
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 10
- **Invoke when**: During PR review pipeline
- **Output**: `.claude/review/security.json`

### style-checker

- **Role**: Checks code against project style conventions
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 8
- **Invoke when**: During PR review pipeline
- **Output**: `.claude/review/style.json`

### coverage-checker

- **Role**: Assesses test coverage for changed code
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 8
- **Invoke when**: During PR review pipeline
- **Output**: `.claude/review/coverage.json`

### review-summarizer

- **Role**: Aggregates all review findings into unified PR comment
- **Model**: claude-opus-4-5
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 6
- **Invoke when**: After all review specialists complete
- **Output**: Unified PR review comment

### ts-fixer

- **Role**: Fixes issues in TypeScript/Node.js projects
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, Bash
- **Max Turns**: 20
- **Invoke when**: Auto-fix dispatches to TypeScript specialist

### py-fixer

- **Role**: Fixes issues in Python projects
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, Bash
- **Max Turns**: 20
- **Invoke when**: Auto-fix dispatches to Python specialist

### go-fixer

- **Role**: Fixes issues in Go projects
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, Bash
- **Max Turns**: 20
- **Invoke when**: Auto-fix dispatches to Go specialist

### schema-designer

- **Role**: Designs database schema changes (Drizzle ORM)
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Bash | **Disallowed**: Edit, MultiEdit
- **Max Turns**: 10
- **Invoke when**: First stage of sequential pipeline

### entity-builder

- **Role**: Creates entity types and repository layer
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Bash | **Disallowed**: MultiEdit
- **Max Turns**: 10
- **Invoke when**: After schema-designer in sequential pipeline

### service-builder

- **Role**: Implements business logic service layer
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, Bash
- **Max Turns**: 12
- **Invoke when**: After entity-builder in sequential pipeline

### route-builder

- **Role**: Creates API route handlers
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, Bash
- **Max Turns**: 10
- **Invoke when**: After service-builder in sequential pipeline

### test-writer

- **Role**: Writes integration and unit tests
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, Bash
- **Max Turns**: 15
- **Invoke when**: Final stage of sequential pipeline

### parallel-worker

- **Role**: Processes a single unit in fan-out pipeline
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, Bash
- **Max Turns**: 15
- **Invoke when**: Coordinator fans out work across modules

### result-merger

- **Role**: Merges all worker results into unified summary
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Bash | **Disallowed**: Edit, MultiEdit
- **Max Turns**: 10
- **Invoke when**: After all parallel-workers complete

### code-critic

- **Role**: Scores code quality in self-reflection loops
- **Model**: claude-opus-4-5
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 8
- **Invoke when**: After implementation to critique and score
- **Output**: `.claude/review-score.json`

### env-deployer

- **Role**: Deploys build to specified environment
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 10
- **Invoke when**: Each stage of staged rollout

### module-migrator

- **Role**: Migrates one module at a time
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, MultiEdit, Bash
- **Max Turns**: 20
- **Invoke when**: For each module in incremental migration

### pattern-finder

- **Role**: Discovers all instances of old pattern (read-only)
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 15
- **Invoke when**: Discovery phase of pattern replacement
- **Output**: `.claude/refactor/instance-manifest.json`

### pattern-replacer

- **Role**: Replaces pattern instances one at a time
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, Bash
- **Max Turns**: 25
- **Invoke when**: After pattern-finder completes

### schema-differ

- **Role**: Produces structured schema diff
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 8
- **Invoke when**: First stage of schema evolution
- **Output**: `.claude/schema/diff.json`

### migration-generator

- **Role**: Generates SQL migration files from schema diff
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Bash
- **Max Turns**: 10
- **Invoke when**: After schema-differ in schema evolution

### compat-checker

- **Role**: Validates migration backward-compatibility
- **Model**: claude-opus-4-5
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 8
- **Invoke when**: After migration-generator for safety gate
- **Output**: `.claude/schema/compat-report.json`

### regression-differ

- **Role**: Compares before/after test results for regressions
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 8
- **Invoke when**: After code changes to detect regressions
- **Output**: Regression diff report

### client-generator

- **Role**: Generates typed API clients from specs
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Bash | **Disallowed**: Edit, MultiEdit
- **Max Turns**: 25
- **Invoke when**: New or updated API spec available

### health-checker

- **Role**: Checks specific health metric
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 5
- **Invoke when**: During watchdog loop polling
- **Output**: `.claude/watchdog/latest-check.json`

### env-parity-checker

- **Role**: Compares env configs against baseline
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 10
- **Invoke when**: Before promotions or environment audits
- **Output**: `.claude/env/parity-report.json`

### secret-finder

- **Role**: Finds all credential references across codebase
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 10
- **Invoke when**: During secret rotation discovery phase

### mr-worker

- **Role**: Processes single item in map-reduce pipeline
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Write, Edit, Bash
- **Max Turns**: 12
- **Invoke when**: For each item in map-reduce fan-out
- **Output**: `.claude/map-reduce/results/<item-id>.json`

### mr-reducer

- **Role**: Aggregates map-reduce results
- **Model**: claude-sonnet-4-6
- **Tools**: Read, Bash | **Disallowed**: Write, Edit, MultiEdit
- **Max Turns**: 8
- **Invoke when**: After all mr-workers complete
- **Output**: `.claude/map-reduce/aggregate.md`

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| Continuous Loop | `/continuous-loop` | Start autonomous build loop |
| Plan Loop | `/plan-loop` | Run planning iteration |
| Cancel Loop | `/cancel-loop` | Cancel active loop |
| Install Pattern | `/install-pattern` | Install workflow pattern from catalog |
| Explore-Implement | `/explore-implement` | Research then implement |
| Competitive Analysis | `/competitive-analysis` | Parallel research and synthesis |
| Contract Test | `/contract-test` | Extract and verify API contracts |
| Spec Verify | `/spec-verify` | Generate and run spec tests |
| Review PR | `/review-pr` | Multi-specialist PR review |
| Plan Feature | `/plan-feature` | Plan a feature (chain step 1) |
| Implement Feature | `/implement-feature` | Implement from plan (chain step 2) |
| Review Feature | `/review-feature` | Review implementation (chain step 3) |
| Auto-Fix | `/auto-fix` | Language-aware auto-fix |
| Sequential Pipeline | `/sequential-pipeline` | Schema-to-tests pipeline |
| Fan-out/Fan-in | `/fan-out-fan-in` | Parallel processing pipeline |
| Self-Reflect | `/self-reflect` | Quality loop with critic |
| Approve then Deploy | `/approve-then-deploy` | Human approval gate |
| Staged Rollout | `/staged-rollout` | Dev-staging-prod promotion |
| Cost-Aware Task | `/cost-aware-task` | Budget-constrained execution |
| Incremental Migrate | `/incremental-migrate` | Module-by-module migration |
| Replace Pattern | `/replace-pattern` | Codebase-wide refactor |
| Schema Evolve | `/schema-evolve` | Database migration pipeline |
| Regression Sweep | `/regression-sweep` | Before/after test diff |
| Generate Client | `/generate-client` | API client from spec |
| Watchdog | `/watchdog` | Continuous health monitoring |
| Env Parity | `/env-parity` | Environment drift detection |
| Rotate Secret | `/rotate-secret` | Credential rotation workflow |
| Map-Reduce | `/map-reduce` | Bulk processing pipeline |
| Dependency Audit | `/dependency-audit` | Audit package dependencies |
| Template Instantiation | `/template-instantiation` | Scaffold new modules |
| Documentation Generation | `/documentation-generation` | Generate docs from code |
| Build Failure Triage | `/build-failure-triage` | Diagnose CI failures |
| Log Analysis | `/log-analysis` | Analyze application logs |
| Compliance Audit | `/compliance-audit` | Audit against rulesets |
| Dead Code Detection | `/dead-code-detection` | Find unused code |
| Infrastructure Drift | `/infrastructure-drift-detection` | Detect IaC drift |
| Postmortem Assistant | `/postmortem-assistant` | Generate incident postmortems |
| Test Failure Explainer | `/test-failure-explainer` | Explain test failures |
| Code Archaeology | `/code-archaeology` | Trace code evolution |
| Markdown Formatting | `/markdown-formatting` | Validate markdown format |

## Security

- Default-deny permission model for shell commands
- Sub-agents follow principle of least privilege (read-only where possible)
- PreToolUse hooks block dangerous commands (force push, recursive delete, sudo)
- No secrets or credentials in source files
- Hook scripts are deterministic with no dynamic code evaluation

## Commit Convention

- `feat:` — new feature implementation
- `fix:` — bug fix
- `docs:` — documentation updates
- `refactor:` — code improvement without functional change
- `test:` — test additions or fixes
