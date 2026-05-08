---
name: watchdog
description: >
  Runs a polling loop that monitors a condition and alerts when thresholds
  are exceeded. Checks bundle size, test health, dependency freshness, or
  custom metrics. Use for continuous monitoring during development.
argument-hint: "[metric: bundle-size|test-health|deps] [threshold] [interval-seconds]"
disable-model-invocation: true
allowed-tools: Read, Bash
---

Start watchdog monitoring: $ARGUMENTS

1. Parse arguments: metric type, threshold value, check interval
2. Loop:
   a. Invoke the `health-checker` sub-agent for the specified metric
   b. Read result from `.claude/watchdog/latest-check.json`
   c. If metric exceeds threshold:
      - Log the violation to `.claude/watchdog/violations.log`
      - Report to user immediately
      - The Stop hook will send external notifications
   d. If within threshold: log "OK" and continue
   e. Wait for the specified interval (`sleep <interval-seconds>`)
3. Continue until the user stops the session

Supported metrics:
- `bundle-size <threshold-KB>` — alert if dist/ exceeds threshold
- `test-health <min-pass-rate>` — alert if pass rate drops below threshold
- `deps <max-critical>` — alert if critical vulnerability count exceeds threshold
