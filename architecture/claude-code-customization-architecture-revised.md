# Claude Code Customization Architecture — Revised
## Memory · Rules · Sub-agents · Agent Teams · Hooks · MCP · Skills · Plugins · Output Styles · Permissions · Sandboxing · Worktrees
### Best Practices for Engineers ｜ Principal Engineer Perspective
#### May 2026 — revised against current Claude Code documentation

> This is a full revision of `claude-code-customization-architecture.md` (March 2026). It corrects model references, frontmatter fields, the hook event taxonomy, the MCP file location, the slash-command/skill unification, the settings precedence order, and the sub-agent nesting claim — and adds the chapters that were missing (Plugins, Agent Teams, Output Styles, Status Line, Sandboxing, Auto/Plan modes, Worktrees, Auto-memory, Surfaces, Observability). Every claim in this document is anchored to current Claude Code documentation at <https://code.claude.com/docs/en/>.

---

## Table of Contents

1. [Architecture Overview — Ten Customization Surfaces](#chapter-1-architecture-overview)
2. [Memory System — CLAUDE.md, AGENTS.md, Rules, and Auto-memory](#chapter-2-memory-system)
3. [Sub-agents — Role Design, Isolation, Memory, and Forks](#chapter-3-sub-agents)
4. [Agent Teams — Multi-teammate Parallel Execution](#chapter-4-agent-teams)
5. [Hooks — The Full Event Taxonomy and Four Handler Types](#chapter-5-hooks)
6. [MCP Servers — `.mcp.json`, Tool Search, OAuth, Managed MCP](#chapter-6-mcp-servers)
7. [Skills (and Legacy Slash Commands) — Unified Workflows](#chapter-7-skills)
8. [Plugins and Marketplaces — Distributable Customization Bundles](#chapter-8-plugins-and-marketplaces)
9. [Output Styles, Status Line, Keybindings — Interface Customization](#chapter-9-interface-customization)
10. [Permission System, Sandboxing, Plan and Auto Modes](#chapter-10-permission-system)
11. [Worktrees and Parallel Execution](#chapter-11-worktrees)
12. [Where Does the Workflow Belong? — Component Placement](#chapter-12-where-does-the-workflow-belong)
13. [Complete Project Structure Example](#chapter-13-complete-project-structure-example)
14. [Token Cost Strategy](#chapter-14-token-cost-strategy)
15. [Security Best Practices](#chapter-15-security-best-practices)
16. [Surfaces and Integrations — CLI, Web, Desktop, IDEs, Slack, CI](#chapter-16-surfaces-and-integrations)
17. [Observability — OpenTelemetry, `/usage`, Analytics](#chapter-17-observability)
18. [Appendix A — Settings Reference and Precedence](#appendix-a-settings-reference)
19. [Appendix B — Permission Modes Reference](#appendix-b-permission-modes)
20. [Appendix C — Hook Event Reference](#appendix-c-hook-events)
21. [Appendix D — AGENTS.md vs CLAUDE.md](#appendix-d-agents-md)
22. [Appendix E — Migrating from Older Patterns](#appendix-e-migration)
23. [Appendix F — Claude Code vs GitHub Copilot Comparison (Updated)](#appendix-f-comparison)

---

## Chapter 1: Architecture Overview

Claude Code's customization system is built around **ten** cooperating surfaces. Each one is a plain text file (or set of files) tracked in version control. The core philosophy is unchanged: **file-first, code-native, observable, auditable**. What has changed is the breadth of the surface area — Claude Code is no longer just a terminal CLI, and its customization model now spans the web app, desktop app, VS Code, JetBrains, Slack, GitHub Actions, GitLab CI, and Chrome.

| Surface | Analogy | Loading Behavior | Configuration Location |
|---|---|---|---|
| **Memory files** | Employee handbook / project wiki | Always-on or path-scoped | `CLAUDE.md`, `AGENTS.md`, `~/.claude/CLAUDE.md`, `CLAUDE.local.md`, `.claude/rules/*.md` |
| **Auto-memory** | A teammate's running notes | Auto-loaded by Claude across sessions | `~/.claude/projects/<project>/memory/MEMORY.md` |
| **Sub-agents** | Specialized teammates | On-demand (auto-delegated or explicit) | `.claude/agents/*.md`, `~/.claude/agents/*.md` |
| **Agent teams** | A parallel project squad | Lead spawns teammates in tmux panes | Existing sub-agent files; activated per-task |
| **Hooks** | Security checkpoints / automation triggers | 30+ lifecycle events | `settings.json` → `hooks` |
| **MCP servers** | External tool integrations | Session startup; deferred tool schemas | `.mcp.json` (project), `~/.claude.json` (user/local) |
| **Skills** (and legacy commands) | Reusable invocable workflows | User-invoked or Claude-invoked | `.claude/skills/<name>/SKILL.md`, `.claude/commands/*.md` |
| **Plugins** | Distributable customization bundles | Installed from marketplaces | `~/.claude/plugins/cache/`, `~/.claude/plugins/data/` |
| **Output styles** | Adjustments to Claude's system prompt | Selected via `outputStyle` setting | `.claude/output-styles/*.md`, `~/.claude/output-styles/*.md` |
| **Status line / keybindings** | Terminal UX | Loaded at session start | `settings.json` → `statusLine`, `~/.claude/keybindings.json` |

### Architectural Principles

- **Memory layer** (`CLAUDE.md`, `AGENTS.md`, `rules/`, auto-memory) establishes *who you are and what you know*.
- **Role layer** (sub-agents, agent teams) defines *who does specialized work*.
- **Safety layer** (hooks, permission rules, sandboxing) ensures *it's done safely and within bounds*.
- **Tool layer** (MCP, LSP) decides *what external capabilities are available*.
- **Workflow layer** (skills, commands, plugins) provides *repeatable task shortcuts*.
- **Interface layer** (output styles, status line, keybindings) tunes *how Claude presents itself*.
- **Distribution layer** (plugins, marketplaces) packages all of the above for sharing.

### Settings Precedence (Top Wins)

This is one of the most commonly misunderstood parts of Claude Code. The precedence order is:

```
Managed (server-managed, MDM, plist/registry, managed-settings.json)
        ↓
CLI flags (--permission-mode, --settings, --add-dir, --plugin-dir, ...)
        ↓
.claude/settings.local.json   (local, gitignored)
        ↓
.claude/settings.json         (project, committed)
        ↓
~/.claude/settings.json       (user-global)
```

Array settings like `permissions.allow` **merge** across all scopes (combined and de-duplicated). Scalar settings like `model` use the highest-priority value. Memory files (`CLAUDE.md`, `AGENTS.md`, `rules/`) work differently — they are all *combined into context*; conflicting instructions are resolved in favor of the more specific scope (project root > sub-directory > user-global).

---

## Chapter 2: Memory System

Claude Code's memory system has six distinct surfaces. The original architecture only covered four — this chapter adds `CLAUDE.local.md`, `.claude/rules/`, and auto-memory.

### 2.1 The Six Memory Surfaces

| # | Surface | Location | Loading | Scope | Committed? |
|---|---|---|---|---|---|
| 1 | Project Memory | `CLAUDE.md` (repo root) or `.claude/CLAUDE.md` | Always-on in this project | All collaborators | ✅ Yes |
| 2 | Cross-platform Agent Memory | `AGENTS.md` (repo root) | Always-on in any AI tool that supports it | All collaborators on any AI tool | ✅ Yes |
| 3 | User Memory | `~/.claude/CLAUDE.md` | Always-on globally | Just you, all projects | ❌ Local only |
| 4 | Local Project Memory | `CLAUDE.local.md` (repo root) | Always-on in this project | Just you, this project | ❌ Gitignored manually |
| 5 | Path-scoped Rules | `.claude/rules/<topic>.md` | Lazy: when matching files enter context | Project (or user via `~/.claude/rules/`) | ✅ Yes |
| 6 | Auto-memory | `~/.claude/projects/<project>/memory/MEMORY.md` | Always-on, **Claude writes it** | Just you, per-project | ❌ Local only |

> ⚠️ **Local override file is `CLAUDE.local.md` at the repo root, not `.claude/CLAUDE.md`.** The earlier `claude-code-customization-architecture.md` had this wrong. `.claude/CLAUDE.md` is just an alternative location for the *committed* project memory — not for personal overrides.

### 2.2 Project CLAUDE.md — Best Practices

The project `CLAUDE.md` is loaded on every session within the project directory. Treat it as a high-priority resource:

- ✅ Keep it focused: target **under 200 lines**. Longer files still load but reduce adherence.
- ✅ Include build/test/lint commands so Claude never guesses.
- ✅ Document the tech stack, key architectural decisions, folder conventions.
- ✅ List anti-patterns the team has explicitly rejected (and why).
- ❌ **Do not embed lengthy workflow orchestration logic.** Use a Skill (Chapter 7).
- ❌ Do not include module-specific content. Use a path-scoped rule (Section 2.5).
- ❌ Do not include secrets, API keys, or machine-local paths. Use `CLAUDE.local.md` and add it to `.gitignore`.

When `CLAUDE.md` approaches 200 lines, **start splitting it into rules**.

### 2.3 CLAUDE.md Structure Example

```markdown
# Project: Acme API Platform

## Tech Stack
- Runtime: Node.js 22 with TypeScript strict mode
- Framework: Fastify 5
- Database: PostgreSQL 16 via Drizzle ORM
- Testing: Vitest + Supertest
- Package manager: pnpm

## Build & Test Commands
- Install: `pnpm install`
- Build: `pnpm build`
- Test (all): `pnpm test`
- Test (single file): `pnpm test -- src/auth/auth.service.test.ts`
- Lint: `pnpm lint:fix`
- DB migrations: `pnpm db:migrate`

## Coding Conventions
- All functions must have JSDoc with @param and @returns
- Prefer `Result<T, E>` over thrown exceptions for expected errors
- Co-locate tests next to source files: `auth.service.ts` → `auth.service.test.ts`
- Never use `any`; use `unknown` and narrow explicitly

## Architecture Decisions
- Route handlers are thin — business logic lives in service files
- All DB queries go through the repository layer
- Auth is handled by `src/auth/`; do not re-implement elsewhere

## Explicit Anti-patterns (Do Not Use)
- `express` (use Fastify instead)
- `moment` (use `date-fns`)
- Class-based services (use plain functions with dependency injection)
```

### 2.4 AGENTS.md — Cross-platform Standard

`AGENTS.md` is an **open, cross-platform specification** for AI coding agents, recognized by Claude Code, GitHub Copilot, Cursor, OpenAI Codex, Google Jules, Factory, and 20+ other tools. It is stewarded by the Agentic AI Foundation under the Linux Foundation.

**Use AGENTS.md for content that should work across any AI tool:**

- Build/test/lint commands
- Code style and naming conventions
- Architecture overview
- Commit conventions

**Use CLAUDE.md for content that is Claude Code-specific:**

- Sub-agent workflow notes
- References to specific skills, hooks, or MCP servers
- Output style preferences
- Anti-patterns specific to Claude Code's tooling

You can have both — they both load into context together. To avoid duplication, you can `@`-import inside CLAUDE.md:

```markdown
# CLAUDE.md

@AGENTS.md

## Claude-specific notes
- After implementing features, invoke the `code-reviewer` sub-agent before presenting results.
- Use the `/run-migration` skill for any schema change — it handles rollback verification.
```

### 2.5 Path-scoped Rules — `.claude/rules/`

Rules are the modern replacement for sub-directory `CLAUDE.md` files. They live as individual topic files under `.claude/rules/` and can be **lazy-loaded** based on which files Claude is working with.

```
.claude/rules/
├── testing.md              # Loads when paths: globs match
├── api-design.md           # Loads when working in src/api/
├── style.md                # No paths: → loads at session start (always-on)
└── frontend/
    └── react.md            # Nested directories work; auto-discovered
```

A rule with `paths:` frontmatter loads only when a file matching the glob enters context:

```yaml
---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
---

# Testing Rules

- Use descriptive test names: "should [expected] when [condition]"
- Mock external dependencies, not internal modules
- Clean up side effects in afterEach
```

A rule without `paths:` loads at session start, like CLAUDE.md.

> **Rule of thumb:** if a rule applies to fewer than half the files in your project, scope it with `paths:`. The token savings compound across long sessions.

### 2.6 Auto-memory — Claude's Notes to Itself

This is one of the most powerful and least-known features. **Claude writes and maintains a memory file across sessions**, accumulating knowledge about your project (build commands, debugging insights, architecture observations) without you authoring anything.

Auto-memory is on by default. Toggle with `/memory` mid-session or with `autoMemoryEnabled` in settings.

**Storage layout:**

```
~/.claude/projects/<encoded-project-path>/memory/
├── MEMORY.md          # Index file — first 200 lines (or 25 KB) load every session
├── debugging.md       # Topic file — read on demand when relevant
├── architecture.md    # Topic file
└── build-and-test.md  # Topic file
```

`MEMORY.md` is the index Claude reads at the start of every session. Topic files are split out automatically when MEMORY.md grows too long; Claude reads them lazily when a related task surfaces. You can edit or delete them — Claude will keep updating them.

**Privacy & operational notes:**

- Auto-memory is local-only. It is not committed and not shared.
- Storage location can be moved with `autoMemoryDirectory` (only accepted from policy and user settings, not project — to prevent a malicious clone from redirecting writes).
- Disable with `autoMemoryEnabled: false` if your organization requires it.

### 2.7 Memory Layer Composition

When multiple files are in scope, all are merged into context. **Conflicts are resolved toward the more specific scope.**

```
Layer 0: ~/.claude/CLAUDE.md (User Memory) — least specific
Layer 1: AGENTS.md (committed, project root)
Layer 2: CLAUDE.md (committed, project root)
Layer 3: .claude/rules/*.md without paths: (committed, project)
Layer 4: CLAUDE.local.md (gitignored, project)
Layer 5: ~/.claude/projects/<project>/memory/MEMORY.md (auto-memory)
Layer 6: .claude/rules/*.md with paths: (loaded only when matching file is in context) — most specific
```

> **Important correction.** The original architecture document put user memory at "highest precedence." That was wrong. User memory has the **lowest** precedence — project root and any narrower scope (rules, sub-directory CLAUDE.md, CLAUDE.local.md) override it on conflicts. Memory is *combined* (not key-merged like settings.json), and disagreements resolve toward the file closest to the work.

### 2.8 What to Inspect in a Live Session

| Slash command | Shows |
|---|---|
| `/context` | Full token-by-category breakdown |
| `/memory` | Which CLAUDE.md/rules files loaded, plus auto-memory entries |
| `/agents` | Configured subagents and their settings |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/skills` | Available skills (project + user + plugin sources) |
| `/permissions` | Current allow/ask/deny rules |
| `/doctor` | Installation and config diagnostics |

When something seems "off" with what Claude knows, run `/context` first.

---

## Chapter 3: Sub-agents

Sub-agents are specialized Claude Code instances with their own persona, tool set, model, permission scope, and (optionally) persistent memory. A parent agent or the user can delegate tasks to sub-agents, enabling **automated divide-and-conquer workflows**.

### 3.1 Built-in Sub-agents

Claude Code ships with three built-in sub-agents available in every session:

| Name | Purpose |
|---|---|
| `Explore` | Read-only research; ideal for `context: fork` skills that gather context |
| `Plan` | Plan-mode partner; produces structured plans without writing code |
| `general-purpose` | Default fallback for custom skills using `context: fork` |

Reference these in skill frontmatter via `agent: Explore`, `agent: Plan`, or `agent: general-purpose`.

### 3.2 Sub-agent File Format and Full Frontmatter

Sub-agents are Markdown files with YAML frontmatter, stored in `~/.claude/agents/` (user-global) or `.claude/agents/` (project-scoped).

**Complete frontmatter reference** (corrected and expanded from the original document):

| Field | Type | Description |
|---|---|---|
| `name` | string | Unique identifier (used for invocation) |
| `description` | string | **Critical**: Claude reads this to decide *when* to invoke. Front-load triggers and use cases |
| `model` | string | Model alias (`sonnet`, `opus`, `haiku`) or pinned ID (e.g., `claude-sonnet-4-6`) |
| `effort` | enum | `low` \| `medium` \| `high` \| `xhigh` (Opus 4.6 only) — extended-thinking budget |
| `maxTurns` | integer | Cap on agentic turns; prevents runaway loops |
| `tools` | list | Explicit tool allowlist (omit to inherit parent's tools) |
| `disallowedTools` | list | Explicit blocklist; takes precedence over `tools` |
| `permissionMode` | enum | `default` \| `acceptEdits` \| `plan` \| `auto` \| `dontAsk` \| `bypassPermissions` |
| `mcpServers` | list | MCP servers available to this sub-agent (by name) |
| `hooks` | object | Per-sub-agent hooks (lifecycle events scoped to this agent) |
| `skills` | list | Skills preloaded into this sub-agent at startup |
| `memory` | enum | `project` \| `local` \| `user` — enable persistent memory at `agent-memory/` (see 3.4) |
| `background` | bool | Run sub-agent in the background |
| `isolation` | string | `worktree` — run sub-agent in an isolated git worktree (game-changer for parallelism) |
| `disabled` | bool | Disable without deleting |

> ⚠️ **Removed from the original document:** the `zze` field was a typo/hallucination. There is no such field. The correct field for preloading skills is `skills`.

> ⚠️ **Plugin-shipped sub-agents have a restricted frontmatter:** for security, plugin agents cannot use `hooks`, `mcpServers`, or `permissionMode`. This is enforced by the plugin runtime.

### 3.3 Example Sub-agent

```yaml
---
name: security-reviewer
description: >
  Analyzes code for security vulnerabilities including injection attacks,
  authentication flaws, insecure dependencies, and secrets exposure.
  Use when reviewing PRs, auditing new modules, or evaluating third-party code.
model: opus
effort: high
tools:
  - Read
  - Grep
  - Glob
  - Bash
disallowedTools:
  - Write
  - Edit
  - MultiEdit
maxTurns: 10
mcpServers:
  - semgrep-mcp
memory: project
---

You are a security specialist focused exclusively on identifying vulnerabilities.

For every code review:
1. Check for injection vulnerabilities (SQL, command, path traversal)
2. Verify authentication and authorization logic
3. Scan for hardcoded secrets or insecure credential handling
4. Check dependency versions against known CVE databases
5. Assess input validation completeness

Return a structured report: severity (Critical/High/Medium/Low), location,
description, and recommended fix for each finding.
```

### 3.4 Sub-agent Persistent Memory

Sub-agents that set `memory:` in frontmatter get a dedicated memory directory the sub-agent writes to itself across runs:

| `memory:` value | Storage location | Committed? |
|---|---|---|
| `project` | `.claude/agent-memory/<agent-name>/MEMORY.md` | ✅ Yes (team-shared) |
| `local` | `.claude/agent-memory-local/<agent-name>/MEMORY.md` | ❌ Gitignored |
| `user` | `~/.claude/agent-memory/<agent-name>/MEMORY.md` | ❌ Cross-project |

The first 200 lines (capped at 25 KB) of `MEMORY.md` are loaded into the sub-agent's system prompt at startup. The sub-agent reads it at the start of each task and writes back what it learns. You don't author this file — the sub-agent does.

This is **distinct from your main session auto-memory** at `~/.claude/projects/`. Each sub-agent has its own.

### 3.5 Context Isolation, Forks, and Chaining

Sub-agents run in an **isolated context** — they don't inherit the parent's history, only the instructions passed at invocation. This gives:

1. **Security**: a sub-agent cannot exfiltrate context it was never given
2. **Focus**: the sub-agent's window is used entirely for its task
3. **Token efficiency**: the parent's history doesn't inflate sub-agent costs
4. **Parallelism**: many sub-agents can run concurrently with no shared state

```
Parent (full context)
   │
   ├── delegates task + relevant snapshot ──→ Sub-agent A (isolated)
   │                                              └── returns result
   │
   └── delegates task + relevant snapshot ──→ Sub-agent B (isolated)
                                                  └── returns result
```

> **Correction from the original document:** sub-agents *can* be chained. The "single-level only" claim is no longer accurate. The official docs document a "Chain subagents" pattern, and Agent Teams (Chapter 4) extend this further with parallel coordination.

In addition, **forks** let you observe and steer a running sub-agent:

```
/fork
```

A fork runs a parallel branch of the conversation that you can interact with while the main session continues. Forks differ from named sub-agents in that they share the full context but execute independently.

### 3.6 Worktree Isolation

Setting `isolation: worktree` runs the sub-agent in a **fresh git worktree**, fully isolated from the main checkout. This is the foundation of high-parallelism patterns like `/batch` (which spawns one sub-agent per work unit, each in its own worktree, each opening its own PR).

```yaml
---
name: parallel-implementer
description: Implements one slice of a larger migration in isolation
isolation: worktree
tools: [Read, Write, Edit, MultiEdit, Bash]
maxTurns: 30
---

Implement the slice described in $ARGUMENTS. Run tests before finishing.
```

When the sub-agent finishes, the worktree is cleaned up (configurable via `WorktreeRemove` hooks).

### 3.7 Pattern: Automated Quality Loop

```yaml
# .claude/agents/code-reviewer.md
---
name: code-reviewer
description: >
  Reviews code changes for quality, security, test coverage, and adherence
  to project standards. Use after implementing any non-trivial feature or fix.
model: opus
effort: high
tools: [Read, Grep, Glob, Bash]
disallowedTools: [Write, Edit, MultiEdit]
maxTurns: 8
---

Review the provided changes. Score 1–5 on:
- Security: injection safety, auth checks, input validation
- Correctness: edge cases, error handling, type safety
- Maintainability: naming, separation of concerns, comments
- Test coverage: key paths and edge cases

Return: overall score (1–5), list of issues with file/line references, and
concrete suggested fixes. Do not approve (score < 4) if any Critical or High
severity issues exist.
```

Combine with a `Stop` hook that re-invokes the implementer if the reviewer scores < 4.

### 3.8 Pattern: Research-Then-Implement

```yaml
# .claude/agents/researcher.md
---
name: researcher
description: >
  Researches the existing codebase to gather context, identify patterns,
  locate relevant files, and map dependencies. Use before implementing new features.
tools: [Read, Grep, Glob, Bash]
disallowedTools: [Write, Edit, MultiEdit]
maxTurns: 15
---

Research thoroughly using read-only tools. Return:
- Relevant files and their purpose
- Existing patterns and conventions to follow
- Dependencies that will be affected
- Potential conflicts or risks
- Recommended implementation approach
```

```yaml
# .claude/agents/implementer.md
---
name: implementer
description: >
  Implements code changes based on a research summary and plan.
  Use when context has been gathered and a plan is ready.
tools: [Read, Write, Edit, MultiEdit, Bash]
maxTurns: 30
---

Implement the provided plan faithfully. Follow all conventions identified
in the research summary. Write tests alongside implementation code.
```

---

## Chapter 4: Agent Teams

**This chapter is new.** Agent teams are a major release — they take divide-and-conquer past simple sub-agent chaining into multi-teammate coordination with a designated lead.

### 4.1 What an Agent Team Is

An agent team consists of:

- **A lead agent** — coordinates the team, claims and assigns tasks, holds the user-facing context
- **One or more teammates** — each is a sub-agent definition, running in its own tmux pane
- **A shared task list** — visible to the lead and all teammates

The lead and teammates communicate through the task list. Each teammate runs in an isolated context window (potentially with `isolation: worktree`), works on its assigned task, and returns when done.

### 4.2 When to Use Agent Teams vs Sub-agents

| Scenario | Use |
|---|---|
| Single delegated task | Sub-agent |
| Sequential research → implement → review | Sub-agent chain |
| 3+ truly parallel work units sharing a goal | **Agent team** |
| Competing-hypothesis investigations | Agent team |
| Code review with multiple specialists | Agent team |

### 4.3 Starting a Team

```
/team
```

The lead asks who should be on the team and what each teammate should do, then spawns the panes. You can also pre-specify:

```
/team start --teammates security-reviewer,perf-reviewer,style-reviewer "review PR #1234"
```

Each teammate uses an existing sub-agent definition. You don't create separate "team" files.

### 4.4 Quality Gates with Hooks

The `TeammateIdle` hook fires when a teammate is about to stop. Use it to enforce gates:

```json
{
  "hooks": {
    "TeammateIdle": [{
      "matcher": "*",
      "hooks": [{
        "type": "prompt",
        "prompt": "Review the teammate's output. If a Critical or High issue is unresolved, return decision=block with specific guidance. Otherwise allow."
      }]
    }]
  }
}
```

### 4.5 Best Practices

- **Give teammates enough context** — they don't share the lead's history; pass plans and findings explicitly.
- **Keep teams small** — 3–5 teammates is the sweet spot. Coordination overhead grows quickly.
- **Avoid file conflicts** — assign disjoint paths or use `isolation: worktree`.
- **Start with research and review tasks** — they parallelize naturally and have low conflict risk.
- **Wait for teammates to finish** — interrupting mid-task wastes work.

---

## Chapter 5: Hooks

Hooks are **deterministic event handlers** that fire at specific lifecycle points. The original document listed five hook events. The current count is **30+**, and there are now **four handler types** (not just shell commands).

> **Token impact:** `command` and `http` hooks consume **zero tokens**. `prompt` and `agent` hooks invoke an LLM and **do** consume tokens. Choose accordingly.

### 5.1 The Full Event Taxonomy

Group events by category:

**Session lifecycle**
- `SessionStart` — session begins or resumes
- `Setup` — fires after auth/init, before user input
- `InstructionsLoaded` — CLAUDE.md or rules file enters context
- `SessionEnd` — session terminates

**User input**
- `UserPromptSubmit` — user submitted a prompt
- `UserPromptExpansion` — `@`-imports or skill expansions resolved

**Tool calls**
- `PreToolUse` — before a tool call (can block)
- `PermissionRequest` — permission dialog appears
- `PostToolUse` — after a tool call succeeded
- `PostToolUseFailure` — after a tool call failed
- `PostToolBatch` — after a batch of tool calls
- `PermissionDenied` — auto-mode classifier denied a tool

**Sub-agents**
- `SubagentStart`
- `SubagentStop`

**Tasks (TodoWrite tool)**
- `TaskCreated`
- `TaskCompleted`

**Stop / errors**
- `Stop` — Claude finished responding
- `StopFailure` — turn ended due to API error
- `Notification` — Claude sent a notification

**Agent teams**
- `TeammateIdle` — a teammate is about to go idle

**Filesystem / config / worktrees**
- `ConfigChange` — a config file changed during a session
- `CwdChanged` — working directory changed (e.g., Claude ran `cd`)
- `FileChanged` — a watched file changed on disk (`matcher` selects which files)
- `WorktreeCreate` — replaces default git worktree creation
- `WorktreeRemove` — at session exit or sub-agent finish

**Compaction**
- `PreCompact`
- `PostCompact`

**MCP**
- `Elicitation` — MCP server requested user input
- `ElicitationResult` — user responded to elicitation

A complete reference with input/output schemas for each event is at <https://code.claude.com/docs/en/hooks.md>.

### 5.2 The Four Handler Types

| Type | Description | Token cost |
|---|---|---|
| `command` | Shell command; receives JSON on stdin, emits JSON or exit code | 0 |
| `http` | POST event JSON to a URL; subject to `allowedHttpHookUrls` | 0 |
| `prompt` | Evaluate a prompt with an LLM; uses `$ARGUMENTS` for context | Yes |
| `agent` | Run an agentic verifier with tools (for complex verification) | Yes |

### 5.3 Hook Configuration Format

Hooks are defined in `settings.json` under the `hooks` key. The format supports multiple types side-by-side:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/validate-bash.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/auto-format.sh" }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Review the conversation. If the task is incomplete or the user's question is unanswered, return decision=block with a clear next step. Otherwise allow."
          }
        ]
      }
    ],
    "FileChanged": [
      {
        "matcher": "**/*.ts",
        "hooks": [
          { "type": "command", "command": "pnpm test --silent" }
        ]
      }
    ]
  }
}
```

### 5.4 Command Hook Protocol

Command hooks use a stdin/stdout protocol. The hook receives JSON on stdin describing the event. It can respond with:

**Exit codes:**

| Code | Meaning |
|---|---|
| `0` | Allow the operation to proceed |
| `2` | **Block** the operation |
| Any other | Non-blocking failure (logged) |

**Or structured JSON output** (recommended for richer behavior):

```json
{
  "decision": "block",
  "reason": "Force pushes are not permitted",
  "hookSpecificOutput": {
    "additionalContext": "git log --oneline shows ..."
  }
}
```

JSON output supports decision control, context injection, tool-input modification, and async deferral. See <https://code.claude.com/docs/en/hooks.md> for the full schema.

### 5.5 Async Hooks

Hooks can run asynchronously by setting `async: true`. The agent loop continues without waiting; the hook's eventual output is logged or fed back as context:

```json
{
  "PostToolUse": [
    {
      "matcher": "Edit|Write",
      "hooks": [
        { "type": "command", "command": "pnpm test", "async": true }
      ]
    }
  ]
}
```

Use async for slow validation that would otherwise block.

### 5.6 Example: Block Dangerous Bash Commands

```bash
#!/usr/bin/env bash
# ~/.claude/hooks/validate-bash.sh
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Block destructive patterns
if echo "$command" | grep -qE 'rm\s+-rf\s+/|sudo\s+rm|>>\s*/etc|chmod\s+777'; then
  echo '{"decision":"block","reason":"Dangerous command pattern detected"}' >&2
  exit 2
fi

# Block git force pushes
if echo "$command" | grep -qE 'git push.*--force|git push.*-f'; then
  echo '{"decision":"block","reason":"Force pushes are not permitted"}' >&2
  exit 2
fi

exit 0
```

### 5.7 Example: Auto-format on Write

```bash
#!/usr/bin/env bash
# ~/.claude/hooks/auto-format.sh
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
[[ -z "$file_path" ]] && exit 0
case "$file_path" in
  *.ts|*.tsx)  npx prettier --write "$file_path" 2>/dev/null ;;
  *.py)        ruff format "$file_path" 2>/dev/null ;;
  *.go)        gofmt -w "$file_path" 2>/dev/null ;;
  *.rs)        rustfmt "$file_path" 2>/dev/null ;;
esac
exit 0
```

### 5.8 Example: LLM-based Stop Gate

A `prompt` hook lets you encode complex quality gates without writing code:

```json
{
  "Stop": [
    {
      "matcher": "*",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "The conversation has ended. Read the last user message and the assistant's response. If the user's question is unanswered, decision=block and provide a one-line next step. If complete, decision=allow.",
          "model": "haiku"
        }
      ]
    }
  ]
}
```

### 5.9 Per-Sub-agent Hooks

Hooks scoped to a specific sub-agent go in the sub-agent's frontmatter:

```yaml
---
name: database-migrator
description: Runs and manages database schema migrations
tools: [Read, Bash]
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: bash .claude/hooks/require-migration-prefix.sh
---
```

Plugin-shipped sub-agents **cannot** define hooks (security restriction). Project and user sub-agents can.

### 5.10 Hook Security

| Risk | Mitigation |
|---|---|
| Hook scripts as attack surface | Version-control all hooks; review changes; keep them small and single-purpose |
| Hook with write access modifying important files | Hooks should read inputs and emit decisions; avoid side effects beyond logging and formatting |
| `bypassPermissions` defeats hooks for that scope | Audit any sub-agent using `bypassPermissions`; document justification; prohibit in production CI |
| Slow hooks blocking the loop | Set timeouts; use `async: true` for slow validation. Target < 500 ms for synchronous hooks |
| HTTP hook leaking secrets | Use `allowedHttpHookUrls` to restrict targets; use `httpHookAllowedEnvVars` to restrict env interpolation |
| `prompt`/`agent` hook prompt-injection from tool outputs | Treat hook prompts like any other LLM call; isolate untrusted input |

---

## Chapter 6: MCP Servers

> **Important correction.** Project-scope MCP servers go in **`.mcp.json` at the project root**, not in `.claude/settings.json`. The original architecture document had this wrong. User- and local-scope MCP servers live in `~/.claude.json`.

### 6.1 Where MCP Servers Live

| Scope | File | Committed? |
|---|---|---|
| Project (team-shared) | `.mcp.json` (repo root) | ✅ Yes |
| User (cross-project) | `~/.claude.json` | ❌ No |
| Local (this project, just you) | `~/.claude.json` (per-project entries) | ❌ No |
| Plugin-bundled | Inside the plugin | Distributed via plugin |
| Managed | `managed-mcp.json` | Enterprise-deployed |

Add via CLI:

```bash
# Project-scope (writes to .mcp.json)
claude mcp add github --command "npx" --args "-y,@modelcontextprotocol/server-github"

# User-scope (writes to ~/.claude.json)
claude mcp add --scope user brave-search ...

# Local-scope (writes to ~/.claude.json with per-project key)
claude mcp add --scope local some-server ...
```

### 6.2 `.mcp.json` Format

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    },
    "search": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${SEARCH_TOKEN}"
      }
    }
  }
}
```

### 6.3 Transport Types

| Type | Use Case | Config |
|---|---|---|
| `stdio` (default) | Local processes — npm packages, Python scripts, binaries | `command` + `args` + optional `env` |
| `http` | Remote services, cloud APIs, shared team servers | `url` + optional `headers` |
| `sse` | Server-sent events streams, real-time data | `url` + optional `headers` |

### 6.4 MCP Tool Search — Token Optimization

By default, **MCP tool schemas are deferred** and loaded on demand via tool search. This keeps your context lean even with many MCP servers. Without tool search, every tool description from every server enters context at session start (this can cost thousands of tokens).

You can:
- Disable tool search with `disableMcpToolSearch: true` (not recommended).
- Exempt specific servers from deferral with the `mcpToolSearchExemptServers` setting (use sparingly, for servers whose tools should always be visible).

### 6.5 OAuth for Remote MCP Servers

Remote MCP servers can authenticate via OAuth. Claude Code supports:

- **Fixed callback port** (`--mcp-oauth-callback-port`) for stable redirect URIs
- **Pre-configured OAuth credentials** for headless environments
- **Override OAuth metadata discovery** for non-standard providers
- **Restrict OAuth scopes** to limit what a server can request

### 6.6 Managed MCP — Enterprise Allow/Deny Lists

Organizations can centrally restrict which MCP servers users can configure:

```json
// managed-settings.json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverName": "postgres" }
  ],
  "deniedMcpServers": [
    { "serverName": "filesystem" }
  ],
  "allowManagedMcpServersOnly": true
}
```

Denylist takes precedence over allowlist. With `allowManagedMcpServersOnly: true`, only managed-defined servers are usable regardless of what users configure locally.

### 6.7 Other MCP Capabilities Worth Knowing

- **MCP elicitation** — servers can request user input mid-tool-call (handled via the `Elicitation` hook).
- **MCP prompts as commands** — MCP servers can expose `/prompt-name` slash commands.
- **Channels** (research preview) — plugins can declare message channels (Telegram, Slack, Discord) that inject messages into the agent loop via MCP.
- **MCP output limits** — large tool results are capped; use `mcpToolOutputLimit` per-tool to raise.
- **Auto-reconnect, dynamic tool updates, push messages** — all handled by Claude Code transparently.

### 6.8 MCP Security Best Practices

- **Never hard-code credentials.** Use `${VAR_NAME}` references in `env` and `headers`.
- **Scope to minimum necessary.** A filesystem MCP should be pointed at a single workspace, not `/`.
- **Prefer project-level `.mcp.json`** for project-specific servers — access tied to repo checkout.
- **Audit tool descriptions** in third-party servers — they enter Claude's context and could contain prompt injection.
- **Use `disallowedTools`** in sub-agent frontmatter to prevent sub-agents from accessing MCP tools they don't need.
- **Pin server versions** (`@1.2.3`, not `latest`) in production.

---

## Chapter 7: Skills (and Legacy Slash Commands)

> **Critical update.** Skills and slash commands are now **the same mechanism**. The current docs say: "Custom commands have been merged into skills. A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way." The original document framed them as separate; that framing is obsolete.

### 7.1 Skills vs Commands — The Same Thing, Different Files

| File | Mechanism | Differences |
|---|---|---|
| `.claude/commands/deploy.md` | Single-file prompt | Cannot bundle supporting files |
| `.claude/skills/deploy/SKILL.md` | Skill (recommended) | Bundles supporting files (templates, scripts, reference docs) in the same directory |

Both invoke the same way: `/deploy`. Both can be auto-invoked by Claude based on `description`. Both support arguments. Skills are recommended for new workflows because they handle bundled assets cleanly. **If a skill and command share a name, the skill wins.**

The invocation prefix is just `/<name>` — the older `/project:<name>` and `/user:<name>` prefixes are gone. Plugin skills are namespaced as `plugin-name:skill-name`.

### 7.2 Bundled Skills (Ship with Claude Code)

| Skill | Purpose |
|---|---|
| `/batch <instruction>` | Spawn many parallel sub-agents in worktrees, each working on a slice of a larger change, each opening its own PR |
| `/claude-api` | Load Claude API + Agent SDK reference for your language; auto-activates when your code imports `anthropic`, `@anthropic-ai/sdk`, or `claude_agent_sdk` |
| `/debug [description]` | Enable debug logging mid-session and analyze the session log |
| `/loop [interval] <prompt>` | Re-run a prompt on an interval — for polling, babysitting deploys, etc. |
| `/simplify [focus]` | Spawn three review agents in parallel against your recent changes and apply their fixes |

### 7.3 Skill File Format

```
.claude/skills/
├── debug-ci/
│   └── SKILL.md
├── summarize-pr/
│   └── SKILL.md
└── generate-endpoint/
    ├── SKILL.md
    ├── template.md            # Optional supporting file
    ├── examples/sample.md     # Example output
    └── scripts/validate.sh    # Executable script Claude can run
```

### 7.4 Full SKILL.md Frontmatter Reference

```yaml
---
name: generate-endpoint
description: >
  Generates a complete REST API endpoint with handler, service, repository,
  and tests. Trigger when user asks to add a new endpoint or API route.
argument-hint: "[resource-name] [method]"
disable-model-invocation: false
user-invocable: true
allowed-tools: Read, Bash, Write, Edit
model: sonnet
effort: medium
context: fork
agent: general-purpose
---

Skill body — full instructions Claude follows when this skill is invoked.
```

| Field | Description |
|---|---|
| `name` | Slash-command name (lowercase, numbers, hyphens, max 64 chars). Defaults to directory name |
| `description` | **Critical.** Front-load the trigger. Truncated above 250 chars in the listing |
| `argument-hint` | Autocomplete hint, e.g., `[issue-number]` |
| `disable-model-invocation` | `true` = only user can invoke; description not in context |
| `user-invocable` | `false` = only Claude can auto-invoke; hidden from `/` menu |
| `allowed-tools` | Comma-separated tools Claude may use without permission prompts while skill is active |
| `model` | Model override |
| `effort` | `low` \| `medium` \| `high` \| `max` (Opus 4.6 only) |
| `context` | `fork` runs in isolated sub-agent context (omit for inline) |
| `agent` | When `context: fork`: `Explore`, `Plan`, or `general-purpose` |

### 7.5 Three Invocation Modes

| Mode | User invoke (`/name`) | Claude auto-invoke | Description in context |
|---|---|---|---|
| Default (no overrides) | ✅ | ✅ | Always |
| `disable-model-invocation: true` | ✅ | ❌ | Never (zero idle token cost) |
| `user-invocable: false` | ❌ | ✅ | Always |

**`disable-model-invocation: true` is the right setting for heavy workflows you only want explicitly triggered** — like `/deploy`. It costs zero idle tokens because the description isn't loaded.

### 7.6 Dynamic Substitutions Inside Skills

| Substitution | Value |
|---|---|
| `$ARGUMENTS` | Full argument string |
| `$0`, `$1`, `$2`, ... | Positional arguments |
| `${CLAUDE_SKILL_DIR}` | Absolute path to the skill's directory (use in scripts) |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `` !`<command>` `` | Inline shell execution — output is injected into the prompt |
| `@<file-path>` | Inline file inclusion — file contents injected into the prompt |

Inline shell execution is governed by `disableSkillShellExecution` (managed setting). Bundled and managed skills are not affected.

### 7.7 Example: Skill with Inline Shell and Bundled File

```yaml
---
name: security-review
description: Reviews a branch or path for security vulnerabilities
disable-model-invocation: true
argument-hint: "<branch-or-path>"
---

## Diff to review

!`git diff $ARGUMENTS`

## Review the changes above for:

1. Injection vulnerabilities (SQL, XSS, command)
2. Authentication and authorization gaps
3. Hardcoded secrets or credentials

Use `checklist.md` in this skill directory for the full review checklist.

Report findings with severity ratings and remediation steps.
```

The bundled `checklist.md` file in the same directory is read on demand when Claude looks at it.

### 7.8 Skill Storage and Priority

| Location | Scope | Priority |
|---|---|---|
| Enterprise (managed settings) | All users in org | Highest |
| `~/.claude/skills/<name>/SKILL.md` | User-global | Personal |
| `.claude/skills/<name>/SKILL.md` | Project | Team |
| `<plugin>/skills/<name>/SKILL.md` | Plugin | Namespaced as `plugin:name` |

When skills share a name across levels: **enterprise > personal > project**. Plugin skills cannot conflict because of the namespace prefix.

### 7.9 Monorepo Auto-discovery

Claude Code auto-discovers skills from **nested** `.claude/skills/` directories. If you're editing a file in `packages/frontend/`, Claude Code also picks up skills from `packages/frontend/.claude/skills/`. This is the right pattern for monorepo-specific workflows.

The `--add-dir` CLI flag also loads skills from added directories (skills are an exception to the rule that `--add-dir` only grants file access, not configuration discovery). Other configuration (sub-agents, commands, output styles) is not loaded from added directories.

---

## Chapter 8: Plugins and Marketplaces

**This chapter is new.** Plugins are now the primary distribution mechanism for shareable Claude Code customization. They were not covered in the original architecture document.

### 8.1 What a Plugin Is

A plugin is a **self-contained directory** of components that extends Claude Code with custom functionality. A single plugin can bundle:

- Skills
- Sub-agents
- Hooks
- MCP servers
- LSP servers (code intelligence — go-to-definition, diagnostics, hover docs)
- Output styles
- Channels (Telegram/Slack/Discord-style message injection)

You install plugins from **marketplaces** — the official Anthropic marketplace, your team's marketplace, or a local path during development.

### 8.2 Why Plugins Matter

Before plugins, sharing customization across teams meant copying `.claude/` directories around or maintaining a "claude-config" repo and symlinking. Plugins solve this:

- **Versioned** — semver constraints, marketplace channels (`stable`/`beta`)
- **Trusted** — marketplace allowlists, plugin-trust warnings, managed restrictions
- **Updatable** — `claude plugin update`
- **Self-contained** — `${CLAUDE_PLUGIN_ROOT}` for bundled scripts, `${CLAUDE_PLUGIN_DATA}` for persistent state

### 8.3 Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json              # Manifest (name is the only required field)
├── commands/                    # Skills (legacy form; works fine)
│   └── status.md
├── skills/                      # Skills (modern form, with supporting files)
│   ├── code-reviewer/
│   │   └── SKILL.md
│   └── pdf-processor/
│       ├── SKILL.md
│       └── scripts/
├── agents/                      # Sub-agents (security-restricted frontmatter)
│   ├── security-reviewer.md
│   └── performance-tester.md
├── output-styles/
│   └── terse.md
├── hooks/
│   ├── hooks.json               # Plugin hooks
│   └── security-hooks.json
├── settings.json                # Default settings the plugin contributes
├── .mcp.json                    # Plugin-bundled MCP servers
├── .lsp.json                    # Plugin-bundled LSP servers
├── scripts/                     # Helper scripts (use ${CLAUDE_PLUGIN_ROOT})
│   ├── format-code.sh
│   └── deploy.js
├── LICENSE
└── CHANGELOG.md
```

### 8.4 The `plugin.json` Manifest

```json
{
  "name": "deployment-tools",
  "version": "2.1.0",
  "description": "Deployment automation for our team's services",
  "author": { "name": "Platform Team", "email": "platform@acme.example" },
  "homepage": "https://docs.acme.example/plugins/deployment-tools",
  "repository": "https://github.com/acme/deployment-tools",
  "license": "Apache-2.0",
  "keywords": ["deployment", "ci-cd"],
  "userConfig": {
    "api_endpoint": {
      "description": "Your team's deployment API endpoint",
      "sensitive": false
    },
    "api_token": {
      "description": "Deployment API token",
      "sensitive": true
    }
  }
}
```

`name` is the only required field. Component locations default to `commands/`, `skills/`, `agents/`, `hooks/hooks.json`, `.mcp.json`, `.lsp.json`, `output-styles/` — set fields like `commands`, `agents`, `skills` to override.

`userConfig` declares values prompted at install time. Non-sensitive values land in `settings.json`; sensitive ones go to the system keychain (or `~/.claude/.credentials.json` when keychain is unavailable). Reference them as `${user_config.api_token}` in MCP/LSP/hook configs.

### 8.5 Security Restrictions on Plugin Sub-agents

Plugin-shipped sub-agents have a **restricted frontmatter** for security:

| Allowed | Disallowed |
|---|---|
| `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation: worktree` | `hooks`, `mcpServers`, `permissionMode` |

This prevents a malicious or vulnerable plugin from escalating privileges via its bundled sub-agents.

### 8.6 The Two Critical Environment Variables

| Variable | Purpose | Persists across updates? |
|---|---|---|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the plugin's installation dir | ❌ Changes on update |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory (`~/.claude/plugins/data/<plugin-id>/`) | ✅ Yes |

Use `${CLAUDE_PLUGIN_ROOT}` for bundled scripts and templates. Use `${CLAUDE_PLUGIN_DATA}` for installed dependencies (`node_modules`, Python venvs), caches, and any state that should survive plugin updates.

A common pattern — install dependencies once, refresh on manifest changes:

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "diff -q \"${CLAUDE_PLUGIN_ROOT}/package.json\" \"${CLAUDE_PLUGIN_DATA}/package.json\" >/dev/null 2>&1 || (cd \"${CLAUDE_PLUGIN_DATA}\" && cp \"${CLAUDE_PLUGIN_ROOT}/package.json\" . && npm install) || rm -f \"${CLAUDE_PLUGIN_DATA}/package.json\""
      }]
    }]
  }
}
```

### 8.7 Marketplaces

Marketplaces are the discovery and distribution mechanism. The official Anthropic marketplace is enabled by default. You can add others:

```bash
# From a GitHub repo
claude plugin marketplace add github:acme/our-plugins

# From any Git host
claude plugin marketplace add git+https://gitlab.example.com/team/plugins.git

# Local development
claude plugin marketplace add /path/to/local/marketplace

# From a remote URL (signed marketplace JSON)
claude plugin marketplace add https://acme.example.com/marketplace.json
```

Discover with `/plugin` (interactive UI), install with `/plugin install <plugin-name>` or `claude plugin install`.

### 8.8 LSP Servers — Real-time Code Intelligence

LSP plugins give Claude **diagnostics, go-to-definition, and hover information** in real time. Available in the official marketplace:

- `pyright-lsp` — Python (requires `pyright`)
- `typescript-lsp` — TypeScript/JavaScript (requires `typescript-language-server`)
- `rust-lsp` — Rust (requires `rust-analyzer`)

LSP plugins drastically reduce wasted iteration — Claude sees errors immediately after each edit instead of waiting for `pnpm tsc` to fail. You must install the language server binary separately.

### 8.9 Managed Plugin Restrictions

Organizations can:

- **Force-enable plugins** via managed settings (`enabledPlugins`)
- **Restrict marketplaces** (`extraKnownMarketplaces`, `strictKnownMarketplaces`)
- **Block specific marketplaces** (`blockedMarketplaces`) — enforced before download
- **Customize the trust warning** (`pluginTrustMessage`)
- **Require managed-only hooks** (`allowManagedHooksOnly`) — blocks user/project/non-managed-plugin hooks

---

## Chapter 9: Interface Customization — Output Styles, Status Line, Keybindings

**This chapter is new.** None of these were covered in the original document. They're the fastest way to make Claude Code feel like it's yours.

### 9.1 Output Styles

An output style is a **section appended to Claude's system prompt** that adjusts how Claude works. Built-in styles:

- `Default` — standard concise software-engineering behavior
- `Explanatory` — adds reasoning notes after each task
- `Learning` — leaves small TODOs for the human, to teach by handing off

Select with `/config` or `outputStyle` in `settings.json`:

```json
{ "outputStyle": "Explanatory" }
```

#### Custom output styles

A custom style is a markdown file at `~/.claude/output-styles/<name>.md` (personal) or `.claude/output-styles/<name>.md` (project-shared):

```yaml
---
description: Explains reasoning and asks me to implement small pieces
keep-coding-instructions: true
---

After completing each task, add a brief "Why this approach" note
explaining the key design decision.

When a change is under 10 lines, ask the user to implement it
themselves by leaving a TODO(human) marker instead of writing it.
```

| Frontmatter | Effect |
|---|---|
| `description` | Shown in `/config` picker |
| `keep-coding-instructions: true` | Keep default software-engineering instructions; otherwise the style replaces them |

Output styles change the system prompt — they take effect on the **next** session, since the system prompt is fixed at startup for prompt-cache reuse.

### 9.2 Status Line

The status line is a single (or multi-line) display rendered at the bottom of the Claude Code interface. Configure with `/statusline` (interactive builder) or set `statusLine` in `settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
```

The script receives session JSON on stdin (model, project, branch, token usage, cost, duration) and prints lines to stdout. Example showing model and cost:

```bash
#!/usr/bin/env bash
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0' | xargs printf "$%.2f")
branch=$(git branch --show-current 2>/dev/null)
echo "[$model] $branch · $cost"
```

Sub-agents can have their own status lines configured per-agent.

### 9.3 Keybindings

Custom keybindings live at `~/.claude/keybindings.json`:

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "$docs": "https://code.claude.com/docs/en/keybindings",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+e": "chat:externalEditor",
        "ctrl+u": null
      }
    }
  ]
}
```

`Ctrl+C`, `Ctrl+D`, and `Ctrl+M` are reserved and cannot be rebound. Run `/keybindings` to open the file with schema reference.

---

## Chapter 10: Permission System, Sandboxing, Plan and Auto Modes

**This chapter is new.** The original document covered only `default`, `acceptEdits`, and `bypassPermissions`. Current Claude Code has six permission modes plus a sandboxing layer.

### 10.1 Permission Rules: Three Buckets

Permission rules go in `settings.json` under `permissions`:

```json
{
  "permissions": {
    "allow": [ "Bash(git log *)", "Bash(pnpm test *)" ],
    "ask":   [ "Bash(git push *)" ],
    "deny":  [ "Bash(rm -rf *)", "Read(./.env)", "Read(./secrets/**)" ],
    "additionalDirectories": [ "/Users/me/shared/libraries" ],
    "defaultMode": "default",
    "disableBypassPermissionsMode": false
  }
}
```

> ⚠️ The original document described only `allow` and `deny`. The `ask` bucket exists too — it prompts before allowing. Evaluation order is **deny → ask → allow**, first match wins.

### 10.2 Pattern Syntax

| Pattern | Matches |
|---|---|
| `Bash(git:*)` | Any `git` subcommand |
| `Bash(pnpm test -- *)` | `pnpm test` with any trailing arguments |
| `Read(**/*.ts)` | Read any TypeScript file at any depth |
| `Write(src/**/*)` | Write any file under `src/` |
| `mcp__github__*` | All tools from the `github` MCP server |
| `Edit(./README.md)` | Specific file |
| `Bash(*)` | Any bash command (use only in `deny` as catch-all) |

### 10.3 The Six Permission Modes

| Mode | Behavior | Use case |
|---|---|---|
| `default` | Prompt for each sensitive operation | Standard interactive use |
| `acceptEdits` | Auto-accept file edits without prompting | CI pipelines, focused work |
| `plan` | Read-only research mode; produces a plan you approve | Pre-implementation analysis |
| `auto` | Classifier-based; auto-allows safe ops, blocks risky ones, prompts on borderline | High-trust automation with safety net |
| `dontAsk` | Allow only pre-approved tools; reject everything else without prompting | Strict CI |
| `bypassPermissions` | Skip **all** permission checks | Last-resort automation; document justification |

Switch modes with `Shift+Tab` (cycles), `--permission-mode`, `defaultMode` in settings, or `permissionMode` in sub-agent frontmatter.

### 10.4 Plan Mode

Plan mode is the read-only research mode. Claude reads, greps, and analyzes — but cannot write, edit, or run side-effecting commands. It produces a structured plan you approve before any changes.

Set as default for the project:

```json
{ "permissions": { "defaultMode": "plan" } }
```

This is the foundation of the **explore-then-implement** pattern. Pair with a sub-agent or skill that reads the plan and implements it.

### 10.5 Auto Mode

Auto mode uses a classifier to decide which operations to auto-allow vs. block vs. prompt. You can customize the classifier:

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "This is a development workstation, not production."
    ],
    "allow": [
      "$defaults",
      "Reading any file under the project tree",
      "Running pnpm test or pnpm build"
    ],
    "soft_deny": [
      "$defaults",
      "Never run terraform apply",
      "Never modify ~/.bashrc or ~/.zshrc"
    ]
  }
}
```

`$defaults` inherits the built-in rules at that position. Manage organization-wide via `disableAutoMode: "disable"` in managed settings.

### 10.6 Sandboxing

Sandboxing is **OS-level isolation** for bash commands — separate from permission rules. Permissions decide *whether* a tool runs; sandboxing decides *what it can touch* when it does.

```json
{
  "sandbox": {
    "mode": "enabled",
    "filesystem": {
      "writablePaths": ["./", "/tmp"],
      "readonlyPaths": ["~/.ssh", "~/.aws"]
    },
    "network": {
      "allowedHosts": ["api.acme.example", "registry.npmjs.org"]
    }
  }
}
```

Sandboxing uses OS-level enforcement (macOS Seatbelt, Linux namespaces). It protects against prompt injection by reducing the blast radius of any single command — a malicious instruction that says "run `rm -rf /`" cannot reach files outside the writable list.

### 10.7 Permission Best Practices

- **Default deny for shell.** End your `deny` list with `Bash(*)` and explicitly enumerate every allowed command pattern.
- **Use `deny` for `.env` and secrets.** `Read(./.env)`, `Read(./.env.*)`, `Read(./secrets/**)`.
- **Sandbox bash commands** in any environment that ingests untrusted input (PR review, public repos).
- **Audit `bypassPermissions` sub-agents** — document justification, prohibit in production CI.
- **Use managed settings for organization-wide policies** — see Chapter 15.

---

## Chapter 11: Worktrees and Parallel Execution

**This chapter is new.** Worktree isolation is the foundation of high-parallelism Claude Code workflows.

### 11.1 What a Worktree Is

A git worktree is a separate working directory checked out from the same repository, sharing the same `.git/` directory. Multiple worktrees can run concurrently without stepping on each other.

Claude Code uses worktrees for:

- **`/batch`** — spawns one sub-agent per work unit, each in its own worktree, each opening its own PR
- **Sub-agents with `isolation: worktree`** — fully isolated execution
- **Parallel sessions** — manual `claude --worktree` for running multiple Claude sessions on different branches

### 11.2 The `EnterWorktree` Tool

Claude can autonomously enter a worktree using the `EnterWorktree` tool. It creates a new worktree (or enters an existing one), switches into it, and continues working there. When the task ends, the worktree is cleaned up (unless preserved by `WorktreeRemove` hook policy).

### 11.3 `.worktreeinclude` — Copy Gitignored Files into Worktrees

Worktrees are fresh checkouts, so untracked files (`.env`, local secrets) are missing. List them in `.worktreeinclude` at the repo root:

```
# Local environment
.env
.env.local

# API credentials
config/secrets.json
```

Patterns use `.gitignore` syntax. Only files that match a pattern *and* are gitignored get copied — tracked files are never duplicated.

If you use a non-git VCS, configure a `WorktreeCreate` hook that copies files yourself.

### 11.4 Pattern: Migrate-by-Slice

A migration touches 200 files. Use `/batch`:

```
/batch migrate src/ from class-based services to functional with dependency injection
```

Claude:
1. Researches the codebase, identifies 20 independent units
2. Presents a plan
3. On your approval, spawns 20 sub-agents — one per unit, each in its own worktree
4. Each sub-agent implements its slice, runs tests, opens a PR

You can review and merge PRs incrementally. The main checkout is never blocked.

### 11.5 Pattern: Competing-Hypothesis Investigation

Use an agent team where each teammate runs in `isolation: worktree` and pursues a different hypothesis for a bug. The lead synthesizes.

### 11.6 Cleanup

Orphaned worktrees from crashed sessions are auto-cleaned at startup based on `cleanupPeriodDays` (default 30). Manual cleanup via `claude worktree prune`.

---

## Chapter 12: Where Does the Workflow Belong?

The single most common architectural mistake is putting everything in `CLAUDE.md`. Use the table below to pick the right surface for each kind of content.

| Workflow type | Correct location | Rationale |
|---|---|---|
| Always-on coding standards, naming, tech stack | `CLAUDE.md` + `AGENTS.md` | Applies to nearly every interaction; AGENTS.md for cross-platform |
| Build / test / lint commands | `AGENTS.md` + `CLAUDE.md` | Universal; AGENTS.md for portability |
| Module-specific conventions | `.claude/rules/<topic>.md` with `paths:` | Loads only when relevant files in context |
| Personal cross-project preferences | `~/.claude/CLAUDE.md` | Personal, not project-specific |
| Personal project-specific preferences | `CLAUDE.local.md` (gitignored) | Local override |
| Complex on-demand procedures (CI debug, DB migrations) | **Skill** | On-demand; doesn't consume tokens otherwise |
| Heavy workflows the user invokes explicitly | Skill with `disable-model-invocation: true` | Zero idle token cost |
| Background knowledge Claude should apply silently | Skill with `user-invocable: false` | Hidden from `/` menu |
| Automated parallel/divide-and-conquer | Sub-agent (or `/batch`) | Parent delegates programmatically |
| 3+ parallel work units sharing a goal | **Agent team** | Coordination via lead agent |
| Read-only research before implementing | Sub-agent with `disallowedTools: [Write, Edit]`, or Plan mode | Safety + focus |
| Unconditional enforcement (lint, block patterns) | Hook | Deterministic; zero tokens |
| Quality gates with reasoning | `prompt` hook | LLM-evaluated gate |
| External tool access (DB, APIs, file systems) | MCP Server | Structured tool interface |
| Real-time code intelligence (diagnostics, go-to-def) | LSP plugin | Native LSP integration |
| Distributable customization for a team | **Plugin** | Versioned, trusted, updatable |
| Adjusting Claude's tone/style | Output style | System-prompt-level |
| Strict tool allowlist for CI | `permissionMode: dontAsk` | Reject anything not pre-approved |
| OS-level sandbox for risky commands | `sandbox` settings | Defense in depth |

### Layered Model (Updated)

```
┌──────────────────────────────────────────────────────────────────────────┐
│  CLAUDE.md / AGENTS.md (Memory)                                          │
│  ✅ Coding standards, build/test commands, architecture decisions         │
│  ❌ Workflow orchestration (use Skills)  ❌ Module-specific (use Rules)   │
├──────────────────────────────────────────────────────────────────────────┤
│  .claude/rules/*.md (Path-scoped Rules)                                  │
│  ✅ Module conventions loaded only when matching files in context        │
├──────────────────────────────────────────────────────────────────────────┤
│  Auto-memory (~/.claude/projects/.../MEMORY.md)                          │
│  ✅ Claude's running notes; you don't author this                         │
├──────────────────────────────────────────────────────────────────────────┤
│  .claude/agents/*.md (Sub-agents)                                        │
│  ✅ Specialists with isolated context, tool restrictions, optional memory │
│  ✅ Worktree isolation for parallelism (isolation: worktree)              │
├──────────────────────────────────────────────────────────────────────────┤
│  Agent Teams                                                              │
│  ✅ Lead + parallel teammates with shared task list                       │
├──────────────────────────────────────────────────────────────────────────┤
│  .claude/skills/<name>/SKILL.md (Skills, modern)                         │
│  .claude/commands/*.md (Commands, legacy — same mechanism)               │
│  ✅ User-triggered + Claude auto-invoked; bundled supporting files        │
├──────────────────────────────────────────────────────────────────────────┤
│  Hooks (settings.json → hooks)                                            │
│  ✅ 30+ events × 4 handler types (command, http, prompt, agent)           │
│  ✅ Async hooks for slow validation                                       │
├──────────────────────────────────────────────────────────────────────────┤
│  MCP Servers (.mcp.json) + LSP Servers (plugins)                         │
│  ✅ Structured external tool access; deferred tool schemas (token saver)  │
├──────────────────────────────────────────────────────────────────────────┤
│  Plugins (~/.claude/plugins/)                                             │
│  ✅ Distributable bundles of all of the above                             │
├──────────────────────────────────────────────────────────────────────────┤
│  Permissions + Sandboxing + Permission Modes                              │
│  ✅ Allow/ask/deny rules + OS-level isolation + 6 modes                   │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Chapter 13: Complete Project Structure Example

A full-stack project, current as of May 2026:

```
your-project/
├── CLAUDE.md                                ← Project memory (committed)
├── CLAUDE.local.md                          ← Your personal project overrides (gitignored)
├── AGENTS.md                                ← Cross-platform agent instructions (committed)
├── REVIEW.md                                ← Tunes Claude Code Review on PRs (committed)
├── .mcp.json                                ← Team-shared MCP servers (committed)
├── .worktreeinclude                         ← Files to copy into worktrees (committed)
├── .gitignore                               ← Includes CLAUDE.local.md, .claude/settings.local.json
├── .claude/
│   ├── settings.json                        ← Permissions, hooks, statusLine, outputStyle, plugins
│   ├── settings.local.json                  ← Your personal overrides (auto-gitignored)
│   ├── rules/
│   │   ├── style.md                         ← No paths: → always-on
│   │   ├── testing.md                       ← paths: ["**/*.test.ts"]
│   │   ├── api-design.md                    ← paths: ["src/api/**/*.ts"]
│   │   └── frontend/
│   │       └── react.md                     ← paths: ["src/components/**/*.tsx"]
│   ├── agents/
│   │   ├── researcher.md                    ← Read-only codebase researcher
│   │   ├── implementer.md                   ← Write-capable implementer
│   │   ├── code-reviewer.md                 ← Read-only quality reviewer
│   │   ├── security-auditor.md              ← Read-only security reviewer
│   │   └── migration-runner.md              ← DB migration specialist
│   ├── agent-memory/                        ← Persistent memory: project scope (committed)
│   │   └── code-reviewer/
│   │       └── MEMORY.md                    ← Auto-written by code-reviewer
│   ├── agent-memory-local/                  ← Persistent memory: local scope (gitignored)
│   ├── skills/
│   │   ├── plan-feature/SKILL.md            ← /plan-feature
│   │   ├── generate-endpoint/
│   │   │   ├── SKILL.md                     ← /generate-endpoint
│   │   │   └── template.md
│   │   ├── write-migration/SKILL.md         ← /write-migration
│   │   ├── summarize-pr/SKILL.md            ← /summarize-pr
│   │   ├── deploy/SKILL.md                  ← /deploy (disable-model-invocation: true)
│   │   └── full-feature/SKILL.md            ← Orchestrates sub-agents
│   ├── commands/                            ← Legacy slash commands (kept for compat)
│   │   └── .gitkeep
│   ├── output-styles/
│   │   └── strict-review.md                 ← Project-shared review mode
│   ├── plans/                               ← Plan-mode artifacts
│   └── hooks/
│       ├── validate-bash.sh
│       ├── auto-format.sh
│       ├── notify-complete.sh
│       └── audit-log.sh
├── src/
│   ├── api/                                 ← .claude/rules/api-design.md applies here
│   ├── components/                          ← .claude/rules/frontend/react.md applies here
│   └── ...
├── backend/
│   └── ...
└── tests/                                   ← .claude/rules/testing.md applies here
```

### `.claude/settings.json` — Comprehensive Example

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "sonnet",
  "outputStyle": "Default",
  "statusLine": {
    "type": "command",
    "command": "bash .claude/hooks/statusline.sh"
  },
  "permissions": {
    "defaultMode": "default",
    "allow": [
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(git status *)",
      "Bash(pnpm test *)",
      "Bash(pnpm lint *)",
      "Bash(pnpm build *)",
      "Bash(pytest *)",
      "Read(**/*)",
      "Edit(src/**/*)",
      "Edit(tests/**/*)",
      "Write(src/**/*)",
      "mcp__github__*"
    ],
    "ask": [
      "Bash(git push *)",
      "Bash(pnpm db:migrate *)"
    ],
    "deny": [
      "Bash(git push --force *)",
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(curl * | bash)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ]
  },
  "sandbox": {
    "mode": "enabled",
    "filesystem": {
      "writablePaths": ["./"],
      "readonlyPaths": ["~/.ssh", "~/.aws", "~/.gnupg"]
    }
  },
  "env": {
    "NODE_ENV": "development",
    "LOG_LEVEL": "debug"
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "bash .claude/hooks/validate-bash.sh" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [{ "type": "command", "command": "bash .claude/hooks/auto-format.sh" }]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [{ "type": "command", "command": "bash .claude/hooks/notify-complete.sh" }]
      }
    ],
    "FileChanged": [
      {
        "matcher": "src/**/*.ts",
        "hooks": [{ "type": "command", "command": "pnpm tsc --noEmit", "async": true }]
      }
    ]
  },
  "enabledPlugins": ["typescript-lsp", "deployment-tools@2.x"]
}
```

### `.mcp.json` — Project-shared MCP Servers

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": { "DATABASE_URL": "${DEV_DATABASE_URL}" }
    }
  }
}
```

---

## Chapter 14: Token Cost Strategy

### 14.1 Token Consumption by Component

| Component | Loading | Idle cost | Typical active cost | Notes |
|---|---|---|---|---|
| `CLAUDE.md` (project root) | Always-on | 200–800 tokens | Same | Cap < 500 tokens; split into rules above ~200 lines |
| `AGENTS.md` (project root) | Always-on | 200–600 tokens | Same | Tool-agnostic; works across any AI tool |
| `~/.claude/CLAUDE.md` (user) | Always-on globally | 100–300 tokens | Same | Keep universal; project rules go in project files |
| `CLAUDE.local.md` | Always-on in project | 100–400 tokens | Same | Local overrides only |
| `.claude/rules/*.md` (no `paths:`) | Always-on in project | Sum of files | Same | Treat like CLAUDE.md content |
| `.claude/rules/*.md` (with `paths:`) | Lazy on file match | **0** | 100–400 tokens per loaded rule | Major token saver for monorepos |
| Auto-memory `MEMORY.md` | Always-on (per project) | First 200 lines (≤ 25 KB) | Same | Topic files are lazy |
| Sub-agent definition (description) | Always in `/agents` index | ~30–80 tokens per agent | Sub-agent runtime separate | Description matters for auto-invoke |
| Sub-agent runtime | On invocation | 0 | Isolated context (no parent history) | Token-efficient for long sessions |
| Sub-agent with `memory:` | Loaded into agent at start | First 200 lines of MEMORY.md | Same | Bounded |
| Skill (default) | Description in context, body on invoke | ~20–50 tokens per skill | 100–500 tokens body | Be precise with descriptions |
| Skill (`disable-model-invocation: true`) | Body on user invoke only | **0** | 100–500 tokens | Best choice for heavy workflows |
| Skill (`user-invocable: false`) | Description in context | ~20–50 tokens | 100–500 tokens body | Background knowledge |
| MCP tool descriptions | Deferred via tool search | ~20 tokens for the search tool itself | ~30–100 tokens per loaded tool | Tool search is essential at scale |
| LSP server | Connection + diagnostics inline | Diagnostics on edits | Variable | Often pays for itself by avoiding wrong code |
| `command` / `http` hook | Event-triggered code | **0** | **0** | Zero-token enforcement |
| `prompt` / `agent` hook | Event-triggered LLM call | 0 | Token cost of the LLM call | Use deliberately |
| Plugin component | Per-component cost above | Sum of enabled components | Same | Audit `/context` after install |
| Output style | System-prompt section | 100–500 tokens | Same | Loaded once at session start |
| Status line | Rendered locally | **0** | **0** | UI only |

### 14.2 Strategic Principles

| Principle | Application |
|---|---|
| **Never always-on what can be lazy** | Sub-directory rule with `paths:` instead of root `CLAUDE.md` line |
| **Never use instructions when hooks suffice** | "Always run lint after writing files" → `PostToolUse` hook |
| **Prefer Skills over Slash Commands for new work** | Skills support auto-invocation, isolated contexts, bundled assets |
| **`disable-model-invocation: true` for heavy skills** | Zero idle cost; user still invokes explicitly |
| **Sub-agents are cheaper than long context** | Delegating from a long parent saves tokens via fresh start |
| **Write precise descriptions for sub-agents and skills** | Bad descriptions → wrong-tool selection or never invoked |
| **Split large CLAUDE.md** | A 2,000-token root CLAUDE.md costs 2,000 every session — split into 400-token rules |
| **Use AGENTS.md for cross-platform conventions** | Build commands, code style → AGENTS.md (any tool); Claude-specific → CLAUDE.md |
| **Tool search is essential past ~5 MCP servers** | Tool descriptions bloat fast; let tool search defer |
| **Use `effort` deliberately** | `low` for routine ops, `high`/`xhigh` for architecture decisions only |
| **Lower the auto-compact threshold for long sessions** | `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70` preserves more context quality |

### 14.3 Cost Spectrum

```
0 tokens ────────────────────────────────────────────── High cost

Hooks    Skills (idle,         Path-scoped       Sub-agent     CLAUDE.md     User CLAUDE.md
(0)      disable-model-        rule (idle, 0)    (on-demand,    (always-on)   (always-on,
         invocation:true, 0)                     isolated)                    all projects)
```

---

## Chapter 15: Security Best Practices

### 15.1 Defense-in-depth Layers

| Layer | Risk | Mitigation |
|---|---|---|
| **Memory files** | Prompt injection from attacker-controlled content | Version control + code review; never auto-generate from untrusted input |
| **Sub-agents** | Over-permissioning | `tools` allowlist + `disallowedTools` blocklist per agent |
| **Sub-agents** | `bypassPermissions` defeating safety | Audit and document; prohibit in production CI |
| **Skills / commands** | Inline shell execution | `disableSkillShellExecution` in managed settings |
| **Hooks** | Hook scripts as attack surface | Audit all scripts; small and single-purpose; no dynamic eval |
| **HTTP hooks** | Data exfiltration | `allowedHttpHookUrls`, `httpHookAllowedEnvVars` |
| **MCP servers** | Malicious tool descriptions | Audit third-party servers; pin versions |
| **MCP servers** | Credential exposure | `${ENV_VAR}` references only; never inline tokens |
| **Plugins** | Third-party plugin compromise | Use trusted marketplaces; managed `blockedMarketplaces`; review on install |
| **`settings.json`** | Overly broad `allow` | Default deny; specific argument patterns |
| **Auto-memory** | Sensitive data accumulating in user-scope file | Periodic review; `autoMemoryEnabled: false` if required |
| **Worktrees** | Secrets copied via `.worktreeinclude` | Audit the file; minimize copied paths |

### 15.2 Default Deny for Shell

```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm test:*)",
      "Bash(pnpm lint:*)",
      "Bash(git log:*)",
      "Bash(git diff:*)",
      "Bash(git status:*)"
    ],
    "deny": ["Bash(*)"]
  }
}
```

### 15.3 Least Privilege for Sub-agents

```yaml
# ❌ Anti-pattern: reviewer with write access
tools: [Read, Write, Edit, Bash]

# ✅ Best practice: read-only reviewer
tools: [Read, Grep, Glob, Bash]
disallowedTools: [Write, Edit, MultiEdit]
```

### 15.4 Sandboxing for Risky Operations

Anything that runs tests, builds, migrations, or evaluates third-party content should run sandboxed:

```json
{
  "sandbox": {
    "mode": "enabled",
    "filesystem": {
      "writablePaths": ["./", "/tmp"],
      "readonlyPaths": ["~/.ssh", "~/.aws", "~/.gnupg", "~/.npmrc"]
    },
    "network": {
      "allowedHosts": ["registry.npmjs.org", "pypi.org", "api.github.com"]
    }
  }
}
```

### 15.5 Audit Trail via PostToolUse Hooks

```bash
#!/usr/bin/env bash
# .claude/hooks/audit-log.sh
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "$timestamp | $tool_name | $(echo "$input" | jq -c '.tool_input')" >> ~/.claude/audit.log
exit 0
```

For enterprise audit, send events to a SIEM via OpenTelemetry (Chapter 17).

### 15.6 Secrets Management

```gitignore
# .gitignore — always include these
CLAUDE.local.md
.claude/settings.local.json
.claude/agent-memory-local/
```

```json
// settings.json — env var references only
{
  "mcpServers": {
    "github": {
      "headers": {
        "Authorization": "Bearer ${GITHUB_TOKEN}"
      }
    }
  }
}
```

### 15.7 Managed Settings — Enterprise Enforcement

For teams of 10+, deploy managed settings to enforce policies users cannot override:

**Server-managed (Anthropic admin console):**
Pushed from the Console; refreshed at session start; can be enforced fail-closed via `forceRemoteSettingsRefresh`.

**MDM/OS-level (macOS/Windows/Linux):**

| Platform | Mechanism |
|---|---|
| macOS | `com.anthropic.claudecode` managed preferences (Jamf, Kandji) |
| Windows | `HKLM\SOFTWARE\Policies\ClaudeCode\Settings` (Group Policy/Intune) |
| Linux/WSL | `/etc/claude-code/managed-settings.json` |
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

Drop-in directory `managed-settings.d/` allows separate teams to deploy independent policy fragments without coordinating edits to a single file. Files are merged alphabetically.

**Common managed settings:**

```json
{
  "allowManagedPermissionRulesOnly": true,
  "allowManagedHooksOnly": true,
  "allowManagedMcpServersOnly": true,
  "disableAutoMode": "disable",
  "disableSkillShellExecution": true,
  "disableRemoteControl": true,
  "forceLoginMethod": "claudeai",
  "forceLoginOrgUUID": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "minimumVersion": "2.1.100",
  "permissions": {
    "deny": ["Bash(rm -rf /:*)", "Bash(sudo:*)", "Bash(curl * | bash)"]
  },
  "deniedMcpServers": [{ "serverName": "filesystem" }],
  "blockedMarketplaces": [{ "source": "github", "repo": "untrusted/plugins" }],
  "companyAnnouncements": [
    "Welcome to Acme Corp. Code reviews required for all PRs."
  ]
}
```

---

## Chapter 16: Surfaces and Integrations

**This chapter is new.** The original document framed Claude Code as terminal-first. That hasn't been true since 2025. Today it's a platform with 10+ surfaces, all sharing the same configuration layer.

### 16.1 Surface Matrix

| Surface | Best for | Configuration |
|---|---|---|
| **CLI** (`claude`) | Interactive coding, deep work | All `.claude/` files; `~/.claude/` for personal |
| **Claude Code on the web** | Cloud-executed tasks; long-running jobs while away | Repo `.claude/`; `SessionStart` hooks for env setup |
| **Claude Code Desktop** | GUI workflow; computer use; preview servers | Same `.claude/` files; desktop-specific config in app settings |
| **VS Code extension** | In-IDE prompt box, diff view, checkpoints | Same `.claude/` files; VS Code user settings for extension behavior |
| **JetBrains plugin** | IntelliJ/PyCharm/etc. integration | Same `.claude/` files; plugin settings for IDE specifics |
| **Slack** | Team-wide ticket-to-PR | Repo selection per channel; CLAUDE.md-driven |
| **GitHub Actions** | `@claude` mentions in PRs/issues; CI automation | Same `.claude/` files; action inputs for prompts |
| **GitLab CI/CD** | Same as GitHub Actions for GitLab | `.gitlab-ci.yml` job; same `.claude/` files |
| **Chrome (browser agent)** | Browser automation; web testing; data extraction | `chrome` MCP; per-site permissions |
| **Computer Use** | Native app testing; UI reproduction | `computer-use` MCP; trust boundary |
| **Remote Control** | Mobile push; remote terminal | Subscription-gated; managed via `disableRemoteControl` |
| **Headless mode** (`-p`) | Scripting; CI piping | All `.claude/` files; `--output-format` for JSON |

### 16.2 The Same Configuration Travels

**`CLAUDE.md`, `AGENTS.md`, `.claude/skills/`, `.claude/agents/`, `.mcp.json`** all work identically across surfaces. A skill you write once is available in CLI, web, desktop, VS Code, JetBrains, Slack, and CI.

This is the single most important architectural point of the new platform: **the configuration is the contract**, not the surface.

### 16.3 Code Review and `REVIEW.md`

Claude Code Review automatically reviews PRs. Tune behavior per-repo with `REVIEW.md` at the project root:

```markdown
# REVIEW.md

## Focus areas
- Security: SQL injection, XSS, auth bypass
- Correctness: edge cases, error handling
- Performance: N+1 queries, unnecessary allocations

## Out of scope
- Style and formatting (handled by CI lint)
- Documentation typos

## Severity guidance
- Critical: data loss, security breach, production crash
- High: incorrect behavior in common path
- Medium: incorrect behavior in edge case
- Low: maintainability concerns
```

`REVIEW.md` is read by the `code-review` system at PR time. Keep it focused — broad guidance produces noisy reviews.

### 16.4 Routines and Scheduled Tasks

**Routines (web):** schedule, API, or GitHub-event triggers that run a Claude Code session in the cloud.

```bash
# Create a routine that triages new bug-labeled issues nightly
claude routine create --schedule "0 2 * * *" "Triage new GitHub issues with the 'bug' label..."
```

**`/loop` (CLI):** runs a prompt repeatedly on an interval while the session stays open.

```
/loop 5m check if the deploy finished
```

Useful for polling deploys, babysitting a PR, or periodically re-running another skill.

### 16.5 GitHub Actions Setup (Brief)

```yaml
# .github/workflows/claude-code.yml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  claude-code:
    if: contains(github.event.comment.body, '@claude')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v2
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

The action reads the same `.claude/` configuration as your local CLI — your sub-agents, skills, hooks, and MCP servers all work in CI.

---

## Chapter 17: Observability

**This chapter is new.** Production teams need usage and security visibility. Claude Code ships with first-class OpenTelemetry support.

### 17.1 Enable OpenTelemetry

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "https://otel.acme.example",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "http/protobuf"
  }
}
```

### 17.2 Metrics

- **Sessions** — total sessions, by user, by project
- **Tokens** — input, output, cache, by model
- **Cost** — total spend, by user, by project
- **Active time** — engagement signal
- **Lines of code** — accepted edits
- **Pull requests** — opened, by user
- **Commits** — created, by user
- **Tool decisions** — accepted vs. rejected counts

### 17.3 Events

User prompts, tool results, API requests/errors, tool decisions, permission mode changes, auth events, MCP connections, hook executions (start/complete), plugin installs, skill activations, compaction events.

### 17.4 Use Cases

| Question | Source |
|---|---|
| How much is Claude Code costing per team? | Cost counter + `user_uuid` attribution |
| Are users getting blocked by permission prompts? | Tool decision counter + permission events |
| Which sub-agents are being invoked, by whom? | `SubagentStart` events |
| Are any users running with `bypassPermissions`? | Permission mode change events |
| Which MCP servers are being used most? | MCP connection + tool result events |
| What was the last command that ran before this incident? | Tool result events |

### 17.5 `/usage` and Analytics

- **`/usage`** — show current session token/cost summary in the CLI
- **Analytics dashboard** (Team/Enterprise plans) — adoption, PRs per user, top contributors, attribution
- **Audit logs** (managed settings) — security-relevant events for SIEM ingestion

---

## Appendix A: Settings Reference and Precedence

### A.1 Precedence (Top Wins)

```
Managed (server, MDM, plist/registry, managed-settings.json)
        ↓
CLI flags
        ↓
.claude/settings.local.json
        ↓
.claude/settings.json
        ↓
~/.claude/settings.json
```

Array settings merge across scopes; scalars use the highest-priority value.

### A.2 Common Settings (Abridged)

| Key | Purpose |
|---|---|
| `model` | Default model (`sonnet`, `opus`, `haiku`, or pinned ID) |
| `effortLevel` | Persistent effort across sessions (`low`/`medium`/`high`/`xhigh`) |
| `availableModels` | Restrict which models users can pick |
| `outputStyle` | Active output style |
| `statusLine` | Status-line config |
| `permissions` | `allow` / `ask` / `deny` / `defaultMode` / `additionalDirectories` |
| `sandbox` | Filesystem and network isolation |
| `hooks` | Lifecycle event handlers |
| `env` | Environment variables for every session |
| `enabledPlugins` | Plugins to enable for this scope |
| `extraKnownMarketplaces` | Additional plugin marketplaces |
| `autoMemoryEnabled` | Toggle auto-memory |
| `autoMemoryDirectory` | Custom auto-memory location |
| `autoMode` | Auto-mode classifier rules |
| `cleanupPeriodDays` | Session and worktree cleanup age |
| `companyAnnouncements` | Startup messages |
| `language` | Response and dictation language |
| `respectGitignore` | `@`-picker behavior |
| `attribution` | Git commit/PR attribution string |
| `apiKeyHelper`, `awsAuthRefresh`, `otelHeadersHelper` | Dynamic credential generation |
| `disableAllHooks`, `disableSkillShellExecution`, `disableRemoteControl`, `disableAutoMode` | Lockdown switches |
| `forceLoginMethod`, `forceLoginOrgUUID`, `minimumVersion`, `forceRemoteSettingsRefresh` | Enterprise auth/version policy |

The full list is at <https://code.claude.com/docs/en/settings.md>.

### A.3 The `$schema` Trick

Add `$schema` for autocompletion and inline validation in any JSON-aware editor:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  ...
}
```

---

## Appendix B: Permission Modes

| Mode | Description | Best for |
|---|---|---|
| `default` | Prompt for each sensitive operation | Standard interactive use |
| `acceptEdits` | Auto-accept file edits without prompting | Focused work, CI |
| `plan` | Read-only research; produces plan you approve | Pre-implementation analysis |
| `auto` | Classifier-based; auto-allows safe ops, blocks risky, prompts borderline | High-trust automation with safety net |
| `dontAsk` | Allow only pre-approved tools; reject everything else | Strict CI |
| `bypassPermissions` | Skip all checks | Last-resort automation; document and audit |

Switch mid-session with `Shift+Tab` (cycles modes).

---

## Appendix C: Hook Events

The full list of events Claude Code emits. See <https://code.claude.com/docs/en/hooks.md> for input/output schemas.

| Category | Events |
|---|---|
| Session | `SessionStart`, `Setup`, `InstructionsLoaded`, `SessionEnd` |
| User input | `UserPromptSubmit`, `UserPromptExpansion` |
| Tool calls | `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `PermissionDenied` |
| Sub-agents | `SubagentStart`, `SubagentStop` |
| Tasks | `TaskCreated`, `TaskCompleted` |
| Stop / errors | `Stop`, `StopFailure`, `Notification` |
| Agent teams | `TeammateIdle` |
| Filesystem / config | `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove` |
| Compaction | `PreCompact`, `PostCompact` |
| MCP | `Elicitation`, `ElicitationResult` |

---

## Appendix D: AGENTS.md vs CLAUDE.md

| Concern | File | Rationale |
|---|---|---|
| Build/test/lint commands | Both | Universal |
| Code style, naming conventions | `AGENTS.md` | Tool-agnostic |
| Architecture overview | `AGENTS.md` | Tool-agnostic |
| Tech stack details | `AGENTS.md` | Tool-agnostic |
| Commit conventions | `AGENTS.md` | Tool-agnostic |
| Claude-specific sub-agent workflow notes | `CLAUDE.md` | Only meaningful to Claude Code |
| Skill / hook / MCP references | `CLAUDE.md` | Only meaningful to Claude Code |
| Output style preferences | `CLAUDE.md` | Claude Code feature |
| Personal editor preferences | `~/.claude/CLAUDE.md` | Claude Code, user-level |
| Local secrets / paths | `CLAUDE.local.md` (gitignored) | Local override |
| Module-specific conventions | `.claude/rules/<topic>.md` with `paths:` | Loads only when relevant |

To avoid duplication, import inside CLAUDE.md:

```markdown
# CLAUDE.md
@AGENTS.md

## Claude-specific notes
- After implementing features, invoke the `code-reviewer` sub-agent.
```

---

## Appendix E: Migrating from Older Patterns

If you're on an older Claude Code setup, here's what to update:

### E.1 Slash commands → Skills

Old `/project:deploy` invocation works as `/deploy` now. Existing `.claude/commands/*.md` files keep working. For new workflows, use skills (directory + SKILL.md). Where you need bundled assets (templates, scripts, reference docs), only skills will do.

### E.2 Sub-directory `CLAUDE.md` → Path-scoped Rules

```
# Before
src/CLAUDE.md
src/api/CLAUDE.md
tests/CLAUDE.md

# After
.claude/rules/style.md           # No paths: → always-on
.claude/rules/api-design.md      # paths: ["src/api/**/*.ts"]
.claude/rules/testing.md         # paths: ["**/*.test.ts"]
```

### E.3 MCP in `settings.json` → `.mcp.json`

```diff
# .claude/settings.json
- "mcpServers": { "github": { ... } }

# Move to .mcp.json at the project root:
+ {
+   "mcpServers": { "github": { ... } }
+ }
```

### E.4 Model References

Update aliases or pinned IDs:

```diff
- "model": "claude-opus-4-5"
+ "model": "opus"        # or "claude-opus-4-6"

- "model": "claude-sonnet-4-5"
+ "model": "sonnet"      # or "claude-sonnet-4-6"
```

### E.5 Permission Lists — Add `ask`

```diff
{
  "permissions": {
    "allow": [...],
+   "ask": ["Bash(git push *)", "Bash(pnpm db:migrate *)"],
    "deny": [...]
  }
}
```

### E.6 Sharing Customization → Plugins

If you've been maintaining a "claude-config" repo and copying files around, package it as a plugin. You get versioning, distribution via marketplaces, `${CLAUDE_PLUGIN_DATA}` for persistent state, and updates via `claude plugin update`.

### E.7 Sub-agent Frontmatter Cleanup

```diff
---
name: code-reviewer
description: ...
- zze: [generate-endpoint]    # ← was a typo; field doesn't exist
+ skills: [generate-endpoint] # ← correct field
+ memory: project              # ← new: persistent memory
+ effort: high                 # ← new: extended-thinking budget
+ isolation: worktree          # ← new: worktree-isolated execution
---
```

---

## Appendix F: Claude Code vs GitHub Copilot Comparison (Updated)

| Dimension | Claude Code (May 2026) | GitHub Copilot |
|---|---|---|
| **Primary config** | `CLAUDE.md` + `AGENTS.md` | `.github/copilot-instructions.md` |
| **Cross-platform agent instructions** | ✅ `AGENTS.md` (open standard) | ✅ `AGENTS.md` (also reads it) |
| **Path-scoped rules** | ✅ `.claude/rules/<name>.md` with `paths:` | ✅ `.instructions.md` with `applyTo` |
| **Auto-memory** | ✅ Claude writes its own notes per project | ❌ Not available |
| **User-level config** | `~/.claude/CLAUDE.md` + `settings.json` | VS Code user settings |
| **Sub-agents** | YAML frontmatter; isolation, memory, effort, skills, worktree | `.agent.md` files |
| **Agent teams** | ✅ Lead + parallel teammates with shared task list | ❌ Single-level only |
| **Sub-agent worktree isolation** | ✅ `isolation: worktree` | ❌ Not available |
| **Sub-agent persistent memory** | ✅ `memory: project/local/user` | ❌ Not available |
| **Hooks** | 30+ events × 4 handler types (command, http, prompt, agent); async hooks | Event-level (git, session); commands only |
| **Skills (reusable workflows)** | ✅ `.claude/skills/<name>/SKILL.md` with bundled assets, auto-invoke, fork context | `.github/prompts/*.prompt.md` |
| **Bundled skills** | ✅ `/batch`, `/claude-api`, `/debug`, `/loop`, `/simplify` | ❌ |
| **Plugins / Marketplaces** | ✅ Versioned bundles; LSP servers; user-config; managed restrictions | Limited extension model |
| **MCP integration** | Native; project file `.mcp.json`; tool search defers schemas | Native; configured via VS Code |
| **Sandboxing** | ✅ OS-level filesystem + network isolation | ❌ Process-level only |
| **Plan mode** | ✅ Read-only research mode with approval gate | ⚠️ Limited |
| **Auto mode** | ✅ Classifier-based with customizable rules | ❌ |
| **Output styles** | ✅ Custom system-prompt sections | ❌ |
| **Status line** | ✅ Custom shell-script-driven | ❌ |
| **Code Review (PR-time)** | ✅ Native + REVIEW.md | ✅ Copilot for PRs |
| **Worktree-based parallelism** | ✅ `/batch`, `EnterWorktree`, `.worktreeinclude` | ❌ |
| **Surfaces** | CLI, web, desktop, VS Code, JetBrains, Slack, GitHub Actions, GitLab CI, Chrome, Computer Use, Remote Control | VS Code, JetBrains, Visual Studio, GitHub.com, mobile |
| **Routines / scheduled tasks** | ✅ Schedule, API, GitHub-event triggers | ❌ |
| **Token consumption** | Hooks: 0 (command/http) or LLM cost (prompt/agent); skills with `disable-model-invocation`: 0 idle; CLAUDE.md: always-on | Similar model |
| **Permission model** | `allow` / `ask` / `deny` + 6 modes + sandbox | Tools list per agent |
| **Managed settings / MDM** | ✅ Server-managed + macOS plist + Windows registry + file-based + drop-in dir | Limited |
| **OpenTelemetry observability** | ✅ Built-in metrics, events, traces | ⚠️ Limited |
| **Version control** | All config files committed (except local overrides) | All config files committed |

---

## Closing — Core Design Philosophy

Claude Code is built for engineers who want their AI tooling to behave like a disciplined, version-controlled member of the team. **Every customization is a plain text file. Every enforcement mechanism is a script or a permission rule. Every context decision is observable via `/context`.** The platform now spans far more than the terminal, but the principle is the same: the *configuration is the contract*, the configuration travels with the project, and what is auditable is what is trustworthy.

The goal isn't to make Claude helpful — that's the baseline. The goal is to make Claude **reliably correct within the specific constraints of your project, your team, and your security posture**. Done right, this stack gives you a teammate that doesn't drift.

---

*Revised May 2026 against current Claude Code documentation at <https://code.claude.com/docs/en/>. Subject to change as the platform evolves; consult the docs for the latest.*

*— END —*
