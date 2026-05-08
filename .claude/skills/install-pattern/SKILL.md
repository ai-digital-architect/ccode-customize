---
name: install-pattern
description: >
  Installs a workflow pattern from the patterns/workflow-patterns/ catalog into
  the current project. Copies SKILL.md, agent definitions, hook scripts, and
  merges settings-fragment.json. Use to add a new Claude Code workflow pattern.
argument-hint: "[pattern-name] [tier: 1|2|3]"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash
---

:package: Install workflow pattern: $ARGUMENTS

## :mag: Step 1 — Locate Pattern

Find the pattern directory by searching all tiers:
- Tier 1: `patterns/workflow-patterns/tier-1-pure-skills/$1/`
- Tier 2: `patterns/workflow-patterns/tier-2-skill-plus-agents/$1/`
- Tier 3: `patterns/workflow-patterns/tier-3-full-stack/$1/`

Read `PATTERN.md` (if present) to understand what components will be installed.
Read `SKILL.md` to get the skill name from frontmatter.

## :building_construction: Step 2 — Create Target Directories

```bash
mkdir -p .claude/skills/<skill-name>
mkdir -p .claude/agents        # if agents/ directory present in pattern
mkdir -p .claude/hooks         # if hooks/ directory present in pattern
```

## :page_facing_up: Step 3 — Copy Skill

```bash
cp patterns/workflow-patterns/<tier>/<pattern>/SKILL.md .claude/skills/<skill-name>/SKILL.md
```

## :busts_in_silhouette: Step 4 — Copy Agents (Tier 2 and 3 only)

For each `agents/*.md` file in the pattern:
```bash
cp patterns/workflow-patterns/<tier>/<pattern>/agents/<agent>.md .claude/agents/<agent>.md
```

:warning: Check for naming conflicts with existing agents before copying.

## :shield: Step 5 — Copy and Enable Hooks (Tier 3 only)

For each `hooks/*.sh` file in the pattern:
```bash
cp patterns/workflow-patterns/<tier>/<pattern>/hooks/<hook>.sh .claude/hooks/<hook>.sh
chmod +x .claude/hooks/<hook>.sh
```

## :gear: Step 6 — Merge Settings

Read `settings-fragment.json` from the pattern and merge into `.claude/settings.json`:
- Add all `permissions.allow` entries (avoid duplicates)
- Add all `permissions.deny` entries (avoid duplicates)
- Add hook configurations under the correct lifecycle event key
- Preserve existing settings — do NOT overwrite them

## :white_check_mark: Step 7 — Verify Installation

1. Confirm all files exist in target locations
2. Confirm hooks are executable (`ls -la .claude/hooks/`)
3. Confirm `.claude/settings.json` is valid JSON (`cat .claude/settings.json | jq '.'`)
4. Present installation summary:
   - Files installed (with paths)
   - Skill invocation command (`/<skill-name>`)
   - Agents added
   - Hooks registered
   - Settings merged
5. Show usage instructions from PATTERN.md

## :arrows_counterclockwise: Idempotency

This installation is idempotent — running it multiple times for the same pattern
will overwrite existing files with the latest versions without creating duplicates.
Settings merging checks for existing entries before adding new ones.
