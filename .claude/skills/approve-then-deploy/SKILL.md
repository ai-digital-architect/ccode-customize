---
name: approve-then-deploy
description: >
  Two-phase workflow that prepares changes, presents a summary for human
  approval, and only executes after explicit sign-off. Use for deployments,
  database migrations, or any irreversible operation.
argument-hint: "[operation description]"
allowed-tools: Read, Write, Edit, Bash
---

Execute with human approval gate: $ARGUMENTS

## Phase 1: Prepare

1. Analyze the requested operation
2. Generate all necessary changes but do NOT apply destructive operations yet
3. Write a clear summary to `.claude/approval/pending.md` containing:
   - What will change (files, resources, environments)
   - Risk assessment (low/medium/high)
   - Rollback plan
   - Estimated impact
4. Present the summary to the user and ask:
   **"Please review the changes above. Type 'approve' to proceed or 'reject' to cancel."**

## Phase 2: Execute (only after approval)

5. Wait for the user to confirm with "approve"
6. Create the sentinel file: `touch .claude/approval/approved`
7. Execute the destructive/irreversible operations
8. Remove the sentinel: `rm .claude/approval/approved`
9. Present the execution result

If the user types "reject", clean up all pending artifacts and stop.
