# Secret Rotation -- User Guide

## Purpose

The secret rotation pattern safely rotates credentials through a four-phase pipeline: discover all references, update them atomically, verify the service works with the new credential, and revoke the old one only after verification passes. Use this pattern for API key rotation, database password changes, certificate renewal, or any credential lifecycle operation.

## Prerequisites

- Claude Code CLI installed and configured
- Sub-agent installed: `secret-finder`
- Hook installed: `require-health-before-revoke.sh` (PreToolUse)
- Settings fragment merged into `.claude/settings.json`
- Directory `.claude/secrets/` created for health check results
- Access to the relevant secrets manager or configuration store

## Architecture

| Component | Type | Role |
|-----------|------|------|
| `SKILL.md` | Skill (model invocation disabled) | Orchestrates the four-phase rotation pipeline |
| `secret-finder` | Sub-agent (read-only) | Discovers all references to the target credential |
| `require-health-before-revoke.sh` | Hook (PreToolUse) | Blocks old credential revocation unless health check passed |

The `secret-finder` agent has `disallowedTools: [Write, Edit, MultiEdit]` -- it can only search and report, never modify. The settings deny list blocks dangerous patterns like pipe-to-bash and `rm -rf /`. Credentials are never written to tracked files.

## Usage

Invoke via the slash command:

```
/rotate-secret DATABASE_PASSWORD
```

The argument is the name of the secret to rotate.

## Workflow

1. **Phase 1 -- Discovery**: The `secret-finder` sub-agent locates all references to the named credential across config files, environment files, secrets managers, and source code.
2. **Phase 2 -- Update**: A new credential value is generated, and every reference found in Phase 1 is updated. This includes environment files, config files, and secrets managers.
3. **Phase 3 -- Verify**: The service is restarted or reloaded, and health checks run to confirm the new credential works. Results are written to `.claude/secrets/health-check.json`. If health checks fail, the system rolls back to the old credential immediately.
4. **Phase 4 -- Revoke**: After verification passes, a summary is presented for human approval. Upon approval, the old credential is revoked. The hook enforces that revocation cannot happen unless the health check passed.

### Hook Behavior

The `require-health-before-revoke.sh` hook triggers on Bash commands matching `revoke`, `delete.*key`, or `remove.*secret`:
- If no health check file exists: exits with code 2, blocking revocation
- If `status != "healthy"`: exits with code 2, blocking revocation and instructing rollback
- If `status == "healthy"`: exits with code 0, allowing revocation to proceed

## Example

```
/rotate-secret API_KEY
```

The pattern will:
1. Find API_KEY in `.env`, `.env.production`, `config/secrets.yaml`, and `k8s/deployment.yaml`
2. Generate a new API key value and update all four locations
3. Restart the service and run health checks
4. Present: "Old key: ...a1b2. New key: ...x9y0. 4 references updated. Health: OK."
5. After your approval, revoke the old key

## Output

| Artifact | Location |
|----------|----------|
| Health check result | `.claude/secrets/health-check.json` |
| Reference map | Presented in the session |

## Configuration

- **Hook trigger patterns**: Adjust the regex in the hook to match your revocation commands
- **Health check command**: Configure the verification step to use your service's health endpoint or smoke tests
- **Secrets manager integration**: Extend the skill to work with AWS Secrets Manager, HashiCorp Vault, or other providers

## Tips

- Always run on a non-production environment first to validate the rotation procedure
- The pattern requires human approval before revocation -- do not skip this step
- Keep a record of rotated credentials and their timestamps for audit purposes
- If health checks fail, the automatic rollback restores service immediately; investigate the failure before retrying
- Never commit actual secret values to version control; the pattern updates config references, not tracked source files

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Hook blocks revocation with "no health file" | Run Phase 3 (verify) first; ensure `.claude/secrets/health-check.json` exists |
| Health check fails after credential update | The pattern rolls back automatically; check service logs for the specific failure |
| `secret-finder` misses some references | Run a manual search for the credential name; add missed locations and re-run |
| Revocation blocked despite passing health check | Verify `.claude/secrets/health-check.json` contains `"status": "healthy"` |
