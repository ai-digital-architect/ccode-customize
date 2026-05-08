#!/usr/bin/env bash
# Stop hook: sends notification if watchdog detected violations

violations_log=".claude/watchdog/violations.log"

if [[ ! -f "$violations_log" ]]; then
  exit 0
fi

violation_count=$(wc -l < "$violations_log")
if [[ "$violation_count" -gt 0 ]]; then
  last_violation=$(tail -1 "$violations_log")

  # Slack notification (uncomment and configure SLACK_WEBHOOK_URL env var)
  # curl -s -X POST "$SLACK_WEBHOOK_URL" \
  #   -H 'Content-Type: application/json' \
  #   -d "{\"text\": \"Watchdog alert: $violation_count violation(s). Latest: $last_violation\"}"

  echo "Watchdog: $violation_count violations detected" >> ~/.claude/notifications.log
fi

exit 0
