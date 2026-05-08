# Self-Reflection Loop

## Purpose

The self-reflection loop pattern implements code with an automated quality feedback cycle. After generating code, it invokes an independent critic agent to score the output, then iterates on improvements until the quality threshold is met. Use this when quality is critical or when implementing non-trivial features that benefit from automated review.

## Prerequisites

- **Sub-agents**: `code-critic` installed in `.claude/agents/` (configured to use claude-opus-4-5)
- **Hooks**: `check-review-score.sh` (SubagentStop) in `.claude/hooks/`, executable
- **Settings**: Hook registrations merged into `.claude/settings.json`
- **File**: `.claude/review-score.json` will be created during execution

## Architecture

The skill orchestrates a generate-critique-revise loop. The `code-critic` sub-agent is read-only (`disallowedTools: [Write, Edit, MultiEdit]`), preventing self-grading bias -- it cannot modify the code it reviews. The `check-review-score.sh` hook fires when the critic sub-agent stops. It reads `.claude/review-score.json` and if the score is below 4 out of 5, exits with code 2, blocking the stop and forcing the parent agent to revise and re-invoke the critic. This enforcement is deterministic.

## Usage

Invoke via the slash command:

```
/self-reflect [feature or task description]
```

Provide a description of the feature or task to implement with quality assurance.

## Workflow

1. **Generate**: The skill implements the requested feature or fix.
2. **Critique**: The `code-critic` sub-agent reviews all changed files and scores them across four dimensions.
3. **Evaluate**: The hook reads `.claude/review-score.json`. If the overall score is 4 or higher, the workflow proceeds to the summary. If below 4, the hook blocks and forces revision.
4. **Iterate**: Steps 2-3 repeat up to 3 times maximum. Each iteration addresses Critical and High issues from the critic.
5. **Report**: The final implementation is presented with the last critic score. If after 3 iterations the score remains below 4, outstanding issues are listed for human review.

## Scoring Rubric

The critic scores on a 1-5 scale across four dimensions:

- **Security**: Injection safety, auth checks, input validation
- **Correctness**: Edge cases, error handling, type safety
- **Maintainability**: Naming, separation of concerns, documentation
- **Test Coverage**: Key paths, edge cases, failure modes

The overall score equals the minimum of all dimension scores.

## Example

```
/self-reflect "implement JWT authentication middleware with refresh token rotation"
```

The skill generates the middleware, the critic scores it (perhaps 3/5 due to missing edge cases), the skill fixes the issues, and the critic re-scores until the threshold is met or 3 iterations are exhausted.

## Output

- Implementation source files for the requested feature
- `.claude/review-score.json` containing the final quality scores
- A summary report with the critic's assessment and any outstanding issues

## Configuration

- **Quality threshold**: The threshold of 4/5 is set in the hook. Edit `check-review-score.sh` to raise or lower it.
- **Max iterations**: The 3-iteration cap is set in the skill. Adjust in `SKILL.md` if needed.
- **Critic model**: The critic uses claude-opus-4-5 by default. Change the model in the agent definition if needed.

## Tips

- The critic is deliberately separated from the generator to avoid self-grading bias.
- Token cost per critic invocation is approximately 2,000-4,000 tokens (using Opus). Budget for up to 3 invocations.
- If the critic consistently scores below threshold, the feature may be too complex for a single pass. Consider breaking it into smaller tasks.
- Review the score dimensions to understand where quality is lacking -- the minimum-score rule means one weak dimension blocks the whole result.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Infinite revision loop | Score never reaches threshold | The 3-iteration cap prevents true infinite loops; review outstanding issues manually |
| Critic modifies code | Agent misconfigured | Verify `disallowedTools` includes Write, Edit, and MultiEdit in `code-critic.md` |
| Hook does not block | `review-score.json` missing or malformed | Check that the critic writes valid JSON to `.claude/review-score.json` |
| High token cost | Multiple Opus invocations | Reduce max iterations or lower the threshold for less critical tasks |
