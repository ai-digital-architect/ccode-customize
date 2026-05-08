---
name: self-reflect
description: >
  Implements code with an automated quality loop. Generates code, invokes
  a critic for scoring, and iterates until score is 4/5 or higher. Use when quality
  is critical or when implementing non-trivial features.
argument-hint: "[feature or task description]"
allowed-tools: Read, Write, Edit, Bash
---

Implement with automated quality loop: $ARGUMENTS

## Workflow

1. **Generate**: Implement the requested feature/fix
2. **Critique**: Invoke the `code-critic` sub-agent on all changed files
3. **Evaluate**: Read the critic's score from `.claude/review-score.json`
   - If overall score >= 4: proceed to final summary
   - If overall score < 4: fix all Critical and High issues, then re-invoke critic
4. **Iterate**: Repeat steps 2–3 up to 3 times maximum
5. **Report**: Present the final implementation with the last critic score

If after 3 iterations the score is still < 4, present the current state
with the outstanding issues listed for human review.

## Scoring Rubric (for reference)

Score 1–5 on each dimension:
- **Security**: injection safety, auth checks, input validation
- **Correctness**: edge cases, error handling, type safety
- **Maintainability**: naming, separation of concerns, documentation
- **Test Coverage**: key paths, edge cases, failure modes

Overall score = minimum of all dimension scores.
