# Spec-First Verification User Guide

## Purpose

The spec-first-verification pattern generates tests from an API specification (OpenAPI, GraphQL schema) and verifies that the implementation satisfies them. It reports missing, incorrect, or incomplete endpoints. Use this after writing or updating an API spec to ensure the implementation matches.

## Prerequisites

The following must be installed in your project:

- **Skill**: `.claude/skills/spec-verify/SKILL.md`
- **Agents**: `.claude/agents/spec-test-generator.md`, `.claude/agents/spec-verifier.md`
- **Directories**: `.claude/spec/` and `tests/spec-verification/` must exist (or be creatable)
- **API spec file**: An OpenAPI (YAML/JSON) or GraphQL schema file in the project

## Architecture

| Component | Role |
|-----------|------|
| `spec-verify` skill | Orchestrates the generate-then-verify workflow |
| `spec-test-generator` sub-agent | Reads the spec file and generates test files (write-capable, writes only to `tests/spec-verification/`) |
| `spec-verifier` sub-agent | Runs generated tests and reports results (read-only, Write/Edit disabled) |

The verifier **cannot modify source code** to make tests pass. This is the core guarantee: the verifier reports the gap between spec and implementation without papering over it.

## Usage

Invoke from the Claude Code prompt:

```
/spec-verify openapi.yaml
```

Or with a path to a GraphQL schema:

```
/spec-verify schema/api.graphql
```

The argument must be the path to the spec file.

## Workflow

1. **Generate tests** -- The `spec-test-generator` reads the spec file and creates test files in `tests/spec-verification/`. Each test exercises an endpoint or operation defined in the spec.
2. **Run verification** -- The `spec-verifier` executes the generated tests against the running implementation.
3. **Report** -- Results are written to `.claude/spec/verification-report.json` and presented as a summary of passed endpoints, failed endpoints, and missing endpoints.

## Example

```
/spec-verify docs/api/openapi.yaml
```

The spec defines `GET /api/products`, `POST /api/products`, and `DELETE /api/products/:id`. The test generator creates three test files. The verifier runs them and reports:
- `GET /api/products` -- PASS
- `POST /api/products` -- FAIL (missing required field validation)
- `DELETE /api/products/:id` -- MISSING (endpoint not implemented)

## Output

- `tests/spec-verification/` -- Generated test files, one per endpoint or operation
- `.claude/spec/verification-report.json` -- Structured report with pass/fail/missing status per endpoint
- Console summary of results

## Tips

- Keep your spec file up to date. The pattern's value depends on the spec being the source of truth.
- The test generator costs 3,000-8,000 tokens (depends on spec size); the verifier costs 1,000-2,000 tokens.
- If a single agent generated tests AND verified, it could silently modify the implementation to make tests pass. The two-agent split with read-only verifier prevents this.
- Generated tests are saved to disk, so you can review and commit them as part of your test suite.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Spec file not found | Ensure the path argument is correct and relative to the project root. |
| Tests fail to run | Check that the test runner is configured and dependencies are installed. The verifier uses `pnpm test` by default. |
| All endpoints reported as MISSING | The implementation may use different route paths than the spec defines. Verify that route prefixes and base paths match. |
| Generator produces no tests | The spec file may be malformed or empty. Validate it with a linter (e.g., `swagger-cli validate`). |
