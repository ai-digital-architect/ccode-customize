---
name: fan-out-fan-in
description: >
  Runs parallel independent workers across modules/packages and merges results.
  Use when a task can be cleanly partitioned across modules, packages, or files
  with no cross-dependencies between partitions.
argument-hint: "[task-description] [module-list-or-glob]"
allowed-tools: Read, Write, Edit, Bash
---

Execute a parallel fan-out/fan-in workflow for: $ARGUMENTS

## Steps

1. **Identify work units**: Determine the list of independent modules or files to process.
   Store the manifest in `.claude/fan-out-results/manifest.json`.

2. **Clean previous results**: `rm -rf .claude/fan-out-results/*.json` (except manifest).

3. **Fan out**: For each work unit, invoke the `parallel-worker` sub-agent with:
   - The specific module/file path
   - The task description
   - The output contract (write result to `.claude/fan-out-results/<worker-name>.json`)

4. **Wait for completion**: After all workers finish, verify each has written a result file.

5. **Merge**: Invoke the `result-merger` sub-agent to reconcile all worker outputs
   into a single unified result.

6. **Report**: Present the merged result with per-worker status summary.
