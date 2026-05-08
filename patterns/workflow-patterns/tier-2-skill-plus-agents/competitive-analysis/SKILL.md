---
name: competitive-analysis
description: >
  Runs parallel research sub-agents against multiple sources or competitors
  and synthesizes findings into a structured comparison report. Use for
  technology evaluations, library comparisons, or competitive research.
argument-hint: "[topic] [target1,target2,target3]"
allowed-tools: Read, Write, Bash
---

Conduct competitive analysis: $ARGUMENTS

## Steps

1. Parse the targets from arguments (comma-separated list or infer from topic)
2. Create `.claude/analysis/` directory
3. For each target, invoke the `source-researcher` sub-agent with:
   - The target name/URL/identifier
   - The analysis criteria (features, pricing, performance, DX, community)
   - Output path: `.claude/analysis/<target-name>.json`
4. After all researchers complete, invoke the `analysis-synthesizer` sub-agent
5. Present the synthesized comparison report from `.claude/analysis/comparison-report.md`
