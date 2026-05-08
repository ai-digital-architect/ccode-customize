---
name: install-pattern
description: >
  Installs a workflow pattern from the patterns/workflow-patterns/ catalog into the current project.
  Copies SKILL.md, agent definitions, hook scripts, and merges settings-fragment.json.
  Use to add a new Claude Code workflow pattern to any project.
argument-hint: "[pattern-name] [tier: 1|2|3]"
allowed-tools: Read, Write, Edit, Bash
---

Install workflow pattern: $ARGUMENTS

## Step 1: Locate Pattern
Find the pattern directory:
- Tier 1: `patterns/workflow-patterns/tier-1-pure-skills/<pattern-name>/`
- Tier 2: `patterns/workflow-patterns/tier-2-skill-plus-agents/<pattern-name>/`
- Tier 3: `patterns/workflow-patterns/tier-3-full-stack/<pattern-name>/`

Read `PATTERN.md` to understand what components will be installed.

## Step 2: Create Target Directories
```bash
mkdir -p .claude/skills/<skill-name>
mkdir -p .claude/agents        # if agents/ present
mkdir -p .claude/hooks         # if hooks/ present
```

## Step 3: Copy Skill
```bash
cp patterns/workflow-patterns/<tier>/<pattern>/SKILL.md .claude/skills/<skill-name>/SKILL.md
```

## Step 4: Copy Agents (Tier 2 and 3 only)
For each `agents/*.md` file in the pattern:
```bash
cp patterns/workflow-patterns/<tier>/<pattern>/agents/<agent>.md .claude/agents/<agent>.md
```

## Step 5: Copy and Enable Hooks (Tier 3 only)
For each `hooks/*.sh` file in the pattern:
```bash
cp patterns/workflow-patterns/<tier>/<pattern>/hooks/<hook>.sh .claude/hooks/<hook>.sh
chmod +x .claude/hooks/<hook>.sh
```

## Step 6: Merge Settings
Read `patterns/workflow-patterns/<tier>/<pattern>/settings-fragment.json` and merge into `.claude/settings.json`:
- Add all `permissions.allow` entries (avoid duplicates)
- Add all `permissions.deny` entries (avoid duplicates)
- Add all hook configurations under the correct lifecycle event

## Step 7: Verify Installation
1. Confirm all files exist in target locations
2. Confirm hooks are executable
3. Confirm settings.json is valid JSON
4. Present installation summary with usage instructions from PATTERN.md
