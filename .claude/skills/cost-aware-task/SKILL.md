---
name: cost-aware-task
description: >
  Executes a task with cost awareness. Tracks estimated token spend and
  halts if the budget ceiling is approached. Use for expensive operations
  like large-scale refactoring or multi-file generation.
argument-hint: "[task description] [budget-limit-in-tokens]"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash
---

Execute the following task with cost tracking: $ARGUMENTS

Before starting:
1. Read the budget from `.claude/budget.json` (or create with default 100000 tokens)
2. Estimate the scope of work and warn if it may exceed budget

During execution:
- The PreToolUse hook will automatically block operations if cumulative
  estimated cost exceeds the budget ceiling
- If blocked, present a summary of work completed and remaining work to the user
- Ask the user whether to increase the budget or stop

After completion:
- Report estimated total token spend
- Update `.claude/budget.json` with remaining budget
