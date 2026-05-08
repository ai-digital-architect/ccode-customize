---
name: continuous-loop
description: >
  Starts a continuous autonomous development loop. The agent reads a plan file,
  selects the highest-priority item, implements it, runs tests, commits on green,
  updates the plan, and repeats. Use when you want to run autonomous iterative
  development with backpressure-driven convergence.
argument-hint: "[task-description] [--max-iterations N] [--completion-promise TEXT]"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash
---

:rocket: Start continuous build loop: $ARGUMENTS

## :gear: Initialization

1. Parse arguments:
   - Task description (required)
   - `--max-iterations` (default: 50)
   - `--completion-promise` (default: `LOOP_COMPLETE`)
2. Create or read `.claude/loop-state.json`:
   ```json
   {
     "iteration": 0,
     "max_iterations": 50,
     "completion_promise": "LOOP_COMPLETE",
     "task": "<task-description>",
     "status": "running",
     "started_at": "<ISO-8601>",
     "last_iteration_at": null
   }
   ```
3. Verify `fix_plan.md` exists — if not, invoke the `loop-planner` sub-agent first
4. Verify `specs/` directory exists — warn if empty

## :hammer: Build Iteration Protocol

Execute ONE item per iteration:

### Step 1 — :mag: Read State
- Read `fix_plan.md` to find the highest-priority incomplete item
- Read relevant `specs/*.md` files for context
- Read `AGENTS.md` for process learnings

### Step 2 — :mag: Search Before Implementing
- Invoke up to 5 parallel sub-agents to search the codebase for existing implementations
- **Do NOT assume code is not implemented** — always verify

### Step 3 — :hammer: Implement
- Invoke the `loop-implementer` sub-agent with:
  - The selected plan item
  - Relevant spec file contents
  - Search results from Step 2
- The implementer writes code and tests
- **Full implementations only — NO placeholders, stubs, or TODOs**

### Step 4 — :test_tube: Backpressure
- Run tests ONLY for the specific module changed: `pnpm test -- <changed-file>`
- If tests fail:
  - Fix the failures (up to 3 attempts)
  - If still failing after 3 attempts, document in `fix_plan.md` and move on
- If tests pass: proceed to Step 5

### Step 5 — :white_check_mark: Commit
- `git add -A`
- `git commit -m "feat: <plan-item-summary>"`
- Tag significant milestones: `git tag loop-iteration-<N>`

### Step 6 — :memo: Update State
- Mark the completed item in `fix_plan.md`
- Update `.claude/loop-state.json` with new iteration count
- If you discovered bugs or issues, document them in `fix_plan.md` even if unrelated to current work

### Step 7 — :arrows_counterclockwise: Self-Improvement
- If you learned something about the build process, update `AGENTS.md`
- **Do NOT place status reports in AGENTS.md** — only build process learnings

### Step 8 — :dart: Completion Check
- If ALL items in `fix_plan.md` are complete:
  - Run the full test suite: `pnpm test`
  - If all pass: emit `LOOP_COMPLETE`
  - If failures remain: add them to `fix_plan.md` and continue
- If items remain: continue to the next iteration

## :warning: Critical Constraints

- **ONE item per iteration** — do not attempt multiple plan items
- **Search before implementing** — always check if code already exists
- **No placeholders** — every implementation must be complete and functional
- **Limit subagents for tests** — only 1 subagent for build/test operations to avoid contention
- **If stuck for 3 attempts** — document the blocker in `fix_plan.md` and move to the next item
- **Do NOT dump status into AGENTS.md** — only build process learnings belong there

## :bell: Stop Hook Integration

The `stop-loop.sh` Stop hook manages loop continuation:
- Checks if `LOOP_COMPLETE` was emitted in the session output
- Checks if max iterations reached
- If neither: blocks exit (exit code 2) and re-injects this prompt
- If either: allows exit and sends notification
