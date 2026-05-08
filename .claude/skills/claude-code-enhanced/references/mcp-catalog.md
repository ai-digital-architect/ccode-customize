# MCP Server Catalog

Install commands and context for all recommended MCP servers.
Reference this during Phase 2 of `/cc-customize`.

All project-scoped servers go in `.mcp.json` at the project root (NOT in settings.json).

---

## Universal / High Value

### context7 — Live Documentation Lookup
**Install when**: Any project using popular libraries (React, Express, Django, Prisma, etc.)
```bash
claude mcp add context7 --command npx --args "-y,@upstash/context7-mcp"
```
`.mcp.json` entry:
```json
"context7": {
  "command": "npx",
  "args": ["-y", "@upstash/context7-mcp"]
}
```
**Why**: Fetches current, version-accurate library docs into Claude's context. Eliminates hallucinated APIs.

---

## Source Control

### GitHub MCP
**Install when**: `.github/` directory, `gh` CLI usage, GitHub Actions
```bash
claude mcp add github --command npx --args "-y,@modelcontextprotocol/server-github" \
  --env GITHUB_TOKEN=\${GITHUB_TOKEN}
```
`.mcp.json` entry:
```json
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
}
```
**Why**: Issues, PRs, Actions directly accessible without browser. Essential for PR workflow.

---

## Databases

### Supabase MCP
**Install when**: `@supabase/supabase-js` in deps, `supabase/` directory
```bash
claude mcp add supabase --command npx --args "-y,@supabase/mcp-server-supabase" \
  --env SUPABASE_URL=\${SUPABASE_URL} --env SUPABASE_SERVICE_KEY=\${SUPABASE_SERVICE_KEY}
```
**Why**: Direct database queries, schema inspection, migrations from Claude.

### PostgreSQL MCP
**Install when**: `pg`, `postgres`, `pgPool`, `@prisma/client` targeting Postgres
```bash
claude mcp add postgres --command npx --args "-y,@modelcontextprotocol/server-postgres" \
  --env DATABASE_URL=\${DATABASE_URL}
```
`.mcp.json` entry:
```json
"postgres": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-postgres"],
  "env": { "DATABASE_URL": "${DATABASE_URL}" }
}
```
**Why**: Run queries, inspect schema, debug data issues without leaving Claude.

### SQLite MCP
**Install when**: `better-sqlite3`, `sqlite3` in deps
```bash
claude mcp add sqlite --command npx --args "-y,@modelcontextprotocol/server-sqlite,./db.sqlite"
```

### MySQL MCP
**Install when**: `mysql2`, `mariadb` in deps
```bash
claude mcp add mysql --command npx --args "-y,@modelcontextprotocol/server-mysql" \
  --env DATABASE_URL=\${DATABASE_URL}
```

---

## Frontend / Browser

### Playwright MCP
**Install when**: `@playwright/test`, `cypress`, frontend project with E2E tests
```bash
claude mcp add playwright --command npx --args "-y,@playwright/mcp@latest"
```
`.mcp.json` entry:
```json
"playwright": {
  "command": "npx",
  "args": ["-y", "@playwright/mcp@latest"]
}
```
**Why**: Browser automation directly from Claude — test UI flows, take screenshots, validate behavior.

---

## Issue Tracking

### Linear MCP
**Install when**: Linear API calls detected, `.linear.yml` present, or team uses Linear
```bash
claude mcp add linear --command npx --args "-y,@linear/mcp-server" \
  --env LINEAR_API_KEY=\${LINEAR_API_KEY}
```
`.mcp.json` entry:
```json
"linear": {
  "command": "npx",
  "args": ["-y", "@linear/mcp-server"],
  "env": { "LINEAR_API_KEY": "${LINEAR_API_KEY}" }
}
```

### Jira MCP
**Install when**: Jira API calls, `atlassian` in deps
```bash
claude mcp add jira --command npx --args "-y,@atlassian/mcp-server-jira" \
  --env JIRA_URL=\${JIRA_URL} --env JIRA_EMAIL=\${JIRA_EMAIL} --env JIRA_TOKEN=\${JIRA_TOKEN}
```

---

## Monitoring / Error Tracking

### Sentry MCP
**Install when**: `@sentry/node`, `@sentry/browser`, `@sentry/nextjs` in deps
```bash
claude mcp add sentry --command npx --args "-y,@sentry/mcp-server" \
  --env SENTRY_AUTH_TOKEN=\${SENTRY_AUTH_TOKEN}
```
**Why**: Inspect and resolve real errors from production without leaving Claude.

---

## Cloud Infrastructure

### AWS MCP
**Install when**: `@aws-sdk/*` in deps, `aws.json`, or Terraform targeting AWS
```bash
claude mcp add aws-kb --command npx --args "-y,@aws/aws-mcp-server"
```
**Note**: AWS MCP gives access to documentation and resource management. Requires AWS credentials.

---

## Communication

### Slack MCP
**Install when**: `@slack/web-api` in deps, Slack webhook URLs in config
```bash
claude mcp add slack --command npx --args "-y,@modelcontextprotocol/server-slack" \
  --env SLACK_BOT_TOKEN=\${SLACK_BOT_TOKEN} --env SLACK_TEAM_ID=\${SLACK_TEAM_ID}
```
**Why**: Send deployment notifications, alert on failures, query channels for context.

---

## Memory / Persistence

### Memory MCP (for cross-session entity tracking)
**Install when**: Project involves tracking many entities, long-running investigations
```bash
claude mcp add memory --command npx --args "-y,@modelcontextprotocol/server-memory"
```
**Why**: Persistent knowledge graph across sessions — track people, decisions, entities.

---

## Filesystem (use carefully)

### Filesystem MCP
**Install when**: Need access to directories outside the project (reference repos, shared libs)
```bash
claude mcp add filesystem --command npx --args "-y,@modelcontextprotocol/server-filesystem,/path/to/dir"
```
**Security note**: Scope to minimum required path. Never point at `~` or `/`.

---

## .mcp.json Composition Example

Multi-server project (TypeScript + PostgreSQL + GitHub + context7):

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": { "DATABASE_URL": "${DATABASE_URL}" }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

---

## Security Notes

- Always use `${ENV_VAR}` references — never inline tokens or secrets
- Pin server versions in production (`@1.2.3`, not `@latest`)
- Use `disallowedTools` in sub-agents to prevent them from using MCP tools they don't need
- Commit `.mcp.json` — it's safe because it only contains references, not actual credentials
- Add required env vars to `.env.example` so the team knows what's needed
