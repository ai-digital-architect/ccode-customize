# Sequential Pipeline

## Purpose

The sequential pipeline pattern executes a strict stage-by-stage feature implementation: schema, entity, service, API route, then tests. Each stage must pass build and test before the next begins. Use this when you need to scaffold a full feature, build a complete endpoint, or implement something end-to-end with guaranteed build stability at every step.

## Prerequisites

- **Sub-agents**: `schema-designer`, `entity-builder`, `service-builder`, `route-builder`, `test-writer` installed in `.claude/agents/`
- **Hooks**: `pipeline-gate.sh` (PostToolUse) and `notify-pipeline-complete.sh` (Stop) in `.claude/hooks/`, both executable
- **Settings**: Hook registrations merged into `.claude/settings.json`
- **Build tooling**: `pnpm build` and `pnpm test` must be functional in the project

## Architecture

The skill orchestrates five sub-agents in strict sequence. Between each stage, the `pipeline-gate.sh` hook intercepts every file write to `src/*` and runs `pnpm build --silent`. If the build fails, the hook exits with code 2, blocking the tool call and forcing the model to fix the error before advancing. This enforcement is deterministic -- it does not rely on the model following instructions.

A second hook, `notify-pipeline-complete.sh`, fires at session end to log a timestamp and optionally send a Slack notification.

## Usage

Invoke via the slash command:

```
/sequential-pipeline [feature-name] [description]
```

The skill expects a feature name and a natural-language description of what to build.

## Workflow

1. **Stage 1 -- Schema Design**: The `schema-designer` sub-agent creates the database schema. Build and test must pass.
2. **Stage 2 -- Entity and Repository**: The `entity-builder` sub-agent generates entity models and repository code using Stage 1 output. Build and test must pass.
3. **Stage 3 -- Service Layer**: The `service-builder` sub-agent creates business logic services using context from Stages 1-2. Build and test must pass.
4. **Stage 4 -- API Route**: The `route-builder` sub-agent creates HTTP route handlers using context from Stages 1-3. Build and test must pass.
5. **Stage 5 -- Integration Tests**: The `test-writer` sub-agent writes integration tests covering all layers. Any test failures are fixed before completion.
6. **Summary**: A final report lists all files created, grouped by stage.

## Example

```
/sequential-pipeline user-profile "CRUD operations for user profiles with email validation and avatar upload"
```

This triggers five sequential stages, producing schema migrations, entity classes, a profile service, REST endpoints, and integration tests -- each verified before the next begins.

## Output

- Database schema files (migrations, DDL)
- Entity and repository source files
- Service layer with business logic
- API route handlers
- Integration test files
- A summary of all created files grouped by pipeline stage

## Configuration

- **Hook customization**: Edit `pipeline-gate.sh` to change the build command (e.g., replace `pnpm build` with `npm run build`).
- **Notification**: Set the `SLACK_WEBHOOK_URL` environment variable to enable Slack notifications on pipeline completion.
- **Stage enforcement**: The hook triggers on writes to `src/*`. Adjust the path pattern in the hook if your source directory differs.

## Tips

- Keep feature descriptions specific. Vague descriptions lead to overly generic implementations.
- If a stage consistently fails, check that prior stages produce the expected file structure.
- Each sub-agent runs in isolation with its own token budget (approximately 1,000-3,000 tokens each), keeping costs predictable.
- The skill itself uses only around 200 tokens of overhead.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Pipeline stalls at a stage | Build failure blocks progression | Check the build error output; fix the compilation issue manually or let the agent retry |
| Hook does not trigger | Hook file not executable or not registered in settings | Run `chmod +x .claude/hooks/pipeline-gate.sh` and verify `settings.json` |
| Sub-agent not found | Agent markdown file missing | Verify all five agent files exist in `.claude/agents/` |
| Slack notification not sent | `SLACK_WEBHOOK_URL` not set | Export the environment variable before starting the session |
