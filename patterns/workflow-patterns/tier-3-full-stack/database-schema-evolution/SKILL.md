---
name: schema-evolve
description: >
  Evolves database schema through a gated pipeline: diff → generate migration →
  check compatibility → produce rollout plan. Each stage validates before the
  next proceeds. Use for any database schema change.
argument-hint: "[description of schema change]"
allowed-tools: Read, Write, Edit, Bash
---

Evolve database schema: $ARGUMENTS

## Stage 1: Schema Diff
Invoke `schema-differ` to compare current schema against the requested change.
Output: `.claude/schema/diff.json`

## Stage 2: Generate Migration
Invoke `migration-generator` to produce up/down migration scripts.
Output: `migrations/<timestamp>_<name>.sql`

## Stage 3: Compatibility Check
Invoke `compat-checker` to verify backward compatibility and reversibility.
Output: `.claude/schema/compat-report.json`
If the migration is NOT reversible, STOP and report the issue.

## Stage 4: Rollout Plan
Invoke `rollout-planner` (or produce inline) to create a deployment plan.
Output: `.claude/schema/rollout-plan.md`

Present the complete plan for human review.
