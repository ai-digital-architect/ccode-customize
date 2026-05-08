---
name: review-feature
description: >
  Reviews a feature implementation by reading the chain artifacts (plan and
  result) and comparing against the original requirements. Use as the
  final step in a feature development chain.
argument-hint: "[optional: specific concerns]"
allowed-tools: Read, Bash
---

Review feature implementation.

## Steps

1. Read `.claude/chain/plan.md` for the original plan
2. Read `.claude/chain/result.md` for the implementation summary
3. Compare implementation against plan:
   - Were all planned steps completed?
   - Were any unplanned changes made?
   - Does the test coverage match the test strategy?
4. Run `pnpm test` to verify everything passes
5. Produce a review summary with:
   - Approval / Request Changes recommendation
   - Any deviations from plan and whether they are acceptable
   - Remaining gaps if any
