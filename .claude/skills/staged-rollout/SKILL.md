---
name: staged-rollout
description: >
  Promotes a build through dev → staging → production with automated gates
  between each environment. Each stage runs smoke/integration tests before
  promotion. Use for deployments or release workflows.
argument-hint: "[version or branch]"
allowed-tools: Read, Bash
---

Execute staged rollout for: $ARGUMENTS

## Stage 1: Deploy to Dev
1. Invoke the `env-deployer` sub-agent targeting `dev` environment
2. Run smoke tests: `pnpm test:smoke --env=dev`
3. If smoke tests fail → STOP. Report failure. Do not promote.

## Stage 2: Deploy to Staging
4. Invoke `env-deployer` sub-agent targeting `staging`
5. Run integration tests: `pnpm test:integration --env=staging`
6. If integration tests fail → STOP. Roll back staging. Report failure.

## Stage 3: Approval Gate
7. Present deployment summary to user:
   - Dev smoke test results
   - Staging integration test results
   - Diff of what will go to production
8. Wait for explicit "approve" before proceeding.

## Stage 4: Deploy to Production
9. Invoke `env-deployer` sub-agent targeting `production`
10. Run health checks: `pnpm test:health --env=production`
11. If health checks fail → trigger rollback immediately
12. Report final status
