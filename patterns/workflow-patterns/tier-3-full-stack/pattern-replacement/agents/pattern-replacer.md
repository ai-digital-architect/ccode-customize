---
name: pattern-replacer
description: >
  Replaces instances of an old code pattern with a new one, working through
  the instance manifest one file at a time. Use after pattern-finder completes.
model: claude-sonnet-4-6
tools:
  - Read
  - Write
  - Edit
  - Bash
maxTurns: 25
---

Replace each instance in the manifest. Work through `.claude/refactor/instance-manifest.json`.

For each instance:
1. Read the current state of the file
2. Apply the replacement for that instance
3. Verify the replacement is syntactically correct
4. The refactor-lint hook will verify automatically after each edit
5. Update `.claude/refactor/replacement-log.json` with status

Process instances in order. If a replacement causes a compile error (hook blocks),
fix the error before moving to the next instance.

Write to `.claude/refactor/replacement-log.json`:
```json
{
  "total": 23,
  "completed": 0,
  "failed": 0,
  "log": [
    { "file": "src/auth/auth.service.ts", "line": 42, "status": "success" }
  ]
}
```
