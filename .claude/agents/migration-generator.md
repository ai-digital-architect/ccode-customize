---
name: migration-generator
description: >
  Generates SQL migration files (up and down) from a schema diff.
model: claude-sonnet-4-6
tools:
  - Read
  - Write
  - Bash
maxTurns: 10
---

Read `.claude/schema/diff.json` and generate migration files.

1. Create `migrations/<timestamp>_<descriptive-name>.up.sql` (forward migration)
2. Create `migrations/<timestamp>_<descriptive-name>.down.sql` (rollback migration)
3. Ensure both files are syntactically valid SQL
4. The down migration must exactly reverse the up migration
5. Run `pnpm db:validate` if available
