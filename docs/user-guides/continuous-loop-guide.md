# :rocket: Continuous Agent Loop — User Guide

## :dart: What Is the Continuous Agent Loop?

The continuous agent loop is a development methodology where an AI coding agent
runs autonomously in an iteration cycle — executing a task, observing results
via tests and linters, and re-executing against modified state — until completion
criteria are met or a safety limit is reached.

**Key insight**: The agent's context window resets each iteration, but the
codebase persists on disk. Each iteration reads what the previous iteration
wrote, creating a feedback loop through code, tests, and plan files.

---

## :clipboard: Prerequisites

Before using the continuous loop:

1. :white_check_mark: **Claude Code CLI** installed and configured
2. :white_check_mark: **Specifications** written in `specs/` directory
3. :white_check_mark: **Git repository** initialized with a feature branch
4. :white_check_mark: **Test framework** configured and working
5. :white_check_mark: **Build tools** available (pnpm, npm, pytest, etc.)

---

## :books: Two Execution Models

### Model A — Stop Hook Loop (In-Session)

The loop runs inside a single Claude Code session. The Stop hook intercepts
exit and re-injects the prompt.

**Best for**: Tasks under ~30 iterations, attended execution

```bash
# Start the loop via the skill
claude
> /continuous-loop "Implement the authentication module per specs/auth.md"
```

### Model B — Bash Loop (Fresh Context)

Each iteration spawns a new Claude Code process with clean context.

**Best for**: 30+ iterations, overnight/unattended execution

```bash
# Start the loop via the bash runner
./loop.sh 50 PROMPT.md

# For overnight runs
nohup ./loop.sh 50 PROMPT.md &
```

| Factor | Model A (Stop Hook) | Model B (Bash Loop) |
|--------|--------------------|--------------------|
| Iteration count | < 30 | 30–500+ |
| Duration | < 2 hours | 2 hours – days |
| Context quality | Degrades with iterations | Constant (fresh) |
| Recovery from stuck states | Harder | Easier |

---

## :wrench: Step-by-Step Usage

### 1. :memo: Write Specifications

Create specification files in `specs/`:

```markdown
# specs/auth.md

## Authentication Module

### Requirements
- JWT-based authentication with refresh tokens
- Password hashing with bcrypt (cost factor 12)
- Rate limiting: 5 login attempts per minute per IP

### API Endpoints
- POST /auth/register — create new account
- POST /auth/login — authenticate and return tokens
- POST /auth/refresh — refresh access token
- POST /auth/logout — revoke refresh token

### Data Models
- User: id, email, password_hash, created_at, updated_at
- RefreshToken: id, user_id, token_hash, expires_at, revoked_at
```

### 2. :mag: Run Planning Mode

```bash
# Option A: Via skill
claude
> /plan-loop specs/

# Option B: Via bash
claude -p "$(cat PROMPT-PLAN.md)"
```

Review the generated `fix_plan.md` before proceeding.

### 3. :building_construction: Create Feature Branch

```bash
git checkout -b loop/auth-module
```

### 4. :rocket: Start the Build Loop

```bash
# Model A (in-session)
claude
> /continuous-loop "Implement authentication per specs/auth.md" --max-iterations 30

# Model B (bash loop, overnight)
nohup ./loop.sh 50 PROMPT.md &
```

### 5. :eyes: Monitor Progress

```bash
# View loop state
cat .claude/loop-state.json | jq '.'

# View recent log entries
tail -20 .claude/loop-log.txt

# View git progress
git log --oneline | head -10

# View plan progress
cat fix_plan.md
```

### 6. :no_entry_sign: Cancel If Needed

```bash
# Via skill
claude
> /cancel-loop "Agent going in circles on rate limiting"

# Via state file (for Model B)
cat .claude/loop-state.json | jq '.status = "cancelled"' > tmp.json && mv tmp.json .claude/loop-state.json
```

---

## :warning: When Things Go Wrong

| Situation | Action |
|-----------|--------|
| Agent going in circles | Stop → add "sign" to PROMPT.md → restart |
| Build completely broken | `git log` → find last green → `git reset --hard <hash>` → restart |
| Plan stale or incorrect | Stop → run planning mode → restart build loop |
| Agent burning tokens on full test suite | Add: "Run only the test file for changed code" |
| Agent producing duplicate code | Add: "Search codebase with subagents before implementing" |
| Agent writing placeholders | Add: "NO PLACEHOLDERS — full implementations only" |
| Agent dumping status in AGENTS.md | Add: "Do NOT place status reports in AGENTS.md" |

---

## :test_tube: Prompt Tuning (The Core Operator Skill)

The operator's primary job during a loop is observing failures and adding
corrective instructions — "signs for the agent":

```markdown
# Added after observing agent re-implement existing auth:
- SEARCH the codebase with 5+ subagents before implementing. Do NOT assume
  code is not implemented.

# Added after observing placeholder implementations:
- DO NOT IMPLEMENT PLACEHOLDER, STUB, or TODO implementations. Every function
  must be fully implemented with real logic.

# Added after observing context exhaustion:
- Run tests ONLY for the specific file you changed, not the entire test suite.
```

---

## :bar_chart: Overnight Execution Checklist

1. :white_check_mark: Feature branch created (`git checkout -b loop/<feature>`)
2. :white_check_mark: Specs complete and reviewed (`specs/*.md`)
3. :white_check_mark: Planning mode run and `fix_plan.md` reviewed
4. :white_check_mark: Max iterations set (recommend 30–80)
5. :white_check_mark: Backpressure hooks installed (`.claude/hooks/post-write-backpressure.sh`)
6. :white_check_mark: Safety hooks installed (`.claude/hooks/pre-bash-safety.sh`)
7. :white_check_mark: API budget has headroom
8. :white_check_mark: Loop started: `nohup ./loop.sh 50 PROMPT.md &`
9. :white_check_mark: Morning review: `git log`, `fix_plan.md`, loop logs

---

## :puzzle_piece: Integration with Other Workflows

The continuous loop composes naturally with other workflow patterns:

| Pattern | Integration |
|---------|-------------|
| **Self-reflection loop** | Used as inner quality gate within each iteration |
| **Explore-then-implement** | Planning mode = explore; Build mode = implement |
| **PR review pipeline** | Run after loop completes before merging |
| **Cost-threshold gate** | PreToolUse hook limits token spend per loop |
| **Watchdog loop** | Monitor loop health while it runs |

Install additional patterns with: `/install-pattern <pattern-name>`

---

## :bulb: Tips

- **Start small**: Begin with 10-iteration loops to calibrate your prompt
- **Feature branches always**: Never run loops on main/master
- **Specs are king**: Incomplete specs produce incomplete implementations
- **One item per iteration**: Multi-item iterations exhaust context
- **Git is your safety net**: Auto-commit on green means easy rollback
- **90% automation, 10% manual**: Expect to finish the last mile yourself
