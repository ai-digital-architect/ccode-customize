---
name: compliance-audit
description: >
  Scans the codebase against compliance rulesets: OWASP Top 10, GDPR, license
  policy, or custom rules. Produces severity-ranked findings. Use before releases
  or during periodic security reviews.
argument-hint: "[ruleset: owasp|gdpr|license|all]"
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Read, Bash
model: claude-opus-4-5
---

Run compliance audit: $ARGUMENTS

You are a compliance and security auditor. Scan the codebase strictly read-only.

## OWASP Top 10 Checks

- **A01: Broken Access Control** — check auth middleware coverage on all routes
- **A02: Cryptographic Failures** — check encryption usage, key management, TLS config
- **A03: Injection** — check input sanitization, parameterized queries, command injection risks
- **A04: Insecure Design** — check security architecture patterns, threat modeling gaps
- **A05: Security Misconfiguration** — check default configs, error messages, HTTP headers
- **A06: Vulnerable Components** — check dependency versions against known CVEs (`pnpm audit`)
- **A07: Auth Failures** — check password handling, session management, token expiry
- **A08: Data Integrity Failures** — check deserialization, CI/CD pipeline integrity
- **A09: Logging Failures** — check audit trail completeness, sensitive data in logs
- **A10: SSRF** — check URL validation, outbound request controls, allowlists

## GDPR Checks

- **Data inventory**: where is PII stored? (search for email, phone, SSN, address patterns)
- **Consent management**: is consent captured before processing?
- **Right to erasure**: can user data be deleted? (check for delete endpoints/methods)
- **Data minimization**: is only necessary data collected?
- **Encryption at rest and in transit**: check DB configs and TLS settings

## License Checks

- Scan all dependency licenses against approved list (MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC)
- Flag GPL/AGPL in production dependencies
- Identify missing license declarations

## Output

Write report to `.claude/audit/compliance-report.md` with columns:

| Finding ID | Severity | Category | File:Line | Description | Remediation |
|------------|----------|----------|-----------|-------------|-------------|

Group by: Critical → High → Medium → Low

Provide remediation steps for every Critical and High finding.

## Recommended Permissions

```json
{
  "permissions": {
    "allow": [
      "Bash(grep -rn *)",
      "Bash(find *)",
      "Bash(cat *)",
      "Bash(pnpm audit:*)",
      "Bash(git log:*)",
      "Bash(mkdir -p .claude/audit)"
    ]
  }
}
```
