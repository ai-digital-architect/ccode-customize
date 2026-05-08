# Human-in-the-Loop Approval

## Purpose

The human-in-the-loop approval pattern implements a two-phase workflow: prepare changes and present them for review, then execute only after explicit human sign-off. Use this for deployments, database migrations, or any irreversible operation where automated execution without confirmation is unacceptable.

## Prerequisites

- **Hooks**: `require-approval.sh` (PreToolUse) in `.claude/hooks/`, executable
- **Settings**: Hook registrations merged into `.claude/settings.json`
- **Directory**: `.claude/approval/` must exist

No sub-agents are required. This pattern uses a skill and a hook only.

## Architecture

The `require-approval.sh` hook intercepts every Bash tool call. When the command matches a destructive pattern (deploy, migrate, kubectl apply, terraform apply, etc.), the hook checks for the sentinel file `.claude/approval/approved`. If absent, it exits with code 2 and blocks execution. This is deterministic enforcement -- the model cannot execute a destructive operation without the sentinel file, regardless of prompt instructions.

## Usage

Invoke via the slash command:

```
/approve-then-deploy [operation description]
```

Provide a description of the operation to prepare and execute.

## Workflow

### Phase 1: Prepare

1. The skill analyzes the requested operation.
2. All necessary changes are generated but destructive operations are NOT executed.
3. A summary is written to `.claude/approval/pending.md` containing what will change, risk assessment, rollback plan, and estimated impact.
4. The summary is presented to the user with the prompt: "Please review the changes above. Type 'approve' to proceed or 'reject' to cancel."

### Phase 2: Execute (only after approval)

5. The user types "approve" to proceed.
6. The sentinel file `.claude/approval/approved` is created.
7. Destructive or irreversible operations are executed (the hook now allows them).
8. The sentinel file is removed after execution.
9. The execution result is presented.

If the user types "reject", all pending artifacts are cleaned up and the workflow stops.

## Example

```
/approve-then-deploy "run database migration to add user_preferences table and deploy API v2.3"
```

The skill prepares the migration SQL and deployment plan, presents a risk assessment showing medium risk with a rollback plan, and waits. After the user types "approve", the migration and deployment execute.

## Output

- `.claude/approval/pending.md` -- detailed change summary with risk assessment and rollback plan
- Execution results from the approved operations
- The sentinel file is transient (created before execution, removed after)

## Configuration

Edit the `destructive_patterns` array in `require-approval.sh` to customize which commands require approval:

```bash
destructive_patterns=(
  "deploy"
  "migrate"
  "kubectl apply"
  "terraform apply"
  "docker push"
  "npm publish"
  "pnpm publish"
  "your-custom-command"
)
```

## Tips

- The sentinel file mechanism is simple but effective. The model could theoretically create the sentinel file itself, but doing so would be explicitly visible in the conversation.
- Always review the rollback plan in `pending.md` before approving.
- For extra safety, run the preparation phase in a separate session from the execution phase.
- Token cost is modest: approximately 2,000-5,000 tokens for preparation and 1,000-3,000 for execution.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Command blocked unexpectedly | Command matches a destructive pattern | Review the `destructive_patterns` list; remove false-positive patterns |
| Command not blocked when expected | Pattern not in the destructive list | Add the command pattern to `destructive_patterns` in `require-approval.sh` |
| Sentinel file persists after execution | Execution crashed before cleanup | Manually delete `.claude/approval/approved` |
| Hook does not fire | Hook not registered or not executable | Verify `settings.json` and run `chmod +x .claude/hooks/require-approval.sh` |
