---
name: rotate-secret
description: >
  Safely rotates a secret/credential: finds all references, updates them
  atomically, verifies the service works, then revokes the old credential.
  Use for API key rotation, database password changes, or certificate renewal.
argument-hint: "[secret-name: DATABASE_PASSWORD|API_KEY|etc]"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash
---

Rotate secret: $ARGUMENTS

## Phase 1: Discovery
Invoke `secret-finder` to locate ALL references to the credential.

## Phase 2: Update
1. Generate a new credential value
2. Update every reference found in Phase 1
3. Update environment files, config files, and secrets managers

## Phase 3: Verify
1. Restart/reload the service
2. Run health checks to verify the new credential works
3. Write health check result to `.claude/secrets/health-check.json`
4. If health checks fail: ROLLBACK to old credential immediately

## Phase 4: Revoke (only after verification passes)
1. Present summary to user for approval
2. After approval: revoke the old credential
3. The `require-health-before-revoke.sh` hook enforces health check passed before revocation
4. Confirm revocation successful
