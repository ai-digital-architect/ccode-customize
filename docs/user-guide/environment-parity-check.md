# Environment Parity Check -- User Guide

## Purpose

The environment parity check pattern compares environment configurations against a canonical baseline defined in your project's `CLAUDE.md` and identifies undocumented divergences. Use this pattern before environment promotions (staging to production), during audits, or after infrastructure changes to ensure all environments have the required configuration keys and expected values.

## Prerequisites

- Claude Code CLI installed and configured
- Sub-agent installed: `env-parity-checker`
- Hook installed: `block-promotion-on-drift.sh` (PreToolUse)
- Settings fragment merged into `.claude/settings.json`
- Directory `.claude/env/` created for report output
- An "Environment Baseline" section defined in your project's `CLAUDE.md`

## Architecture

| Component | Type | Role |
|-----------|------|------|
| `SKILL.md` | Skill | Orchestrates checker invocation and divergence reporting |
| `env-parity-checker` | Sub-agent (read-only) | Diffs environment configs against the CLAUDE.md baseline |
| `block-promotion-on-drift.sh` | Hook (PreToolUse) | Blocks deploy/promote/release commands if parity fails |

The `env-parity-checker` agent has `disallowedTools: [Write, Edit, MultiEdit]` and checks for key presence and pattern matching -- it does not read actual secret values. The hook enforces that promotion cannot proceed while divergences exist.

## Usage

Invoke via the slash command:

```
/env-parity dev,staging,production
```

The argument is a comma-separated list of environments to check.

## Workflow

1. **Invoke checker**: The `env-parity-checker` sub-agent reads environment configuration files and compares them against the baseline defined in `CLAUDE.md`.
2. **Divergence report**: If divergences are found, each one is presented with the environment name, key, expected value, and actual value. Promotion is blocked until divergences are resolved or acknowledged.
3. **Parity confirmed**: If no divergences are found, parity is confirmed and promotion is allowed.
4. **Promotion gate**: Any subsequent Bash command containing "deploy", "promote", or "release" is intercepted by the hook and checked against the parity report.

### Hook Behavior

The `block-promotion-on-drift.sh` hook triggers on Bash commands containing "deploy", "promote", or "release":
- If no parity report exists: allows through (checker not yet run)
- If `parity_status == "fail"`: exits with code 2 and reports divergence count
- If `parity_status == "pass"`: exits with code 0 and allows promotion

## Example

First, define the baseline in your `CLAUDE.md`:

```markdown
## Environment Baseline
All environments must have these configuration keys:
- DATABASE_URL, REDIS_URL, API_BASE_URL
- AUTH_SECRET (different values per env, but key must exist)
- LOG_LEVEL: dev=debug, staging=info, production=warn
- RATE_LIMIT_RPM: dev=1000, staging=500, production=100
- FEATURE_FLAGS: must be identical across staging and production
```

Then run:

```
/env-parity staging,production
```

The checker might report: "FEATURE_FLAGS divergence: staging has `new_dashboard=true` but production has `new_dashboard=false`."

## Output

| Artifact | Location |
|----------|----------|
| Parity report | `.claude/env/parity-report.json` |

## Configuration

- **Baseline definition**: Edit the "Environment Baseline" section in your `CLAUDE.md` to define required keys and expected values
- **Hook trigger words**: Modify the hook to match your deployment tool commands (default: "deploy", "promote", "release")
- **Environment file locations**: Configure the checker to read from your specific env file paths (`.env.staging`, Kubernetes ConfigMaps, etc.)

## Tips

- Run the parity check as part of your pre-deployment checklist, not just when problems arise
- Keep the baseline in `CLAUDE.md` updated as new configuration keys are added
- Use specific value expectations where possible (e.g., `LOG_LEVEL: production=warn`) rather than just key presence checks
- The pattern checks key presence and patterns, not secret values -- it is safe to run without exposing credentials

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Hook blocks deployment unexpectedly | Check `.claude/env/parity-report.json` for specific divergences; resolve them and re-run the checker |
| Checker cannot find environment files | Verify environment file paths are accessible; configure the checker with correct paths |
| False positives on intentionally different values | Update the baseline to allow per-environment values (use "key must exist" instead of specific values) |
| Hook allows deployment despite known drift | Ensure the checker was run after the last config change; the hook reads the most recent report |
