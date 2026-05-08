# Map-Reduce -- User Guide

## Purpose

The map-reduce pattern fans out a task across multiple items (files, modules, endpoints) using independent worker sub-agents, then reduces the results into a unified output. Use this pattern for bulk operations that can be parallelized, such as migrating many files to a new API, auditing all modules for a specific issue, or generating reports across a large codebase.

## Prerequisites

- Claude Code CLI installed and configured
- Sub-agents installed: `mr-worker`, `mr-reducer`
- Hook installed: `mr-track-completion.sh` (SubagentStop)
- Settings fragment merged into `.claude/settings.json`
- Directory `.claude/map-reduce/results/` created for worker outputs

## Architecture

| Component | Type | Role |
|-----------|------|------|
| `SKILL.md` | Skill | Coordinator: enumerates items, fans out workers, triggers reduction |
| `mr-worker` | Sub-agent (write) | Processes a single item in isolation |
| `mr-reducer` | Sub-agent (read-only) | Aggregates all worker results into a unified output |
| `mr-track-completion.sh` | Hook (SubagentStop) | Logs each worker completion to a JSONL audit trail |

The `mr-reducer` has `disallowedTools: [Write, Edit, MultiEdit]` -- it aggregates results but cannot modify source files. Workers are scoped by explicit instructions to process only their assigned item and not modify shared resources.

## Usage

Invoke via the slash command:

```
/map-reduce "Convert all fetch calls to use the new HTTP client" src/**/*.ts
```

Arguments:
- First argument: the task description (what to do to each item)
- Second argument: an item list or glob pattern identifying the targets

## Workflow

1. **Enumerate**: The coordinator parses the item list or discovers items via glob. A manifest is written to `.claude/map-reduce/manifest.json` containing the task, item list, and total count. Previous results are cleaned up.
2. **Map (fan-out)**: For each item, the `mr-worker` sub-agent is invoked with the item identifier and task description. Each worker writes its result to `.claude/map-reduce/results/<item-id>.json`.
3. **Track**: The `mr-track-completion.sh` hook fires on each worker completion, appending `{agent, completed_at}` to `.claude/map-reduce/completion.jsonl`.
4. **Reduce**: After all workers complete, the `mr-reducer` sub-agent reads all result files and produces a unified output at `.claude/map-reduce/aggregate.md`.
5. **Report**: The aggregated result is presented in the session.

### Hook Behavior

The `mr-track-completion.sh` hook fires on every sub-agent stop event but filters to only act on agents named `mr-worker`. It appends a completion record to `.claude/map-reduce/completion.jsonl`. It always exits 0 -- tracking is non-blocking.

## Example

```
/map-reduce "Add error boundary wrapper to each component" src/components/*.tsx
```

Given 12 component files, this will:
1. Create a manifest listing all 12 files
2. Spawn a worker for each file to add the error boundary
3. Track completion of each worker in the JSONL log
4. Produce an aggregate report: "12/12 components wrapped. 2 components already had error boundaries (skipped). 10 components modified."

## Output

| Artifact | Location |
|----------|----------|
| Manifest | `.claude/map-reduce/manifest.json` |
| Per-item results | `.claude/map-reduce/results/<item-id>.json` |
| Completion log | `.claude/map-reduce/completion.jsonl` |
| Aggregate report | `.claude/map-reduce/aggregate.md` |

## Configuration

- **Worker scope**: Customize the `mr-worker` agent instructions to match your task requirements
- **Result format**: Adjust the expected result JSON schema for your use case
- **Completion tracking**: The JSONL log provides an audit trail; extend the hook to add custom metadata

## Tips

- Each worker operates in isolation -- design tasks that do not require cross-item coordination
- For tasks that modify files, review the aggregate report and run tests afterward
- Use specific globs rather than broad patterns to avoid processing unintended files
- The completion log is useful for debugging if some workers fail silently
- For very large item sets (100+), consider batching into smaller map-reduce runs

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Some workers produce no output | Check `.claude/map-reduce/completion.jsonl` to identify which workers completed; inspect their result files |
| Reducer produces incomplete aggregate | Verify all result files exist in `.claude/map-reduce/results/`; check for worker errors |
| Workers modifying shared resources | Review worker scope instructions; add explicit isolation constraints to the `mr-worker` agent |
| Manifest shows wrong item count | Check your glob pattern; ensure it matches the intended files |
