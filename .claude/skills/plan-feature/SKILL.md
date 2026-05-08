---
name: plan-feature
description: >
  Creates a detailed implementation plan for a feature. Outputs a plan file
  that can be consumed by implement-feature. Use as the first step in a
  feature development chain.
argument-hint: "[feature description]"
allowed-tools: Read, Bash
---

Plan feature: $ARGUMENTS

## Steps

1. Clean the chain directory: `rm -f .claude/chain/plan.md .claude/chain/result.md`
2. Research the codebase to understand relevant modules and patterns
3. Design the implementation approach
4. Write the plan to `.claude/chain/plan.md` with:
   - Feature summary
   - Files to create/modify (with paths)
   - Implementation steps (ordered)
   - Test strategy
   - Risks and mitigations
5. Tell the user: "Plan saved to `.claude/chain/plan.md`. Run `implement-feature` to execute it."
