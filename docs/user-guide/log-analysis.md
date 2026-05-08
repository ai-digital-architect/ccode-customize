# Log Analysis

## Purpose

The log analysis skill examines error logs to identify failure patterns, cluster similar errors, and rank them by frequency. It produces both a machine-readable JSON report and a human-readable summary.

Use this skill:
- For periodic log review to catch recurring issues
- During incident investigation to understand error distribution
- To identify new error patterns that have not been seen before

## Prerequisites

- A log file with timestamped entries accessible from the project directory
- Optionally, a known patterns file at `.claude/logs/known-patterns.json` for new-pattern detection
- Standard Unix text tools available (`grep`, `awk`, `sort`, `uniq`)

## Usage

Invoke the skill with a slash command:

```
/analyze-logs [log-file-path] [time-window]
```

Arguments:
- `log-file-path` -- path to the log file to analyze
- `time-window` -- how far back to look: `1h`, `24h`, or `7d`

## Example

```
/analyze-logs /var/log/app/error.log 24h
```

This scans the error log for the last 24 hours, clusters similar errors by normalizing variable parts (timestamps, IDs, UUIDs, IP addresses), ranks patterns by frequency, and flags any patterns not found in the known patterns file.

## Output

The skill produces two output files:

**`.claude/logs/analysis-report.json`** -- structured JSON with:
- Time window and log file path
- Total error count and distinct pattern count
- Number of new (previously unseen) patterns
- Array of patterns ranked by frequency, each with: rank, pattern description, count, first/last seen timestamps, example message, severity, and new-pattern flag

**`.claude/logs/analysis-summary.md`** -- human-readable summary of the same data, suitable for sharing in incident channels or stand-up meetings.

## Tips

- Maintain a `.claude/logs/known-patterns.json` file to enable new-pattern detection. Update it after each review to track which patterns have been acknowledged.
- Use `1h` during active incidents for real-time pattern tracking.
- Use `7d` for weekly log reviews to catch slow-building issues.
- Add recommended permissions to `.claude/settings.json`:
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

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Zero errors found | Time window does not cover the log entries, or timestamp format is not recognized | Try a wider time window or verify the log uses standard timestamp formats |
| All patterns marked as "new" | No `.claude/logs/known-patterns.json` file exists | Create the known patterns file from a previous report |
| Cluster quality is poor | Log messages have highly variable formats | The skill normalizes IDs, UUIDs, and IPs; other variable parts may need manual review |
| Permission denied on log file | Log file requires elevated permissions | Copy the log to an accessible location or adjust file permissions |
