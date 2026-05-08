# Pattern Replacement

## Purpose

The pattern replacement workflow finds all instances of an old code pattern across the codebase using a read-only discovery pass, then replaces each instance one at a time with lint and compile verification after each change. Use this for large-scale refactors like API migrations, naming convention changes, or deprecated pattern elimination where each replacement must be individually verified.

## Prerequisites

- **Sub-agents**: `pattern-finder` and `pattern-replacer` installed in `.claude/agents/`
- **Hooks**: `refactor-lint.sh` (PostToolUse) in `.claude/hooks/`, executable
- **Settings**: Hook registrations merged into `.claude/settings.json`
- **Directory**: `.claude/refactor/` must exist for manifests and logs
- **Tooling**: `prettier` and `pnpm build` must be available

## Architecture

The workflow is split into two phases with distinct agents. The `pattern-finder` sub-agent has `disallowedTools: [Write, Edit, MultiEdit]`, guaranteeing a read-only discovery phase. The `pattern-replacer` sub-agent performs the actual modifications. The `refactor-lint.sh` hook fires after every write to `src/*` or `packages/*`, runs `prettier --write` (non-blocking) followed by `pnpm build --silent` (blocking). If the build fails, the hook exits with code 2, forcing a fix before the next replacement. This per-instance gate makes large-scale replacements safe.

## Usage

Invoke via the slash command:

```
/replace-pattern [old-pattern description] [new-pattern description]
```

Provide natural-language descriptions of the pattern to find and the pattern to replace it with.

## Workflow

### Phase 1: Discovery (read-only)

1. The `pattern-finder` sub-agent scans the entire codebase for instances of the old pattern.
2. A manifest is produced at `.claude/refactor/instance-manifest.json` with file paths and line numbers for every instance.
3. The manifest is presented for review before proceeding.

### Phase 2: Replacement (one at a time)

4. The `pattern-replacer` sub-agent reads the instance manifest.
5. Each instance is replaced individually.
6. After each replacement, the `refactor-lint.sh` hook runs prettier and then verifies compilation.
7. If verification fails, the issue is fixed before moving to the next instance.
8. A replacement log is written to `.claude/refactor/replacement-log.json`.

### Phase 3: Final Verification

9. `pnpm build && pnpm test` runs to verify the complete replacement is clean.
10. A summary is presented: instances found, successfully replaced, and any failures.

## Example

```
/replace-pattern "callback-style async functions using (err, result) => {}" "async/await with try-catch blocks"
```

The finder discovers 47 callback-style functions across 12 files. The replacer converts each one individually, with lint and compile checks after every change. The final summary shows 47 found, 47 replaced, 0 failures.

## Output

- `.claude/refactor/instance-manifest.json` -- all discovered instances
- `.claude/refactor/replacement-log.json` -- per-instance replacement status
- Modified source files with the new pattern applied
- Final build and test results

## Configuration

- **Lint tool**: Replace `prettier --write` in `refactor-lint.sh` with your project's formatter if different.
- **Build command**: Replace `pnpm build --silent` in the hook if you use a different build system.
- **Path triggers**: The hook triggers on `src/*` and `packages/*`. Adjust for your project structure.
- **Finder scope**: The finder scans the entire codebase by default. Add exclusion patterns in the agent definition to skip vendor or generated code.

## Tips

- Review the instance manifest before proceeding to Phase 2. Unexpected matches may indicate the pattern description needs refinement.
- The one-at-a-time approach is slower than bulk replacement but catches errors immediately, preventing cascading failures.
- The read-only guarantee on the finder means you can safely run discovery without risk of unintended changes.
- For very large codebases, the discovery phase may take significant time. Consider scoping the search to specific directories.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Finder modifies files | Agent misconfigured | Verify `disallowedTools` in `pattern-finder.md` includes Write, Edit, and MultiEdit |
| Build fails after replacement | Replacement introduced a syntax or type error | The hook blocks progression; fix the error before continuing |
| Manifest contains false positives | Pattern description too broad | Refine the old-pattern description to be more specific |
| Prettier reformats unrelated code | Prettier runs on the entire file | This is expected behavior; the formatting changes are non-blocking and will not cause failures |
