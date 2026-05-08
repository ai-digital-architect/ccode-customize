# Cost-Threshold Gate

## Purpose

The cost-threshold gate pattern tracks estimated token spend during task execution and halts operations if the budget ceiling is approached. Use this for expensive operations like large-scale refactoring, multi-file generation, or any task where unbounded token consumption is a concern.

## Prerequisites

- **Hooks**: `cost-gate.sh` (PreToolUse) in `.claude/hooks/`, executable
- **Settings**: Hook registrations merged into `.claude/settings.json` with matcher `*` (all tools)
- **File**: `.claude/budget.json` must be initialized before starting

No sub-agents are required. This pattern uses a skill and a hook only.

## Architecture

The `cost-gate.sh` hook fires before every tool call (matcher: `*`). It estimates the cost of the pending call based on tool type, adds the estimate to cumulative spend tracked in `.claude/budget.json`, and blocks with exit code 2 if the total would exceed the budget ceiling. The model cannot bypass this because the hook fires before the tool executes. The `disable-model-invocation: true` flag in the skill ensures cost tracking is accurate.

## Usage

Invoke via the slash command:

```
/cost-aware-task [task description] [budget-limit-in-tokens]
```

Provide the task to execute and optionally a budget limit. If no budget is specified, the default of 100,000 tokens is used.

## Workflow

1. **Initialize**: The skill reads `.claude/budget.json` (or creates it with a default 100,000 token budget).
2. **Estimate**: The scope of work is analyzed and a warning is issued if it may exceed the budget.
3. **Execute with tracking**: Every tool call is intercepted by the hook. Cost is estimated by tool type:
   - Write/Edit: content length divided by 4
   - Bash: 50 tokens
   - Read: 20 tokens
4. **On budget exceeded**: The hook blocks the tool call. A summary of completed and remaining work is presented. The user is asked whether to increase the budget or stop.
5. **Completion**: The estimated total token spend is reported and `.claude/budget.json` is updated with the remaining budget.

## Example

```
/cost-aware-task "refactor all database queries to use parameterized statements" 50000
```

The skill begins refactoring. After modifying several files, the cumulative estimated cost approaches 50,000 tokens. The hook blocks the next operation, and the user is asked whether to increase the budget to continue or accept the partial result.

## Output

- The task results (whatever files were created or modified before the budget was reached)
- Updated `.claude/budget.json` with remaining budget
- `.claude/spend.log` with per-operation cost records
- A summary of estimated total token spend

## Configuration

Initialize the budget file before starting:

```json
{"budget_tokens": 100000, "spent_tokens": 0}
```

To increase the budget mid-session, edit `.claude/budget.json` directly -- set `budget_tokens` to the new limit. The hook will read the updated value on the next tool call.

Cost estimation weights can be adjusted in `cost-gate.sh` by modifying the per-tool-type estimates.

## Tips

- The budget file is the source of truth. The model could modify it, but doing so would be explicitly visible in the conversation transcript.
- Start with a conservative budget and increase as needed. It is easier to raise a limit than to undo excess work.
- The hook adds zero token overhead itself (it is a shell script, not an LLM invocation).
- Use `spend.log` to analyze which operations consumed the most budget and optimize future runs.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| All tool calls blocked immediately | `spent_tokens` already at or above `budget_tokens` | Reset `spent_tokens` to 0 in `.claude/budget.json` or increase `budget_tokens` |
| Budget file not found | `.claude/budget.json` was not initialized | Create the file with `{"budget_tokens": 100000, "spent_tokens": 0}` |
| Cost estimates seem inaccurate | Estimation heuristics are approximate | Adjust the per-tool weights in `cost-gate.sh` for your workload |
| Hook does not fire | Matcher not set to `*` in settings | Verify the hook registration in `settings.json` uses matcher `*` |
