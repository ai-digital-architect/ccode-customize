# Watchdog Loop -- User Guide

## Purpose

The watchdog loop pattern runs a continuous polling loop that monitors a specified metric and alerts when thresholds are exceeded. It supports bundle size, test health, and dependency vulnerability monitoring. Use this pattern for continuous monitoring during active development sessions.

## Prerequisites

- Claude Code CLI installed and configured
- Sub-agent installed: `health-checker`
- Hook installed: `watchdog-notify.sh` (Stop)
- Settings fragment merged into `.claude/settings.json`
- Directory `.claude/watchdog/` created for check results and violation logs
- For Slack notifications: `SLACK_WEBHOOK_URL` environment variable set

## Architecture

| Component | Type | Role |
|-----------|------|------|
| `SKILL.md` | Skill (model invocation disabled) | Polling loop orchestrator |
| `health-checker` | Sub-agent (read-only) | Checks the specified metric (bundle size, test health, deps) |
| `watchdog-notify.sh` | Hook (Stop) | Sends notifications when session ends if violations were logged |

The `health-checker` agent has `disallowedTools: [Write, Edit, MultiEdit]` -- it can run builds, tests, and audits but cannot modify code. The Slack webhook URL is read from the environment, never hardcoded.

## Usage

Invoke via the slash command:

```
/watchdog bundle-size 500 60
```

Arguments:
- Metric type: `bundle-size`, `test-health`, or `deps`
- Threshold value (meaning depends on metric)
- Check interval in seconds

### Supported Metrics

| Metric | Threshold | Meaning |
|--------|-----------|---------|
| `bundle-size` | Size in KB | Alert if `dist/` exceeds this size |
| `test-health` | Pass rate (0-100) | Alert if test pass rate drops below this percentage |
| `deps` | Count | Alert if critical vulnerability count exceeds this number |

## Workflow

1. **Parse arguments**: Extract metric type, threshold, and interval.
2. **Loop iteration**: Invoke the `health-checker` sub-agent for the specified metric.
3. **Read result**: Check `.claude/watchdog/latest-check.json` for the current value.
4. **Evaluate**: If the metric exceeds the threshold, log the violation to `.claude/watchdog/violations.log` and report immediately.
5. **Continue**: If within threshold, log "OK" and sleep for the specified interval.
6. **Repeat**: Continue until the user stops the session.
7. **On session end**: The Stop hook checks for violations and optionally sends a Slack notification.

### Hook Behavior

The `watchdog-notify.sh` hook fires when the Claude session ends:
- Reads `.claude/watchdog/violations.log`
- If violations exist: logs to `~/.claude/notifications.log` and optionally POSTs to Slack
- Always exits 0 -- Stop hooks are informational and non-blocking

## Example

```
/watchdog bundle-size 250 120
```

This starts monitoring the `dist/` directory size every 2 minutes. If the bundle exceeds 250KB, the watchdog logs a violation and alerts you immediately. When you end the session, the Stop hook sends a summary of all violations to Slack (if configured).

## Output

| Artifact | Location |
|----------|----------|
| Latest check result | `.claude/watchdog/latest-check.json` |
| Violation log | `.claude/watchdog/violations.log` |
| Notification log | `~/.claude/notifications.log` |

## Configuration

- **Slack notifications**: Set `SLACK_WEBHOOK_URL` in your environment or `.env` file
- **Custom metrics**: Extend the `health-checker` agent to support additional metric types
- **Notification targets**: Modify `watchdog-notify.sh` to POST to other webhook services (Teams, Discord, PagerDuty)

## Tips

- Use longer intervals (120-300 seconds) for expensive checks like full test suites
- Use shorter intervals (30-60 seconds) for cheap checks like bundle size
- Run the watchdog alongside other development workflows to catch regressions in real time
- Clean up `.claude/watchdog/violations.log` between sessions to avoid stale alerts

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Watchdog not alerting | Verify threshold value is correct; check `.claude/watchdog/latest-check.json` for current readings |
| Slack notification not sent | Verify `SLACK_WEBHOOK_URL` is set and valid; check `~/.claude/notifications.log` for error details |
| High resource usage | Increase the check interval; expensive metrics like test-health run the full test suite each check |
| Violations log growing large | Clear the log periodically; it appends on each violation |
