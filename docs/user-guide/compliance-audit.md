# Compliance Audit

## Purpose

The compliance audit skill scans the codebase against established compliance rulesets including OWASP Top 10, GDPR, and license policy. It produces severity-ranked findings with remediation guidance. The skill operates strictly in read-only mode.

Use this skill:
- Before releases to verify security and compliance posture
- During periodic security reviews
- When preparing for regulatory audits or compliance certifications

## Prerequisites

- Source code accessible under the project directory
- For license checks: dependency manifests (`package.json`, etc.)
- For OWASP checks: route handlers and middleware visible in the source tree
- This skill uses the `claude-opus-4-5` model for deeper analysis

## Usage

Invoke the skill with a slash command:

```
/compliance-audit [ruleset]
```

The `ruleset` argument selects which checks to run:
- `owasp` -- OWASP Top 10 security checks (A01 through A10)
- `gdpr` -- GDPR data protection checks
- `license` -- dependency license compliance checks
- `all` -- run all rulesets

## Example

```
/compliance-audit owasp
```

This scans all route handlers for auth middleware coverage, checks for injection risks, reviews cryptographic usage, validates HTTP security headers, and more -- covering all 10 OWASP categories.

```
/compliance-audit all
```

This runs the full suite: OWASP, GDPR, and license checks in a single pass.

## Output

The skill writes a report to `.claude/audit/compliance-report.md` with findings in a table:

| Finding ID | Severity | Category | File:Line | Description | Remediation |

Findings are grouped by severity: Critical, High, Medium, Low. Every Critical and High finding includes specific remediation steps.

OWASP checks cover: Broken Access Control, Cryptographic Failures, Injection, Insecure Design, Security Misconfiguration, Vulnerable Components, Auth Failures, Data Integrity, Logging Failures, and SSRF.

GDPR checks cover: data inventory (PII locations), consent management, right to erasure, data minimization, and encryption at rest and in transit.

License checks flag GPL/AGPL in production dependencies and identify missing license declarations.

## Tips

- Run `all` before major releases for comprehensive coverage.
- Address Critical and High findings before shipping -- the report includes remediation steps for these.
- Approved licenses are: MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC. GPL and AGPL are not approved for production dependencies.
- Add recommended permissions:
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

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| No OWASP findings | Routes or middleware not in expected locations | Verify route handlers are under `src/routes/` or adjust the scan scope |
| GDPR check misses PII fields | Field names do not match common PII patterns | Review GDPR findings manually for domain-specific PII field names |
| License check incomplete | Some dependencies lack license metadata | Check those packages manually on npm or their repository |
| Slow execution | Large codebase with many files | Run with a specific ruleset instead of `all` to reduce scan time |
