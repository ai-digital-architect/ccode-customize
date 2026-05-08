# Incremental Migration

## Purpose

The incremental migration pattern migrates modules one at a time, running the full test suite between each module. The build is never broken mid-migration. Use this for framework upgrades, API version migrations, or pattern replacements that span multiple modules and must remain stable throughout the process.

## Prerequisites

- **Sub-agents**: `module-migrator` installed in `.claude/agents/`
- **Hooks**: `migration-gate.sh` (PostToolUse) in `.claude/hooks/`, executable
- **Settings**: Hook registrations merged into `.claude/settings.json`
- **Build tooling**: `pnpm build` and `pnpm test` must be functional
- **Directory**: `.claude/migration/` will be created for progress tracking

## Architecture

The skill orchestrates the `module-migrator` sub-agent, invoking it once per module in sequence. The `migration-gate.sh` hook fires after every write to `src/*` or `packages/*` and runs `pnpm build --silent`. If the build fails, the hook exits with code 2, blocking the result and forcing the model to fix the issue before moving to the next module. This ensures the codebase compiles at every step of the migration.

## Usage

Invoke via the slash command:

```
/incremental-migrate [migration-description] [module-list-or-auto]
```

Provide a description of the migration and either an explicit list of modules or `auto` to let the skill discover them.

## Workflow

1. **Discover modules**: The skill identifies all modules to migrate, either from the arguments or by auto-detection.
2. **Migrate each module**: For each module, sequentially:
   a. The `module-migrator` sub-agent is invoked with the module path and migration specification.
   b. After the sub-agent completes, `pnpm build && pnpm test` is run.
   c. If tests fail, failures are fixed before proceeding to the next module.
   d. If tests pass, success is logged and the next module begins.
   e. Progress is written to `.claude/migration/progress.json`.
3. **Final verification**: The full test suite runs one final time after all modules are migrated.
4. **Report**: A migration summary is presented with per-module status.

## Example

```
/incremental-migrate "upgrade from Express v4 to Express v5" packages/*
```

The skill discovers all packages, migrates each one sequentially (updating imports, middleware signatures, error handling), and verifies the build passes after every package. Progress is tracked so the migration can be resumed if interrupted.

## Output

- Modified source files in each migrated module
- `.claude/migration/progress.json` -- per-module migration status
- A final migration summary showing success/failure per module
- Full test suite results after all modules are complete

## Configuration

- **Build command**: Edit `migration-gate.sh` to change the build command if you do not use `pnpm build`.
- **Path triggers**: The hook triggers on writes to `src/*` or `packages/*`. Adjust the path pattern if your project structure differs.
- **Progress file**: The progress JSON enables resumption. If restarting a partial migration, the skill can read existing progress and skip completed modules.

## Tips

- Auto-detection works best in monorepos with a clear `packages/` structure. For custom layouts, provide an explicit module list.
- The module-by-module approach means each module is independently stable. If the migration is interrupted, completed modules remain correctly migrated.
- Review `progress.json` to understand which modules are done and which remain.
- For very large migrations, consider running the skill in multiple sessions, using `progress.json` to track state.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Build fails after module migration | Incompatible changes introduced | The hook blocks progression; fix the build error before continuing |
| Module not detected by auto-discovery | Non-standard project structure | Provide an explicit module list instead of using `auto` |
| Progress file missing | First run or file was deleted | The skill creates it automatically; no action needed |
| Hook triggers on non-source files | Path pattern too broad | Narrow the trigger pattern in `migration-gate.sh` to match only relevant paths |
