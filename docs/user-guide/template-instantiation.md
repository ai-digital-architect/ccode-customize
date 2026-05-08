# Template Instantiation

## Purpose

The template instantiation skill scaffolds a complete new module with all required boilerplate files: entity, repository, service, route handler, tests, and module registration. It follows existing project conventions automatically.

Use this skill:
- When creating a new feature module from scratch
- To ensure consistent file structure across modules
- To accelerate development by generating boilerplate that conforms to project standards

## Prerequisites

- A `CLAUDE.md` file in the project root defining coding conventions
- An existing `src/routes/index.ts` file for module registration
- Project tooling configured (`pnpm build` and `pnpm test` must work)
- Drizzle ORM set up (entities use `InferSelectModel` / `InferInsertModel`)

## Usage

Invoke the skill with a slash command:

```
/scaffold [module-name] [brief description]
```

Both arguments are required:
- `module-name` -- the name of the new module (used for file naming)
- `brief description` -- a short phrase describing the module's purpose

## Example

```
/scaffold invoice Manages customer invoices and payment tracking
```

This creates a full module with entity types, CRUD repository functions, business logic service, route handlers with OpenAPI annotations, and test coverage.

## Output

The skill creates the following files:

| File | Purpose |
|------|---------|
| `src/entities/<name>.entity.ts` | TypeScript types and interfaces with JSDoc |
| `src/repositories/<name>.repository.ts` | CRUD functions returning `Result<T, RepositoryError>` |
| `src/services/<name>.service.ts` | Business logic with dependency injection |
| `src/routes/<name>.routes.ts` | Thin HTTP handlers with OpenAPI annotations |
| `src/routes/<name>.routes.test.ts` | Tests covering happy path, validation, and auth |

The skill also registers the new module in `src/routes/index.ts` and runs `pnpm build && pnpm test` to verify everything compiles and passes.

## Tips

- Provide a descriptive brief so the generated entity fields and service logic are meaningful.
- Review generated tests and add edge cases specific to your domain after scaffolding.
- The skill reads `CLAUDE.md` for conventions, so keep that file up to date with your project's patterns.
- All repository functions use Drizzle ORM -- no raw SQL is generated.

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Build fails after scaffolding | Missing Drizzle schema or DB table | Define the DB table in your Drizzle schema before scaffolding |
| Tests fail | Test database not configured | Ensure your test environment has a working database connection |
| Module not registered | `src/routes/index.ts` has an unexpected format | Manually add the import and route registration |
| Wrong naming convention | Project uses a different file naming pattern | Update `CLAUDE.md` with your naming conventions before running |
