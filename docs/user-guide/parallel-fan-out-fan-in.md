# Parallel Fan-out / Fan-in

## Purpose

The parallel fan-out/fan-in pattern distributes independent work units across multiple parallel workers and then merges the results. Use this when a task can be cleanly partitioned across modules, packages, or files with no cross-dependencies between partitions -- for example, applying the same transformation to every package in a monorepo.

## Prerequisites

- **Sub-agents**: `parallel-worker` and `result-merger` installed in `.claude/agents/`
- **Hooks**: `track-worker-completion.sh` (SubagentStop) in `.claude/hooks/`, executable
- **Settings**: Hook registrations merged into `.claude/settings.json`
- **Directory**: `.claude/fan-out-results/` must be writable

## Architecture

The skill acts as a coordinator. It identifies independent work units, fans out by invoking one `parallel-worker` sub-agent per unit, then invokes the `result-merger` sub-agent to reconcile all outputs. The `result-merger` has `disallowedTools: [Edit, MultiEdit]` -- it reads and summarizes but never modifies source files. The `track-worker-completion.sh` hook logs each sub-agent's completion to `completion-log.jsonl` for reliable tracking even if the coordinator crashes.

## Usage

Invoke via the slash command:

```
/fan-out-fan-in [task-description] [module-list-or-glob]
```

Provide a description of the task to perform on each unit, and either an explicit list of modules or a glob pattern to discover them.

## Workflow

1. **Identify work units**: The skill determines which modules or files to process and writes a manifest to `.claude/fan-out-results/manifest.json`.
2. **Clean previous results**: Old result files in `.claude/fan-out-results/` are removed (except the manifest).
3. **Fan out**: For each work unit, a `parallel-worker` sub-agent is invoked with the module path, task description, and output contract (write to `.claude/fan-out-results/<worker-name>.json`).
4. **Completion tracking**: The `track-worker-completion.sh` hook appends a JSON record to `completion-log.jsonl` each time a sub-agent stops.
5. **Merge**: The `result-merger` sub-agent reads all worker output files and produces a unified result.
6. **Report**: The merged result is presented with a per-worker status summary.

## Example

```
/fan-out-fan-in "add input validation to all handler functions" packages/*
```

This discovers all packages, spawns a parallel worker for each, and merges the validation results into a single report showing which packages were updated and how.

## Output

- `.claude/fan-out-results/manifest.json` -- list of all work units
- `.claude/fan-out-results/<worker-name>.json` -- per-worker result files
- `completion-log.jsonl` -- timestamped completion records
- A unified merged result with per-worker status summary

## Configuration

- **Worker scoping**: Workers are scoped to their assigned module by instruction. For strict path enforcement, add a PostToolUse path-validation hook.
- **Result format**: Workers write JSON to a predictable path. Customize the output contract in the skill if your format differs.
- **Merger permissions**: The `result-merger` is read-only by default. Do not add write tools to its allowed list.

## Tips

- Ensure work units are truly independent. Cross-module dependencies will cause merge conflicts or broken builds.
- Check `completion-log.jsonl` if a fan-out appears to hang -- it shows which workers completed and which did not.
- Token cost scales linearly with the number of workers (approximately 1,000-3,000 tokens per worker plus 1,000-2,000 for the merger).
- For large module counts, consider batching to avoid excessive parallelism.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Missing worker results | Worker failed or wrote to wrong path | Check `completion-log.jsonl` for errors; verify output path matches the contract |
| Merger modifies source files | Merger agent misconfigured | Verify `disallowedTools` includes Write, Edit, and MultiEdit in the agent definition |
| Stale results from previous run | Old result files not cleaned | Ensure the clean step runs before fan-out; manually delete `.claude/fan-out-results/*.json` |
| Manifest is empty | Glob pattern matched nothing | Check the module list or glob pattern; verify the paths exist |
