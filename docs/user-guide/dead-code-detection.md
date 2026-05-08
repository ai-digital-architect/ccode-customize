# Dead Code Detection

## Purpose

The dead code detection skill identifies unused exports, unreachable code branches, stale feature flags, and orphaned files in the codebase. It produces a deletion candidate list to help reduce technical debt. The skill operates in read-only mode.

Use this skill:
- During cleanup sprints to identify safe deletions
- Before releases to reduce bundle size and attack surface
- When onboarding to understand which code is actually active

## Prerequisites

- Source code under `src/` (TypeScript/JavaScript files)
- A git repository (used for last-modified dates on candidates)
- Standard tools available: `grep`, `find`, `git`

## Usage

Invoke the skill with a slash command:

```
/dead-code [scope]
```

The `scope` argument controls what is scanned:
- `all` -- scan the entire `src/` directory
- `src/module-name` -- scan only a specific module

## Example

```
/dead-code all
```

This scans every TypeScript file under `src/`, checks each exported symbol for imports elsewhere, identifies unreachable branches and permanently disabled feature flags, and finds files that are never imported.

```
/dead-code src/billing
```

This limits the scan to the `billing` module only.

## Output

The skill writes a structured report to `.claude/analysis/dead-code-report.json` with each candidate containing:

- **File path and line number** of the dead code
- **Type**: `unused-export`, `unreachable`, `stale-flag`, or `orphaned`
- **Symbol/identifier name**
- **Last modified date** from git history
- **Confidence level**: high, medium, or low

Results are also presented grouped by detection type:
1. Unused exports (exported symbols with zero imports)
2. Unreachable branches (`if (false)`, permanently disabled conditions)
3. Stale feature flags (flags permanently set to true or false)
4. Orphaned files (files not imported by any other file)

## Tips

- Start with high-confidence candidates -- these are safest to remove.
- Review `medium` and `low` confidence candidates manually before deletion, as they may be used dynamically or via reflection.
- Orphaned files may include entry points, scripts, or config files that are legitimately not imported. Verify before removing.
- Add recommended permissions:
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

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| False positives on exports | Symbol is used dynamically (e.g., `module[key]`) | Mark as reviewed and skip; dynamic usage cannot be statically detected |
| Entry point files flagged as orphaned | Main entry files are not imported by other files | These are expected -- exclude entry points from the orphan check |
| Feature flag detection misses custom patterns | Flag naming does not match `FEATURE_`, `featureFlag`, or `isEnabled` | Add your flag naming convention to the skill's grep patterns |
| Large number of results | Codebase has accumulated significant dead code | Focus on one type at a time, starting with unused exports |
