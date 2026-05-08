# Contract Testing User Guide

## Purpose

The contract-testing pattern detects API drift between frontend consumers and backend providers. It scans frontend code to extract API usage contracts, then verifies those contracts against the backend implementation. Use this before releases or after API changes to catch mismatches early.

## Prerequisites

The following must be installed in your project:

- **Skill**: `.claude/skills/contract-test/SKILL.md`
- **Agents**: `.claude/agents/contract-extractor.md`, `.claude/agents/contract-verifier.md`
- **Directory**: `.claude/contracts/` must exist
- **Project structure**: Identifiable frontend and backend code (e.g., separate `src/client` and `src/server` directories, or equivalent)

## Architecture

| Component | Role |
|-----------|------|
| `contract-test` skill | Orchestrates the extract-then-verify workflow |
| `contract-extractor` sub-agent | Scans frontend code for API usage patterns (read-only, Write/Edit disabled) |
| `contract-verifier` sub-agent | Checks backend endpoints against extracted contracts (read-only, Write/Edit disabled) |

Both agents are physically prevented from modifying the code they analyze. The verifier cannot "fix" backend code to pass contracts -- it can only report gaps.

## Usage

Invoke from the Claude Code prompt:

```
/contract-test all
```

Or target a specific API module:

```
/contract-test users-api
```

## Workflow

1. **Extract contracts** -- The `contract-extractor` scans frontend API call sites (fetch, axios, SDK usage) and generates consumer contracts describing expected endpoints, methods, request bodies, and response shapes.
2. **Contract output** -- Contracts are written to `.claude/contracts/consumer-contracts.json`.
3. **Verify contracts** -- The `contract-verifier` reads the consumer contracts and checks each one against the backend implementation (route definitions, handlers, response types).
4. **Verification output** -- Results are written to `.claude/contracts/verification.json`.
5. **Report** -- If drift is detected, mismatches are reported with file and line references. If no drift, all contracts are confirmed as satisfied.

## Example

```
/contract-test all
```

The extractor finds that the frontend calls `POST /api/users` with `{ name: string, email: string }` and expects `{ id: number, name: string }` in the response. The verifier checks the backend route handler and confirms the contract matches -- or reports that the backend now returns `{ id: string, name: string }` (type mismatch on `id`).

## Output

- `.claude/contracts/consumer-contracts.json` -- Extracted API contracts from frontend code
- `.claude/contracts/verification.json` -- Verification results with pass/fail per contract
- Console report summarizing mismatches with file/line references

## Tips

- Run contract testing after any API schema change to catch drift before it reaches production.
- The extractor works best when frontend API calls follow consistent patterns (centralized API client, typed SDK, etc.).
- Each agent costs 2,000-4,000 tokens. The total workflow is relatively lightweight.
- Separate extractor and verifier contexts ensure each agent focuses on its domain (frontend vs backend) without mixing concerns.
- Consider running this pattern as part of your CI pipeline by invoking it before each release.
- The pattern is inspired by consumer-driven contract testing (similar to Pact) but operates via static code analysis rather than runtime recording.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Extractor finds no API calls | Ensure your frontend code uses recognizable HTTP call patterns. If using a custom SDK, the extractor may need the API module name as the argument. |
| Verifier reports false mismatches | Check that the backend routes use standard patterns (Express routes, FastAPI endpoints, etc.) that the verifier can parse. |
| `.claude/contracts/` directory missing | Run `mkdir -p .claude/contracts` before invoking the skill. |
| Contracts are incomplete | Run with a specific module name instead of `all` to get more focused extraction. |
| Previous contracts interfere with current run | Delete `.claude/contracts/consumer-contracts.json` before re-running to ensure fresh extraction. |
