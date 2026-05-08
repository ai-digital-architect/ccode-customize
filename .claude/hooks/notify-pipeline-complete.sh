#!/usr/bin/env bash
# Stop hook: fires when the pipeline session completes
# Logs completion and optionally sends a Slack notification

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "[$timestamp] Sequential pipeline completed" >> ~/.claude/pipeline.log

# Optional: Slack notification (set SLACK_WEBHOOK_URL in environment)
# curl -s -X POST "${SLACK_WEBHOOK_URL}" \
#   -H 'Content-Type: application/json' \
#   -d "{\"text\": \"Sequential pipeline completed at ${timestamp}\"}"

exit 0
