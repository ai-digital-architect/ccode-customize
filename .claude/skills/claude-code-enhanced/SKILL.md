---
name: claude-code-enhanced
description: >
  Analyze a codebase and create actual Claude Code customization files tailored to it —
  CLAUDE.md, AGENTS.md, .claude/agents/*.md, .claude/rules/*.md, .mcp.json,
  .claude/settings.json hooks/permissions, .claude/skills/*.md, REVIEW.md, and more.
  Use this skill when the user wants to set up Claude Code for a project, customize
  their Claude Code workflow, add automations, create subagents, configure hooks, or
  asks "how should I set up Claude Code for this project?" — even if they don't say
  "customize". This skill goes beyond recommendations and actually writes the files.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Claude Code Customize

Analyze a codebase and generate the complete Claude Code customization layer for it —
writing every file, not just recommending what to create.

## MANDATORY: Read the Architecture Document First

**Before doing anything else**, read the authoritative architecture reference:

```
references/claude-code-customization-architecture.md
```

This document is the single source of truth for every decision in this skill:
- Correct file locations (e.g., `.mcp.json` at project root, NOT in `settings.json`)
- All frontmatter fields for sub-agents and skills (current names — no obsolete fields like `zze`)
- The full hook event taxonomy (30+ events) and four handler types
- Settings precedence order and which settings belong at which scope
- Memory surface hierarchy (six surfaces, their locations, commit status)
- Permission system: three buckets (allow/ask/deny), six modes, sandboxing

If anything in this skill's supporting files (`references/`) conflicts with the architecture
document, **the architecture document wins**. The reference files are convenience shortcuts;
the architecture document is the contract.

See `references/detection-signals.md` for the full signal → surface mapping table.
See `references/file-templates.md` for boilerplate templates for each file type.
See `references/mcp-catalog.md` for the MCP server install commands by framework.
See `references/workflow-patterns-catalog.md` for all 33 workflow patterns with detection signals and installation instructions.

---

## Phase 1: Codebase Analysis

Run these commands to gather project context. Work in the user's project directory
(confirm it with the user if invoked from a different directory than their project).

```bash
# Identify language and build tooling
ls package.json pyproject.toml Cargo.toml go.mod pom.xml build.gradle Gemfile 2>/dev/null

# Detect framework and key dependencies
cat package.json 2>/dev/null | head -80
cat pyproject.toml 2>/dev/null | head -60

# Detect formatter/linter/typecheck tooling
ls .prettierrc* .eslintrc* eslint.config.* tsconfig.json ruff.toml mypy.ini \
   .black pyrightconfig.json go.mod Cargo.toml 2>/dev/null

# Detect test tooling
ls jest.config.* vitest.config.* pytest.ini conftest.py 2>/dev/null
ls -d tests/ __tests__/ spec/ 2>/dev/null

# Detect CI/CD, issue tracking, databases
ls .github/ .gitlab-ci.yml Dockerfile docker-compose.yml 2>/dev/null
grep -r "stripe\|supabase\|prisma\|postgres\|mysql\|mongodb\|redis\|linear\|jira\|sentry\|openai\|anthropic" \
     package.json pyproject.toml 2>/dev/null | head -20

# Check what Claude Code config already exists
ls -la CLAUDE.md AGENTS.md REVIEW.md .worktreeinclude .mcp.json 2>/dev/null
ls -la .claude/ 2>/dev/null
ls .claude/agents/ .claude/skills/ .claude/rules/ .claude/hooks/ 2>/dev/null

# Gauge project size and structure
find . -not -path './.git/*' -not -path './node_modules/*' -not -path './.venv/*' \
       -name '*.ts' -o -name '*.py' -o -name '*.go' -o -name '*.rs' | wc -l
ls -d src/ app/ lib/ api/ backend/ frontend/ packages/ 2>/dev/null

# Check for sensitive files to protect
ls .env .env.local .env.production .env.staging secrets.* credentials.* 2>/dev/null

# Check for lock files (to protect from direct edits)
ls package-lock.json yarn.lock pnpm-lock.yaml Cargo.lock poetry.lock 2>/dev/null

# Detect workflow pattern signals
ls openapi.yaml openapi.json schema.graphql *.proto 2>/dev/null
ls terraform/ cdk/ helm/ pulumi/ 2>/dev/null
ls -d migrations/ db/migrations/ alembic/ 2>/dev/null
ls runbooks/ incidents/ 2>/dev/null
ls packages/ apps/ services/ 2>/dev/null
grep -r "deploy\|rollout\|staging\|production" .github/ 2>/dev/null | head -5
```

Capture these key indicators from the analysis:

| Indicator | Informs |
|-----------|---------|
| Language + runtime | CLAUDE.md tech stack, hook formatters, rule scoping |
| Framework (React, FastAPI, etc.) | MCP servers, agents, path-scoped rules |
| Formatter/linter present | PostToolUse auto-format/lint hooks |
| Type checker present | PostToolUse type-check hooks |
| Test framework present | PostToolUse test hooks, test-writer agent |
| .env / secrets present | PreToolUse deny rules, permission deny |
| Lock files present | PreToolUse deny rules |
| Auth/payment/PII code | security-reviewer agent |
| DB usage | DB MCP server, migration agent |
| GitHub/Linear/Jira | GitHub/issue-tracker MCP |
| CI/CD configured | GitHub Actions / headless Claude guidance |
| Existing .claude/ | Augment rather than overwrite |
| Project size (files) | Recommend code-reviewer agent if >500 |
| Monorepo (packages/) | Nested .claude/skills/, package-scoped rules |
| OpenAPI/proto/GraphQL spec | api-client-generation, spec-first-verification patterns |
| IaC files (terraform, helm, cdk) | infrastructure-drift-detection pattern |
| migrations/ directory + ORM | database-schema-evolution pattern |
| Multi-environment deploys | staged-rollout-gate, environment-parity-check patterns |
| Secrets/credentials in repo | secret-rotation pattern |
| Incident/runbook files | postmortem-assistant pattern |
| Monorepo packages/ | parallel-fan-out-fan-in, incremental-migration patterns |

---

## Phase 2: Customization Design

Using the detection results, design customizations for each relevant surface.
Consult `references/detection-signals.md` for the full signal-to-surface mapping.
Consult `references/workflow-patterns-catalog.md` for the Detection Signal → Pattern table.

Work through each surface in order. **Skip a surface if it has no strong signals** — don't
create files that add no value. Mark each surface as: **Create**, **Skip**, or **Already exists**.

### Surface Checklist

#### Memory Layer
- [ ] **CLAUDE.md** — Always create if missing. Contains: tech stack, build/test commands, coding conventions, architecture decisions, anti-patterns. Target < 200 lines. If existing: check if it's already good or needs augmentation.
- [ ] **AGENTS.md** — Create if the project has build commands, code conventions, or architecture worth documenting for any AI tool. Contains: build/test/lint commands, code style, commit conventions, architecture overview.
- [ ] **.claude/rules/*.md** — Create path-scoped rules for any module-specific conventions (API design, testing, frontend components). Use `paths:` frontmatter for lazy loading.
- [ ] **CLAUDE.local.md** — Note to user: add to .gitignore; for personal overrides only. Don't create this; explain the pattern.
- [ ] **REVIEW.md** — Create if the project is on GitHub and PRs are reviewed. Defines Claude Code Review focus areas, severity guidance, out-of-scope items.

#### Agent Layer
- [ ] **researcher.md** — Create for medium/large projects (>100 files). Read-only research agent.
- [ ] **code-reviewer.md** — Create for medium/large projects. Read-only quality reviewer.
- [ ] **security-reviewer.md** — Create if auth, payments, PII, or API keys detected.
- [ ] **test-writer.md** — Create if test suite exists and test coverage looks thin.
- [ ] **api-documenter.md** — Create if REST/GraphQL API routes detected.
- [ ] **performance-analyzer.md** — Create if DB queries or performance-critical code detected.
- [ ] Custom agents — Design any agents specific to this project's domain.

When creating agents, use the full revised frontmatter from `references/file-templates.md`:
- Set `model`, `effort`, `tools`, `disallowedTools`, `maxTurns`
- Add `memory: project` for agents that accumulate knowledge across runs
- Add `isolation: worktree` for agents that need parallel safe execution
- Write a precise `description:` — this is what triggers auto-invocation

#### Hook Layer
- [ ] **PreToolUse: Bash safety** — Always. Block `rm -rf /`, `sudo rm`, force push, `curl|bash`.
- [ ] **PreToolUse: protect .env** — If .env files detected. Block Read/Edit/Write to secret files.
- [ ] **PreToolUse: protect lock files** — If lock files detected.
- [ ] **PostToolUse: auto-format** — If formatter detected (prettier, ruff, gofmt, rustfmt, black).
- [ ] **PostToolUse: auto-lint** — If linter detected (eslint, ruff).
- [ ] **PostToolUse: type-check** — If tsconfig.json or mypy/pyright detected (use `async: true`).
- [ ] **PostToolUse: run tests** — If test framework detected (use `async: true`).
- [ ] **FileChanged** — If TypeScript: async tsc --noEmit on *.ts changes.
- [ ] **Stop: audit log** — Optional. Log tool calls for audit trail.

Use all 4 handler types where appropriate:
- `command` for shell validation (0 tokens)
- `http` for team notifications
- `prompt` for LLM-based quality gates (e.g., Stop gate)
- `agent` for agentic verifiers

#### MCP Layer
- [ ] **GitHub MCP** — If GitHub Actions or gh CLI usage detected.
- [ ] **context7 MCP** — If popular libraries detected (React, Express, Django, etc.). Live docs lookup.
- [ ] **Playwright MCP** — If frontend with testing needs detected.
- [ ] **Database MCP** — If Supabase, Postgres, MySQL detected.
- [ ] **Linear/Jira MCP** — If issue tracking detected.
- [ ] **Sentry MCP** — If Sentry SDK detected.
- [ ] See `references/mcp-catalog.md` for full catalog.

#### Skills Layer
Create project-specific skills in `.claude/skills/<name>/SKILL.md`:
- [ ] **create-migration** — If DB + migrations detected (`disable-model-invocation: true`)
- [ ] **deploy** — If deployment scripts detected (`disable-model-invocation: true`)
- [ ] **gen-test** — If test suite + low coverage detected (`disable-model-invocation: true`)
- [ ] **summarize-pr** — If GitHub + active PRs detected (both user and Claude can invoke)
- [ ] **project-conventions** — If complex conventions worth encapsulating (`user-invocable: false`)

Use correct skill frontmatter fields:
- `disable-model-invocation: true` for any skill with side effects (deploy, commit, migrate)
- `user-invocable: false` for background knowledge skills Claude auto-invokes
- `allowed-tools:` to scope tool access during skill execution
- `context: fork` + `agent: general-purpose` for skills that should run in isolated context

#### Permission Layer
Always create a permissions section in `.claude/settings.json` with:
- **allow** — Specific patterns for safe read/test/lint operations
- **ask** — Sensitive but authorized ops: git push, DB migrations
- **deny** — Hard blocks: rm -rf, force push, reading .env, reading secrets

#### Sandboxing
Create a `sandbox` config if the project runs tests, builds, or ingests external input:
- Writable: `./`, `/tmp`
- Read-only: `~/.ssh`, `~/.aws`, `~/.gnupg`
- Network: allow registry + project APIs only

#### Supplementary Files
- [ ] **.worktreeinclude** — If .env or other gitignored files are needed in worktrees.
- [ ] **.gitignore additions** — Add `CLAUDE.local.md`, `.claude/settings.local.json`, `.claude/agent-memory-local/`.

#### Workflow Patterns

Read `references/workflow-patterns-catalog.md` and cross-reference its Detection Signal → Pattern table against the signals found in Phase 1. For each matched pattern, evaluate whether it provides real value (don't install patterns speculatively — only when the signal is clear and the workflow need is genuine).

Mark each as **Install**, **Adapt**, or **Skip**. Skip a pattern if its enforcement mechanism would be disruptive or if the team's workflow doesn't match. Adapt if the pattern fits conceptually but needs project-specific hook commands or agent configurations.

**Checklist by common scenario:**

- [ ] CI/CD pipeline + staged feature builds → `sequential-pipeline` (Tier 3)
- [ ] Monorepo with many independent packages → `parallel-fan-out-fan-in` (Tier 3)
- [ ] Quality gate / critic-before-ship requirement → `self-reflection-loop` (Tier 3)
- [ ] Multi-env deploys (dev → staging → prod) → `staged-rollout-gate` (Tier 3)
- [ ] GitHub PRs + code review workflow → `pr-review-pipeline` (Tier 2)
- [ ] OpenAPI/GraphQL spec file present → `spec-first-verification` (Tier 2) + `api-client-generation` (Tier 3)
- [ ] DB ORM + migrations directory → `database-schema-evolution` (Tier 3)
- [ ] Multiple `.env.*` files → `environment-parity-check` (Tier 3)
- [ ] Credentials/secrets management needed → `secret-rotation` (Tier 3)
- [ ] Large-scale refactor planned → `incremental-migration` (Tier 3) or `pattern-replacement` (Tier 3)
- [ ] Test suite present + no baseline → `regression-sweep` (Tier 3)
- [ ] IaC files (terraform, helm, cdk) → `infrastructure-drift-detection` (Tier 1)
- [ ] Complex or repeated module scaffolding → `template-instantiation` (Tier 1)
- [ ] Research-before-implement workflow → `explore-then-implement` (Tier 2)
- [ ] Multiple languages in repo → `conditional-branching` (Tier 2)
- [ ] Plan → implement → review pipeline → `workflow-chaining` (Tier 2)
- [ ] Package.json / pyproject.toml present → `dependency-audit` (Tier 1)
- [ ] Destructive ops (deploy, bulk delete) → `human-in-the-loop-approval` (Tier 3)

**Tier 3 installation note:** Each Tier 3 pattern includes a `settings-fragment.json`. You must **merge** (not overwrite) its `hooks` and `permissions` sections into `.claude/settings.json`. See the catalog's Installation Instructions section for the merge strategy.

---

## Phase 3: Present the Plan

Before creating any files, present a structured plan:

```
## Claude Code Customization Plan

### What I found
- Language/Framework: ...
- Existing config: ...
- Key signals: ...

### Files I'll create

#### Memory
- CLAUDE.md — [will create / will augment existing / already good]
- AGENTS.md — [will create / skip]
- .claude/rules/testing.md — paths: ["**/*.test.*"]
- .claude/rules/api-design.md — paths: ["src/api/**/*"]

#### Agents (.claude/agents/)
- researcher.md — read-only codebase researcher
- security-reviewer.md — [because: auth + Stripe detected]

#### Hooks (.claude/settings.json → hooks section)
- PreToolUse/Bash: bash-safety.sh — block dangerous commands
- PostToolUse/Edit|Write: auto-format.sh — runs prettier
- PostToolUse/Edit|Write: typecheck.sh (async) — runs tsc

#### MCP Servers (.mcp.json)
- github — [because: .github/ detected]
- context7 — [because: React + Express detected]

#### Project Skills (.claude/skills/)
- create-migration — [because: Prisma detected]

#### Workflow Patterns (from catalog)
- sequential-pipeline (Tier 3) — [because: CI/CD + feature scaffold workflow detected]
- pr-review-pipeline (Tier 2) — [because: GitHub PRs active]
  installs: .claude/skills/review-pr/, agents: diff-analyzer, security-reviewer, style-checker, coverage-checker, review-summarizer
- regression-sweep (Tier 3) — [because: test suite present, no baseline]
  installs: .claude/skills/regression-sweep/, hooks: capture-baseline.sh, merges settings-fragment.json

#### Permissions (.claude/settings.json)
- allow: git log/diff/status, pnpm test, pnpm lint
- ask: git push, pnpm db:migrate
- deny: git push --force, rm -rf, .env access

#### Other
- REVIEW.md — PR review focus areas
- .worktreeinclude — copy .env into worktrees
- .gitignore — add CLAUDE.local.md entries

Shall I create all of these? You can ask me to skip or adjust any item.
```

Wait for explicit user approval before proceeding. If the user wants adjustments, revise the plan.

---

## Phase 4: File Creation

### Architecture Compliance Check (do this before writing any file)

Re-read the relevant chapters of `references/claude-code-customization-architecture.md`
for every surface you are about to create. Specifically:

| File type you're writing | Architecture chapter to re-read |
|--------------------------|----------------------------------|
| CLAUDE.md / AGENTS.md / rules | Chapter 2 (Memory System) |
| .claude/agents/*.md | Chapter 3 (Sub-agents) — full frontmatter table in §3.2 |
| .claude/settings.json hooks | Chapter 5 (Hooks) — event taxonomy in §5.1, handler types in §5.2 |
| .mcp.json | Chapter 6 (MCP Servers) — §6.1 file location, §6.2 format |
| .claude/skills/*/SKILL.md | Chapter 7 (Skills) — full frontmatter table in §7.4 |
| Workflow pattern settings-fragment.json | Chapter 5 (Hooks) + Chapter 10 (Permissions) — merge strategy |
| settings.json permissions | Chapter 10 (Permission System) — §10.1 three buckets, §10.3 six modes |
| sandbox config | Chapter 10 §10.6 |
| .worktreeinclude | Chapter 11 (Worktrees) §11.3 |
| REVIEW.md | Chapter 16 §16.3 |

Flag any discrepancy between what you planned in Phase 2 and what the architecture says, and
correct the plan before writing. Common mistakes to catch:

- MCP servers written into `settings.json` instead of `.mcp.json` at project root
- Sub-agent frontmatter using `zze:` instead of `skills:`
- Permissions written with only `allow`/`deny`, missing the `ask` bucket
- Hooks using only `command` type when `prompt` or `agent` would be more appropriate
- CLAUDE.md containing workflow orchestration (belongs in a skill)
- Path-scoped rules missing the `paths:` frontmatter key
- Skill frontmatter missing `disable-model-invocation: true` for side-effecting skills
- Sub-agents omitting `disallowedTools` for read-only agents
- Workflow pattern `settings-fragment.json` overwriting instead of merging into `.claude/settings.json`
- Installing Tier 3 patterns without running `chmod +x` on hook scripts

Create files in this order (dependencies first):

1. **Hook scripts first** — `.claude/hooks/*.sh` — needed before settings.json references them
2. **Workflow pattern hook scripts** — copy from pattern source, run `chmod +x .claude/hooks/*.sh`
3. **.claude/settings.json** — hooks + permissions + sandbox (create or merge into existing)
4. **Workflow pattern settings-fragment.json** — merge (not replace) hooks and permissions into settings.json
5. **.mcp.json** — MCP servers at project root (NOT in settings.json)
6. **CLAUDE.md** — project memory
7. **AGENTS.md** — cross-platform agent instructions
8. **.claude/rules/*.md** — path-scoped rules
9. **.claude/agents/*.md** — sub-agent definitions (custom + pattern agents)
10. **.claude/skills/*/SKILL.md** — project-specific skills + installed workflow pattern skills
11. **REVIEW.md** — PR review instructions
12. **.worktreeinclude** — worktree file copy list
13. **.gitignore** — add entries if needed

### Critical correctness rules

**CLAUDE.md:** Keep under 200 lines. Don't put workflow orchestration in it (use skills). Don't include module-specific content (use rules). Don't include secrets (use CLAUDE.local.md).

**AGENTS.md:** Build/test/lint commands, code style, architecture. NOT Claude-specific content (that goes in CLAUDE.md).

**.claude/rules/*.md frontmatter:**
```yaml
---
paths:
  - "**/*.test.ts"
---
```
Rules without `paths:` load always-on like CLAUDE.md. Rules with `paths:` load lazily — major token saver.

**Sub-agent frontmatter** (correct fields per revised architecture):
```yaml
---
name: security-reviewer
description: >
  Reviews code for security vulnerabilities. Use when reviewing PRs,
  auditing auth/payment/PII code, evaluating third-party integrations.
model: opus
effort: high
tools: [Read, Grep, Glob, Bash]
disallowedTools: [Write, Edit, MultiEdit]
maxTurns: 10
memory: project
---
```
Do NOT use `zze:` — the correct field is `skills:`. Include `effort:` for review agents (`high`). Include `memory: project` for agents that accumulate codebase knowledge.

**Skill frontmatter** (correct fields):
```yaml
---
name: create-migration
description: Generate and apply a database migration. Use when the user asks to add a column, create a table, or modify schema.
disable-model-invocation: true
argument-hint: "[description of schema change]"
allowed-tools: Read, Bash, Write
---
```

**.mcp.json** — MUST be at project root, not in settings.json:
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    }
  }
}
```

**settings.json permissions:** Include all three buckets:
```json
{
  "permissions": {
    "allow": ["Bash(git log *)", "Bash(pnpm test *)"],
    "ask":   ["Bash(git push *)", "Bash(pnpm db:migrate *)"],
    "deny":  ["Bash(git push --force *)", "Bash(rm -rf *)", "Read(./.env)"]
  }
}
```

**Hook scripts:** Make executable. Use jq for JSON parsing. Exit 0 to allow, exit 2 to block:
```bash
#!/usr/bin/env bash
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')
if echo "$command" | grep -qE 'rm\s+-rf\s+/|sudo\s+rm'; then
  echo '{"decision":"block","reason":"Dangerous command blocked"}' >&2
  exit 2
fi
exit 0
```

Create hook scripts in `.claude/hooks/` and register them in `.claude/settings.json` under `hooks`.

---

## Phase 5: Post-Creation Summary

After creating all files, show:

```
## Created Files

Memory:
  ✅ CLAUDE.md
  ✅ AGENTS.md
  ✅ .claude/rules/testing.md (lazy: **/*.test.ts)

Agents:
  ✅ .claude/agents/researcher.md
  ✅ .claude/agents/security-reviewer.md

Hooks:
  ✅ .claude/hooks/bash-safety.sh
  ✅ .claude/hooks/auto-format.sh
  → registered in .claude/settings.json

MCP:
  ✅ .mcp.json (github, context7)

Skills:
  ✅ .claude/skills/create-migration/SKILL.md

Workflow Patterns:
  ✅ sequential-pipeline (Tier 3) — .claude/skills/sequential-pipeline/, hooks: pipeline-gate.sh
  ✅ pr-review-pipeline (Tier 2) — .claude/skills/review-pr/, agents: diff-analyzer + 4 others

## Next Steps

1. Run `git add .claude/ CLAUDE.md AGENTS.md .mcp.json REVIEW.md .worktreeinclude`
2. Add to .gitignore: CLAUDE.local.md, .claude/settings.local.json
3. Set env vars needed by MCP servers: GITHUB_TOKEN
4. Run `/memory` to see which files loaded into context
5. Run `/agents` to verify sub-agents registered
6. Run `/hooks` to verify hooks registered
7. Run `/mcp` to verify MCP servers connected

Want me to create a CLAUDE.local.md for personal machine-specific settings?
Want me to set up an output style for this project?
```

---

## Key Differences from `claude-automation-recommender`

This skill **creates files**, not just recommendations. It also covers surfaces the recommender
does not address:

| Surface | Recommender | This Skill |
|---------|-------------|------------|
| AGENTS.md (cross-platform) | ❌ | ✅ |
| Path-scoped .claude/rules/ | ❌ | ✅ |
| All 30+ hook events | Partial (7) | ✅ |
| `ask` permission bucket | ❌ | ✅ |
| Sandboxing config | ❌ | ✅ |
| Output styles | ❌ | ✅ (guidance) |
| REVIEW.md for PR review | ❌ | ✅ |
| .worktreeinclude | ❌ | ✅ |
| Sub-agent memory/effort/isolation | ❌ | ✅ |
| Skill: allowed-tools/context/fork | ❌ | ✅ |
| Correct .mcp.json placement | Partial | ✅ |
| 4 hook handler types | Only command | ✅ |
| Actually writes files | ❌ | ✅ |
| 33 workflow patterns (catalog) | ❌ | ✅ |
| Pattern detection signals | ❌ | ✅ |
| Pattern settings-fragment merge | ❌ | ✅ |
