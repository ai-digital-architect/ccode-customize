# Workflow Patterns Catalog

Reference for `claude-code-enhanced` Phase 2 Pattern Selection.
All 33 patterns from `patterns/workflow-patterns/`, organized by tier.

## Table of Contents

- [How to Use This Catalog](#how-to-use)
- [Detection Signal → Pattern Mapping](#detection-signal-mapping)
- [Tier 1 — Pure Skills (11 patterns)](#tier-1)
- [Tier 2 — Skill + Agents (7 patterns)](#tier-2)
- [Tier 3 — Full Stack with Hooks (15 patterns)](#tier-3)
- [Installation Instructions](#installation-instructions)

---

## How to Use This Catalog

In Phase 2 of the skill workflow:
1. Check the Detection Signal Mapping table for signals found in Phase 1
2. For each matching pattern: read its entry, verify the tier fits the need
3. Mark as **Install**, **Adapt**, or **Skip** in the plan
4. Use the tier-specific installation instructions in Phase 4

**Tier selection rule (from `pattern-decision-matrix.md`):**
- Task is purely analytical (read/report)? → **Tier 1**
- Task needs isolated read-only + write steps? → **Tier 2**
- Task needs deterministic enforcement (blocking/gating)? → **Tier 3**

---

## Detection Signal Mapping

| Codebase Signal | Recommended Pattern | Tier |
|----------------|--------------------|----|
| `.github/`, CI/CD pipeline, staged feature builds | sequential-pipeline | 3 |
| Multiple independent analysis tasks, monorepo packages | parallel-fan-out-fan-in | 3 |
| Quality review, self-critique loop before delivery | self-reflection-loop | 3 |
| Multi-environment deploys (dev/staging/prod) | staged-rollout-gate | 3 |
| Large LLM usage, cost concerns | cost-threshold-gate | 3 |
| Test suite + no baseline tracking | regression-sweep | 3 |
| OpenAPI spec, gRPC, code-generated clients | api-client-generation | 3 |
| Continuous monitoring, threshold alerting | watchdog-loop | 3 |
| DB ORM (Prisma, Drizzle, Alembic, GORM) | database-schema-evolution | 3 |
| Large-scale migration (many modules) | incremental-migration | 3 |
| Cross-codebase pattern replacement/refactor | pattern-replacement | 3 |
| Multiple `.env.*` files, environment drift risk | environment-parity-check | 3 |
| Credentials, API keys, secret management | secret-rotation | 3 |
| Destructive operations, deploy without approval | human-in-the-loop-approval | 3 |
| Batch processing, fan-out aggregation | map-reduce | 3 |
| Research-first, write-second workflows | explore-then-implement | 2 |
| Competitor/approach research needed | competitive-analysis | 2 |
| Microservices, service-to-service API contracts | contract-testing | 2 |
| OpenAPI/GraphQL spec file present | spec-first-verification | 2 |
| GitHub PRs active, code review needed | pr-review-pipeline | 2 |
| Plan → implement → review pipeline | workflow-chaining | 2 |
| Multiple languages/frameworks in repo | conditional-branching | 2 |
| `package.json`, `requirements.txt`, `Cargo.toml` | dependency-audit | 1 |
| Scaffold patterns, repeating module structure | template-instantiation | 1 |
| Source code lacks docs, JSDoc/docstrings missing | documentation-generation | 1 |
| CI failures, flaky builds | build-failure-triage | 1 |
| Log files, structured logging system | log-analysis | 1 |
| Security/compliance policies (OWASP, GDPR) | compliance-audit | 1 |
| Large codebase, dead exports/orphaned files | dead-code-detection | 1 |
| IaC files (Terraform, CDK, Pulumi, Helm) | infrastructure-drift-detection | 1 |
| Incident log, oncall runbook | postmortem-assistant | 1 |
| Frequent test failures, debugging workflow | test-failure-explainer | 1 |
| Long-lived feature, complex git history | code-archaeology | 1 |

---

## Tier 1 — Pure Skills

Single `SKILL.md` per pattern. No agents or hooks required.
Install path: `.claude/skills/<pattern-name>/SKILL.md`
Source: `patterns/workflow-patterns/tier-1-pure-skills/<pattern>/SKILL.md`

---

### dependency-audit

**Detection signals:** `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`, `Gemfile`
**What it does:** Audits package dependencies for known vulnerabilities and license compliance.
**Files installed:**
```
.claude/skills/dependency-audit/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-1-pure-skills/dependency-audit/SKILL.md`

---

### template-instantiation

**Detection signals:** Repeated module structure, boilerplate directories, scaffold scripts, monorepo with similar packages
**What it does:** Scaffolds new modules from a canonical template, preserving conventions.
**Files installed:**
```
.claude/skills/template-instantiation/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-1-pure-skills/template-instantiation/SKILL.md`

---

### documentation-generation

**Detection signals:** Source files lacking docstrings/JSDoc, no `docs/` directory, missing `README.md` sections
**What it does:** Generates or updates documentation from source code, tests, and git history.
**Files installed:**
```
.claude/skills/documentation-generation/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-1-pure-skills/documentation-generation/SKILL.md`

---

### build-failure-triage

**Detection signals:** `.github/workflows/`, `Jenkinsfile`, CI/CD config, frequent build failures
**What it does:** Diagnoses CI/build failures by correlating error logs with recent commits.
**Files installed:**
```
.claude/skills/build-failure-triage/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-1-pure-skills/build-failure-triage/SKILL.md`

---

### log-analysis

**Detection signals:** `logs/` directory, structured logging (winston, pino, slog, loguru), ECS/JSON log format
**What it does:** Parses and summarizes log files for error patterns, performance anomalies, and trends.
**Files installed:**
```
.claude/skills/log-analysis/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-1-pure-skills/log-analysis/SKILL.md`

---

### compliance-audit

**Detection signals:** Auth/payment/PII code, GDPR/HIPAA requirements, security policies, `SECURITY.md`
**What it does:** Audits code against OWASP, GDPR, license, and custom compliance rules.
**Files installed:**
```
.claude/skills/compliance-audit/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-1-pure-skills/compliance-audit/SKILL.md`

---

### dead-code-detection

**Detection signals:** Large codebase (>500 files), long-lived project, TypeScript `noUnusedLocals` warnings, `--coverage` gaps
**What it does:** Finds unused exports, orphaned files, stale feature flags, unreachable branches.
**Files installed:**
```
.claude/skills/dead-code-detection/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-1-pure-skills/dead-code-detection/SKILL.md`

---

### infrastructure-drift-detection

**Detection signals:** `terraform/`, `cdk/`, `helm/`, `pulumi/`, `.tf` files, Kubernetes manifests
**What it does:** Compares live infrastructure state against IaC definitions to detect drift.
**Files installed:**
```
.claude/skills/infrastructure-drift-detection/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-1-pure-skills/infrastructure-drift-detection/SKILL.md`

---

### postmortem-assistant

**Detection signals:** `runbooks/`, `incidents/`, PagerDuty/Opsgenie integration, oncall rotation files
**What it does:** Generates structured 5-Why postmortems from incident timelines and log data.
**Files installed:**
```
.claude/skills/postmortem-assistant/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-1-pure-skills/postmortem-assistant/SKILL.md`

---

### test-failure-explainer

**Detection signals:** Flaky test history, test output logs saved, CI test failure artifacts
**What it does:** Explains test failures with root cause analysis and a fix suggestion, correlating with recent commits.
**Files installed:**
```
.claude/skills/test-failure-explainer/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-1-pure-skills/test-failure-explainer/SKILL.md`

---

### code-archaeology

**Detection signals:** Complex feature with long git history, recent regression in old code, "how did this get here?" questions
**What it does:** Traces a feature's full history through git log, blame, and commit messages to produce a narrative.
**Files installed:**
```
.claude/skills/code-archaeology/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-1-pure-skills/code-archaeology/SKILL.md`

---

## Tier 2 — Skill + Agents

`SKILL.md` plus one or more agent definition files. No hooks needed — isolation is enforced via `disallowedTools`.
Install path: `.claude/skills/<name>/SKILL.md` + `.claude/agents/<agent>.md`
Source: `patterns/workflow-patterns/tier-2-skill-plus-agents/<pattern>/`

---

### explore-then-implement

**Detection signals:** User requests research-before-code workflow; complex unfamiliar codebase; refactoring a poorly-understood module
**What it does:** Researcher agent (read-only) gathers full context first; implementer agent (write-capable) acts on the research. Never mixes the two roles.
**Files installed:**
```
.claude/skills/explore-implement/SKILL.md
.claude/agents/researcher.md
.claude/agents/implementer.md
```
**Source:** `patterns/workflow-patterns/tier-2-skill-plus-agents/explore-then-implement/`
**Key constraint:** `researcher.md` must have `disallowedTools: [Write, Edit, MultiEdit]`

---

### competitive-analysis

**Detection signals:** Multiple competing libraries/approaches to evaluate; architecture decision record needed; benchmark comparisons
**What it does:** Parallel source-researcher agents each study one target; analysis-synthesizer aggregates findings into a comparison report.
**Files installed:**
```
.claude/skills/competitive-analysis/SKILL.md
.claude/agents/source-researcher.md
.claude/agents/analysis-synthesizer.md
```
**Source:** `patterns/workflow-patterns/tier-2-skill-plus-agents/competitive-analysis/`

---

### contract-testing

**Detection signals:** Microservices, service-to-service HTTP calls, API versioning, frontend/backend split teams
**What it does:** Contract-extractor (read-only) scans frontend for API consumer shapes; contract-verifier (read-only) validates against backend routes.
**Files installed:**
```
.claude/skills/contract-test/SKILL.md
.claude/agents/contract-extractor.md
.claude/agents/contract-verifier.md
```
**Source:** `patterns/workflow-patterns/tier-2-skill-plus-agents/contract-testing/`

---

### spec-first-verification

**Detection signals:** `openapi.yaml`, `schema.graphql`, gRPC `.proto` files present
**What it does:** Spec-test-generator writes tests from the spec; spec-verifier runs them against the implementation and reports coverage gaps.
**Files installed:**
```
.claude/skills/spec-verify/SKILL.md
.claude/agents/spec-test-generator.md
.claude/agents/spec-verifier.md
```
**Source:** `patterns/workflow-patterns/tier-2-skill-plus-agents/spec-first-verification/`

---

### pr-review-pipeline

**Detection signals:** GitHub PR workflow active, `REVIEW.md` needed, multi-perspective review desired
**What it does:** Five specialist sub-agents (diff-analyzer, security-reviewer, style-checker, coverage-checker, review-summarizer) each review independently; summarizer aggregates.
**Files installed:**
```
.claude/skills/review-pr/SKILL.md
.claude/agents/diff-analyzer.md
.claude/agents/security-reviewer.md
.claude/agents/style-checker.md
.claude/agents/coverage-checker.md
.claude/agents/review-summarizer.md
```
**Source:** `patterns/workflow-patterns/tier-2-skill-plus-agents/pr-review-pipeline/`

---

### workflow-chaining

**Detection signals:** Multi-phase workflows (plan → implement → review), team handoffs, artifact-passing between sessions
**What it does:** Three linked skills that pass artifacts via `.claude/chain/`: `/plan-feature` writes `plan.md`, `/implement-feature` reads it and writes `result.md`, `/review-feature` reads both.
**Files installed:**
```
.claude/skills/plan-feature/SKILL.md
.claude/skills/implement-feature/SKILL.md
.claude/skills/review-feature/SKILL.md
```
**Source:** `patterns/workflow-patterns/tier-2-skill-plus-agents/workflow-chaining/`

---

### conditional-branching

**Detection signals:** Multiple languages or frameworks in one repo (TypeScript + Python, Go + JS), polyglot monorepos
**What it does:** Coordinator skill detects file type and delegates to the appropriate language-specialist sub-agent.
**Files installed:**
```
.claude/skills/auto-fix/SKILL.md
.claude/agents/ts-fixer.md
.claude/agents/py-fixer.md
.claude/agents/go-fixer.md
```
**Source:** `patterns/workflow-patterns/tier-2-skill-plus-agents/conditional-branching/`

---

## Tier 3 — Full Stack with Hooks

`SKILL.md` + agent files + hook scripts + `settings-fragment.json`.
The `settings-fragment.json` must be **merged** into `.claude/settings.json` (not replaced).
Hook scripts go in `.claude/hooks/` and must be made executable (`chmod +x`).

---

### sequential-pipeline

**Detection signals:** Full feature scaffold workflow (schema → entity → service → route → tests), CI/CD gating needed
**What it does:** Executes a strict stage-by-stage pipeline; `pipeline-gate.sh` (PostToolUse) blocks each stage if build/test fails.
**Files installed:**
```
.claude/skills/sequential-pipeline/SKILL.md
.claude/agents/schema-designer.md
.claude/agents/entity-builder.md
.claude/agents/service-builder.md
.claude/agents/route-builder.md
.claude/agents/test-writer.md
.claude/hooks/pipeline-gate.sh
.claude/hooks/notify-pipeline-complete.sh
```
**Hook event:** `PostToolUse` (Write|Edit|MultiEdit)
**Source:** `patterns/workflow-patterns/tier-3-full-stack/sequential-pipeline/`

---

### parallel-fan-out-fan-in

**Detection signals:** Large number of independent units to analyze (packages, modules, endpoints), monorepo analysis
**What it does:** Coordinator fans out to parallel worker agents; `track-worker-completion.sh` (SubagentStop) tracks when all workers finish; fan-in aggregator runs.
**Files installed:**
```
.claude/skills/fan-out-fan-in/SKILL.md
.claude/agents/parallel-worker.md
.claude/agents/result-merger.md
.claude/hooks/track-worker-completion.sh
```
**Hook event:** `SubagentStop`
**Source:** `patterns/workflow-patterns/tier-3-full-stack/parallel-fan-out-fan-in/`

---

### self-reflection-loop

**Detection signals:** Quality gates needed, code review before delivery, critic-before-ship requirement
**What it does:** Implementer sub-agent writes code; `check-review-score.sh` (SubagentStop) reads critic's JSON score and blocks session stop if score < 4.
**Files installed:**
```
.claude/skills/self-reflect/SKILL.md
.claude/agents/loop-implementer.md
.claude/agents/loop-reviewer.md
.claude/hooks/check-review-score.sh
```
**Hook event:** `SubagentStop`
**Source:** `patterns/workflow-patterns/tier-3-full-stack/self-reflection-loop/`

---

### human-in-the-loop-approval

**Detection signals:** Destructive operations (deploys, DB drops, bulk deletes), regulated environments, compliance requirements
**What it does:** `require-approval.sh` (PreToolUse) blocks dangerous Bash commands unless `.claude/approval/approved` sentinel file exists.
**Files installed:**
```
.claude/skills/approve-then-deploy/SKILL.md
.claude/hooks/require-approval.sh
```
**Hook event:** `PreToolUse` (Bash)
**Source:** `patterns/workflow-patterns/tier-3-full-stack/human-in-the-loop-approval/`

---

### staged-rollout-gate

**Detection signals:** Multi-environment deploy (dev → staging → production), environment promotion workflow
**What it does:** `rollout-gate.sh` (PreToolUse) enforces environment promotion order; blocks prod deploy without staging sentinel.
**Files installed:**
```
.claude/skills/staged-rollout/SKILL.md
.claude/hooks/rollout-gate.sh
```
**Hook event:** `PreToolUse` (Bash)
**Source:** `patterns/workflow-patterns/tier-3-full-stack/staged-rollout-gate/`

---

### cost-threshold-gate

**Detection signals:** Large LLM usage, expensive API calls, budget-sensitive operations
**What it does:** `cost-gate.sh` (PreToolUse) estimates cumulative cost and blocks tool calls if budget exceeded. Requires `jq`.
**Files installed:**
```
.claude/skills/cost-aware-task/SKILL.md
.claude/hooks/cost-gate.sh
```
**Hook event:** `PreToolUse` (all tools)
**Source:** `patterns/workflow-patterns/tier-3-full-stack/cost-threshold-gate/`

---

### incremental-migration

**Detection signals:** Large-scale migration (many modules), monorepo package upgrades, library version bumps across packages
**What it does:** Migrates one module at a time; `migration-gate.sh` (PostToolUse) runs full test suite after each module and blocks if any test fails.
**Files installed:**
```
.claude/skills/incremental-migrate/SKILL.md
.claude/agents/module-migrator.md
.claude/hooks/migration-gate.sh
```
**Hook event:** `PostToolUse` (Write|Edit|MultiEdit)
**Source:** `patterns/workflow-patterns/tier-3-full-stack/incremental-migration/`

---

### pattern-replacement

**Detection signals:** Cross-codebase refactoring, API renaming, import path changes, deprecated pattern cleanup
**What it does:** pattern-finder locates all instances; pattern-replacer fixes one file at a time; `refactor-lint.sh` (PostToolUse) runs lint + compile after each file.
**Files installed:**
```
.claude/skills/replace-pattern/SKILL.md
.claude/agents/pattern-finder.md
.claude/agents/pattern-replacer.md
.claude/hooks/refactor-lint.sh
```
**Hook event:** `PostToolUse` (Write|Edit|MultiEdit)
**Source:** `patterns/workflow-patterns/tier-3-full-stack/pattern-replacement/`

---

### database-schema-evolution

**Detection signals:** ORM detected (Prisma, Drizzle, Alembic, GORM, Ecto), `migrations/` directory, schema change needed
**What it does:** `require-reversible-migration.sh` (PreToolUse) blocks migration rollout unless a down migration exists.
**Files installed:**
```
.claude/skills/schema-evolve/SKILL.md
.claude/agents/schema-designer.md
.claude/agents/migration-generator.md
.claude/agents/compat-checker.md
.claude/hooks/require-reversible-migration.sh
```
**Hook event:** `PreToolUse` (Bash)
**Source:** `patterns/workflow-patterns/tier-3-full-stack/database-schema-evolution/`

---

### regression-sweep

**Detection signals:** Test suite present, refactoring about to happen, no test baseline tracking
**What it does:** `capture-baseline.sh` (PreToolUse) captures test results BEFORE the first edit; after changes, compares results to identify regressions.
**Files installed:**
```
.claude/skills/regression-sweep/SKILL.md
.claude/agents/regression-differ.md
.claude/hooks/capture-baseline.sh
```
**Hook event:** `PreToolUse` (Write|Edit)
**Source:** `patterns/workflow-patterns/tier-3-full-stack/regression-sweep/`

---

### api-client-generation

**Detection signals:** OpenAPI spec, gRPC proto, GraphQL schema; TypeScript/Go/Python typed client needed
**What it does:** Generates typed client code from spec; `typecheck-generated.sh` (PostToolUse) type-checks each generated file immediately after writing.
**Files installed:**
```
.claude/skills/generate-client/SKILL.md
.claude/agents/client-generator.md
.claude/hooks/typecheck-generated.sh
```
**Hook event:** `PostToolUse` (Write)
**Source:** `patterns/workflow-patterns/tier-3-full-stack/api-client-generation/`

---

### watchdog-loop

**Detection signals:** Threshold monitoring needed (bundle size, test pass rate, dependency freshness), alerting on session end
**What it does:** Runs health checks each iteration; `watchdog-notify.sh` (Stop) fires on session end if any threshold was violated.
**Files installed:**
```
.claude/skills/watchdog/SKILL.md
.claude/agents/health-checker.md
.claude/hooks/watchdog-notify.sh
```
**Hook event:** `Stop`
**Source:** `patterns/workflow-patterns/tier-3-full-stack/watchdog-loop/`

---

### environment-parity-check

**Detection signals:** Multiple `.env.*` files, environment drift risk, staging/prod config divergence
**What it does:** Compares env configs against baseline; `block-promotion-on-drift.sh` (PreToolUse) blocks deployment if parity report shows drift.
**Files installed:**
```
.claude/skills/env-parity/SKILL.md
.claude/agents/env-parity-checker.md
.claude/hooks/block-promotion-on-drift.sh
```
**Hook event:** `PreToolUse` (Bash)
**Source:** `patterns/workflow-patterns/tier-3-full-stack/environment-parity-check/`

---

### secret-rotation

**Detection signals:** Credentials detected in codebase, secrets management workflow needed, API key rotation
**What it does:** `require-health-before-revoke.sh` (PreToolUse) blocks credential revocation unless a health check has passed first.
**Files installed:**
```
.claude/skills/rotate-secret/SKILL.md
.claude/agents/secret-finder.md
.claude/hooks/require-health-before-revoke.sh
```
**Hook event:** `PreToolUse` (Bash)
**Source:** `patterns/workflow-patterns/tier-3-full-stack/secret-rotation/`

---

### map-reduce

**Detection signals:** Batch processing, large dataset analysis, fan-out aggregation over many items
**What it does:** Coordinator fans out to parallel mr-worker agents; `mr-track-completion.sh` (SubagentStop) tracks completions; mr-reducer aggregates.
**Files installed:**
```
.claude/skills/map-reduce/SKILL.md
.claude/agents/mr-worker.md
.claude/agents/mr-reducer.md
.claude/hooks/mr-track-completion.sh
```
**Hook event:** `SubagentStop`
**Source:** `patterns/workflow-patterns/tier-3-full-stack/map-reduce/`

---

## Installation Instructions

### Tier 1 — Copy SKILL.md

```bash
# From the project root:
mkdir -p .claude/skills/<pattern-name>
cp patterns/workflow-patterns/tier-1-pure-skills/<pattern>/SKILL.md \
   .claude/skills/<pattern-name>/SKILL.md
```

### Tier 2 — Copy SKILL.md + agents

```bash
mkdir -p .claude/skills/<pattern-name>
cp patterns/workflow-patterns/tier-2-skill-plus-agents/<pattern>/SKILL.md \
   .claude/skills/<pattern-name>/SKILL.md
cp patterns/workflow-patterns/tier-2-skill-plus-agents/<pattern>/agents/*.md \
   .claude/agents/
```

### Tier 3 — Copy SKILL.md + agents + hooks, then merge settings

```bash
# 1. Copy skill
mkdir -p .claude/skills/<pattern-name>
cp patterns/workflow-patterns/tier-3-full-stack/<pattern>/SKILL.md \
   .claude/skills/<pattern-name>/SKILL.md

# 2. Copy agents (if any)
cp patterns/workflow-patterns/tier-3-full-stack/<pattern>/agents/*.md \
   .claude/agents/ 2>/dev/null || true

# 3. Copy and chmod hook scripts
cp patterns/workflow-patterns/tier-3-full-stack/<pattern>/hooks/*.sh \
   .claude/hooks/
chmod +x .claude/hooks/*.sh

# 4. Preview settings fragment (do NOT blindly overwrite)
cat patterns/workflow-patterns/tier-3-full-stack/<pattern>/settings-fragment.json
# Manually merge hooks[] and permissions{} into .claude/settings.json
```

### Merging settings-fragment.json

The `settings-fragment.json` contains `permissions` and `hooks` sections that must be **merged** into the existing `.claude/settings.json`. Never overwrite — the existing file may already have hooks and permissions.

**Merge strategy:**
- `permissions.allow` — append new entries (deduplicate)
- `permissions.ask` — append new entries (deduplicate)
- `permissions.deny` — append new entries (deduplicate)
- `hooks.<EventName>[]` — append new hook matchers (check for duplicates)

**Verify registration after merge:**
```bash
# In Claude Code session:
/hooks    # verify hooks registered
/agents   # verify agents registered
```
