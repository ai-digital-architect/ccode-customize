---
name: implement-feature
description: >
  Implements a feature from a plan file produced by plan-feature. Reads
  the plan and executes each step. Use after planning is complete.
argument-hint: "[optional: override instructions]"
allowed-tools: Read, Write, Edit, Bash
---

Implement from plan.

## Steps

1. Read `.claude/chain/plan.md` — if it does not exist, tell the user to run `plan-feature` first
2. Execute each implementation step from the plan
3. Write tests alongside code
4. Run `pnpm build && pnpm test`
5. Write implementation summary to `.claude/chain/result.md`:
   - Files created/modified
   - Test results
   - Any deviations from the plan
6. Tell the user: "Implementation complete. Run `review-feature` to review."
