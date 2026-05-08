#!/usr/bin/env bash
# SubagentStop hook: reads critic score and decides whether to allow stop
# Only gates on the code-critic agent; all others pass through
# Exit 0 = allow stop; Exit 2 = block stop (force another iteration)

input=$(cat)
agent_name=$(echo "$input" | jq -r '.agent_name // ""')

# Only gate on the code-critic agent
if [[ "$agent_name" != "code-critic" ]]; then
  exit 0
fi

# Read the score file
score_file=".claude/review-score.json"
if [[ ! -f "$score_file" ]]; then
  echo '{"reason": "Critic did not produce a score file. Re-run the review."}' >&2
  exit 2
fi

overall=$(jq -r '.overall_score // 0' "$score_file")

if [[ "$overall" -lt 4 ]]; then
  issues=$(jq -r '.recommendation // "See review for details"' "$score_file")
  echo "{\"reason\": \"Score $overall/5 below threshold (need 4). $issues\"}" >&2
  # Exit 2 blocks the stop — parent agent sees this and iterates
  exit 2
fi

# Score meets threshold — allow stop
exit 0
