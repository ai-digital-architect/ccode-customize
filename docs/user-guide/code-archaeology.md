# Code Archaeology

## Purpose

The code archaeology skill traces the evolution of a file or function through git history and produces a narrative explaining why the code looks the way it does today. It identifies key decisions, inflection points, and contributors.

Use this skill:
- When onboarding to understand legacy code and its design rationale
- Before refactoring to understand why the current design was chosen
- To document the history of a critical component for the team

## Prerequisites

- A git repository with meaningful commit history
- The target file must be tracked in git
- Descriptive commit messages improve the quality of the narrative

## Usage

Invoke the skill with a slash command:

```
/code-archaeology [file-path] [function-name]
```

Arguments:
- `file-path` (required) -- path to the file to trace
- `function-name` (optional) -- a specific function to trace within the file

## Example

```
/code-archaeology src/services/billing.service.ts
```

This traces the full history of the billing service file, identifies major rewrites, architectural shifts, and bug fixes, and produces a chronological narrative of its evolution.

```
/code-archaeology src/services/billing.service.ts calculateTotal
```

This narrows the analysis to the `calculateTotal` function, using `git log -L` for function-level history tracking.

## Output

The skill writes a narrative to `.claude/archaeology/history.md` containing:

- **Origin** -- the commit that created the file, its date, author, and original purpose
- **Evolution Timeline** -- chronological list of significant changes with dates, purposes, and citations from commit messages
- **Key Decisions** -- architectural and design decisions with rationale drawn from commit context
- **Current State** -- what the code does today, why it looks the way it does, trade-offs to be aware of, and refactoring recommendations
- **Contributors** -- list of authors who significantly shaped the code and their main contributions

## Tips

- Use function-level tracing for large files with many unrelated changes.
- The quality of the narrative depends heavily on commit message quality. Files with descriptive commit messages produce much richer histories.
- Add recommended permissions to `.claude/settings.json`:
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
- Share the output with team members during onboarding or before design reviews.
- Run this before major refactors to avoid repeating past mistakes or undoing deliberate trade-offs.

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| "No history found" | File is not tracked in git or was just created | Verify the file has been committed at least once |
| Sparse timeline | File has very few commits | This is normal for stable code; the narrative will be shorter |
| Function-level tracking fails | Function name does not match or `git log -L` is not supported | Use the file-level trace instead and search for the function manually in the output |
| Missing contributor info | Commits were made with a shared or generic account | This is a data quality issue; supplement with team knowledge |
