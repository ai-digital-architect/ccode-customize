# Postmortem Assistant

## Purpose

The postmortem assistant skill drafts structured postmortem documents from incident data including logs, alerts, and timelines. It identifies root cause using the "5 Whys" method, surfaces contributing factors, and produces prioritized action items.

Use this skill:
- After any production incident to create a draft postmortem
- To ensure consistent postmortem format across the organization
- To accelerate the incident review process with pre-analyzed timelines

## Prerequisites

- Incident logs, alert history, or timeline data accessible as files
- This skill uses the `claude-opus-4-5` model for deeper analysis
- A git repository (optional, for correlating code changes with incidents)

## Usage

Invoke the skill with a slash command:

```
/postmortem [incident-id or log-file-path]
```

Arguments:
- An incident identifier to search for related logs, OR
- A file path to incident logs or alert data

## Example

```
/postmortem /var/log/incidents/2025-01-15-db-outage.log
```

This reads the incident log, constructs a chronological timeline, performs 5 Whys root cause analysis, assesses detection and response times, and drafts a complete postmortem document.

```
/postmortem INC-4523
```

This searches for logs and data related to incident INC-4523 and produces the same structured analysis.

## Output

The skill writes a draft postmortem to `.claude/postmortem/draft.md` with the following sections:

- **Summary** -- 2-3 sentence description of the incident, its impact, and resolution
- **Timeline** -- chronological table of events with timestamps and sources
- **Root Cause** -- 5 Whys analysis showing the chain of causation
- **Contributing Factors** -- adjacent causes that amplified the incident's impact
- **Impact** -- users affected, revenue impact, data impact, SLA breach status
- **Detection and Response** -- time to detect, time to respond, time to resolve
- **Action Items** -- prioritized table with preventive, detective, and mitigative actions
- **Lessons Learned** -- what went well, what did not, and where the team got lucky

The output uses a standard template that can be enhanced with a Stop hook for section validation.

## Tips

- Provide as much raw data as possible -- logs, alert screenshots, Slack threads -- for a more complete timeline.
- The draft status is "Pending Review" by default. Always review and refine before publishing.
- Action items are categorized as preventive (stop recurrence), detective (find faster), and mitigative (reduce impact).
- Consider adding a validation hook to ensure all required sections are present:
  ```bash
  # .claude/hooks/format-postmortem.sh
  required_sections=("Summary" "Timeline" "Root Cause" "Impact" "Action Items")
  ```

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Timeline has gaps | Missing log entries for certain time periods | Supplement with manual observations or Slack messages from the incident channel |
| Root cause analysis is shallow | Insufficient data to complete 5 Whys | Add more context about the system architecture and failure modes |
| Action items are too generic | Incident data lacks specifics about the resolution | Include details about what was done to resolve the incident |
| Missing sections in output | Template rendering issue | Re-run the skill; check that the output directory `.claude/postmortem/` is writable |
