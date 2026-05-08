---
name: explore-implement
description: >
  Two-phase workflow: first researches the codebase read-only, then implements
  changes based on findings. Use for any new feature, refactor, or bug fix
  where understanding the existing code is important before making changes.
argument-hint: "[feature or task description]"
allowed-tools: Read, Write, Edit, Bash
---

Research, then implement: $ARGUMENTS

## Phase 1: Research

Invoke the `researcher` sub-agent with the task description.

The researcher will produce `.claude/research-output/research.md` with:
- Relevant files and their purposes
- Existing patterns and conventions to follow
- Dependencies that will be affected
- Potential conflicts or risks
- Recommended implementation approach

The researcher is physically prevented from writing files (`disallowedTools`).
This guarantees the research phase is read-only.

## Phase 2: Implement

Read `.claude/research-output/research.md`, then invoke the `implementer`
sub-agent with:
- The original task description
- The full research summary
- Specific files to modify and patterns to follow

## Phase 3: Verify

Run `pnpm build && pnpm test` and fix any issues.

Present a summary of what was implemented and how it follows existing patterns.
