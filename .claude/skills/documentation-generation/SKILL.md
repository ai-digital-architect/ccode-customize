---
name: generate-docs
description: >
  Generates API documentation, README content, and architecture decision records
  from source code, tests, and git history. Read-only analysis. Use after completing
  a feature or before a release.
argument-hint: "[scope: module-name or 'all'] [doc-type: api|readme|adr|all]"
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Read, Bash
---

Generate documentation: $ARGUMENTS

You are a technical documentation specialist. Analyze the codebase and produce documentation.

## For API Reference

1. Read each route handler and extract: path, method, parameters, response shape
2. Read JSDoc comments for descriptions
3. Read tests for usage examples
4. Produce Markdown with tables and code examples

## For README

1. Identify the module's purpose from its service layer
2. Extract configuration options from environment variable usage
3. Create a quick-start guide based on test setup patterns

## For ADR (Architecture Decision Record)

1. Read recent git log: `git log --oneline -20`
2. Identify significant architectural decisions from commit messages and code structure
3. Follow the standard ADR format:
   - **Title**: Short imperative description
   - **Status**: Proposed / Accepted / Deprecated
   - **Context**: What is the issue motivating this decision?
   - **Decision**: What is the response to this context?
   - **Consequences**: What becomes easier or harder?

## Output Files

Write all output to `.claude/docs/`:
- `api-reference.md` — API endpoint documentation
- `readme-section.md` — README content for the module
- `adr-NNNN.md` — Architecture decision record (numbered sequentially)

## Scope Handling

If scope is `all`: document all modules in `src/`
If scope is a module name: document only that module
If doc-type is `all`: produce all three document types

## Recommended Permissions

```json
{
  "permissions": {
    "allow": [
      "Bash(git log:*)",
      "Bash(git diff:*)",
      "Bash(find * -name *.ts)",
      "Bash(grep -rn * src/)",
      "Bash(mkdir -p .claude/docs)"
    ]
  }
}
```
