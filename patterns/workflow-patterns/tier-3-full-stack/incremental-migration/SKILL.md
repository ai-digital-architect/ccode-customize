---
name: incremental-migrate
description: >
  Migrates modules one at a time, running full test suite between each.
  Never breaks the build mid-migration. Use for framework upgrades,
  API version migrations, or pattern replacements across modules.
argument-hint: "[migration-description] [module-list-or-auto]"
allowed-tools: Read, Write, Edit, Bash
---

Execute incremental migration: $ARGUMENTS

## Workflow

1. **Discover modules**: List all modules to migrate (from arguments or auto-detect)
2. **For each module** (sequential, one at a time):
   a. Invoke the `module-migrator` sub-agent with the module path and migration spec
   b. After the sub-agent completes, run `pnpm build && pnpm test`
   c. If tests fail: fix the failures before moving to the next module
   d. If tests pass: log success and proceed to next module
   e. Write progress to `.claude/migration/progress.json`
3. **After all modules**: Run full test suite one final time
4. **Report**: Migration summary with per-module status
