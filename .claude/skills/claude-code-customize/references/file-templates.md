# File Templates

Ready-to-use templates for every file type created by `/cc-customize`.
Customize each with project-specific values before writing.

---

## CLAUDE.md Template

```markdown
# Project: <Name>

## Tech Stack
- Runtime: <Node.js 22 / Python 3.12 / Go 1.22 / ...>
- Framework: <Fastify 5 / FastAPI / Gin / ...>
- Database: <PostgreSQL 16 via Prisma / SQLite / ...>
- Testing: <Vitest / pytest / go test / ...>
- Package manager: <pnpm / uv / go modules / ...>

## Build & Test Commands
- Install: `<pnpm install>`
- Build: `<pnpm build>`
- Test (all): `<pnpm test>`
- Test (single): `<pnpm test -- src/auth/auth.test.ts>`
- Lint: `<pnpm lint:fix>`
- Type check: `<pnpm tsc --noEmit>`
- DB migrations: `<pnpm db:migrate>`

## Coding Conventions
- <convention 1 — e.g., prefer Result<T,E> over thrown exceptions>
- <convention 2 — e.g., co-locate tests next to source>
- <convention 3 — e.g., never use `any`; use `unknown`>

## Architecture
- <Route handlers are thin — business logic lives in services>
- <All DB queries go through the repository layer>
- <Auth is handled by src/auth/ — do not re-implement elsewhere>

## Anti-patterns (Do Not Use)
- `<moment>` — use `date-fns` instead
- <class-based services> — use plain functions with DI

## Claude Code Notes
- After implementing features, invoke the `code-reviewer` sub-agent before presenting results.
- Use `/create-migration` skill for any schema change — it handles rollback verification.
```

---

## AGENTS.md Template

```markdown
# Project: <Name> — Agent Instructions

## Build & Test Commands
- Install: `<pnpm install>`
- Build: `<pnpm build>`
- Test: `<pnpm test>`
- Lint: `<pnpm lint>`
- Type check: `<pnpm tsc --noEmit>`

## Code Style
- Language: <TypeScript strict mode / Python 3.12+ with type hints / ...>
- Formatter: <Prettier 3 / Ruff / gofmt / ...>
- Naming: <camelCase functions, PascalCase classes, SCREAMING_SNAKE constants>
- Max line length: <100>

## Architecture Overview
- <Monorepo with packages/ — each package is independently deployable>
- <API layer → Service layer → Repository layer → Database>
- <Frontend: Next.js App Router in apps/web/>

## Commit Conventions
- Format: `<type>(<scope>): <description>`
- Types: feat, fix, chore, docs, refactor, test, ci
- Example: `feat(auth): add JWT refresh token rotation`

## Key Directories
- `src/api/` — route handlers (thin)
- `src/services/` — business logic
- `src/db/` — repository layer and migrations
- `tests/` — test files mirror src/ structure
```

---

## Sub-agent Templates

### researcher.md
```yaml
---
name: researcher
description: >
  Researches the existing codebase to gather context, identify patterns,
  locate relevant files, and map dependencies. Use before implementing
  new features or making significant changes. Read-only — cannot modify files.
model: sonnet
tools:
  - Read
  - Grep
  - Glob
  - Bash
disallowedTools:
  - Write
  - Edit
  - MultiEdit
maxTurns: 15
---

Research thoroughly using only read-only tools.

Return:
- Relevant files and their purpose
- Existing patterns and conventions to follow
- Dependencies that will be affected
- Potential conflicts or risks
- Recommended implementation approach
```

### code-reviewer.md
```yaml
---
name: code-reviewer
description: >
  Reviews code changes for quality, security, test coverage, and adherence
  to project standards. Returns a structured score 1-5. Use after implementing
  any non-trivial feature or fix, and before presenting results to the user.
model: opus
effort: high
tools:
  - Read
  - Grep
  - Glob
  - Bash
disallowedTools:
  - Write
  - Edit
  - MultiEdit
maxTurns: 10
memory: project
---

Review the provided changes. Score 1–5 on:
- Security: injection safety, auth checks, input validation
- Correctness: edge cases, error handling, type safety
- Maintainability: naming, separation of concerns
- Test coverage: key paths and edge cases covered

Return: overall score (1–5), list of issues with file:line references,
and concrete suggested fixes. Do not approve (score < 4) if any Critical
or High severity issues remain.
```

### security-reviewer.md
```yaml
---
name: security-reviewer
description: >
  Analyzes code for security vulnerabilities including injection attacks,
  authentication flaws, hardcoded secrets, and insecure dependencies.
  Use when reviewing PRs, auditing auth/payment/PII code, or evaluating
  third-party integrations.
model: opus
effort: high
tools:
  - Read
  - Grep
  - Glob
  - Bash
disallowedTools:
  - Write
  - Edit
  - MultiEdit
maxTurns: 10
---

For every review, check:
1. Injection vulnerabilities (SQL, command, path traversal, XSS)
2. Authentication and authorization logic
3. Hardcoded secrets or credentials
4. Input validation completeness
5. Dependency versions against known CVEs

Return a structured report: severity (Critical/High/Medium/Low),
location (file:line), description, and recommended fix for each finding.
```

### test-writer.md
```yaml
---
name: test-writer
description: >
  Writes integration and unit tests for completed features, matching project
  test conventions and framework. Use after implementing a feature to ensure
  adequate test coverage before the PR is ready.
model: sonnet
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
maxTurns: 20
---

Write tests that:
1. Match the existing test file structure and naming conventions
2. Cover the happy path, error cases, and edge cases
3. Mock only external dependencies, not internal modules
4. Clean up side effects in afterEach/teardown

Co-locate test files next to source: `auth.service.ts` → `auth.service.test.ts`
```

### api-documenter.md
```yaml
---
name: api-documenter
description: >
  Generates or updates API documentation (OpenAPI/Swagger specs, endpoint READMEs).
  Use when new API routes are added or when the user asks to document endpoints.
model: sonnet
tools:
  - Read
  - Write
  - Grep
  - Glob
maxTurns: 15
---

For each endpoint, document:
- Method, path, description
- Request: path params, query params, body schema (with types)
- Response: success schema, error codes and shapes
- Authentication requirements
- Example request and response

Output format: OpenAPI 3.1 YAML unless the project already uses a different format.
```

---

## Hook Script Templates

### bash-safety.sh
```bash
#!/usr/bin/env bash
# .claude/hooks/bash-safety.sh — Block dangerous shell commands
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

if echo "$command" | grep -qE 'rm\s+-rf\s+/|sudo\s+rm|>>\s*/etc|chmod\s+777'; then
  echo '{"decision":"block","reason":"Dangerous command pattern detected"}' >&2
  exit 2
fi

if echo "$command" | grep -qE 'git push.*--force|git push.*-f\b'; then
  echo '{"decision":"block","reason":"Force pushes are not permitted — use PR workflow"}' >&2
  exit 2
fi

if echo "$command" | grep -qE 'curl .* \| (bash|sh)|wget .* \| (bash|sh)'; then
  echo '{"decision":"block","reason":"Piping remote content to shell is not permitted"}' >&2
  exit 2
fi

exit 0
```

### protect-env.sh
```bash
#!/usr/bin/env bash
# .claude/hooks/protect-env.sh — Block reads/writes to .env and secret files
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

case "$file_path" in
  .env|.env.*|*/.env|*/.env.*)
    echo '{"decision":"block","reason":".env files are protected — use CLAUDE.local.md to reference env vars"}' >&2
    exit 2
    ;;
  */secrets/*|*/credentials.*)
    echo '{"decision":"block","reason":"Secrets files are protected from direct edits"}' >&2
    exit 2
    ;;
esac

exit 0
```

### protect-locks.sh
```bash
#!/usr/bin/env bash
# .claude/hooks/protect-locks.sh — Block direct edits to lock files
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

case "$file_path" in
  package-lock.json|yarn.lock|pnpm-lock.yaml|Cargo.lock|poetry.lock|Pipfile.lock)
    echo '{"decision":"block","reason":"Lock files must only change via the package manager, not direct edits"}' >&2
    exit 2
    ;;
esac

exit 0
```

### auto-format.sh (multi-language)
```bash
#!/usr/bin/env bash
# .claude/hooks/auto-format.sh — Auto-format after file writes
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
[[ -z "$file_path" ]] && exit 0

case "$file_path" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
    npx prettier --write "$file_path" 2>/dev/null ;;
  *.py)
    ruff format "$file_path" 2>/dev/null
    ruff check --fix "$file_path" 2>/dev/null ;;
  *.go)
    gofmt -w "$file_path" 2>/dev/null ;;
  *.rs)
    rustfmt "$file_path" 2>/dev/null ;;
esac
exit 0
```

### typecheck-async.sh
```bash
#!/usr/bin/env bash
# .claude/hooks/typecheck-async.sh — Run type check after TypeScript edits
# Run with async: true in settings.json to avoid blocking
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
[[ "$file_path" != *.ts && "$file_path" != *.tsx ]] && exit 0

npx tsc --noEmit 2>&1 | head -20
exit 0
```

### audit-log.sh
```bash
#!/usr/bin/env bash
# .claude/hooks/audit-log.sh — Log all tool calls for audit trail
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // "unknown"')
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "$timestamp | $tool_name | $(echo "$input" | jq -c '.tool_input // {}' 2>/dev/null)" \
  >> ~/.claude/audit.log
exit 0
```

---

## settings.json Template

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "sonnet",
  "permissions": {
    "defaultMode": "default",
    "allow": [
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(git status *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(pnpm test *)",
      "Bash(pnpm lint *)",
      "Bash(pnpm build *)",
      "Bash(pnpm tsc *)",
      "Read(**/*)",
      "Edit(src/**/*)",
      "Edit(tests/**/*)",
      "Write(src/**/*)",
      "Write(tests/**/*)"
    ],
    "ask": [
      "Bash(git push *)",
      "Bash(pnpm db:migrate *)",
      "Bash(pnpm db:seed *)"
    ],
    "deny": [
      "Bash(git push --force *)",
      "Bash(git push -f *)",
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(curl * | bash)",
      "Bash(wget * | bash)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Edit(./.env)",
      "Edit(./.env.*)",
      "Write(./.env)",
      "Write(./.env.*)"
    ]
  },
  "sandbox": {
    "mode": "enabled",
    "filesystem": {
      "writablePaths": ["./", "/tmp"],
      "readonlyPaths": ["~/.ssh", "~/.aws", "~/.gnupg"]
    }
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/bash-safety.sh" }
        ]
      },
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/protect-env.sh" },
          { "type": "command", "command": "bash .claude/hooks/protect-locks.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/auto-format.sh" },
          { "type": "command", "command": "bash .claude/hooks/typecheck-async.sh", "async": true }
        ]
      }
    ]
  }
}
```

---

## .mcp.json Template

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

---

## Path-scoped Rule Templates

### .claude/rules/testing.md
```yaml
---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.spec.ts"
  - "**/__tests__/**/*"
---

# Testing Rules

- Describe tests as: `it("should [expected behavior] when [condition]", ...)`
- Mock external dependencies (HTTP, DB, filesystem), not internal modules
- Clean up side effects in `afterEach` or `afterAll`
- Co-locate test files: `auth.service.ts` → `auth.service.test.ts`
- Test the public interface, not implementation details
```

### .claude/rules/api-design.md
```yaml
---
paths:
  - "src/api/**/*"
  - "src/routes/**/*"
  - "app/api/**/*"
---

# API Design Rules

- Route handlers are thin — delegate to service functions
- Validate all input at the route boundary using Zod/Pydantic/etc.
- Return consistent error shapes: `{ error: { code, message, details? } }`
- Use 400 for validation errors, 401 for auth, 403 for authorization, 404 for not found
- Document new endpoints with JSDoc/docstrings before closing the task
```

---

## REVIEW.md Template

```markdown
# Claude Code Review Instructions

## Focus Areas
- Security: SQL injection, XSS, auth bypass, exposed secrets
- Correctness: edge cases, error handling, boundary conditions
- Performance: N+1 queries, unnecessary allocations, blocking I/O

## Out of Scope
- Style and formatting (handled by CI lint)
- Documentation typos (flag but don't block)
- Minor naming preferences

## Severity Guidance
- **Critical**: data loss, security breach, production crash
- **High**: incorrect behavior in the common path
- **Medium**: incorrect behavior in edge cases
- **Low**: maintainability or readability concerns

## Project-specific Notes
- Auth changes always need a High or Critical review of the session handling
- Database migrations must include a rollback path
```

---

## .worktreeinclude Template

```
# Files to copy into git worktrees (worktrees are fresh checkouts; these don't exist there by default)
# Only gitignored files are copied — tracked files are never duplicated

# Local environment config
.env
.env.local
.env.development

# Local secrets and credentials (review before including)
# config/secrets.json
```

---

## Project Skill Templates

### .claude/skills/create-migration/SKILL.md
```yaml
---
name: create-migration
description: >
  Generate and apply a database migration using Prisma/Drizzle.
  Use when the user asks to add a column, create a table, rename a field,
  or modify the database schema in any way.
disable-model-invocation: true
argument-hint: "[description of schema change]"
allowed-tools: Read, Bash, Write, Edit
---

# Create Migration

Generate a database migration for: $ARGUMENTS

## Steps

1. Read the current schema file (`prisma/schema.prisma` or `drizzle/schema.ts`)
2. Design the schema change — add the new field/table/index
3. Write the updated schema
4. Generate the migration: `pnpm prisma migrate dev --name $ARGUMENTS` or equivalent
5. Verify the generated SQL looks correct
6. Run `pnpm db:migrate` to apply

## Rollback Safety Rules
- Every migration must be reversible
- Never drop a column without a multi-step deprecation plan
- Always add `DEFAULT` values when adding NOT NULL columns to existing tables
- Test with: describe what happens if this migration is rolled back
```

### .claude/skills/deploy/SKILL.md
```yaml
---
name: deploy
description: >
  Deploy the application to a target environment.
  Only invoke when the user explicitly asks to deploy.
disable-model-invocation: true
argument-hint: "[environment: dev|staging|production]"
allowed-tools: Read, Bash
---

# Deploy

Deploy to environment: $ARGUMENTS

## Pre-deploy Checklist
1. Run tests: `pnpm test` — must pass
2. Run build: `pnpm build` — must succeed
3. Check for uncommitted changes: `git status`
4. Confirm target environment with user if not specified

## Deploy Command
```bash
# Replace with your actual deploy command
pnpm deploy --env $ARGUMENTS
```

## Post-deploy Verification
1. Check health endpoint: `curl https://$ARGUMENTS.your-domain.com/health`
2. Tail logs for 30 seconds: `kubectl logs -f deploy/app -n $ARGUMENTS` (or equivalent)
3. Report: deploy success/failure + health check result
```
