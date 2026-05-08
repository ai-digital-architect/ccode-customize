# Detection Signals → Customization Surfaces

Full mapping from codebase signals to which Claude Code surfaces to populate.
Reference this during Phase 2 of `/cc-customize`.

---

## Language / Runtime Signals

| Signal | Detected By | Creates |
|--------|-------------|---------|
| TypeScript | `tsconfig.json`, `.ts` files | PostToolUse tsc hook (async), ts-specific rules |
| JavaScript | `package.json`, `.js` files | Prettier/ESLint hooks |
| Python | `pyproject.toml`, `*.py` | Ruff/Black/mypy hooks, pytest hook |
| Go | `go.mod` | gofmt hook, go-specific CLAUDE.md content |
| Rust | `Cargo.toml` | rustfmt hook, cargo test hook |
| Java/Kotlin | `pom.xml`, `build.gradle` | Maven/Gradle build hooks |
| Ruby | `Gemfile` | Rubocop hook |

---

## Framework Signals

| Signal | Detected By | Creates |
|--------|-------------|---------|
| React/Next.js | `react` in deps, `next.config.*` | `.claude/rules/frontend/react.md` (paths: components/**), Playwright MCP, ui-reviewer agent |
| Vue | `vue` in deps | `.claude/rules/frontend/vue.md`, ui-reviewer agent |
| Angular | `@angular/core` | `.claude/rules/frontend/angular.md`, ui-reviewer agent |
| Express/Fastify/Hono | deps | `.claude/rules/api-design.md`, api-documenter agent |
| FastAPI/Django/Flask | `fastapi/django/flask` in pyproject | `.claude/rules/api-design.md`, api-documenter agent |
| NestJS | `@nestjs/core` | `.claude/rules/api-design.md` (paths: src/**/*.controller.ts) |
| Next.js App Router | `app/` directory | `.claude/rules/nextjs.md` |
| Prisma | `@prisma/client` | DB MCP, create-migration skill, migration-gate hook |
| Drizzle | `drizzle-orm` | create-migration skill |
| SQLAlchemy | `sqlalchemy` | create-migration skill |

---

## Infrastructure Signals

| Signal | Detected By | Creates |
|--------|-------------|---------|
| Docker | `Dockerfile`, `docker-compose.yml` | Docker safety hooks, Docker-specific deny rules |
| GitHub Actions | `.github/workflows/` | GitHub MCP server, CI-specific CLAUDE.md notes |
| GitLab CI | `.gitlab-ci.yml` | CI-specific notes |
| Terraform/Pulumi | `*.tf`, `Pulumi.yaml` | infrastructure-drift-detection skill ref, safety hooks |
| AWS CDK | `aws-cdk-lib` in deps | AWS MCP consideration |
| Kubernetes | `*.yaml` with `apiVersion:` | K8s-specific rules |

---

## Database Signals

| Signal | Detected By | Creates |
|--------|-------------|---------|
| Supabase | `@supabase/supabase-js` | Supabase MCP |
| PostgreSQL | `pg`, `postgres`, `pgPool` | postgres MCP server |
| MySQL | `mysql2`, `mariadb` | mysql MCP server |
| MongoDB | `mongodb`, `mongoose` | mongodb MCP server |
| Redis | `redis`, `ioredis` | redis MCP |
| SQLite | `better-sqlite3`, `sqlite3` | sqlite MCP |
| Prisma | `@prisma/client`, `prisma/` dir | create-migration skill + migration-gate hook |
| Drizzle | `drizzle-orm` | create-migration skill |

---

## External Service Signals

| Signal | Detected By | Creates |
|--------|-------------|---------|
| Stripe | `stripe` dep | security-reviewer agent (payment code), deny rules for Stripe keys |
| OpenAI | `openai` dep | context7 MCP for OpenAI docs |
| Anthropic | `@anthropic-ai/sdk` dep | claude-api skill auto-triggers |
| Sentry | `@sentry/node` etc | Sentry MCP |
| Slack | `@slack/web-api` | Slack MCP |
| Linear | linear API calls | Linear MCP |
| Jira | jira client patterns | Jira MCP |
| AWS SDK | `@aws-sdk/*` | AWS MCP |

---

## Security / Sensitivity Signals

| Signal | Detected By | Creates |
|--------|-------------|---------|
| Auth code | `auth/`, `login`, `session`, `jwt` patterns | security-reviewer agent (high priority), security-focused rules |
| Payment code | `stripe`, `payment`, `billing` | security-reviewer agent |
| PII handling | `user.email`, `profile`, `pii` patterns | security-reviewer agent, deny rules for user data files |
| API keys in env | `.env` files | PreToolUse deny: Read(.env), permission deny rules |
| Lock files | `package-lock.json` etc | PreToolUse deny: Edit(lock file paths) |
| Sensitive dirs | `secrets/`, `credentials/` | PreToolUse deny rules |

---

## Code Quality Signals

| Signal | Detected By | Creates |
|--------|-------------|---------|
| Prettier | `.prettierrc*`, `prettier.config.*` | PostToolUse auto-format hook |
| ESLint | `.eslintrc*`, `eslint.config.*` | PostToolUse auto-lint hook |
| Ruff | `ruff.toml`, `[tool.ruff]` in pyproject | PostToolUse ruff format+check hook |
| Black | `[tool.black]` in pyproject | PostToolUse black hook |
| mypy | `mypy.ini`, `[tool.mypy]` | PostToolUse mypy hook (async) |
| pyright | `pyrightconfig.json` | PostToolUse pyright hook (async) |
| gofmt | `go.mod` | PostToolUse gofmt hook |
| rustfmt | `Cargo.toml` | PostToolUse rustfmt hook |

---

## Testing Signals

| Signal | Detected By | Creates |
|--------|-------------|---------|
| Jest | `jest` in deps, `jest.config.*` | PostToolUse jest hook, test-writer agent |
| Vitest | `vitest` in deps | PostToolUse vitest hook, test-writer agent |
| pytest | `pytest.ini`, `[tool.pytest]` | PostToolUse pytest hook, test-writer agent |
| Playwright | `@playwright/test` | Playwright MCP, E2E test rules |
| Cypress | `cypress` dep | E2E testing notes |
| Low test ratio | source files >> test files | test-writer agent (higher priority) |

---

## Project Structure Signals

| Signal | Detected By | Creates |
|--------|-------------|---------|
| Monorepo | `packages/`, `apps/`, `workspaces` in package.json | Per-package `.claude/skills/`, workspace-level CLAUDE.md |
| Large codebase (>500 files) | file count | code-reviewer agent (higher priority) |
| Small project (<50 files) | file count | Minimal setup — just CLAUDE.md + key hooks |
| Active git history | recent commits | code-archaeology context in CLAUDE.md |
| Component library | `components/`, `ui/`, `design-system/` | ui-reviewer agent, frontend rules |
| API project (no frontend) | no `components/` or `pages/` | api-documenter agent, no frontend rules |
| Full-stack | both `api/` and `components/` | Both API and frontend agents+rules |

---

## Hook Selection Matrix

Given detected signals, which hooks to create:

| Detected | Hook | Event | Handler Type |
|----------|------|-------|--------------|
| Any project | bash-safety | PreToolUse/Bash | command |
| .env files | protect-env | PreToolUse/Write,Edit | command |
| Lock files | protect-locks | PreToolUse/Write,Edit | command |
| Prettier | auto-format | PostToolUse/Write,Edit | command |
| ESLint | auto-lint | PostToolUse/Write,Edit | command |
| tsconfig.json | typecheck (async) | PostToolUse/Write,Edit | command (async) |
| mypy/pyright | typecheck (async) | PostToolUse/Write,Edit | command (async) |
| gofmt | auto-format | PostToolUse/Write,Edit | command |
| rustfmt | auto-format | PostToolUse/Write,Edit | command |
| Tests present | run-tests (async) | PostToolUse/Write,Edit | command (async) |
| Any project | audit-log (optional) | PostToolUse/* | command |
| Quality-focused | stop-gate (optional) | Stop/* | prompt |

---

## Agent Priority Matrix

| Agent | Create When | Priority |
|-------|-------------|----------|
| researcher | >100 source files | High — almost always |
| code-reviewer | >200 files or team project | High |
| security-reviewer | auth OR payment OR PII OR API keys | High (if any signal) |
| test-writer | test framework present + low test ratio | Medium |
| api-documenter | REST routes OR GraphQL detected | Medium |
| performance-analyzer | DB queries OR ORM OR critical paths | Medium |
| ui-reviewer | frontend framework detected | Medium |
| migration-helper | ORM + old deps OR major version behind | Low (opt-in) |

---

## CLAUDE.md vs AGENTS.md Split

| Content Type | File |
|--------------|------|
| Build/test/lint commands | Both (AGENTS.md for portability, CLAUDE.md for Claude-specific notes) |
| Code style, naming conventions | AGENTS.md |
| Architecture overview | AGENTS.md |
| Commit message conventions | AGENTS.md |
| Tech stack details | AGENTS.md |
| Sub-agent workflow notes | CLAUDE.md only |
| Skill/hook/MCP references | CLAUDE.md only |
| Anti-patterns specific to this project | CLAUDE.md |
| Output style preferences | CLAUDE.md |
| CI-specific Claude behavior | CLAUDE.md |

---

## Rule Scoping Guide

Create path-scoped `.claude/rules/*.md` files for these directories:

| Directory Pattern | Rule File | `paths:` Value |
|-------------------|-----------|----------------|
| `src/api/` | api-design.md | `["src/api/**/*"]` |
| `src/components/` | frontend-react.md | `["src/components/**/*.tsx"]` |
| `tests/`, `__tests__/` | testing.md | `["**/*.test.*", "**/*.spec.*"]` |
| `migrations/` | migrations.md | `["migrations/**/*", "**/migrate.ts"]` |
| `src/auth/` | auth-patterns.md | `["src/auth/**/*", "**/*auth*"]` |
| `infrastructure/`, `*.tf` | infra.md | `["**/*.tf", "infrastructure/**/*"]` |
| `packages/*/` (monorepo) | per-package.md | `["packages/<name>/**/*"]` |
