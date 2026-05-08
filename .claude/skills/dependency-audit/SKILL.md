---
name: dependency-audit
description: >
  Scans all dependency manifests for security vulnerabilities, outdated packages,
  and license compliance issues. Produces a risk-ranked report. Use before releases,
  during security reviews, or on a regular schedule.
argument-hint: "[scope: all|frontend|backend]"
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Read, Bash
---

Run dependency audit for: $ARGUMENTS

You are a dependency security specialist. Audit all project dependencies.

## Steps

1. Find all manifest files: `package.json`, `pnpm-lock.yaml`, `requirements.txt`, `go.mod`, `Cargo.toml`, etc.
2. Run native audit commands:
   - Node: `pnpm audit --json` or `npm audit --json`
   - Python: `pip audit --format=json` (if available)
   - Go: `go vuln check ./...`
3. Parse results and cross-reference severity
4. Check licenses: read each dependency's license field; flag any not in the approved list
5. Identify packages more than 1 major version behind latest

## Approved Licenses

MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, 0BSD, Unlicense are approved.
GPL and AGPL are NOT approved for production dependencies.
LGPL is approved for dynamically-linked dependencies only.

## Output

Write report to `.claude/audit/dependency-report.md` with sections:

### Critical Vulnerabilities
Table: package | version | CVE | severity | fix version

### License Violations
Table: package | license | status

### Outdated Dependencies
Table: package | current | latest | risk

### Summary Statistics
- Total packages scanned
- Critical/High/Medium/Low CVE counts
- License violation count
- Outdated package count

### Recommended Actions
Prioritized list by risk level.

## Recommended Permissions

Add to `.claude/settings.json`:
```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm audit:*)",
      "Bash(npm audit:*)",
      "Bash(pip audit:*)",
      "Bash(cat package.json)",
      "Bash(find * -name package.json)",
      "Bash(mkdir -p .claude/audit)"
    ]
  }
}
```
