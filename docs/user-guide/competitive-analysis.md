# Competitive Analysis User Guide

## Purpose

The competitive-analysis pattern runs parallel research agents against multiple targets (competitors, libraries, technologies) and synthesizes findings into a structured comparison report. Use this for technology evaluations, library comparisons, or market competitive research.

## Prerequisites

The following must be installed in your project:

- **Skill**: `.claude/skills/competitive-analysis/SKILL.md`
- **Agents**: `.claude/agents/source-researcher.md`, `.claude/agents/analysis-synthesizer.md`
- **Directory**: `.claude/analysis/` must exist

## Architecture

| Component | Role |
|-----------|------|
| `competitive-analysis` skill | Orchestrates fan-out research and synthesis |
| `source-researcher` sub-agent | Researches a single target (read-only, Write/Edit disabled) |
| `analysis-synthesizer` sub-agent | Aggregates per-target findings into a comparison report (uses `claude-opus-4-5` for stronger reasoning) |

Both sub-agents have `disallowedTools: [Write, Edit, MultiEdit]`, so researchers cannot contaminate each other's output or modify project files.

## Usage

Invoke from the Claude Code prompt:

```
/competitive-analysis state management React Redux,Zustand,Jotai,MobX
```

Format: `/competitive-analysis [topic] [target1,target2,target3]`

Targets are comma-separated. If omitted, the skill will infer reasonable targets from the topic.

## Workflow

1. **Parse targets** -- The skill extracts the comma-separated target list from your arguments.
2. **Create output directory** -- `.claude/analysis/` is prepared.
3. **Fan-out research** -- For each target, a `source-researcher` sub-agent is invoked with the target name and analysis criteria (features, pricing, performance, developer experience, community).
4. **Per-target output** -- Each researcher writes its findings to `.claude/analysis/<target-name>.json`.
5. **Synthesis** -- The `analysis-synthesizer` sub-agent reads all per-target JSON files and produces a unified comparison.
6. **Report** -- The final report is saved to `.claude/analysis/comparison-report.md` and presented.

## Example

```
/competitive-analysis CSS-in-JS libraries styled-components,emotion,vanilla-extract,Panda CSS
```

Four `source-researcher` agents will each analyze one library across standard criteria. The synthesizer then produces a comparison table with recommendations.

## Output

- `.claude/analysis/<target>.json` -- One structured research file per target
- `.claude/analysis/comparison-report.md` -- Unified comparison report with feature matrix, strengths/weaknesses, and recommendations

## Tips

- Keep the target list to 3-5 items. More targets increase token costs linearly (each researcher costs 1,000-3,000 tokens).
- Be specific about the analysis topic. "Database" is too broad; "embedded database for Electron apps" gives focused results.
- The synthesizer uses `claude-opus-4-5` for higher-quality reasoning on the comparison, so it produces more nuanced trade-off analysis than a single-pass approach.
- You can re-run with different criteria by modifying the skill arguments.
- Per-target JSON files persist after the run, so you can inspect individual research results before looking at the synthesis.
- The fan-out architecture means adding more targets scales linearly in cost but does not degrade research quality per target.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Targets not parsed correctly | Ensure targets are comma-separated with no spaces after commas, or enclose the list in quotes. |
| `.claude/analysis/` directory missing | Run `mkdir -p .claude/analysis` before invoking the skill. |
| Thin research on a target | The source-researcher may lack context. Add more detail to the topic description or provide a URL/identifier for the target. |
| Synthesizer produces shallow comparison | Ensure each per-target JSON file has substantive content. Re-run individual researchers if any produced incomplete output. |
| Stale results from a previous analysis | Delete the `.claude/analysis/` directory contents before re-running, or verify you are comparing fresh output. |
