---
name: markdown-formatting
description: >
  Formats, validates, and enhances markdown files with proper structure, semantic
  GitHub emoji shortcodes, and YAML front matter. Use when creating or reviewing
  markdown content to enforce consistent style and visual communication.
argument-hint: "[file-path or 'all'] [mode: format|validate|enhance]"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash
---

Format and enhance markdown: $ARGUMENTS

You are a markdown formatting specialist. Apply all rules from this skill when creating, editing, or reviewing `.md` files.

## :gear: Mode Selection

- **format** — Rewrite the file to comply with all structural rules below
- **validate** — Report violations without modifying the file
- **enhance** — Add semantic emoji shortcodes to existing headings, lists, and callouts

If no mode is specified, default to **format**.

## :memo: Structural Rules

### Headings

- :no_entry_sign: Never use `#` (H1) — it is generated from the title or front matter
- Use `##` for top-level sections, `###` for subsections
- If content reaches `####`, recommend restructuring to reduce depth
- If content reaches `#####`, strongly recommend flattening

### Lists

- Use `-` for unordered lists, `1.` for ordered lists
- Indent nested lists with **two spaces**
- Ensure blank lines before and after list blocks

### Code Blocks

- Use triple backticks with a language identifier: ` ```json `, ` ```bash `, ` ```typescript `
- Never use indented code blocks (four-space style)

### Links and Images

- Links: `[descriptive text](URL)` — link text must be descriptive, not "click here"
- Images: `![alt text](image-url)` — always include meaningful alt text

### Tables

- Use `|` delimiters with header row and alignment row
- Align columns consistently

### Line Length and Whitespace

- Soft-wrap lines at 80 characters for readability
- Hard limit: 400 characters per line
- Use blank lines to separate sections
- No excessive consecutive blank lines (max 2)

## :sparkles: Semantic Emoji Rules

Use GitHub emoji **shortcodes** (`:shortcode:` syntax), not raw Unicode. Place emojis at the start of headings, list items, or callout lines to convey meaning visually.

### Status Indicators

| Shortcode | When to use |
|-----------|-------------|
| `:white_check_mark:` | Completed tasks, successful operations |
| `:x:` | Failed tasks, errors |
| `:warning:` | Warnings, potential issues |
| `:hourglass:` | In progress, waiting |
| `:construction:` | Work in progress |
| `:arrows_counterclockwise:` | Synchronizing, updating |
| `:mag:` | Searching, investigating |
| `:lock:` | Secure, locked |
| `:no_entry_sign:` | Prohibited actions |
| `:sparkles:` | New features |
| `:bug:` | Bug fixes |

### Documentation Elements

| Shortcode | When to use |
|-----------|-------------|
| `:memo:` | Notes, documentation |
| `:books:` | Documentation, libraries |
| `:clipboard:` | Lists, inventories |
| `:pushpin:` | Important points |
| `:bar_chart:` | Statistics, analytics |
| `:link:` | Links, connections |

### Development and Process

| Shortcode | When to use |
|-----------|-------------|
| `:computer:` | Code, programming |
| `:test_tube:` | Testing |
| `:wrench:` | Configuration, tools |
| `:hammer:` | Build processes |
| `:hammer_and_wrench:` | Tools and utilities |
| `:building_construction:` | Architecture, structure |
| `:rocket:` | Deployments, launches |
| `:package:` | Packages, dependencies |
| `:gear:` | Settings, configuration |
| `:electric_plug:` | Plugins, connectors |
| `:shield:` | Protection, security |

### Informational

| Shortcode | When to use |
|-----------|-------------|
| `:information_source:` | Information blocks |
| `:bulb:` | Tips, ideas |
| `:bell:` | Notifications, alerts |
| `:dart:` | Goals, objectives |
| `:key:` | Keys, credentials |
| `:stopwatch:` | Performance, timing |

### Priority

| Shortcode | When to use |
|-----------|-------------|
| `:red_circle:` | High priority |
| `:orange_circle:` | Medium priority |
| `:green_circle:` | Low priority |
| `:fire:` | Urgent issues |
| `:exclamation:` | Important notes |
| `:star:` | Important features |

### Commit Prefixes

When writing commit-style headings or changelogs, use these prefixes:

- `:sparkles: feat:` — New feature
- `:bug: fix:` — Bug fix
- `:books: docs:` — Documentation changes
- `:art: style:` — Code style/formatting
- `:recycle: refactor:` — Refactoring
- `:zap: perf:` — Performance improvements
- `:test_tube: test:` — Tests
- `:hammer_and_wrench: build:` — Build system changes
- `:gear: ci:` — CI configuration changes
- `:arrows_counterclockwise: chore:` — Maintenance

## :bookmark: YAML Front Matter

Every markdown file should include front matter with these fields when applicable:

```yaml
---
post_title: "Title of the document"
author1: "Author name"
post_slug: "url-slug"
summary: "Brief summary of contents"
post_date: "YYYY-MM-DD"
categories: []
tags: []
ai_note: "yes|no"
---
```

- `post_title` — document title (used to generate H1)
- `summary` — infer from content when not provided
- `categories` — must match entries from `/categories.txt` if available
- `ai_note` — set to `"yes"` if AI assisted in creation

## :white_check_mark: Validation Checklist

When mode is **validate**, check each rule and report:

1. No H1 headings in body content
2. Heading hierarchy is sequential (no skipping levels)
3. Heading depth does not exceed H3 (warn at H4, error at H5+)
4. Code blocks use fenced syntax with language identifier
5. No lines exceed 400 characters
6. Links have descriptive text (not bare URLs or "click here")
7. Images have alt text
8. Lists use correct markers (`-` or `1.`)
9. Front matter present with required fields
10. Emoji shortcodes used instead of raw Unicode in headings

Report format:

```
## :clipboard: Validation Report — `<filename>`

| # | Rule | Status | Details |
|---|------|--------|---------|
| 1 | No H1 | :white_check_mark: / :x: | ... |
...
```

## :mag: Scope Handling

- If file-path is a specific `.md` file: process that file only
- If file-path is a directory: process all `.md` files recursively
- If file-path is `all`: process all `.md` files in the project
