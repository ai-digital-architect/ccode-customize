---
name: scaffold
description: >
  Scaffolds a complete new module with all boilerplate: entity, repository,
  service, route handler, tests, and module registration. Follows project
  conventions. Use when creating a new feature module.
argument-hint: "[module-name] [brief description]"
disable-model-invocation: false
allowed-tools: Read, Write, Bash
---

Scaffold new module: $ARGUMENTS

## Steps

1. Read project conventions from `CLAUDE.md`
2. Read the template structure below
3. Create all files for the new module:
   - `src/entities/$1.entity.ts`
   - `src/repositories/$1.repository.ts`
   - `src/services/$1.service.ts`
   - `src/routes/$1.routes.ts`
   - `src/routes/$1.routes.test.ts`
4. Register the new module in `src/routes/index.ts`
5. Run `pnpm build && pnpm test`
6. Present list of created files with a brief description of each

## Module Template Structure

### Entity: `src/entities/{name}.entity.ts`
- Export TypeScript types/interfaces for the entity
- Include all fields with JSDoc comments
- Use Drizzle `InferSelectModel` / `InferInsertModel` for DB types

### Repository: `src/repositories/{name}.repository.ts`
- Export functions: `findById`, `findAll`, `create`, `update`, `delete`
- All queries use Drizzle ORM — no raw SQL
- Return `Result<T, RepositoryError>` types

### Service: `src/services/{name}.service.ts`
- Business logic only
- Depends on repository via function parameters (dependency injection)
- Return `Result<T, AppError>` types
- JSDoc on every exported function

### Routes: `src/routes/{name}.routes.ts`
- Thin handlers: validate → call service → return response
- OpenAPI annotations on each handler
- Standard error response format

### Tests: `src/routes/{name}.routes.test.ts`
- Happy path for each endpoint
- Validation error cases
- Auth failure cases
- Use Supertest for HTTP assertions
