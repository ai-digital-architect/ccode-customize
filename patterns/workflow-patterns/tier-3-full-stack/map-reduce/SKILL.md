---
name: map-reduce
description: >
  Fans out a task across multiple items (files, modules, endpoints) using
  independent worker sub-agents, then reduces results into a unified output.
  Use for bulk operations across many files or modules.
argument-hint: "[task] [item-list-or-glob]"
allowed-tools: Read, Write, Edit, Bash
---

Execute map-reduce: $ARGUMENTS

## Phase 1: Enumerate (Coordinator)
1. Parse the item list from arguments or discover items via glob/find
2. Write manifest to `.claude/map-reduce/manifest.json`:
   ```json
   { "task": "...", "items": ["item1", "item2", ...], "total": N }
   ```
3. Clean previous results: `rm -rf .claude/map-reduce/results/`

## Phase 2: Map (Fan-out)
4. For each item, invoke the `mr-worker` sub-agent with:
   - The item identifier (file path, module name, etc.)
   - The task description
   - Worker writes result to `.claude/map-reduce/results/<item-id>.json`

## Phase 3: Reduce (Aggregation)
5. After all workers complete, invoke the `mr-reducer` sub-agent
6. Reducer reads all result files and produces unified output
7. Present the aggregated result from `.claude/map-reduce/aggregate.md`
