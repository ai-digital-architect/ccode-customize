# Claude Code Plugin Generation Specification

## Goal

You are Claude Code. Read the repository in the current working directory and produce a Claude Code **plugin** that exposes its useful capabilities as skills, agents, commands, hooks, and (where appropriate) MCP servers. The plugin must be self-contained, installable, and follow the official plugin reference.

---

## Inputs

- **Source repository**: the current working directory, or a path the user provides.
- **Plugin name** (optional): if not given, derive from the repo name (kebab-case).
- **Target directory** (optional): defaults to `./<plugin-name>/`.

## Outputs

A directory with the following layout:

```
<plugin-name>/
├── .claude-plugin/
│   └── plugin.json           # manifest — ONLY this lives here
├── commands/                 # slash commands (.md files)
├── agents/                   # subagents (.md files with frontmatter)
├── skills/                   # skill directories, each with a SKILL.md
├── hooks/                    # event hook scripts
├── scripts/                  # any shared helper scripts
├── mcp/                      # optional MCP server configs/code
└── README.md                 # install + usage instructions
```

Components live at the plugin **root**, not inside `.claude-plugin/`.

---

## Step 1 — Analyze the repository

Before generating anything, build a mental inventory:

1. **Read** `README.md`, `package.json` / `pyproject.toml` / `Cargo.toml`, top-level config, and any `docs/` directory.
2. **Identify** the repo's primary purpose in one sentence.
3. **List** the user-facing capabilities. For each, decide which plugin component fits best:

| Repo capability                                   | Map to              |
| ------------------------------------------------- | ------------------- |
| One-shot script or scaffold the user runs         | **Command**         |
| Reusable workflow with steps, examples, reference | **Skill**           |
| Multi-turn task needing isolated context          | **Agent**           |
| Lint / format / validate on file events           | **Hook**            |
| External API or live data source                  | **MCP server**      |
| Language-specific code intelligence               | **LSP server**      |

4. **Reject** capabilities that don't add value as a plugin (e.g. internal build tooling, CI-only scripts).

Write this inventory to `PLAN.md` in the working directory before creating files. Confirm with the user if the repo is ambiguous.

---

## Step 2 — Write the manifest

Create `.claude-plugin/plugin.json`:

```json
{
  "name": "<plugin-name>",
  "version": "0.1.0",
  "description": "<one-line summary derived from the repo>",
  "author": {
    "name": "<from package.json / git config>",
    "url": "<repo URL if known>"
  },
  "homepage": "<repo URL>",
  "license": "<from repo>"
}
```

Only declare custom paths (`skills`, `commands`, `agents`, `outputStyles`, `themes`, `monitors`) if you are adding directories beyond the defaults. To keep the default and add more, include both: `"skills": ["./skills/", "./extras/"]`. All paths must be relative and start with `./`.

Do **not** duplicate component definitions in both `plugin.json` and a marketplace entry — that conflicts.

---

## Step 3 — Generate components

### Commands (`commands/<name>.md`)

Plain markdown. The filename becomes the slash command (`/<plugin>:<name>`). Open with a one-line description, then the prompt body. Use `${CLAUDE_PLUGIN_ROOT}` to reference plugin-bundled scripts.

### Skills (`skills/<skill-name>/SKILL.md`)

YAML frontmatter + markdown body:

```markdown
---
name: <skill-name>
description: When Claude should invoke this skill. Be specific about triggers.
arguments:        # optional
  - name: target
    description: File or directory to operate on
tools:            # optional whitelist
  - Read
  - Write
context: fork     # optional — runs in isolated sub-agent
---

# Body

Step-by-step instructions for Claude. Reference bundled files with relative paths.
Include progressive disclosure: brief overview first, then details, then reference.md
for deep specifics.
```

Skills can include `reference.md`, `scripts/`, and any other support files alongside `SKILL.md`.

### Agents (`agents/<agent-name>.md`)

```markdown
---
name: <agent-name>
description: What this agent specializes in and when Claude should invoke it
model: sonnet            # or haiku, opus
effort: medium           # low | medium | high
maxTurns: 20
tools: [Read, Grep, Bash]
disallowedTools: [Write, Edit]
isolation: worktree      # ONLY valid value
---

Detailed system prompt: role, expertise, behavior, output format.
```

**Security restrictions** for plugin-shipped agents: `hooks`, `mcpServers`, and `permissionMode` are **not** allowed in agent frontmatter.

### Hooks (`hooks/hooks.json`)

```json
{
  "hooks": [
    {
      "event": "PostToolUse",
      "matcher": "Write|Edit",
      "type": "command",
      "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
    }
  ]
}
```

Event names are case-sensitive (`PostToolUse`, not `postToolUse`). Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`. Always reference scripts via `${CLAUDE_PLUGIN_ROOT}`.

### MCP servers

Declare in `plugin.json` under `mcpServers`. If the repo already provides one, point to its entrypoint. If not, only build one when the capability genuinely needs live external data — MCP tool definitions cost ~100–300 tokens each at session start, so prefer skills for prompt-only workflows.

---

## Step 4 — Conventions and quality bar

- **Naming**: kebab-case for plugin, skills, agents, commands. Match filenames to declared `name` fields.
- **Descriptions matter**: skill and agent `description` fields are how Claude decides to invoke them. Write them as triggers ("Use when the user wants to…"), not summaries.
- **Token discipline**: prefer skills (progressive disclosure) over MCP servers (eager loading) when either would work.
- **Idempotent hooks**: hooks may run repeatedly. Implement a "quick exit" — check for a config file, exit 0 if absent.
- **Bundled scripts**: place in `scripts/` and make executable. Always invoke via `${CLAUDE_PLUGIN_ROOT}/scripts/...`.
- **No secrets** in the manifest or committed files. Use `userConfig` to prompt at install time.

---

## Step 5 — Write the README

The plugin's `README.md` must include:

1. One-paragraph description.
2. Installation instructions (marketplace install command and/or local install path).
3. List of every command, skill, and agent with a one-line purpose.
4. Required configuration (env vars, API keys, MCP credentials).
5. Link back to the source repo.

---

## Step 6 — Validate before finishing

Run through this checklist and report results to the user:

- [ ] `.claude-plugin/plugin.json` exists and parses as valid JSON.
- [ ] No components are duplicated between `plugin.json` and external manifests.
- [ ] Every component path in the manifest exists on disk.
- [ ] All hook commands resolve and are executable.
- [ ] Every agent file has valid frontmatter and no forbidden fields (`hooks`, `mcpServers`, `permissionMode`).
- [ ] Every skill directory has a `SKILL.md` with `name` and `description`.
- [ ] Slash command names don't collide with built-ins.
- [ ] `README.md` documents every user-visible component.
- [ ] No secrets are checked in.

---

## Step 7 — Report

End with a short summary: plugin name, what was generated (counts of commands/skills/agents/hooks), what was deliberately skipped from the source repo and why, and the exact install command the user should run.

## References

- Plugins reference: https://code.claude.com/docs/en/plugins-reference
- Official examples: https://github.com/anthropics/claude-code/tree/main/plugins
