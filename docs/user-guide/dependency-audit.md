# Dependency Audit

## Purpose

The dependency audit skill scans all project dependency manifests for security vulnerabilities, outdated packages, and license compliance issues. It produces a risk-ranked report with actionable remediation steps.

Use this skill:
- Before releases to verify dependency safety
- During periodic security reviews
- When onboarding a new project to assess its dependency health

## Prerequisites

- At least one dependency manifest file in the project (`package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, etc.)
- Native audit tooling installed for your stack (e.g., `pnpm`, `npm`, `pip audit`, `go vuln`)
- Recommended permissions added to `.claude/settings.json` (see Tips)

## Usage

Invoke the skill with a slash command:

```
/dependency-audit [scope]
```

The `scope` argument controls which dependencies are audited:
- `all` -- audit every manifest in the project (default)
- `frontend` -- audit only frontend dependencies
- `backend` -- audit only backend dependencies

## Example

```
/dependency-audit all
```

This runs audit commands for every detected package manager, cross-references CVE severity, checks licenses against the approved list, and identifies packages more than one major version behind latest.

## Output

The skill writes a structured report to `.claude/audit/dependency-report.md` containing:

- **Critical Vulnerabilities** -- table of package, version, CVE, severity, and fix version
- **License Violations** -- table of packages with non-approved licenses (GPL, AGPL flagged)
- **Outdated Dependencies** -- table of packages behind latest with risk assessment
- **Summary Statistics** -- total packages scanned, CVE counts by severity, violation and outdated counts
- **Recommended Actions** -- prioritized remediation list ordered by risk level

## Tips

- Add the recommended permissions to `.claude/settings.json` to avoid repeated approval prompts:
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
- Run with `backend` or `frontend` scope to keep reports focused when working on a specific area.
- Approved licenses are: MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, 0BSD, Unlicense. LGPL is approved only for dynamically-linked dependencies.

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| "No manifest files found" | Project uses a package manager the skill does not detect | Ensure your manifest file uses a standard name (`package.json`, `requirements.txt`, etc.) |
| Audit command fails | Native audit tool is not installed | Install the required tool (e.g., `pip install pip-audit`) |
| Empty report | No vulnerabilities or outdated packages detected | This is a clean result -- no action needed |
| Permission denied errors | Bash commands not pre-approved | Add the recommended permissions to `.claude/settings.json` |
