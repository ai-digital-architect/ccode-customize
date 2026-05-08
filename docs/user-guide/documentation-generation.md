# Documentation Generation

## Purpose

The documentation generation skill produces API documentation, README content, and Architecture Decision Records (ADRs) by analyzing source code, tests, and git history. It is a read-only analysis skill that does not modify source code.

Use this skill:
- After completing a feature to document the new API surface
- Before a release to ensure documentation is current
- To capture architectural decisions in a standard ADR format

## Prerequisites

- Source code under `src/` with JSDoc comments on exported functions
- Route handlers with defined paths, methods, and response shapes
- A git repository with commit history (required for ADR generation)

## Usage

Invoke the skill with a slash command:

```
/generate-docs [scope] [doc-type]
```

Arguments:
- `scope` -- `all` to document every module, or a specific module name (e.g., `invoice`)
- `doc-type` -- `api` for API reference, `readme` for README content, `adr` for Architecture Decision Records, or `all` for all three

## Example

```
/generate-docs invoice api
```

This reads the `invoice` module's route handlers, extracts endpoints and response shapes, pulls usage examples from tests, and generates an API reference document.

```
/generate-docs all adr
```

This reads the last 20 git commits, identifies significant architectural decisions, and produces numbered ADR documents.

## Output

All documentation is written to `.claude/docs/`:

| File | Contents |
|------|----------|
| `api-reference.md` | Endpoint tables with path, method, parameters, response shape, and code examples |
| `readme-section.md` | Module purpose, configuration options, and quick-start guide |
| `adr-NNNN.md` | Architecture Decision Record with Title, Status, Context, Decision, and Consequences |

## Tips

- Add the recommended permissions to `.claude/settings.json` to streamline execution:
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
- Well-written JSDoc comments directly improve the quality of generated documentation.
- Use descriptive commit messages -- ADR generation relies on them to identify decisions.
- Run with `doc-type: all` before a release to get a complete documentation refresh.

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Empty API reference | No route handlers found in scope | Verify the module name matches a directory under `src/routes/` |
| ADR has vague context | Commit messages lack detail | Write more descriptive commit messages for architectural changes |
| Missing configuration section in README | No environment variable usage detected | Ensure config values are read from `process.env` with clear names |
| Permission prompts during execution | Bash commands not pre-approved | Add recommended permissions to `.claude/settings.json` |
