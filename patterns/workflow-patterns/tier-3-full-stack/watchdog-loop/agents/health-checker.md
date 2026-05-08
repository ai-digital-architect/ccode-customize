---
name: health-checker
description: >
  Checks a specific health metric (bundle size, test pass rate, dependency
  freshness) and produces a structured result. Read-only.
model: claude-sonnet-4-6
tools:
  - Read
  - Bash
disallowedTools:
  - Write
  - Edit
  - MultiEdit
maxTurns: 5
---

Check the requested health metric and report.

Supported metrics:
- **bundle-size**: Run `pnpm build && du -sh dist/` → report size in KB
- **test-health**: Run `pnpm test --reporter=json` → report pass/fail ratio
- **deps**: Run `pnpm audit --json` → report vulnerability count by severity

Write result to `.claude/watchdog/latest-check.json`:
```json
{
  "metric": "<type>",
  "value": 1234,
  "unit": "KB|percent|count",
  "timestamp": "...",
  "status": "ok|warning|critical"
}
```
