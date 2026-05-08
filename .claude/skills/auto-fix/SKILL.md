---
name: auto-fix
description: >
  Automatically detects the project type and dispatches to the correct
  specialist sub-agent. Handles TypeScript, Python, and Go projects.
  Use when the user needs a fix and the project type determines the approach.
argument-hint: "[issue description]"
allowed-tools: Read, Write, Edit, Bash
---

Auto-fix with project detection: $ARGUMENTS

## Step 1: Detect Project Type

Inspect the repository to determine the primary language/framework:
- If `package.json` + `tsconfig.json` exist → TypeScript project
- If `requirements.txt` or `pyproject.toml` exists → Python project
- If `go.mod` exists → Go project
- If multiple match: check the most recently modified manifest

## Step 2: Dispatch

Based on detected project type:
- **TypeScript**: Invoke `ts-fixer` sub-agent with the issue description
- **Python**: Invoke `py-fixer` sub-agent with the issue description
- **Go**: Invoke `go-fixer` sub-agent with the issue description

## Step 3: Verify

After the specialist completes, run the project's test suite to confirm the fix.
