#!/usr/bin/env bash
# SubagentStop hook: tracks map-reduce worker completions

input=$(cat)
agent_name=$(echo "$input" | jq -r '.agent_name // ""')

if [[ "$agent_name" != "mr-worker" ]]; then
  exit 0
fi

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "{\"agent\": \"$agent_name\", \"completed_at\": \"$timestamp\"}" \
  >> .claude/map-reduce/completion.jsonl

exit 0
