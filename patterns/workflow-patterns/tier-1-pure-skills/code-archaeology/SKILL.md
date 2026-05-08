---
name: code-archaeology
description: >
  Traces the evolution of a file or function through git history and produces a
  narrative explaining why the code looks the way it does. Use for onboarding,
  understanding legacy code, or before refactoring.
argument-hint: "[file-path] [optional: function-name]"
disable-model-invocation: false
context: fork
agent: Explore
allowed-tools: Read, Bash
---

Trace code history: $ARGUMENTS

You are a code archaeology specialist. Trace the history of the specified file or function.

## Steps

1. Run `git log --follow --all -- <file>` for full history
2. For key commits (major changes, inflection points), run `git show <hash>` to see actual changes
3. If a function is specified, use `git log -L :<function>:<file>` for function-level history
4. Read commit messages and correlate with code changes for context
5. Identify inflection points: major rewrites, architectural shifts, bug fixes, feature additions

## Output

Produce a narrative at `.claude/archaeology/history.md`:

```
## Code Archaeology: [file/function name]

### Origin
- **Created**: commit [hash] on [date] by [author]
- **Original purpose**: [what it was built for]

### Evolution Timeline
1. **[date] — [purpose/event]**: [what changed and why, citing commit message]
2. **[date] — [purpose/event]**: [what changed and why]
[Continue chronologically]

### Key Decisions
- **[Decision]**: [Why it was made, citing commit message or PR context]
- **[Decision]**: [Why it was made]

### Current State
- The code currently [does X] because of [historical reasons Y and Z]
- Trade-offs to be aware of: [list]
- If refactoring, consider: [specific recommendations based on history]

### Contributors
[List of authors who significantly shaped this code, with their main contributions]
```

Present the narrative history with:
- Chronological evolution of the code
- Key decisions and why they were made
- Patterns that emerged over time
- Current design trade-offs to be aware of

## Recommended Permissions

```json
{
  "permissions": {
    "allow": [
      "Bash(git log:*)",
      "Bash(git show:*)",
      "Bash(git blame:*)",
      "Bash(git diff:*)",
      "Bash(cat *)",
      "Bash(mkdir -p .claude/archaeology)"
    ]
  }
}
```
