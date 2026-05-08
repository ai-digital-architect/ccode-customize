---
name: cancel-loop
description: >
  Cancels an active continuous loop. Updates loop state, presents a summary of
  completed work, and ensures clean shutdown. Use to stop a running loop gracefully.
argument-hint: "[optional: reason]"
disable-model-invocation: true
allowed-tools: Read, Write, Bash
---

:no_entry_sign: Cancel continuous loop: $ARGUMENTS

## :gear: Cancellation Protocol

### Step 1 — :mag: Read State
- Read `.claude/loop-state.json` to get current iteration count and status
- If no active loop found, report "No active loop to cancel" and stop

### Step 2 — :memo: Update State
- Set `status` to `"cancelled"` in `.claude/loop-state.json`
- Set `cancelled_at` to current ISO-8601 timestamp
- Set `cancel_reason` to the provided reason (or `"user-requested"`)

### Step 3 — :bar_chart: Generate Summary
Read `fix_plan.md` and present:

```markdown
## :no_entry_sign: Loop Cancelled

- **Iterations completed**: <N>
- **Cancel reason**: <reason>
- **Items completed**: <count>
- **Items remaining**: <count>
- **Last commit**: <git log --oneline -1>

### Completed Items
<list from fix_plan.md>

### Remaining Items
<list from fix_plan.md>
```

### Step 4 — :white_check_mark: Clean Exit
- Remove the stop-loop sentinel file if present
- The Stop hook will see `status: "cancelled"` and allow clean exit

## :warning: Note
This does NOT revert any changes. Use `git log` to review commits
made during the loop and `git reset --hard <hash>` if rollback is needed.
