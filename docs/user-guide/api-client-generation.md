# API Client Generation -- User Guide

## Purpose

The API client generation pattern produces fully typed client libraries from an OpenAPI or gRPC specification. It parses endpoints, request/response schemas, and auth requirements, then generates typed client modules with automatic type-checking after each file. Use this pattern when a new API spec is available or when an existing spec has been updated.

## Prerequisites

- Claude Code CLI installed and configured
- Sub-agent installed: `client-generator`
- Hook installed: `typecheck-generated.sh` (PostToolUse)
- Settings fragment merged into `.claude/settings.json`
- An OpenAPI (JSON/YAML) or gRPC (`.proto`) specification file
- Language-specific type checker available: `pnpm typecheck` (TypeScript), `mypy` (Python), or `go vet` (Go)

## Architecture

| Component | Type | Role |
|-----------|------|------|
| `SKILL.md` | Skill | Orchestrates spec parsing, client generation, and type verification |
| `client-generator` | Sub-agent (write) | Generates one client module per resource/endpoint group |
| `typecheck-generated.sh` | Hook (PostToolUse) | Type-checks each generated file immediately after creation |

The `client-generator` agent has `disallowedTools: [Edit, MultiEdit]` to prevent it from modifying existing non-generated source files -- it can only write new client files. The hook catches type errors immediately, preventing broken clients from accumulating.

## Usage

Invoke via the slash command:

```
/generate-client openapi.yaml ts
```

Arguments:
- First argument: path to the spec file
- Second argument: target language (`ts`, `python`, or `go`)

## Workflow

1. **Parse spec**: Read the specification file and extract all endpoints, schemas, and auth requirements.
2. **Generate client modules**: For each resource/endpoint group, produce a typed client module in the target language.
3. **Type-check per file**: The `typecheck-generated.sh` hook fires on every Write, running the appropriate type checker.
4. **Generate barrel file**: Create an index/barrel file that re-exports all generated clients.
5. **Generate types**: Produce type definitions for all request/response schemas.
6. **Final type-check**: Run the full type checker across all generated code.
7. **Report**: Present the list of generated files with endpoint coverage.

### Output Locations by Language

| Language | Client modules | Types |
|----------|---------------|-------|
| TypeScript | `src/clients/<resource>.client.ts` | `src/clients/types.ts` |
| Python | `clients/<resource>_client.py` | `clients/types.py` |
| Go | `clients/<resource>.go` | `clients/types.go` |

### Hook Behavior

The `typecheck-generated.sh` hook triggers on every Write call but filters by file path:
- TypeScript: acts on `src/clients/*.ts`, runs `pnpm typecheck`
- Python: acts on `clients/*.py`, runs `mypy <file>`
- Go: acts on `clients/*.go`, runs `go vet ./clients/...`

On type failure, it exits with code 2, blocking the session until the error is fixed.

## Example

```
/generate-client specs/petstore.yaml ts
```

Generates:
- `src/clients/pets.client.ts` -- CRUD operations for the Pets resource
- `src/clients/store.client.ts` -- Store/inventory operations
- `src/clients/users.client.ts` -- User management operations
- `src/clients/types.ts` -- Pet, Order, User interfaces
- `src/clients/index.ts` -- Barrel file exporting all clients

## Configuration

- **Output directories**: Adjust the client output paths in the skill to match your project structure
- **Type checker command**: Modify the hook to use your specific type checker configuration
- **Auth handling**: The generator reads auth requirements from the spec; configure base URL and auth token injection in the generated client base class

## Tips

- Keep your OpenAPI spec up to date -- the generated clients are only as accurate as the spec
- Re-run the pattern after spec updates to regenerate clients; review diffs carefully
- For large specs, the per-file type checking provides fast feedback rather than waiting for all files to be generated
- Consider adding the generated client directory to `.gitignore` if you regenerate on each build, or commit them if you want diff visibility

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Type-check hook blocks with errors | Review the generated file for schema mismatches; verify the spec has valid type definitions |
| Missing endpoints in generated clients | Check that the spec file includes all endpoints; some specs split across multiple files |
| Hook not firing on generated files | Verify file paths match the hook's filter patterns (`src/clients/*.ts`, etc.) |
| Auth not handled correctly | Ensure the spec includes `securitySchemes` and `security` sections |
