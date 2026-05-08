---
name: generate-client
description: >
  Generates fully typed API clients from an OpenAPI or gRPC spec. Runs
  type-checking after each generated file. Use when a new API spec is
  available or the spec has been updated.
argument-hint: "[spec-file-path] [target-language: ts|python|go]"
allowed-tools: Read, Write, Bash
---

Generate API client from spec: $ARGUMENTS

1. Read the spec file at `$1`
2. Parse all endpoints, request/response schemas, and auth requirements
3. For each resource/endpoint group, generate a typed client module:
   - TypeScript: `src/clients/<resource>.client.ts`
   - Python: `clients/<resource>_client.py`
   - Go: `clients/<resource>.go`
4. Generate a barrel/index file that exports all clients
5. Generate types/interfaces for all request/response schemas
6. Run the type-checker (`pnpm typecheck` / `mypy` / `go vet`)
7. Present list of generated files with endpoint coverage

Note: The `typecheck-generated.sh` PostToolUse hook automatically type-checks
each generated file as it is written.
