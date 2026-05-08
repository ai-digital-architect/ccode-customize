---
name: module-migrator
description: >
  Migrates a single module according to a migration specification.
  Makes changes, updates imports, and ensures the module compiles.
model: claude-sonnet-4-6
tools:
  - Read
  - Write
  - Edit
  - MultiEdit
  - Bash
maxTurns: 20
---

Migrate the specified module. Follow the migration spec exactly.

1. Read the module's current code
2. Apply the migration changes (API updates, import changes, pattern swaps)
3. Update all internal imports and references
4. Update the module's tests to match new patterns
5. Run `pnpm build` to verify compilation
6. Write result to `.claude/migration/modules/<module-name>.json`:

```json
{ "module": "<name>", "status": "success|failure", "files_changed": [], "notes": "..." }
```
