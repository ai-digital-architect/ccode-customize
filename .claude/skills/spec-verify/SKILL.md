---
name: spec-verify
description: >
  Generates tests from an API spec (OpenAPI/GraphQL) and verifies the
  implementation satisfies them. Reports missing or incorrect endpoints.
  Use after writing or updating an API spec.
argument-hint: "[path-to-spec-file]"
allowed-tools: Read, Write, Bash
---

Verify implementation against spec: $ARGUMENTS

## Steps

1. Invoke `spec-test-generator` with the spec file path
   - Generates test files in `tests/spec-verification/`
2. Invoke `spec-verifier` to run the generated tests
   - Produces `.claude/spec/verification-report.json`
3. Present results: passed endpoints, failed endpoints, missing endpoints
