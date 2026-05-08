# Workflow Chaining User Guide

## Purpose

The workflow-chaining pattern links three separate skills into a sequential feature development pipeline: plan, implement, review. Each skill reads the previous skill's output from the filesystem. Use this for structured feature development where planning, execution, and review are distinct phases with human checkpoints between them.

## Prerequisites

The following must be installed in your project:

- **Skills**: `.claude/skills/plan-feature/SKILL.md`, `.claude/skills/implement-feature/SKILL.md`, `.claude/skills/review-feature/SKILL.md`
- **Directory**: `.claude/chain/` must exist
- **Permissions**: Build, test, and chain directory commands in `.claude/settings.json`
- **CLAUDE.md entry**: Document the chain convention so all agents understand the artifact flow

Note: This pattern uses no `agents/` directory. The three skills are the architectural components.

## Architecture

| Component | Role |
|-----------|------|
| `plan-feature` skill | Phase 1: Researches the codebase and writes an implementation plan |
| `implement-feature` skill | Phase 2: Reads the plan and executes each step, writing code and tests |
| `review-feature` skill | Phase 3: Compares implementation against the plan and produces a review |

Chain artifacts in `.claude/chain/`:
- `plan.md` -- Output of `plan-feature`, input to `implement-feature`
- `result.md` -- Output of `implement-feature`, input to `review-feature`

## Usage

Invoke each skill sequentially from the Claude Code prompt:

```
/plan-feature Add user notification preferences with email and push options
```

Review the plan, then:

```
/implement-feature
```

Review the implementation, then:

```
/review-feature
```

Each skill can accept optional arguments (override instructions or specific concerns).

## Workflow

1. **Plan** -- `/plan-feature [description]` cleans the chain directory, researches the codebase, and writes `.claude/chain/plan.md` with feature summary, files to create/modify, implementation steps, test strategy, and risks.
2. **Human checkpoint** -- You review the plan and decide whether to proceed.
3. **Implement** -- `/implement-feature` reads `plan.md`, executes each step, writes tests, runs the build and test suite, and writes `.claude/chain/result.md` with files changed, test results, and deviations.
4. **Human checkpoint** -- You review the code changes.
5. **Review** -- `/review-feature` reads both `plan.md` and `result.md`, compares implementation against plan, runs tests, and produces a review with approval or change-request recommendation.

## Example

```
/plan-feature Add rate limiting middleware with configurable limits per route
```

The plan includes: create `src/middleware/rate-limiter.ts`, modify `src/app.ts` to register the middleware, add tests in `src/middleware/__tests__/rate-limiter.test.ts`, handle Redis-backed counting.

After reviewing the plan:

```
/implement-feature
```

The implementer follows the plan step by step, creates the files, and confirms tests pass.

```
/review-feature Are the Redis connection error cases handled?
```

The reviewer compares plan to result and specifically checks error handling as requested.

## Output

- `.claude/chain/plan.md` -- Detailed implementation plan
- `.claude/chain/result.md` -- Implementation summary with test results
- Modified/created source and test files
- Review summary with approval or change-request recommendation

## Tips

- The `plan-feature` skill cleans the chain directory before each new feature to prevent stale artifacts from interfering.
- You can skip straight to `/implement-feature` if you manually write `.claude/chain/plan.md`.
- Total token cost: plan (2,000-5,000) + implement (5,000-15,000) + review (1,000-2,000).
- Add the chain convention to your `CLAUDE.md` so all agents understand the artifact flow.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `implement-feature` says no plan found | Run `plan-feature` first. The plan must exist at `.claude/chain/plan.md`. |
| `review-feature` says no result found | Run `implement-feature` first. The result must exist at `.claude/chain/result.md`. |
| Stale plan from a previous feature | Run `plan-feature` again -- it cleans the chain directory automatically. |
| `.claude/chain/` directory missing | Run `mkdir -p .claude/chain` or add the Bash permission for that command. |
| Implementation deviates significantly from plan | The review step will flag deviations. Re-run `implement-feature` with override instructions if needed. |
