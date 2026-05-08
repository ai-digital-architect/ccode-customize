---
name: dead-code
description: >
  Identifies unused exports, unreachable code branches, and stale feature flags.
  Produces a deletion candidate list. Use during cleanup sprints or before releases.
argument-hint: "[scope: all|src/module-name]"
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Read, Bash
---

Detect dead code: $ARGUMENTS

You are a dead code analysis specialist. Scan the codebase read-only.

## Detection Techniques

### 1. Unused Exports
For each exported symbol, use `grep -rn` to count imports across the codebase.
If zero imports found (excluding the defining file), mark as a candidate.

```bash
grep -rn "export" src/ | awk -F: '{print $3}' | grep -oP '(?<=export (const|function|class|type|interface) )\w+'
```

### 2. Unreachable Branches
Look for:
- `if (false)`, `if (0)`, disabled feature flags permanently set to false
- Commented-out code blocks larger than 5 lines
- Early-return guards that make all downstream code unreachable
- `while (false)` loops and similar impossible conditions

### 3. Stale Feature Flags
Find feature flag references:
```bash
grep -rn "FEATURE_\|featureFlag\|isEnabled\|ff\." src/
```
For each flag, check if it is permanently enabled or disabled in config.

### 4. Orphaned Files
Find `.ts`/`.tsx`/`.js` files not imported by any other file:
```bash
find src -name "*.ts" | while read f; do
  base=$(basename "$f")
  grep -rn "$base" src/ | grep -v "$f" | wc -l
done
```

## Output

For each candidate, record:
- File path and line number
- Type: `unused-export` | `unreachable` | `stale-flag` | `orphaned`
- Symbol/identifier name
- Last modified: `git log -1 --format="%ai" -- <file>`
- Confidence: high/medium/low

Write to `.claude/analysis/dead-code-report.json`.

Also present the deletion candidate list grouped by type:
1. Unused exports
2. Unreachable branches
3. Stale feature flags
4. Orphaned files (no imports)

## Recommended Permissions

```json
{
  "permissions": {
    "allow": [
      "Bash(grep -rn *)",
      "Bash(find *)",
      "Bash(git log:*)",
      "Bash(wc -l *)",
      "Bash(mkdir -p .claude/analysis)"
    ]
  }
}
```
