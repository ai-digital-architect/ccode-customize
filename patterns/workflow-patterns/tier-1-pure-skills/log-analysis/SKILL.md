---
name: analyze-logs
description: >
  Analyzes error logs to identify failure patterns, clusters similar errors,
  and ranks by frequency. Use for periodic log review or incident investigation.
argument-hint: "[log-file-path] [time-window: 1h|24h|7d]"
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Read, Bash
---

Analyze logs: $ARGUMENTS

You are a log analysis specialist. Analyze the provided log file for failure patterns.

## Steps

1. Use `grep`, `awk`, `sort`, `uniq -c` to extract error lines from the log file
2. Filter to the specified time window using timestamp patterns
3. Cluster similar errors by normalizing variable parts (timestamps, IDs, UUIDs, IP addresses, paths)
4. For each distinct pattern, determine:
   - Frequency (count)
   - First occurrence timestamp
   - Last occurrence timestamp
   - Representative example message
   - Severity assessment (critical/high/medium/low)
5. Rank patterns by frequency (most common first)
6. Compare against `.claude/logs/known-patterns.json` if it exists; flag new patterns

## Output Schema

Write to `.claude/logs/analysis-report.json`:

```json
{
  "time_window": "24h",
  "log_file": "<path>",
  "total_errors": 1542,
  "distinct_patterns": 8,
  "new_patterns": 2,
  "patterns": [
    {
      "rank": 1,
      "pattern": "Connection refused to database",
      "count": 892,
      "first_seen": "2025-01-01T03:00:00Z",
      "last_seen": "2025-01-01T14:30:00Z",
      "example": "ERROR 2025-01-01T10:15:32 Connection refused to postgres://db:5432",
      "severity": "critical",
      "is_new": false
    }
  ]
}
```

Also write a human-readable summary to `.claude/logs/analysis-summary.md`.

## Recommended Permissions

```json
{
  "permissions": {
    "allow": [
      "Bash(cat *)",
      "Bash(grep *)",
      "Bash(awk *)",
      "Bash(sort *)",
      "Bash(uniq *)",
      "Bash(wc *)",
      "Bash(tail *)",
      "Bash(head *)",
      "Bash(mkdir -p .claude/logs)"
    ]
  }
}
```
