# Workflow Pattern User Guides

This directory contains user guides for all 33 installed workflow patterns.

## Tier 1 -- Pure Skills

Single-skill patterns for read-only analysis tasks. No agents or hooks required.

| Guide | Command | Description |
|-------|---------|-------------|
| [Dependency Audit](dependency-audit.md) | `/dependency-audit` | Audit package dependencies for vulnerabilities |
| [Template Instantiation](template-instantiation.md) | `/template-instantiation` | Scaffold new modules from project templates |
| [Documentation Generation](documentation-generation.md) | `/documentation-generation` | Generate documentation from source code |
| [Build Failure Triage](build-failure-triage.md) | `/build-failure-triage` | Diagnose CI/build failures |
| [Log Analysis](log-analysis.md) | `/log-analysis` | Analyze application log files |
| [Compliance Audit](compliance-audit.md) | `/compliance-audit` | Audit code against compliance rulesets |
| [Dead Code Detection](dead-code-detection.md) | `/dead-code-detection` | Find unused code across the codebase |
| [Infrastructure Drift Detection](infrastructure-drift-detection.md) | `/infrastructure-drift-detection` | Detect drift in infrastructure-as-code |
| [Postmortem Assistant](postmortem-assistant.md) | `/postmortem-assistant` | Generate structured incident postmortems |
| [Test Failure Explainer](test-failure-explainer.md) | `/test-failure-explainer` | Explain why a test is failing |
| [Code Archaeology](code-archaeology.md) | `/code-archaeology` | Trace code evolution through git history |

## Tier 2 -- Skill + Agents

Multi-agent patterns with specialized sub-agents for different workflow phases.

| Guide | Command | Description |
|-------|---------|-------------|
| [Explore-then-Implement](explore-then-implement.md) | `/explore-implement` | Research codebase read-only, then implement |
| [Competitive Analysis](competitive-analysis.md) | `/competitive-analysis` | Parallel research and synthesis |
| [Contract Testing](contract-testing.md) | `/contract-test` | Extract and verify API consumer contracts |
| [Spec-First Verification](spec-first-verification.md) | `/spec-verify` | Generate tests from API spec and verify |
| [PR Review Pipeline](pr-review-pipeline.md) | `/review-pr` | Multi-specialist pull request review |
| [Workflow Chaining](workflow-chaining.md) | `/plan-feature` | Three-step plan-implement-review chain |
| [Conditional Branching](conditional-branching.md) | `/auto-fix` | Language-aware auto-fix dispatch |

## Tier 3 -- Full Stack

Complete patterns with skills, agents, hooks, and settings integration.

| Guide | Command | Description |
|-------|---------|-------------|
| [Sequential Pipeline](sequential-pipeline.md) | `/sequential-pipeline` | Schema-to-tests stage-by-stage pipeline |
| [Parallel Fan-out/Fan-in](parallel-fan-out-fan-in.md) | `/fan-out-fan-in` | Parallel workers with result merging |
| [Self-Reflection Loop](self-reflection-loop.md) | `/self-reflect` | Implement-critique-revise quality loop |
| [Human-in-the-Loop Approval](human-in-the-loop-approval.md) | `/approve-then-deploy` | Human approval gate for destructive ops |
| [Staged Rollout Gate](staged-rollout-gate.md) | `/staged-rollout` | Dev-staging-production promotion |
| [Cost-Threshold Gate](cost-threshold-gate.md) | `/cost-aware-task` | Budget-constrained execution |
| [Incremental Migration](incremental-migration.md) | `/incremental-migrate` | Module-by-module migration with build gates |
| [Pattern Replacement](pattern-replacement.md) | `/replace-pattern` | Discover-and-replace codebase refactoring |
| [Database Schema Evolution](database-schema-evolution.md) | `/schema-evolve` | Gated database migration pipeline |
| [Regression Sweep](regression-sweep.md) | `/regression-sweep` | Before/after test diff analysis |
| [API Client Generation](api-client-generation.md) | `/generate-client` | Typed API clients from spec |
| [Watchdog Loop](watchdog-loop.md) | `/watchdog` | Continuous health monitoring |
| [Environment Parity Check](environment-parity-check.md) | `/env-parity` | Environment configuration drift detection |
| [Secret Rotation](secret-rotation.md) | `/rotate-secret` | Credential rotation workflow |
| [Map-Reduce](map-reduce.md) | `/map-reduce` | Bulk processing with workers and reducer |
