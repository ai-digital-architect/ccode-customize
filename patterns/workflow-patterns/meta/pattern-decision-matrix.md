# Pattern Decision Matrix

Use this matrix to select the right workflow pattern for your use case.

## Quick Tier Selection

| Question | Answer → Tier |
|----------|--------------|
| Does the task only read/analyze code? | Yes → **Tier 1** |
| Does the task need isolated read-only analysis + write steps? | Yes → **Tier 2** |
| Do you need deterministic enforcement (blocking, gating, notifications)? | Yes → **Tier 3** |

---

## Tier 1: Pure Skills (Single Agent, Read-Heavy)

| Pattern | Skill Name | When to Use |
|---------|-----------|-------------|
| [01] Dependency Audit | `dependency-audit` | Audit licenses and vulnerabilities before releases |
| [02] Template Instantiation | `instantiate-template` | Scaffold new components from a canonical template |
| [03] Documentation Generation | `generate-docs` | Generate or update docs from source code |
| [04] Build Failure Triage | `triage-build` | Diagnose and explain CI/CD build failures |
| [05] Log Analysis | `analyze-logs` | Parse and summarize log files for patterns/errors |
| [06] Compliance Audit | `compliance-audit` | Check code against OWASP, GDPR, license rules |
| [07] Dead Code Detection | `find-dead-code` | Find unused exports, orphaned files, stale flags |
| [08] Infrastructure Drift Detection | `detect-drift` | Compare live infra state vs IaC definitions |
| [09] Postmortem Assistant | `postmortem` | Generate 5-Why postmortem from incident timeline |
| [20] Build Failure Triage | `triage-build` | Explain test failures with root cause + fix suggestion |
| [21] Code Archaeology | `code-archaeology` | Trace a feature's full history and evolution |

---

## Tier 2: Skill + Agents (Isolation Needed, No Hook Enforcement)

| Pattern | Skill Name | When to Use |
|---------|-----------|-------------|
| [10] Explore-then-Implement | `explore-implement` | Research first, implement second, never mix |
| [13] Competitive Analysis | `competitive-analysis` | Analyze competitor approaches without risk of modifications |
| [14] Contract Testing | `contract-test` | Extract and verify API contracts between services |
| [16] Spec-First Verification | `spec-first` | Write tests before implementation, verify coverage |
| [18] PR Review Pipeline | `review-pr` | Multi-perspective code review (security, style, coverage) |
| [22] Workflow Chaining | (multiple skills) | Chain plan → implement → review as separate skills |
| [23] Conditional Branching | `fix-lint` | Branch to language-specific agents based on file type |

---

## Tier 3: Full Stack (Hooks Required for Enforcement)

### Pipeline & Orchestration

| Pattern | Skill Name | Hook Type | Enforcement |
|---------|-----------|-----------|-------------|
| [11] Sequential Pipeline | `build-feature` | PostToolUse | Blocks next step on build failure |
| [12] Parallel Fan-out/Fan-in | `parallel-analyze` | SubagentStop | Tracks worker completion |
| [33] Map-Reduce | `map-reduce` | SubagentStop | Tracks per-worker completion |

### Quality Gates

| Pattern | Skill Name | Hook Type | Enforcement |
|---------|-----------|-----------|-------------|
| [13] Self-Reflection Loop | `reflect-and-improve` | SubagentStop | Blocks if critic score < 4 |
| [15] Regression Sweep | `regression-sweep` | PreToolUse | Captures baseline before first edit |
| [17] API Client Generation | `generate-client` | PostToolUse | Type-checks each generated file |

### Human & Cost Controls

| Pattern | Skill Name | Hook Type | Enforcement |
|---------|-----------|-----------|-------------|
| [24] Human-in-the-Loop Approval | `safe-deploy` | PreToolUse | Blocks destructive ops without approval sentinel |
| [27] Cost Threshold Gate | `cost-aware` | PreToolUse | Blocks expensive ops if budget exceeded |

### Deployment Safety

| Pattern | Skill Name | Hook Type | Enforcement |
|---------|-----------|-----------|-------------|
| [28] Staged Rollout Gate | `staged-rollout` | PreToolUse | Blocks prod deploy without env approval sentinel |
| [25] Environment Parity Check | `env-parity` | PreToolUse | Blocks promotion if config diverges from baseline |
| [26] Secret Rotation | `rotate-secret` | PreToolUse | Blocks credential revocation before health check passes |
| [12] Database Schema Evolution | `schema-evolve` | PreToolUse | Blocks rollout if migration is not reversible |

### Migration & Refactoring

| Pattern | Skill Name | Hook Type | Enforcement |
|---------|-----------|-----------|-------------|
| [29] Incremental Migration | `migrate-module` | PostToolUse | Blocks on build failure after each module |
| [30] Pattern Replacement | `replace-pattern` | PostToolUse | Lint + compile check after each replacement |

### Monitoring

| Pattern | Skill Name | Hook Type | Enforcement |
|---------|-----------|-----------|-------------|
| [19] Watchdog Loop | `watchdog` | Stop | Sends notification on session end if violations found |

---

## Decision Flowchart

```
Is the task purely analytical (read, report, summarize)?
├── YES → Tier 1 (Pure Skill)
│   └── Does it need multiple specialized analysis passes?
│       ├── YES → Consider Tier 2 (add specialized sub-agents)
│       └── NO → Tier 1 is sufficient
└── NO (involves writing/modifying code)
    └── Do you need to PREVENT certain operations automatically?
        ├── YES → Tier 3 (add hooks for enforcement)
        │   └── Which lifecycle event?
        │       ├── Before a tool runs → PreToolUse hook
        │       ├── After a tool runs → PostToolUse hook
        │       ├── When a sub-agent stops → SubagentStop hook
        │       └── When session ends → Stop hook
        └── NO → Tier 2 (isolation via disallowedTools is enough)
```

---

## Hook Selection Guide

| Goal | Hook Event | Exit Code | Example Pattern |
|------|-----------|-----------|-----------------|
| Block a dangerous operation | PreToolUse | 2 | Human approval, parity check |
| Capture state before a change | PreToolUse | 0 | Regression baseline capture |
| Validate output after a write | PostToolUse | 2 on fail | Type-check generated files |
| Gate progression on build success | PostToolUse | 2 on fail | Sequential pipeline |
| Track parallel worker completion | SubagentStop | 0 | Map-reduce, fan-out |
| Gate on sub-agent output quality | SubagentStop | 2 | Self-reflection loop |
| Send notifications at session end | Stop | 0 | Watchdog notify |

---

## Anti-Patterns

| Anti-Pattern | Problem | Correct Approach |
|-------------|---------|-----------------|
| Putting enforcement logic in skill instructions | LLM may not follow it | Use hooks — they run regardless |
| Using `disallowedTools` as the only safety for write operations | Only prevents the agent's own writes | Combine with hooks for cross-agent enforcement |
| Chaining agents in one SKILL.md for isolation | Single context = no isolation | Use separate sub-agent files |
| Hardcoding credentials in hook scripts | Security risk | Use environment variables |
| Block hook that always exits 2 | Deadlocks the session | Always provide a bypass mechanism or fix condition |
