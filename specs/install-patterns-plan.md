# Install Patterns Plan

## Metadata

| Field | Value |
|-------|-------|
| Project | cc-customize |
| Purpose | Install all 33 workflow patterns from the pattern library into `.claude/` |
| Date | 2026-03-29 |
| Methodology | Continuous Agent Loop |
| Architecture Spec | `architecture/claude-code-customization-architecture.md` |
| Pattern Library | `patterns/workflow-patterns/` |
| Install Skill | `.claude/skills/install-pattern/SKILL.md` |

---

## Table of Contents

- [Conventions](#conventions)
- [Phase 1 — Pattern Installation](#phase-1--pattern-installation)
  - [Tier 1 Patterns (P1-001 through P1-011)](#tier-1-patterns)
  - [Tier 2 Patterns (P1-012 through P1-018)](#tier-2-patterns)
  - [Tier 3 Patterns (P1-019 through P1-033)](#tier-3-patterns)
- [Phase 2 — AGENTS.md Generation](#phase-2--agentsmd-generation)
  - [P2-001 — Create or Update AGENTS.md](#task-p2-001--create-or-update-agentsmd)
- [Phase 3 — Documentation Generation](#phase-3--documentation-generation)
  - [P3-001 through P3-033 — Per-pattern User Guides](#tier-1-documentation)
  - [P3-DOC-INDEX — Documentation Index](#task-p3-doc-index--generate-docsuser-guidereadmemd-index)
- [Phase 4 — Project Root Files](#phase-4--project-root-files)
  - [P4-001 — Update CLAUDE.MD](#task-p4-001--update-or-generate-claudemd)
  - [P4-002 — Update README.md](#task-p4-002--update-or-generate-readmemd)

---

## Conventions

### Execution Annotations

Each task is annotated with an execution mode:

- **PARALLEL** — Task has no dependencies on other tasks in the same phase (or depends only on a prior phase). The continuous-agent-loop executor may batch these tasks across multiple sub-agents.
- **SEQUENTIAL** — Task depends on the output of one or more prior tasks. Must wait for dependencies to complete.

### Done Check Format

Every task includes a `Done Check` field containing a concrete, runnable shell expression. The executor runs this before starting the task:
- If the check **passes** (exit 0), the task is **skipped** (already complete).
- If the check **fails** (non-zero exit), the task **executes**.

### Idempotency

All tasks begin with a done check. Re-running the plan after a partial failure resumes from where it stopped. Tasks that copy files overwrite existing versions (safe to re-run).

### Install-Pattern Skill Invocation

The install-pattern skill is invoked as:

```
/install-pattern <pattern-name> <tier>
```

It performs: locate pattern source -> create target directories -> copy SKILL.md -> copy agents (Tier 2/3) -> copy hooks (Tier 3) -> merge settings-fragment.json -> verify installation.

Source: `.claude/skills/install-pattern/SKILL.md`

---

## Phase 1 — Pattern Installation

**Completion Criterion:** All 33 workflow patterns are installed into `.claude/`. Every `Done Check` in this phase passes.

### Tier 1 Patterns

Tier 1 patterns consist of a single SKILL.md file. No agents, hooks, or settings are required.

---

### TASK P1-001 — Install Dependency Audit (Tier 1)

| Field | Value |
|-------|-------|
| ID | P1-001 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-1-pure-skills/dependency-audit/SKILL.md` |
| Outputs | `.claude/skills/dependency-audit/SKILL.md` |
| Done Check | `[[ -f .claude/skills/dependency-audit/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern dependency-audit 1`
3. Verify installed file exists at `.claude/skills/dependency-audit/SKILL.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes:** Pure read-only analysis pattern. Single agent reads manifests, runs audit, produces report. No special configuration required.

---

### TASK P1-002 — Install Template Instantiation (Tier 1)

| Field | Value |
|-------|-------|
| ID | P1-002 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-1-pure-skills/template-instantiation/SKILL.md` |
| Outputs | `.claude/skills/template-instantiation/SKILL.md` |
| Done Check | `[[ -f .claude/skills/template-instantiation/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern template-instantiation 1`
3. Verify installed file exists at `.claude/skills/template-instantiation/SKILL.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes:** Single agent reads conventions and creates files from templates. No special configuration required.

---

### TASK P1-003 — Install Documentation Generation (Tier 1)

| Field | Value |
|-------|-------|
| ID | P1-003 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-1-pure-skills/documentation-generation/SKILL.md` |
| Outputs | `.claude/skills/documentation-generation/SKILL.md` |
| Done Check | `[[ -f .claude/skills/documentation-generation/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern documentation-generation 1`
3. Verify installed file exists at `.claude/skills/documentation-generation/SKILL.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes:** Single read-only analysis — reads source, tests, git log. No special configuration required.

---

### TASK P1-004 — Install Build Failure Triage (Tier 1)

| Field | Value |
|-------|-------|
| ID | P1-004 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-1-pure-skills/build-failure-triage/SKILL.md` |
| Outputs | `.claude/skills/build-failure-triage/SKILL.md` |
| Done Check | `[[ -f .claude/skills/build-failure-triage/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern build-failure-triage 1`
3. Verify installed file exists at `.claude/skills/build-failure-triage/SKILL.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes:** Single read-only analysis of failure logs and git history. No special configuration required.

---

### TASK P1-005 — Install Log Analysis (Tier 1)

| Field | Value |
|-------|-------|
| ID | P1-005 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-1-pure-skills/log-analysis/SKILL.md` |
| Outputs | `.claude/skills/log-analysis/SKILL.md` |
| Done Check | `[[ -f .claude/skills/log-analysis/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern log-analysis 1`
3. Verify installed file exists at `.claude/skills/log-analysis/SKILL.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes:** Single read-only analysis using Bash preprocessing tools. No special configuration required.

---

### TASK P1-006 — Install Compliance Audit (Tier 1)

| Field | Value |
|-------|-------|
| ID | P1-006 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-1-pure-skills/compliance-audit/SKILL.md` |
| Outputs | `.claude/skills/compliance-audit/SKILL.md` |
| Done Check | `[[ -f .claude/skills/compliance-audit/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern compliance-audit 1`
3. Verify installed file exists at `.claude/skills/compliance-audit/SKILL.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes:** Single read-only scan against ruleset. No special configuration required.

---

### TASK P1-007 — Install Dead Code Detection (Tier 1)

| Field | Value |
|-------|-------|
| ID | P1-007 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-1-pure-skills/dead-code-detection/SKILL.md` |
| Outputs | `.claude/skills/dead-code-detection/SKILL.md` |
| Done Check | `[[ -f .claude/skills/dead-code-detection/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern dead-code-detection 1`
3. Verify installed file exists at `.claude/skills/dead-code-detection/SKILL.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes:** Single read-only analysis using grep/find and code reading. No special configuration required.

---

### TASK P1-008 — Install Infrastructure Drift Detection (Tier 1)

| Field | Value |
|-------|-------|
| ID | P1-008 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-1-pure-skills/infrastructure-drift-detection/SKILL.md` |
| Outputs | `.claude/skills/infrastructure-drift-detection/SKILL.md` |
| Done Check | `[[ -f .claude/skills/infrastructure-drift-detection/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern infrastructure-drift-detection 1`
3. Verify installed file exists at `.claude/skills/infrastructure-drift-detection/SKILL.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes:** Single read-only analysis with deny list in permissions fragment. No special configuration required beyond the skill itself.

---

### TASK P1-009 — Install Postmortem Assistant (Tier 1)

| Field | Value |
|-------|-------|
| ID | P1-009 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-1-pure-skills/postmortem-assistant/SKILL.md` |
| Outputs | `.claude/skills/postmortem-assistant/SKILL.md` |
| Done Check | `[[ -f .claude/skills/postmortem-assistant/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern postmortem-assistant 1`
3. Verify installed file exists at `.claude/skills/postmortem-assistant/SKILL.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes:** Single read-only analysis of incident data. No special configuration required.

---

### TASK P1-010 — Install Test Failure Explainer (Tier 1)

| Field | Value |
|-------|-------|
| ID | P1-010 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-1-pure-skills/test-failure-explainer/SKILL.md` |
| Outputs | `.claude/skills/test-failure-explainer/SKILL.md` |
| Done Check | `[[ -f .claude/skills/test-failure-explainer/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern test-failure-explainer 1`
3. Verify installed file exists at `.claude/skills/test-failure-explainer/SKILL.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes:** Single read-only analysis — git log + error output produces explanation. No special configuration required.

---

### TASK P1-011 — Install Code Archaeology (Tier 1)

| Field | Value |
|-------|-------|
| ID | P1-011 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-1-pure-skills/code-archaeology/SKILL.md` |
| Outputs | `.claude/skills/code-archaeology/SKILL.md` |
| Done Check | `[[ -f .claude/skills/code-archaeology/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern code-archaeology 1`
3. Verify installed file exists at `.claude/skills/code-archaeology/SKILL.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes:** Single read-only analysis — git history produces narrative. No special configuration required.

---

### Tier 2 Patterns

Tier 2 patterns consist of SKILL.md plus sub-agent definitions in `agents/`. No hooks or settings-fragment.json are required (though some include optional permissions in their PATTERN.md).

---

### TASK P1-012 — Install Explore-then-Implement (Tier 2)

| Field | Value |
|-------|-------|
| ID | P1-012 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-2-skill-plus-agents/explore-then-implement/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/explore-then-implement/agents/researcher.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/explore-then-implement/agents/implementer.md` |
| Outputs | `.claude/skills/explore-implement/SKILL.md`, `.claude/agents/researcher.md`, `.claude/agents/implementer.md` |
| Done Check | `[[ -f .claude/skills/explore-implement/SKILL.md ]] && [[ -f .claude/agents/researcher.md ]] && [[ -f .claude/agents/implementer.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern explore-then-implement 2`
3. Verify installed files:
   - `.claude/skills/explore-implement/SKILL.md`
   - `.claude/agents/researcher.md`
   - `.claude/agents/implementer.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Create `.claude/research-output/` directory if not present
6. Confirm done check now passes

**Notes from PATTERN.md:**

- Researcher has `disallowedTools: [Write, Edit, MultiEdit]` — physical enforcement, not prompt instruction.
- Implementer is write-capable and works from research output.
- Optional permissions in `.claude/settings.json` for build/test/search commands.
- Skill name in target is `explore-implement` (not `explore-then-implement`).

---

### TASK P1-013 — Install Competitive Analysis (Tier 2)

| Field | Value |
|-------|-------|
| ID | P1-013 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-2-skill-plus-agents/competitive-analysis/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/competitive-analysis/agents/source-researcher.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/competitive-analysis/agents/analysis-synthesizer.md` |
| Outputs | `.claude/skills/competitive-analysis/SKILL.md`, `.claude/agents/source-researcher.md`, `.claude/agents/analysis-synthesizer.md` |
| Done Check | `[[ -f .claude/skills/competitive-analysis/SKILL.md ]] && [[ -f .claude/agents/source-researcher.md ]] && [[ -f .claude/agents/analysis-synthesizer.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern competitive-analysis 2`
3. Verify installed files:
   - `.claude/skills/competitive-analysis/SKILL.md`
   - `.claude/agents/source-researcher.md`
   - `.claude/agents/analysis-synthesizer.md`
4. Create `.claude/analysis/` directory if not present
5. Validate installed SKILL.md with markdown-formatting skill
6. Confirm done check now passes

**Notes from PATTERN.md:**

- Both agents have `disallowedTools: [Write, Edit, MultiEdit]` — read-only enforcement.
- Synthesizer uses `claude-opus-4-5` for stronger reasoning.
- Researchers run in parallel with isolated contexts.

---

### TASK P1-014 — Install Contract Testing (Tier 2)

| Field | Value |
|-------|-------|
| ID | P1-014 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-2-skill-plus-agents/contract-testing/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/contract-testing/agents/contract-extractor.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/contract-testing/agents/contract-verifier.md` |
| Outputs | `.claude/skills/contract-test/SKILL.md`, `.claude/agents/contract-extractor.md`, `.claude/agents/contract-verifier.md` |
| Done Check | `[[ -f .claude/skills/contract-test/SKILL.md ]] && [[ -f .claude/agents/contract-extractor.md ]] && [[ -f .claude/agents/contract-verifier.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern contract-testing 2`
3. Verify installed files:
   - `.claude/skills/contract-test/SKILL.md`
   - `.claude/agents/contract-extractor.md`
   - `.claude/agents/contract-verifier.md`
4. Create `.claude/contracts/` directory if not present
5. Validate installed SKILL.md with markdown-formatting skill
6. Confirm done check now passes

**Notes from PATTERN.md:**

- Both agents are read-only (`disallowedTools: [Write, Edit, MultiEdit]`).
- Skill name in target is `contract-test` (not `contract-testing`).
- Extractor scans frontend, verifier checks backend — separate contexts.

---

### TASK P1-015 — Install Spec-First Verification (Tier 2)

| Field | Value |
|-------|-------|
| ID | P1-015 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-2-skill-plus-agents/spec-first-verification/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/spec-first-verification/agents/spec-test-generator.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/spec-first-verification/agents/spec-verifier.md` |
| Outputs | `.claude/skills/spec-verify/SKILL.md`, `.claude/agents/spec-test-generator.md`, `.claude/agents/spec-verifier.md` |
| Done Check | `[[ -f .claude/skills/spec-verify/SKILL.md ]] && [[ -f .claude/agents/spec-test-generator.md ]] && [[ -f .claude/agents/spec-verifier.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern spec-first-verification 2`
3. Verify installed files:
   - `.claude/skills/spec-verify/SKILL.md`
   - `.claude/agents/spec-test-generator.md`
   - `.claude/agents/spec-verifier.md`
4. Create `.claude/spec/` directory if not present
5. Validate installed SKILL.md with markdown-formatting skill
6. Confirm done check now passes

**Notes from PATTERN.md:**

- Verifier has `disallowedTools: [Write, Edit, MultiEdit]` — cannot modify source to make tests pass.
- Test generator writes only to `tests/spec-verification/`.
- Skill name in target is `spec-verify`.

---

### TASK P1-016 — Install PR Review Pipeline (Tier 2)

| Field | Value |
|-------|-------|
| ID | P1-016 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-2-skill-plus-agents/pr-review-pipeline/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/pr-review-pipeline/agents/diff-analyzer.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/pr-review-pipeline/agents/security-reviewer.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/pr-review-pipeline/agents/style-checker.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/pr-review-pipeline/agents/coverage-checker.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/pr-review-pipeline/agents/review-summarizer.md` |
| Outputs | `.claude/skills/review-pr/SKILL.md`, `.claude/agents/diff-analyzer.md`, `.claude/agents/security-reviewer.md`, `.claude/agents/style-checker.md`, `.claude/agents/coverage-checker.md`, `.claude/agents/review-summarizer.md` |
| Done Check | `[[ -f .claude/skills/review-pr/SKILL.md ]] && [[ -f .claude/agents/diff-analyzer.md ]] && [[ -f .claude/agents/security-reviewer.md ]] && [[ -f .claude/agents/review-summarizer.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern pr-review-pipeline 2`
3. Verify installed files:
   - `.claude/skills/review-pr/SKILL.md`
   - `.claude/agents/diff-analyzer.md`
   - `.claude/agents/security-reviewer.md`
   - `.claude/agents/style-checker.md`
   - `.claude/agents/coverage-checker.md`
   - `.claude/agents/review-summarizer.md`
4. Create `.claude/review/` directory if not present
5. Validate installed SKILL.md with markdown-formatting skill
6. Confirm done check now passes

**Notes from PATTERN.md:**

- All five agents are read-only (`disallowedTools: [Write, Edit, MultiEdit]`).
- `security-reviewer` and `review-summarizer` use `claude-opus-4-5` for higher accuracy.
- Skill name in target is `review-pr`.
- Optional permissions for git diff/log/show and test commands.

---

### TASK P1-017 — Install Workflow Chaining (Tier 2)

| Field | Value |
|-------|-------|
| ID | P1-017 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-2-skill-plus-agents/workflow-chaining/plan-feature/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/workflow-chaining/implement-feature/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/workflow-chaining/review-feature/SKILL.md` |
| Outputs | `.claude/skills/plan-feature/SKILL.md`, `.claude/skills/implement-feature/SKILL.md`, `.claude/skills/review-feature/SKILL.md` |
| Done Check | `[[ -f .claude/skills/plan-feature/SKILL.md ]] && [[ -f .claude/skills/implement-feature/SKILL.md ]] && [[ -f .claude/skills/review-feature/SKILL.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern workflow-chaining 2`
3. Verify installed files:
   - `.claude/skills/plan-feature/SKILL.md`
   - `.claude/skills/implement-feature/SKILL.md`
   - `.claude/skills/review-feature/SKILL.md`
4. Create `.claude/chain/` directory for artifact exchange
5. Validate all three SKILL.md files with markdown-formatting skill
6. Confirm done check now passes

**Notes from PATTERN.md:**

- This is a Tier 2 variant with **no agents/ directory** — uses three linked skills instead.
- Chain artifacts stored in `.claude/chain/`: `plan.md` and `result.md`.
- `plan-feature` cleans the chain directory before each new feature.
- CLAUDE.md should document the chaining convention (added in Phase 4).
- Optional permissions for build/test and chain directory access.

---

### TASK P1-018 — Install Conditional Branching (Tier 2)

| Field | Value |
|-------|-------|
| ID | P1-018 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-2-skill-plus-agents/conditional-branching/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/conditional-branching/agents/ts-fixer.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/conditional-branching/agents/py-fixer.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/conditional-branching/agents/go-fixer.md` |
| Outputs | `.claude/skills/auto-fix/SKILL.md`, `.claude/agents/ts-fixer.md`, `.claude/agents/py-fixer.md`, `.claude/agents/go-fixer.md` |
| Done Check | `[[ -f .claude/skills/auto-fix/SKILL.md ]] && [[ -f .claude/agents/ts-fixer.md ]] && [[ -f .claude/agents/py-fixer.md ]] && [[ -f .claude/agents/go-fixer.md ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern conditional-branching 2`
3. Verify installed files:
   - `.claude/skills/auto-fix/SKILL.md`
   - `.claude/agents/ts-fixer.md`
   - `.claude/agents/py-fixer.md`
   - `.claude/agents/go-fixer.md`
4. Validate installed SKILL.md with markdown-formatting skill
5. Confirm done check now passes

**Notes from PATTERN.md:**

- Specialists are write-capable (they apply fixes). No `disallowedTools`.
- Skill name in target is `auto-fix`.
- Coordinator detects project type then dispatches the appropriate specialist.
- Extensible: add new language specialists by adding agent files and detection rules.
- Optional permissions for build/test per language ecosystem.

---

### Tier 3 Patterns

Tier 3 patterns consist of SKILL.md, sub-agent definitions, hook scripts, and a settings-fragment.json that must be merged into `.claude/settings.json`.

---

### TASK P1-019 — Install Sequential Pipeline (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-019 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/sequential-pipeline/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/sequential-pipeline/agents/*.md`, `patterns/workflow-patterns/tier-3-full-stack/sequential-pipeline/hooks/*.sh`, `patterns/workflow-patterns/tier-3-full-stack/sequential-pipeline/settings-fragment.json` |
| Outputs | `.claude/skills/sequential-pipeline/SKILL.md`, `.claude/agents/schema-designer.md`, `.claude/agents/entity-builder.md`, `.claude/agents/service-builder.md`, `.claude/agents/route-builder.md`, `.claude/agents/test-writer.md`, `.claude/hooks/pipeline-gate.sh`, `.claude/hooks/notify-pipeline-complete.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/sequential-pipeline/SKILL.md ]] && [[ -f .claude/hooks/pipeline-gate.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern sequential-pipeline 3`
3. Verify installed files:
   - `.claude/skills/sequential-pipeline/SKILL.md`
   - `.claude/agents/schema-designer.md`, `entity-builder.md`, `service-builder.md`, `route-builder.md`, `test-writer.md`
   - `.claude/hooks/pipeline-gate.sh` (executable)
   - `.claude/hooks/notify-pipeline-complete.sh` (executable)
4. Verify settings-fragment.json merged into `.claude/settings.json`
5. Validate installed SKILL.md with markdown-formatting skill
6. Confirm done check now passes

**Notes from PATTERN.md:**

- 5 agents (schema-designer, entity-builder, service-builder, route-builder, test-writer).
- `pipeline-gate.sh` (PostToolUse): gates each stage on `pnpm build --silent` pass.
- `notify-pipeline-complete.sh` (Stop): logs completion, optional Slack notification via `${SLACK_WEBHOOK_URL}`.
- Prerequisite: pnpm build environment must be configured.

---

### TASK P1-020 — Install Parallel Fan-out / Fan-in (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-020 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/parallel-fan-out-fan-in/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/parallel-fan-out-fan-in/agents/*.md`, `patterns/workflow-patterns/tier-3-full-stack/parallel-fan-out-fan-in/hooks/*.sh`, `patterns/workflow-patterns/tier-3-full-stack/parallel-fan-out-fan-in/settings-fragment.json` |
| Outputs | `.claude/skills/fan-out-fan-in/SKILL.md`, `.claude/agents/parallel-worker.md`, `.claude/agents/result-merger.md`, `.claude/hooks/track-worker-completion.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/fan-out-fan-in/SKILL.md ]] && [[ -f .claude/hooks/track-worker-completion.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern parallel-fan-out-fan-in 3`
3. Verify installed files:
   - `.claude/skills/fan-out-fan-in/SKILL.md`
   - `.claude/agents/parallel-worker.md`, `result-merger.md`
   - `.claude/hooks/track-worker-completion.sh` (executable)
4. Verify settings-fragment.json merged into `.claude/settings.json`
5. Validate installed SKILL.md with markdown-formatting skill
6. Confirm done check now passes

**Notes from PATTERN.md:**

- `result-merger` has `disallowedTools: [Edit, MultiEdit]` (read-only).
- `track-worker-completion.sh` (SubagentStop): appends JSON record to `completion-log.jsonl`.
- Skill name in target is `fan-out-fan-in`.

---

### TASK P1-021 — Install Self-Reflection Loop (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-021 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/self-reflection-loop/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/self-reflection-loop/agents/*.md`, `patterns/workflow-patterns/tier-3-full-stack/self-reflection-loop/hooks/*.sh`, `patterns/workflow-patterns/tier-3-full-stack/self-reflection-loop/settings-fragment.json` |
| Outputs | `.claude/skills/self-reflect/SKILL.md`, `.claude/agents/code-critic.md`, `.claude/hooks/check-review-score.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/self-reflect/SKILL.md ]] && [[ -f .claude/hooks/check-review-score.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern self-reflection-loop 3`
3. Verify installed files:
   - `.claude/skills/self-reflect/SKILL.md`
   - `.claude/agents/code-critic.md`
   - `.claude/hooks/check-review-score.sh` (executable)
4. Verify settings-fragment.json merged into `.claude/settings.json`
5. Validate installed SKILL.md with markdown-formatting skill
6. Confirm done check now passes

**Notes from PATTERN.md:**

- `code-critic` is read-only (`disallowedTools: [Write, Edit, MultiEdit]`) and uses `claude-opus-4-5`.
- `check-review-score.sh` (SubagentStop): reads `.claude/review-score.json`, exits 2 if score < 4.
- Skill name in target is `self-reflect`.
- Prerequisite: `claude-opus-4-5` model available for critic agent.

---

### TASK P1-022 — Install Human-in-the-Loop Approval (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-022 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/human-in-the-loop-approval/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/human-in-the-loop-approval/hooks/require-approval.sh`, `patterns/workflow-patterns/tier-3-full-stack/human-in-the-loop-approval/settings-fragment.json` |
| Outputs | `.claude/skills/approve-then-deploy/SKILL.md`, `.claude/hooks/require-approval.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/approve-then-deploy/SKILL.md ]] && [[ -f .claude/hooks/require-approval.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern human-in-the-loop-approval 3`
3. Verify installed files:
   - `.claude/skills/approve-then-deploy/SKILL.md`
   - `.claude/hooks/require-approval.sh` (executable)
4. Create `.claude/approval/` directory for sentinel file
5. Verify settings-fragment.json merged into `.claude/settings.json`
6. Validate installed SKILL.md with markdown-formatting skill
7. Confirm done check now passes

**Notes from PATTERN.md:**

- No agents — this pattern uses only a skill + hook.
- `require-approval.sh` (PreToolUse): blocks destructive commands (deploy, migrate, kubectl apply, terraform apply, docker push, npm/pnpm publish) unless `.claude/approval/approved` sentinel file exists.
- Skill name in target is `approve-then-deploy`.
- Customizable: edit `destructive_patterns` array in hook to add custom commands.

---

### TASK P1-023 — Install Staged Rollout Gate (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-023 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/staged-rollout-gate/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/staged-rollout-gate/agents/*.md`, `patterns/workflow-patterns/tier-3-full-stack/staged-rollout-gate/hooks/*.sh`, `patterns/workflow-patterns/tier-3-full-stack/staged-rollout-gate/settings-fragment.json` |
| Outputs | `.claude/skills/staged-rollout/SKILL.md`, `.claude/agents/env-deployer.md`, `.claude/hooks/rollout-gate.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/staged-rollout/SKILL.md ]] && [[ -f .claude/hooks/rollout-gate.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern staged-rollout-gate 3`
3. Verify installed files:
   - `.claude/skills/staged-rollout/SKILL.md`
   - `.claude/agents/env-deployer.md`
   - `.claude/hooks/rollout-gate.sh` (executable)
4. Create `.claude/rollout/` directory
5. Verify settings-fragment.json merged into `.claude/settings.json`
6. Validate installed SKILL.md with markdown-formatting skill
7. Confirm done check now passes

**Notes from PATTERN.md:**

- `env-deployer` has `disallowedTools: [Write, Edit, MultiEdit]` (executes commands only).
- `rollout-gate.sh` (PreToolUse): enforces environment promotion order (dev -> staging -> production). Requires `dev-result.json` with `status: success` for staging, and `staging-result.json` + `production-approved` sentinel for production.
- Skill name in target is `staged-rollout`.

---

### TASK P1-024 — Install Cost-Threshold Gate (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-024 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/cost-threshold-gate/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/cost-threshold-gate/hooks/cost-gate.sh`, `patterns/workflow-patterns/tier-3-full-stack/cost-threshold-gate/settings-fragment.json` |
| Outputs | `.claude/skills/cost-aware-task/SKILL.md`, `.claude/hooks/cost-gate.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/cost-aware-task/SKILL.md ]] && [[ -f .claude/hooks/cost-gate.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern cost-threshold-gate 3`
3. Verify installed files:
   - `.claude/skills/cost-aware-task/SKILL.md`
   - `.claude/hooks/cost-gate.sh` (executable)
4. Initialize budget file: `echo '{"budget_tokens":100000,"spent_tokens":0}' > .claude/budget.json`
5. Verify settings-fragment.json merged into `.claude/settings.json`
6. Validate installed SKILL.md with markdown-formatting skill
7. Confirm done check now passes

**Notes from PATTERN.md:**

- No agents — this pattern uses only a skill + hook.
- `cost-gate.sh` (PreToolUse): triggers on ALL tool calls (matcher: `*`). Estimates cost by tool type and blocks if total exceeds budget.
- Budget file `.claude/budget.json` must be initialized with `budget_tokens` and `spent_tokens`.
- Skill name in target is `cost-aware-task`.

---

### TASK P1-025 — Install Incremental Migration (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-025 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/incremental-migration/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/incremental-migration/agents/module-migrator.md`, `patterns/workflow-patterns/tier-3-full-stack/incremental-migration/hooks/migration-gate.sh`, `patterns/workflow-patterns/tier-3-full-stack/incremental-migration/settings-fragment.json` |
| Outputs | `.claude/skills/incremental-migrate/SKILL.md`, `.claude/agents/module-migrator.md`, `.claude/hooks/migration-gate.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/incremental-migrate/SKILL.md ]] && [[ -f .claude/hooks/migration-gate.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern incremental-migration 3`
3. Verify installed files:
   - `.claude/skills/incremental-migrate/SKILL.md`
   - `.claude/agents/module-migrator.md`
   - `.claude/hooks/migration-gate.sh` (executable)
4. Verify settings-fragment.json merged into `.claude/settings.json`
5. Validate installed SKILL.md with markdown-formatting skill
6. Confirm done check now passes

**Notes from PATTERN.md:**

- `module-migrator` is write-capable (migrates one module at a time).
- `migration-gate.sh` (PostToolUse): triggers on Write/Edit/MultiEdit to `src/*` or `packages/*`; runs `pnpm build --silent`; exits 2 on failure.
- Skill name in target is `incremental-migrate`.
- Prerequisite: pnpm build environment.

---

### TASK P1-026 — Install Pattern Replacement (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-026 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/pattern-replacement/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/pattern-replacement/agents/pattern-finder.md`, `patterns/workflow-patterns/tier-3-full-stack/pattern-replacement/agents/pattern-replacer.md`, `patterns/workflow-patterns/tier-3-full-stack/pattern-replacement/hooks/refactor-lint.sh`, `patterns/workflow-patterns/tier-3-full-stack/pattern-replacement/settings-fragment.json` |
| Outputs | `.claude/skills/replace-pattern/SKILL.md`, `.claude/agents/pattern-finder.md`, `.claude/agents/pattern-replacer.md`, `.claude/hooks/refactor-lint.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/replace-pattern/SKILL.md ]] && [[ -f .claude/hooks/refactor-lint.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern pattern-replacement 3`
3. Verify installed files:
   - `.claude/skills/replace-pattern/SKILL.md`
   - `.claude/agents/pattern-finder.md`, `pattern-replacer.md`
   - `.claude/hooks/refactor-lint.sh` (executable)
4. Create `.claude/refactor/` directory
5. Verify settings-fragment.json merged into `.claude/settings.json`
6. Validate installed SKILL.md with markdown-formatting skill
7. Confirm done check now passes

**Notes from PATTERN.md:**

- `pattern-finder` has `disallowedTools: [Write, Edit, MultiEdit]` (read-only discovery).
- `pattern-replacer` is write-capable.
- `refactor-lint.sh` (PostToolUse): runs prettier + `pnpm build --silent` after each edit; exits 2 on compile failure.
- Skill name in target is `replace-pattern`.

---

### TASK P1-027 — Install Database Schema Evolution (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-027 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/database-schema-evolution/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/database-schema-evolution/agents/schema-differ.md`, `patterns/workflow-patterns/tier-3-full-stack/database-schema-evolution/agents/migration-generator.md`, `patterns/workflow-patterns/tier-3-full-stack/database-schema-evolution/agents/compat-checker.md`, `patterns/workflow-patterns/tier-3-full-stack/database-schema-evolution/hooks/require-reversible-migration.sh`, `patterns/workflow-patterns/tier-3-full-stack/database-schema-evolution/settings-fragment.json` |
| Outputs | `.claude/skills/schema-evolve/SKILL.md`, `.claude/agents/schema-differ.md`, `.claude/agents/migration-generator.md`, `.claude/agents/compat-checker.md`, `.claude/hooks/require-reversible-migration.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/schema-evolve/SKILL.md ]] && [[ -f .claude/hooks/require-reversible-migration.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern database-schema-evolution 3`
3. Verify installed files:
   - `.claude/skills/schema-evolve/SKILL.md`
   - `.claude/agents/schema-differ.md`, `migration-generator.md`, `compat-checker.md`
   - `.claude/hooks/require-reversible-migration.sh` (executable)
4. Create `.claude/schema/` directory
5. Verify settings-fragment.json merged into `.claude/settings.json`
6. Validate installed SKILL.md with markdown-formatting skill
7. Confirm done check now passes

**Notes from PATTERN.md:**

- `schema-differ` and `compat-checker` are read-only.
- `compat-checker` uses `claude-opus-4-5` for safety-critical accuracy.
- `require-reversible-migration.sh` (PreToolUse): triggers on Bash calls containing "rollout"; reads `.claude/schema/compat-report.json`; exits 2 if `reversible: false` or `blocking_issues` non-empty.
- Skill name in target is `schema-evolve`.
- Output file: `.claude/schema/compat-report.json`.

---

### TASK P1-028 — Install Regression Sweep (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-028 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/regression-sweep/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/regression-sweep/agents/regression-differ.md`, `patterns/workflow-patterns/tier-3-full-stack/regression-sweep/hooks/capture-baseline.sh`, `patterns/workflow-patterns/tier-3-full-stack/regression-sweep/settings-fragment.json` |
| Outputs | `.claude/skills/regression-sweep/SKILL.md`, `.claude/agents/regression-differ.md`, `.claude/hooks/capture-baseline.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/regression-sweep/SKILL.md ]] && [[ -f .claude/hooks/capture-baseline.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern regression-sweep 3`
3. Verify installed files:
   - `.claude/skills/regression-sweep/SKILL.md`
   - `.claude/agents/regression-differ.md`
   - `.claude/hooks/capture-baseline.sh` (executable)
4. Create `.claude/regression/` directory
5. Verify settings-fragment.json merged into `.claude/settings.json`
6. Validate installed SKILL.md with markdown-formatting skill
7. Confirm done check now passes

**Notes from PATTERN.md:**

- `regression-differ` is read-only (`disallowedTools: [Write, Edit, MultiEdit]`).
- `capture-baseline.sh` (PreToolUse): triggers on Write/Edit/MultiEdit to `src/*`; runs only once; captures test baseline via `pnpm test --reporter=json` BEFORE first edit.
- Timing is critical: baseline must reflect pre-change state.
- Saves baseline to `.claude/regression/baseline.json`.

---

### TASK P1-029 — Install API Client Generation (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-029 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/api-client-generation/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/api-client-generation/agents/client-generator.md`, `patterns/workflow-patterns/tier-3-full-stack/api-client-generation/hooks/typecheck-generated.sh`, `patterns/workflow-patterns/tier-3-full-stack/api-client-generation/settings-fragment.json` |
| Outputs | `.claude/skills/generate-client/SKILL.md`, `.claude/agents/client-generator.md`, `.claude/hooks/typecheck-generated.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/generate-client/SKILL.md ]] && [[ -f .claude/hooks/typecheck-generated.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern api-client-generation 3`
3. Verify installed files:
   - `.claude/skills/generate-client/SKILL.md`
   - `.claude/agents/client-generator.md`
   - `.claude/hooks/typecheck-generated.sh` (executable)
4. Verify settings-fragment.json merged into `.claude/settings.json`
5. Validate installed SKILL.md with markdown-formatting skill
6. Confirm done check now passes

**Notes from PATTERN.md:**

- `client-generator` has `disallowedTools: [Edit, MultiEdit]` (write-only for new clients, cannot modify existing).
- `typecheck-generated.sh` (PostToolUse): triggers on every Write; filters for client file patterns; runs language-specific type checker (pnpm typecheck / mypy / go vet); exits 2 on failure.
- Skill name in target is `generate-client`.

---

### TASK P1-030 — Install Watchdog Loop (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-030 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/watchdog-loop/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/watchdog-loop/agents/health-checker.md`, `patterns/workflow-patterns/tier-3-full-stack/watchdog-loop/hooks/watchdog-notify.sh`, `patterns/workflow-patterns/tier-3-full-stack/watchdog-loop/settings-fragment.json` |
| Outputs | `.claude/skills/watchdog/SKILL.md`, `.claude/agents/health-checker.md`, `.claude/hooks/watchdog-notify.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/watchdog/SKILL.md ]] && [[ -f .claude/hooks/watchdog-notify.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern watchdog-loop 3`
3. Verify installed files:
   - `.claude/skills/watchdog/SKILL.md`
   - `.claude/agents/health-checker.md`
   - `.claude/hooks/watchdog-notify.sh` (executable)
4. Create `.claude/watchdog/` directory
5. Verify settings-fragment.json merged into `.claude/settings.json`
6. Validate installed SKILL.md with markdown-formatting skill
7. Confirm done check now passes

**Notes from PATTERN.md:**

- `health-checker` is read-only (`disallowedTools: [Write, Edit, MultiEdit]`); writes only to `.claude/watchdog/latest-check.json`.
- `watchdog-notify.sh` (Stop): reads `.claude/watchdog/violations.log`; logs to `~/.claude/notifications.log` and optionally POSTs to Slack.
- Environment variable `${SLACK_WEBHOOK_URL}` must be set for Slack notifications.
- Skill name in target is `watchdog`.

---

### TASK P1-031 — Install Environment Parity Check (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-031 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/environment-parity-check/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/environment-parity-check/agents/env-parity-checker.md`, `patterns/workflow-patterns/tier-3-full-stack/environment-parity-check/hooks/block-promotion-on-drift.sh`, `patterns/workflow-patterns/tier-3-full-stack/environment-parity-check/settings-fragment.json` |
| Outputs | `.claude/skills/env-parity/SKILL.md`, `.claude/agents/env-parity-checker.md`, `.claude/hooks/block-promotion-on-drift.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/env-parity/SKILL.md ]] && [[ -f .claude/hooks/block-promotion-on-drift.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern environment-parity-check 3`
3. Verify installed files:
   - `.claude/skills/env-parity/SKILL.md`
   - `.claude/agents/env-parity-checker.md`
   - `.claude/hooks/block-promotion-on-drift.sh` (executable)
4. Create `.claude/env/` directory
5. Verify settings-fragment.json merged into `.claude/settings.json`
6. Validate installed SKILL.md with markdown-formatting skill
7. Confirm done check now passes

**Notes from PATTERN.md:**

- `env-parity-checker` is read-only; checks key presence and pattern matching (not actual secret values).
- Writes report to `.claude/env/parity-report.json`.
- `block-promotion-on-drift.sh` (PreToolUse): triggers on commands containing "deploy", "promote", or "release"; reads parity report; exits 2 if `parity_status == "fail"`.
- Prerequisite: add Environment Baseline section to CLAUDE.md.
- Skill name in target is `env-parity`.

---

### TASK P1-032 — Install Secret Rotation (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-032 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/secret-rotation/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/secret-rotation/agents/secret-finder.md`, `patterns/workflow-patterns/tier-3-full-stack/secret-rotation/hooks/require-health-before-revoke.sh`, `patterns/workflow-patterns/tier-3-full-stack/secret-rotation/settings-fragment.json` |
| Outputs | `.claude/skills/rotate-secret/SKILL.md`, `.claude/agents/secret-finder.md`, `.claude/hooks/require-health-before-revoke.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/rotate-secret/SKILL.md ]] && [[ -f .claude/hooks/require-health-before-revoke.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern secret-rotation 3`
3. Verify installed files:
   - `.claude/skills/rotate-secret/SKILL.md`
   - `.claude/agents/secret-finder.md`
   - `.claude/hooks/require-health-before-revoke.sh` (executable)
4. Create `.claude/secrets/` directory
5. Verify settings-fragment.json merged into `.claude/settings.json`
6. Validate installed SKILL.md with markdown-formatting skill
7. Confirm done check now passes

**Notes from PATTERN.md:**

- `secret-finder` is read-only (`disallowedTools: [Write, Edit, MultiEdit]`) — search and report only.
- `require-health-before-revoke.sh` (PreToolUse): triggers on Bash commands matching "revoke", "delete.*key", or "remove.*secret"; requires `.claude/secrets/health-check.json` with `status: "healthy"`.
- Credentials never written to tracked files; deny list blocks dangerous patterns.
- Skill name in target is `rotate-secret`.

---

### TASK P1-033 — Install Map-Reduce (Tier 3)

| Field | Value |
|-------|-------|
| ID | P1-033 |
| Execution | PARALLEL |
| Depends On | none |
| Inputs | `patterns/workflow-patterns/tier-3-full-stack/map-reduce/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/map-reduce/agents/mr-worker.md`, `patterns/workflow-patterns/tier-3-full-stack/map-reduce/agents/mr-reducer.md`, `patterns/workflow-patterns/tier-3-full-stack/map-reduce/hooks/mr-track-completion.sh`, `patterns/workflow-patterns/tier-3-full-stack/map-reduce/settings-fragment.json` |
| Outputs | `.claude/skills/map-reduce/SKILL.md`, `.claude/agents/mr-worker.md`, `.claude/agents/mr-reducer.md`, `.claude/hooks/mr-track-completion.sh`, `.claude/settings.json` (merged) |
| Done Check | `[[ -f .claude/skills/map-reduce/SKILL.md ]] && [[ -f .claude/hooks/mr-track-completion.sh ]]` |

**Installation Steps:**

1. Check if already installed: run the Done Check. If it passes, skip to next task.
2. Invoke install-pattern skill: `/install-pattern map-reduce 3`
3. Verify installed files:
   - `.claude/skills/map-reduce/SKILL.md`
   - `.claude/agents/mr-worker.md`, `mr-reducer.md`
   - `.claude/hooks/mr-track-completion.sh` (executable)
4. Create `.claude/map-reduce/results/` directory
5. Verify settings-fragment.json merged into `.claude/settings.json`
6. Validate installed SKILL.md with markdown-formatting skill
7. Confirm done check now passes

**Notes from PATTERN.md:**

- `mr-reducer` is read-only (`disallowedTools: [Write, Edit, MultiEdit]`); uses Bash echo/tee for output to `aggregate.md`.
- `mr-worker` is write-capable, scoped to single-item processing.
- `mr-track-completion.sh` (SubagentStop): filters for `agent_name == "mr-worker"`; appends completion record to `.claude/map-reduce/completion.jsonl`.
- Skill name in target is `map-reduce`.

---

## Phase 2 — AGENTS.md Generation

**Completion Criterion:** `AGENTS.md` exists in the project root and documents all installed agents with their roles, capabilities, and invocation patterns.

---

### TASK P2-001 — Create or Update AGENTS.md

| Field | Value |
|-------|-------|
| ID | P2-001 |
| Execution | SEQUENTIAL (must follow completion of all Phase 1 tasks) |
| Depends On | All P1-NNN tasks (P1-001 through P1-033) |
| Inputs | All installed agent files in `.claude/agents/`; architecture spec AGENTS.md format (Chapter 2, Section 2.6) |
| Outputs | `AGENTS.md` in project root |
| Done Check | `[[ -f AGENTS.md ]]` |

**Steps:**

1. Read architecture spec section on AGENTS.md format (Chapter 2, Section 2.6)
2. Enumerate all agent definition files installed in `.claude/agents/` from Phase 1:
   - Tier 2 agents: `researcher.md`, `implementer.md`, `source-researcher.md`, `analysis-synthesizer.md`, `contract-extractor.md`, `contract-verifier.md`, `spec-test-generator.md`, `spec-verifier.md`, `diff-analyzer.md`, `security-reviewer.md`, `style-checker.md`, `coverage-checker.md`, `review-summarizer.md`, `ts-fixer.md`, `py-fixer.md`, `go-fixer.md`
   - Tier 3 agents: `schema-designer.md`, `entity-builder.md`, `service-builder.md`, `route-builder.md`, `test-writer.md`, `parallel-worker.md`, `result-merger.md`, `code-critic.md`, `env-deployer.md`, `module-migrator.md`, `pattern-finder.md`, `pattern-replacer.md`, `schema-differ.md`, `migration-generator.md`, `compat-checker.md`, `regression-differ.md`, `client-generator.md`, `health-checker.md`, `env-parity-checker.md`, `secret-finder.md`, `mr-worker.md`, `mr-reducer.md`
3. For each agent: extract name, description, model, tools, disallowedTools, and maxTurns from frontmatter
4. Cross-reference each agent with the skills it supports (which workflow pattern it belongs to)
5. Generate `AGENTS.md` following the architecture specification format:
   - Project Overview section
   - Tech Stack section
   - Build and Test Commands section
   - Agent inventory table with roles and capabilities
   - Per-agent detail sections
6. Validate with markdown-formatting skill
7. Confirm done check passes

---

## Phase 3 — Documentation Generation

**Completion Criterion:** Every installed workflow pattern has a user guide in `docs/user-guide/` and a `docs/user-guide/README.md` index exists.

Tasks within this phase are PARALLEL (except the final index task).

---

### TASK P3-001 — Document Dependency Audit User Guide

| Field | Value |
|-------|-------|
| ID | P3-001 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/dependency-audit/SKILL.md` |
| Outputs | `docs/user-guide/dependency-audit.md` |
| Done Check | `[[ -f docs/user-guide/dependency-audit.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read `.claude/skills/dependency-audit/SKILL.md`
3. Generate user guide covering: purpose, prerequisites, step-by-step usage, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-002 — Document Template Instantiation User Guide

| Field | Value |
|-------|-------|
| ID | P3-002 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/template-instantiation/SKILL.md` |
| Outputs | `docs/user-guide/template-instantiation.md` |
| Done Check | `[[ -f docs/user-guide/template-instantiation.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read `.claude/skills/template-instantiation/SKILL.md`
3. Generate user guide covering: purpose, prerequisites, step-by-step usage, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-003 — Document Documentation Generation User Guide

| Field | Value |
|-------|-------|
| ID | P3-003 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/documentation-generation/SKILL.md` |
| Outputs | `docs/user-guide/documentation-generation.md` |
| Done Check | `[[ -f docs/user-guide/documentation-generation.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read `.claude/skills/documentation-generation/SKILL.md`
3. Generate user guide covering: purpose, prerequisites, step-by-step usage, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-004 — Document Build Failure Triage User Guide

| Field | Value |
|-------|-------|
| ID | P3-004 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/build-failure-triage/SKILL.md` |
| Outputs | `docs/user-guide/build-failure-triage.md` |
| Done Check | `[[ -f docs/user-guide/build-failure-triage.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read `.claude/skills/build-failure-triage/SKILL.md`
3. Generate user guide covering: purpose, prerequisites, step-by-step usage, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-005 — Document Log Analysis User Guide

| Field | Value |
|-------|-------|
| ID | P3-005 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/log-analysis/SKILL.md` |
| Outputs | `docs/user-guide/log-analysis.md` |
| Done Check | `[[ -f docs/user-guide/log-analysis.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read `.claude/skills/log-analysis/SKILL.md`
3. Generate user guide covering: purpose, prerequisites, step-by-step usage, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-006 — Document Compliance Audit User Guide

| Field | Value |
|-------|-------|
| ID | P3-006 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/compliance-audit/SKILL.md` |
| Outputs | `docs/user-guide/compliance-audit.md` |
| Done Check | `[[ -f docs/user-guide/compliance-audit.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read `.claude/skills/compliance-audit/SKILL.md`
3. Generate user guide covering: purpose, prerequisites, step-by-step usage, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-007 — Document Dead Code Detection User Guide

| Field | Value |
|-------|-------|
| ID | P3-007 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/dead-code-detection/SKILL.md` |
| Outputs | `docs/user-guide/dead-code-detection.md` |
| Done Check | `[[ -f docs/user-guide/dead-code-detection.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read `.claude/skills/dead-code-detection/SKILL.md`
3. Generate user guide covering: purpose, prerequisites, step-by-step usage, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-008 — Document Infrastructure Drift Detection User Guide

| Field | Value |
|-------|-------|
| ID | P3-008 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/infrastructure-drift-detection/SKILL.md` |
| Outputs | `docs/user-guide/infrastructure-drift-detection.md` |
| Done Check | `[[ -f docs/user-guide/infrastructure-drift-detection.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read `.claude/skills/infrastructure-drift-detection/SKILL.md`
3. Generate user guide covering: purpose, prerequisites, step-by-step usage, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-009 — Document Postmortem Assistant User Guide

| Field | Value |
|-------|-------|
| ID | P3-009 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/postmortem-assistant/SKILL.md` |
| Outputs | `docs/user-guide/postmortem-assistant.md` |
| Done Check | `[[ -f docs/user-guide/postmortem-assistant.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read `.claude/skills/postmortem-assistant/SKILL.md`
3. Generate user guide covering: purpose, prerequisites, step-by-step usage, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-010 — Document Test Failure Explainer User Guide

| Field | Value |
|-------|-------|
| ID | P3-010 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/test-failure-explainer/SKILL.md` |
| Outputs | `docs/user-guide/test-failure-explainer.md` |
| Done Check | `[[ -f docs/user-guide/test-failure-explainer.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read `.claude/skills/test-failure-explainer/SKILL.md`
3. Generate user guide covering: purpose, prerequisites, step-by-step usage, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-011 — Document Code Archaeology User Guide

| Field | Value |
|-------|-------|
| ID | P3-011 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/code-archaeology/SKILL.md` |
| Outputs | `docs/user-guide/code-archaeology.md` |
| Done Check | `[[ -f docs/user-guide/code-archaeology.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read `.claude/skills/code-archaeology/SKILL.md`
3. Generate user guide covering: purpose, prerequisites, step-by-step usage, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-012 — Document Explore-then-Implement User Guide

| Field | Value |
|-------|-------|
| ID | P3-012 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/explore-implement/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/explore-then-implement/PATTERN.md` |
| Outputs | `docs/user-guide/explore-then-implement.md` |
| Done Check | `[[ -f docs/user-guide/explore-then-implement.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md for integration context
3. Generate user guide covering: purpose, prerequisites, setup, step-by-step usage, example invocations, agent interactions, tips, troubleshooting, integration with other workflows
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-013 — Document Competitive Analysis User Guide

| Field | Value |
|-------|-------|
| ID | P3-013 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/competitive-analysis/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/competitive-analysis/PATTERN.md` |
| Outputs | `docs/user-guide/competitive-analysis.md` |
| Done Check | `[[ -f docs/user-guide/competitive-analysis.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, step-by-step usage, example invocations, agent interactions, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-014 — Document Contract Testing User Guide

| Field | Value |
|-------|-------|
| ID | P3-014 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/contract-test/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/contract-testing/PATTERN.md` |
| Outputs | `docs/user-guide/contract-testing.md` |
| Done Check | `[[ -f docs/user-guide/contract-testing.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, step-by-step usage, example invocations, agent interactions, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-015 — Document Spec-First Verification User Guide

| Field | Value |
|-------|-------|
| ID | P3-015 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/spec-verify/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/spec-first-verification/PATTERN.md` |
| Outputs | `docs/user-guide/spec-first-verification.md` |
| Done Check | `[[ -f docs/user-guide/spec-first-verification.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, step-by-step usage, example invocations, agent interactions, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-016 — Document PR Review Pipeline User Guide

| Field | Value |
|-------|-------|
| ID | P3-016 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/review-pr/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/pr-review-pipeline/PATTERN.md` |
| Outputs | `docs/user-guide/pr-review-pipeline.md` |
| Done Check | `[[ -f docs/user-guide/pr-review-pipeline.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, step-by-step usage, example invocations, agent interactions, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-017 — Document Workflow Chaining User Guide

| Field | Value |
|-------|-------|
| ID | P3-017 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/plan-feature/SKILL.md`, `.claude/skills/implement-feature/SKILL.md`, `.claude/skills/review-feature/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/workflow-chaining/PATTERN.md` |
| Outputs | `docs/user-guide/workflow-chaining.md` |
| Done Check | `[[ -f docs/user-guide/workflow-chaining.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read all three installed skills and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, the three-step chain flow, example invocations, chain artifact convention, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-018 — Document Conditional Branching User Guide

| Field | Value |
|-------|-------|
| ID | P3-018 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/auto-fix/SKILL.md`, `patterns/workflow-patterns/tier-2-skill-plus-agents/conditional-branching/PATTERN.md` |
| Outputs | `docs/user-guide/conditional-branching.md` |
| Done Check | `[[ -f docs/user-guide/conditional-branching.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, step-by-step usage, language detection, specialist dispatch, adding new language specialists, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-019 — Document Sequential Pipeline User Guide

| Field | Value |
|-------|-------|
| ID | P3-019 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/sequential-pipeline/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/sequential-pipeline/PATTERN.md` |
| Outputs | `docs/user-guide/sequential-pipeline.md` |
| Done Check | `[[ -f docs/user-guide/sequential-pipeline.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, pipeline stages, hook behavior, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-020 — Document Parallel Fan-out / Fan-in User Guide

| Field | Value |
|-------|-------|
| ID | P3-020 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/fan-out-fan-in/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/parallel-fan-out-fan-in/PATTERN.md` |
| Outputs | `docs/user-guide/parallel-fan-out-fan-in.md` |
| Done Check | `[[ -f docs/user-guide/parallel-fan-out-fan-in.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, fan-out/fan-in flow, hook behavior, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-021 — Document Self-Reflection Loop User Guide

| Field | Value |
|-------|-------|
| ID | P3-021 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/self-reflect/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/self-reflection-loop/PATTERN.md` |
| Outputs | `docs/user-guide/self-reflection-loop.md` |
| Done Check | `[[ -f docs/user-guide/self-reflection-loop.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, generate-critique-revise loop, score threshold, hook behavior, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-022 — Document Human-in-the-Loop Approval User Guide

| Field | Value |
|-------|-------|
| ID | P3-022 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/approve-then-deploy/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/human-in-the-loop-approval/PATTERN.md` |
| Outputs | `docs/user-guide/human-in-the-loop-approval.md` |
| Done Check | `[[ -f docs/user-guide/human-in-the-loop-approval.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, two-phase workflow, sentinel file mechanism, customizing destructive patterns, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-023 — Document Staged Rollout Gate User Guide

| Field | Value |
|-------|-------|
| ID | P3-023 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/staged-rollout/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/staged-rollout-gate/PATTERN.md` |
| Outputs | `docs/user-guide/staged-rollout-gate.md` |
| Done Check | `[[ -f docs/user-guide/staged-rollout-gate.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, environment promotion order, hook enforcement, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-024 — Document Cost-Threshold Gate User Guide

| Field | Value |
|-------|-------|
| ID | P3-024 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/cost-aware-task/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/cost-threshold-gate/PATTERN.md` |
| Outputs | `docs/user-guide/cost-threshold-gate.md` |
| Done Check | `[[ -f docs/user-guide/cost-threshold-gate.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, budget configuration, cost estimation, hook enforcement, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-025 — Document Incremental Migration User Guide

| Field | Value |
|-------|-------|
| ID | P3-025 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/incremental-migrate/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/incremental-migration/PATTERN.md` |
| Outputs | `docs/user-guide/incremental-migration.md` |
| Done Check | `[[ -f docs/user-guide/incremental-migration.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, module-by-module flow, build gate behavior, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-026 — Document Pattern Replacement User Guide

| Field | Value |
|-------|-------|
| ID | P3-026 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/replace-pattern/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/pattern-replacement/PATTERN.md` |
| Outputs | `docs/user-guide/pattern-replacement.md` |
| Done Check | `[[ -f docs/user-guide/pattern-replacement.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, discover-replace flow, lint gate behavior, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-027 — Document Database Schema Evolution User Guide

| Field | Value |
|-------|-------|
| ID | P3-027 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/schema-evolve/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/database-schema-evolution/PATTERN.md` |
| Outputs | `docs/user-guide/database-schema-evolution.md` |
| Done Check | `[[ -f docs/user-guide/database-schema-evolution.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, diff-generate-verify flow, reversibility enforcement, compat report format, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-028 — Document Regression Sweep User Guide

| Field | Value |
|-------|-------|
| ID | P3-028 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/regression-sweep/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/regression-sweep/PATTERN.md` |
| Outputs | `docs/user-guide/regression-sweep.md` |
| Done Check | `[[ -f docs/user-guide/regression-sweep.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, baseline capture timing, post-change diff analysis, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-029 — Document API Client Generation User Guide

| Field | Value |
|-------|-------|
| ID | P3-029 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/generate-client/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/api-client-generation/PATTERN.md` |
| Outputs | `docs/user-guide/api-client-generation.md` |
| Done Check | `[[ -f docs/user-guide/api-client-generation.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, spec parsing, client generation, type-check enforcement, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-030 — Document Watchdog Loop User Guide

| Field | Value |
|-------|-------|
| ID | P3-030 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/watchdog/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/watchdog-loop/PATTERN.md` |
| Outputs | `docs/user-guide/watchdog-loop.md` |
| Done Check | `[[ -f docs/user-guide/watchdog-loop.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, polling loop, health checks, notification configuration, Slack integration, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-031 — Document Environment Parity Check User Guide

| Field | Value |
|-------|-------|
| ID | P3-031 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/env-parity/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/environment-parity-check/PATTERN.md` |
| Outputs | `docs/user-guide/environment-parity-check.md` |
| Done Check | `[[ -f docs/user-guide/environment-parity-check.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, environment baseline, parity checking, deployment gate, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-032 — Document Secret Rotation User Guide

| Field | Value |
|-------|-------|
| ID | P3-032 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/rotate-secret/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/secret-rotation/PATTERN.md` |
| Outputs | `docs/user-guide/secret-rotation.md` |
| Done Check | `[[ -f docs/user-guide/secret-rotation.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, discover-update-verify-revoke flow, health check requirement, security considerations, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-033 — Document Map-Reduce User Guide

| Field | Value |
|-------|-------|
| ID | P3-033 |
| Execution | PARALLEL |
| Depends On | P2-001 |
| Inputs | `.claude/skills/map-reduce/SKILL.md`, `patterns/workflow-patterns/tier-3-full-stack/map-reduce/PATTERN.md` |
| Outputs | `docs/user-guide/map-reduce.md` |
| Done Check | `[[ -f docs/user-guide/map-reduce.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Read installed skill and PATTERN.md
3. Generate user guide covering: purpose, prerequisites, setup, enumerate-fanout-reduce flow, completion tracking, example invocations, tips, troubleshooting
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

### TASK P3-DOC-INDEX — Generate docs/user-guide/README.md Index

| Field | Value |
|-------|-------|
| ID | P3-DOC-INDEX |
| Execution | SEQUENTIAL (must follow all P3-NNN tasks) |
| Depends On | P3-001 through P3-033 |
| Inputs | All generated `docs/user-guide/*.md` files |
| Outputs | `docs/user-guide/README.md` |
| Done Check | `[[ -f docs/user-guide/README.md ]]` |

**Steps:**

1. Skip if Done Check passes
2. Enumerate all `docs/user-guide/*.md` files
3. Generate index with:
   - Title and purpose
   - Table organized by tier (Tier 1, Tier 2, Tier 3) with links to each guide
   - Brief one-line description per guide
4. Validate with markdown-formatting skill
5. Confirm Done Check passes

---

## Phase 4 — Project Root Files

**Completion Criterion:** `.claude/CLAUDE.MD` and `README.md` are updated to reference all installed components.

Both tasks can run in PARALLEL.

---

### TASK P4-001 — Update or Generate CLAUDE.MD

| Field | Value |
|-------|-------|
| ID | P4-001 |
| Execution | PARALLEL |
| Depends On | P3-DOC-INDEX |
| Inputs | All `.claude/` content; architecture spec; installed patterns |
| Outputs | `.claude/CLAUDE.MD` (updated) |
| Done Check | `grep -q "install-patterns-plan" .claude/CLAUDE.MD` |

**Steps:**

1. Read existing `.claude/CLAUDE.MD`
2. Read architecture spec for CLAUDE.MD requirements (Chapter 2, Sections 2.3-2.4)
3. Enumerate all installed skills in `.claude/skills/`
4. Enumerate all installed agents in `.claude/agents/`
5. Enumerate all installed hooks in `.claude/hooks/`
6. Update CLAUDE.MD to include:
   - Reference to this plan: `specs/install-patterns-plan.md`
   - List of all available skills with invocation commands
   - List of all installed agents with brief descriptions
   - List of all hooks with their trigger events
   - Workflow chaining convention (`.claude/chain/` artifacts)
   - Environment baseline section for env-parity pattern
7. Validate with markdown-formatting skill
8. Confirm done check passes

---

### TASK P4-002 — Update or Generate README.md

| Field | Value |
|-------|-------|
| ID | P4-002 |
| Execution | PARALLEL |
| Depends On | P3-DOC-INDEX |
| Inputs | `docs/user-guide/README.md`; `architecture/`; `.claude/` folder structure |
| Outputs | `README.md` in project root |
| Done Check | `[[ -f README.md ]]` |

**Steps:**

1. Check if `README.md` exists and read it if so
2. Generate or update with these sections ONLY (do not reference `specs/` or `patterns/`):
   - Project overview and purpose
   - Quick start referencing `.claude/` setup
   - Architecture reference linking to `architecture/` folder
   - Documentation index linking to `docs/` folder
   - References to `.claude/` for skills, agents, and workflows
3. Do NOT include direct references to `specs/` or `patterns/` — these are internal
4. Validate with markdown-formatting skill
5. Confirm done check passes

---

## Appendix — Pattern-to-Skill Name Mapping

This reference table maps pattern source folder names to their installed skill names (used in done checks and invocation commands).

| # | Pattern Source Folder | Installed Skill Name | Tier |
|---|----------------------|---------------------|------|
| 01 | `sequential-pipeline` | `sequential-pipeline` | 3 |
| 02 | `parallel-fan-out-fan-in` | `fan-out-fan-in` | 3 |
| 03 | `self-reflection-loop` | `self-reflect` | 3 |
| 04 | `human-in-the-loop-approval` | `approve-then-deploy` | 3 |
| 05 | `staged-rollout-gate` | `staged-rollout` | 3 |
| 06 | `cost-threshold-gate` | `cost-aware-task` | 3 |
| 07 | `explore-then-implement` | `explore-implement` | 2 |
| 08 | `competitive-analysis` | `competitive-analysis` | 2 |
| 09 | `dependency-audit` | `dependency-audit` | 1 |
| 10 | `incremental-migration` | `incremental-migrate` | 3 |
| 11 | `pattern-replacement` | `replace-pattern` | 3 |
| 12 | `database-schema-evolution` | `schema-evolve` | 3 |
| 13 | `contract-testing` | `contract-test` | 2 |
| 14 | `spec-first-verification` | `spec-verify` | 2 |
| 15 | `regression-sweep` | `regression-sweep` | 3 |
| 16 | `template-instantiation` | `template-instantiation` | 1 |
| 17 | `api-client-generation` | `generate-client` | 3 |
| 18 | `documentation-generation` | `documentation-generation` | 1 |
| 19 | `watchdog-loop` | `watchdog` | 3 |
| 20 | `build-failure-triage` | `build-failure-triage` | 1 |
| 21 | `log-analysis` | `log-analysis` | 1 |
| 22 | `pr-review-pipeline` | `review-pr` | 2 |
| 23 | `compliance-audit` | `compliance-audit` | 1 |
| 24 | `dead-code-detection` | `dead-code-detection` | 1 |
| 25 | `environment-parity-check` | `env-parity` | 3 |
| 26 | `secret-rotation` | `rotate-secret` | 3 |
| 27 | `infrastructure-drift-detection` | `infrastructure-drift-detection` | 1 |
| 28 | `postmortem-assistant` | `postmortem-assistant` | 1 |
| 29 | `test-failure-explainer` | `test-failure-explainer` | 1 |
| 30 | `code-archaeology` | `code-archaeology` | 1 |
| 31 | `workflow-chaining` | `plan-feature`, `implement-feature`, `review-feature` | 2 |
| 32 | `conditional-branching` | `auto-fix` | 2 |
| 33 | `map-reduce` | `map-reduce` | 3 |
