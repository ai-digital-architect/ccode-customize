#!/usr/bin/env bash
# SubagentStop hook: logs worker sub-agent completion to a shared log file
# Fires when any sub-agent stops

input=$(cat)
agent_name=$(echo "$input" | jq -r '.agent_name // "unknown"')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p .claude/fan-out-results

echo "{\"agent\": \"$agent_name\", \"completed_at\": \"$timestamp\", \"session\": \"$session_id\"}" \
  >> .claude/fan-out-results/completion-log.jsonl

exit 0
