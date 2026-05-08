# Staged Rollout Gate

## Purpose

The staged rollout gate pattern promotes a build through dev, staging, and production environments with automated gates between each stage. Each environment runs smoke or integration tests before promotion is allowed. Use this for deployments, release workflows, or any multi-environment promotion pipeline.

## Prerequisites

- **Sub-agents**: `env-deployer` installed in `.claude/agents/`
- **Hooks**: `rollout-gate.sh` (PreToolUse) in `.claude/hooks/`, executable
- **Settings**: Hook registrations merged into `.claude/settings.json`
- **Directory**: `.claude/rollout/` must exist for result files and sentinel
- **Test scripts**: `pnpm test:smoke`, `pnpm test:integration`, and `pnpm test:health` must be configured

## Architecture

The skill orchestrates the `env-deployer` sub-agent across three environments in sequence. The `env-deployer` has `disallowedTools: [Write, Edit, MultiEdit]` -- it executes deployment commands but cannot modify source files. The `rollout-gate.sh` hook enforces promotion order deterministically: staging deployment requires a successful `dev-result.json`, and production deployment requires both a successful `staging-result.json` and a `production-approved` sentinel file. The model cannot skip environments.

## Usage

Invoke via the slash command:

```
/staged-rollout [version or branch]
```

Provide the version tag or branch name to deploy.

## Workflow

1. **Stage 1 -- Deploy to Dev**: The `env-deployer` sub-agent deploys to the dev environment. Smoke tests run via `pnpm test:smoke --env=dev`. If tests fail, the workflow stops.
2. **Stage 2 -- Deploy to Staging**: The hook verifies `dev-result.json` shows success. The `env-deployer` deploys to staging. Integration tests run via `pnpm test:integration --env=staging`. If tests fail, staging is rolled back and the workflow stops.
3. **Stage 3 -- Approval Gate**: A deployment summary is presented to the user showing dev smoke results, staging integration results, and the diff going to production. The user must type "approve" to continue.
4. **Stage 4 -- Deploy to Production**: The hook verifies both `staging-result.json` and the `production-approved` sentinel. The `env-deployer` deploys to production. Health checks run via `pnpm test:health --env=production`. If health checks fail, an immediate rollback is triggered.

## Example

```
/staged-rollout v2.4.0
```

This deploys v2.4.0 to dev (smoke tests pass), promotes to staging (integration tests pass), presents a summary for approval, and after approval deploys to production with health check verification.

## Output

- `dev-result.json` -- dev deployment and smoke test results
- `staging-result.json` -- staging deployment and integration test results
- Production health check results
- A final status report across all environments

## Configuration

- **Destructive patterns**: The `rollout-gate.sh` hook checks for "staging" or "production" in Bash commands. Adjust patterns if your deployment commands differ.
- **Test commands**: Replace `pnpm test:smoke`, `pnpm test:integration`, and `pnpm test:health` in the skill if your test scripts have different names.
- **Sentinel path**: The `production-approved` sentinel is checked in `.claude/rollout/`. Ensure this directory is consistent across hook and skill.

## Tips

- The `env-deployer` is intentionally read-only for source files. It should only execute deployment commands.
- Always verify that dev and staging test suites are representative of production behavior.
- The approval gate between staging and production is both a prompt-level pause and a hook-level enforcement via the sentinel file.
- Keep result JSON files to enable audit trails of past deployments.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Staging deployment blocked | `dev-result.json` missing or shows failure | Verify dev deployment succeeded; check the result file contents |
| Production deployment blocked | Missing `staging-result.json` or `production-approved` sentinel | Ensure staging passed and the user approved; check for the sentinel file |
| Health check fails in production | Deployment issue or test misconfiguration | Review health check output; the rollback should trigger automatically |
| Hook not enforcing order | Hook not registered or commands do not match patterns | Verify `settings.json` registration and check that deployment commands contain "staging" or "production" |
