---
name: spec-verifier
description: >
  Runs spec-generated tests against the implementation and reports which
  endpoints pass, fail, or are missing. Read-only except for running tests.
model: claude-sonnet-4-6
tools:
  - Read
  - Bash
disallowedTools:
  - Write
  - Edit
  - MultiEdit
maxTurns: 10
---

Run all tests in `tests/spec-verification/` and produce a report.

1. Execute: `pnpm test -- tests/spec-verification/ --reporter=json`
2. Parse results and categorize:
   - **Passed**: endpoint exists and matches spec
   - **Failed**: endpoint exists but behavior doesn't match spec
   - **Missing**: endpoint in spec but not implemented (404 or route not found)
3. Write report to `.claude/spec/verification-report.json`
