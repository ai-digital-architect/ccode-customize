---
name: sequential-pipeline
description: >
  Executes a strict stage-by-stage feature implementation pipeline:
  schema → entity → service → API route → tests. Each stage must pass
  build and test before the next begins. Trigger when user asks to
  scaffold a full feature, build a complete endpoint, or implement
  something end-to-end.
argument-hint: "[feature-name] [description]"
allowed-tools: Read, Write, Edit, Bash
---

Implement the following feature through a strict sequential pipeline: $ARGUMENTS

## Pipeline Stages (execute in exact order)

### Stage 1: Schema Design
Invoke the `schema-designer` sub-agent with the feature description.
Wait for completion. Run `pnpm build && pnpm test` — do NOT proceed if either fails.

### Stage 2: Entity & Repository Layer
Invoke the `entity-builder` sub-agent with the schema output from Stage 1.
Wait for completion. Run `pnpm build && pnpm test` — do NOT proceed if either fails.

### Stage 3: Service Layer
Invoke the `service-builder` sub-agent with context from Stages 1–2.
Wait for completion. Run `pnpm build && pnpm test` — do NOT proceed if either fails.

### Stage 4: API Route
Invoke the `route-builder` sub-agent with context from Stages 1–3.
Wait for completion. Run `pnpm build && pnpm test` — do NOT proceed if either fails.

### Stage 5: Integration Tests
Invoke the `test-writer` sub-agent covering all layers.
Run `pnpm test` — fix any failures before presenting results.

Present a summary of all files created, grouped by stage.
