# Skill-Creator Prompts for Agent-Consumed Skills

## Three Modes, Not Two

The original framing of "human skill vs agent skill" is incomplete. There are
three configurations, and choosing the wrong one produces a skill that either
confuses developers or breaks workflows:

```
Human-only    Consumed exclusively by people in conversation.
              Output is prose. Clarifying questions are fine.
              → Covered in skill-creator-prompts.md

Agent-only    Consumed exclusively by an autonomous agent or
              workflow pipeline. No human in the loop at execution time.
              Output is tool calls and files.
              → Prompt A-Agent and Prompt B-Agent in this document

Dual-mode     A single SKILL.md that serves both consumers.
              Detects its context at runtime and branches accordingly.
              → Prompt A-Dual and Prompt B-Dual in this document
```

This document covers agent-only and dual-mode. For human-only skills,
see `skill-creator-prompts.md`.

---

## The Decision: Which Mode?

Before writing any prompt, decide which configuration applies.

**Use agent-only when:**
- The skill will exclusively run inside a workflow pipeline or autonomous agent
- No developer will ever interact with it conversationally
- The orchestrator always injects it — keyword triggering is irrelevant
- The behavioral contract (no questions, write artifacts, exit cleanly) would
  read strangely in a conversation
- You want an independent release cycle from any human-facing skill

**Use dual-mode when:**
- A developer in Claude Code might ask questions AND trigger autonomous tasks
  from the same skill — switching between "explain canary deployment" and
  "create the pipeline now" in the same session
- The shared knowledge base is large (>50% of content is identical across modes)
  — CLI reference, YAML patterns, correctness invariants, anti-pattern rules
- Keeping one file in sync is cheaper than keeping two files consistent

**Stay with two separate skills when:**
- The agent is always injected (description optimization is wasted effort for it)
- Shared content is less than 50% (more to maintain than to save)
- The two consumers have different release cycles or different owning teams

---

## The Five Structural Differences

Understanding these is prerequisite to using any prompt below.

### 1. Triggering vs dispatch

**Human:** User types something. Claude keyword/intent-matches it against
skill descriptions. The description should say what the *user says*.

**Agent (Claude Code):** Agent is mid-task. It decides whether this skill
covers the work it is currently doing. The description should say what the
*agent is doing*.

**Agent (injected/routed):** The orchestrator injects the skill or routes
to this agent programmatically. Triggering does not apply. The description
becomes documentation, not a trigger mechanism.

### 2. What counts as output

**Human:** Well-formed text the user reads and acts on.

**Agent:** Tool calls that leave artifacts on disk — files written, commands
run, state changed. The "output" is what the agent leaves behind.

This makes assertion character completely different:

```
Human assertion:  "Response includes a harness-cli create command"
                   → checked by reading text

Agent assertion:  "bash_tool was called with --dry-run before the live create"
                   → checked from tool call log order
                  "File outputs/result.json exists with status field"
                   → checked programmatically
```

### 3. Elicitation

**Human:** Can ask clarifying questions. Natural and expected.

**Agent:** Cannot ask. Must specify: infer from this signal, use this default,
or fail with a structured error the orchestrator can handle. Interactive
clarification breaks the loop and may not be technically possible.

### 4. Verification

**Human:** The user verifies visually.

**Agent:** Must self-verify after each significant step — exit code, file
existence, required fields present. The skill must specify what to check and
what to do when the check fails.

### 5. Completion signal

**Human:** Response ends when the text ends.

**Agent:** Must signal completion in a machine-readable way the orchestrator
can parse to determine success, handle failure, and route the next step.

---

---

# PROMPT A — Agent-Only (Complete Template)

Use when the skill is exclusively consumed by autonomous agents or workflow
pipelines. No human in the loop at execution time.

---

```
I want to create a new agent-only skill.
Skip the clarification interview — I have provided all context below.
Go straight to drafting SKILL.md, then propose agent-mode test cases.

──────────────────────────────────────────────────────────────────────
SKILL IDENTITY
──────────────────────────────────────────────────────────────────────

Name:         <skill-identifier-in-kebab-case>
Domain:       <one sentence — what problem space this skill covers>
One-liner:    <what the agent will be able to do with this skill>

──────────────────────────────────────────────────────────────────────
DISPATCH MODEL
──────────────────────────────────────────────────────────────────────

Model:        [choose one]
  keyword-triggered   Agent sees a skill list and decides when to load it.
                      Trigger when the AGENT IS DOING:
                        - <task type 1>
                        - <task type 2>
                      NOT when doing:
                        - <exclusion 1>

  injected            Orchestrator injects directly into agent system prompt.
                      Triggering does not apply. Write the description as
                      documentation of what this agent does. Skip run_loop.py.

  routed              Orchestrator classifies task type and routes here.
                      Triggering does not apply. Skip run_loop.py.

──────────────────────────────────────────────────────────────────────
TOOL INTERFACE  (external CLI / API / system the skill wraps)
──────────────────────────────────────────────────────────────────────

Tool name:     <tool-name>
Install:       <install command>
Auth:          <env vars, config file, token format>

Command syntax rule:
  <State the fundamental pattern. This becomes a correctness invariant.
   Example: "Verb first, resource type second — always.
   CORRECT: tool-name <verb> <resource>
   INCORRECT: tool-name <resource> <verb>  (does not exist)">

Key commands the skill must use:
  <8-15 correct examples with exact syntax>

Commands that do NOT exist — never generate these:
  <List wrong-syntax variants so the skill never generates them>

──────────────────────────────────────────────────────────────────────
EXECUTION CONTEXT
──────────────────────────────────────────────────────────────────────

Tools available:
  - bash_tool       Execute shell commands; exit code 0 = success
  - create_file     Write new files to filesystem
  - str_replace     Edit existing files in place
  - view            Read files and directory listings
  <add or remove tools as appropriate>

Working directories:
  - <path>          <purpose — e.g., /home/claude/ for generated files>
  - <path>          <purpose — e.g., /mnt/user-data/outputs/ for deliverables>

Prior state the skill CAN assume:
  - <what is guaranteed to exist when this skill fires>
  - <env vars set, files present, dependencies installed>

Prior state the skill CANNOT assume:
  - <what may be absent and must be handled>
  - <what the skill must check for before using>

──────────────────────────────────────────────────────────────────────
PRIMARY USE CASES  (input → steps → output, not conversational exchange)
──────────────────────────────────────────────────────────────────────

1. <Use case name>
   Inputs available:
     - <env vars, files, task description string>
   Steps the skill must execute:
     1. <Step with tool call>
     2. <Verify: what to check after step 1>
     3. <Next step>
     ...
     N. Write completion artifact: outputs/<task>-result.json
   Completion: <what result.json contains on success>
   On failure: <what to do — write failed artifact, cleanup, exit>

2. <Use case name>
   Inputs available: ...
   Steps: ...

──────────────────────────────────────────────────────────────────────
OUTPUT CONTRACT
──────────────────────────────────────────────────────────────────────

The agent MUST:
  - Run <tool> --dry-run BEFORE every live create/update call
  - Verify each bash_tool exit code (0 = success) before proceeding
  - Write outputs/<task-name>-result.json as the FINAL step, always
    (on both success and failure — the orchestrator must always find it)
  - Log structured progress: {"step": N, "action": "...", "status": "..."}

The agent MUST NOT:
  - Prompt the user interactively under any circumstances
  - Proceed past a failed validation/dry-run
  - Leave partial state without a cleanup step on failure
  - <domain-specific prohibition — e.g., "use resource-first CLI syntax">
  - <domain-specific prohibition — e.g., "reference MCP servers or harness-mcp-v2">

──────────────────────────────────────────────────────────────────────
NO-ELICITATION POLICY
──────────────────────────────────────────────────────────────────────

This skill runs autonomously. Never ask the user for input. For each
potentially missing or ambiguous input, apply these resolution rules:

  <input_name>:      <how to infer or what default to use>
  <input_name>:      <inference rule>
  ...

If a required input cannot be resolved by any rule:
  - Do NOT proceed with the main task
  - Write a structured failure artifact immediately:
    {"status": "failed", "reason": "missing_required_input",
     "missing": "<input_name>", "resolution": "<how to provide it>"}
  - Exit cleanly — no stack traces, no interactive prompts

──────────────────────────────────────────────────────────────────────
COMPLETION SIGNAL
──────────────────────────────────────────────────────────────────────

Final artifact: outputs/<task-name>-result.json

Schema:
{
  "status":       "success" | "failed" | "partial",
  "task":         "<task identifier>",
  "timestamp":    "<ISO 8601>",
  "resource_id":  "<created/updated resource identifier, if applicable>",
  "resource_url": "<UI or API URL to the resource, if available>",
  "artifacts":    ["<relative paths of files written to outputs/>"],
  "error":        "<error message if status is failed, else null>",
  "next_steps":   ["<optional hints for the orchestrator or next agent>"]
}

Write this file as the absolute last step, regardless of outcome.
On failure mid-execution, still write it with status="failed".

──────────────────────────────────────────────────────────────────────
CORRECTNESS INVARIANTS
──────────────────────────────────────────────────────────────────────

These are objectively wrong if violated — not style issues.
Every eval assertion must check for each of these.

1. <Invariant — e.g., "Verb-first CLI syntax. tool-name <resource> <verb>
   does not exist and must never appear in skill output.">
2. <Invariant — e.g., "--dry-run always precedes a live create or update call">
3. <Invariant — e.g., "Completion artifact always written, success or failure">
4. <Invariant — e.g., "No interactive prompts issued under any circumstances">

──────────────────────────────────────────────────────────────────────
EXTENSIONS  (if needed)
──────────────────────────────────────────────────────────────────────

Extension 1: extensions/<name>/<NAME>.md
  Load when: <narrow, explicit condition — be specific>
  Contains:  <org-specific runbooks, config, policy templates>

──────────────────────────────────────────────────────────────────────
SKILL BODY STRUCTURE
──────────────────────────────────────────────────────────────────────

Target structure for SKILL.md:

Section 1 — Tool interface and auth (always loaded)
  <what goes here>

Section 2 — Execution contract
  No-elicitation policy and resolution rules
  Verification steps and failure handling

Section 3 — Task runbooks (one per primary use case)
  <Step-by-step procedures with exact tool calls>
  → Load references/runbook-<usecase>.md for detailed steps

Section 4 — Completion signal and error catalog
  Artifact schema
  Known error codes and recovery actions

Target lengths:
  SKILL.md: ~300 lines (runbooks kept short; detail in references/)
  Each reference runbook: ~150-200 lines

──────────────────────────────────────────────────────────────────────
TEST CASE SEEDS  (task specs, not conversational prompts)
──────────────────────────────────────────────────────────────────────

Expand these into evals/evals-agent.json with programmatic assertions.

1. Task: <task-identifier>
   Starting context:
     - <files present in working directory>
     - <env vars set>
     - <prior state>
   Task description: "<the instruction string the orchestrator provides>"
   Expected tool call sequence:
     - view <path>
     - create_file <path>
     - bash_tool: <exact command>
     - create_file outputs/<task>-result.json
   Expected artifacts:
     - <file path> with <content description>
     - outputs/result.json with status="success"
   Assertions (all programmatic):
     - <file> exists at <path>
     - result.json .status == "success"
     - <tool call> preceded <other tool call> in log
     - No interactive prompts issued

2. Task: <failure-path-task>
   Starting context: <missing required input scenario>
   Task description: "<ambiguous or underspecified instruction>"
   Expected: skill writes failed artifact and exits without main execution
   Assertions:
     - result.json exists with status="failed"
     - result.json .reason describes the missing input
     - Main task tool calls were NOT made
     - No interactive prompts issued

──────────────────────────────────────────────────────────────────────
EVAL STRATEGY
──────────────────────────────────────────────────────────────────────

Eval file:   evals/evals-agent.json
Grading:     Programmatic — file existence, JSON parsing, tool call log order
Baseline:    No skill
Target:      >=80% pass rate on tool/file assertions
             100% pass rate on "no interactive prompts" assertion
             100% pass rate on completion artifact assertion

Triggering:
  If keyword-triggered: run description optimization (run_loop.py) after
    content quality reaches target. Use agent-phrased trigger queries.
  If injected or routed: skip run_loop.py. Description is documentation only.

QUALITY.md:
  Single benchmark table (agent mode only).
  Minimum release bar: >=80% overall; 100% on no-prompts and artifact assertions.
```

---

---

# PROMPT A — Dual-Mode (Complete Template)

Use when one SKILL.md must serve both an interactive developer in Claude Code
and an autonomous agent or workflow pipeline.

---

```
I want to create a dual-mode skill. It must serve two consumers from a
single SKILL.md and detect which mode applies at runtime.
Skip the clarification interview — I have provided all context below.
Go straight to drafting SKILL.md, then propose both human and agent test cases.

──────────────────────────────────────────────────────────────────────
SKILL IDENTITY
──────────────────────────────────────────────────────────────────────

Name:         <skill-identifier-in-kebab-case>
Domain:       <one sentence>
One-liner:    <what this skill enables — covers both consumers>

──────────────────────────────────────────────────────────────────────
SKILL MODE
──────────────────────────────────────────────────────────────────────

This is a dual-mode skill. One SKILL.md, two consumers:

Mode 1 — Human (conversational)
  Consumer:  A developer using Claude Code interactively
  Trigger:   Keyword/intent match against description
  Behavior:  Conversational; clarifying questions allowed; produces
             explanatory prose with examples and CLI commands

Mode 2 — Agent (autonomous)
  Consumer:  Autonomous agent in Claude Code agentic mode, or a
             custom workflow agent with the skill injected
  Trigger:   Keyword match (Claude Code) OR injected by orchestrator
  Behavior:  Runbook-style; no interactive prompts; produces files
             and a structured completion artifact; self-verifies

Content split:
  Shared (~<N>%):   <list — CLI reference, YAML patterns, invariants, etc.>
  Human-only:       Conversational format, clarifying questions, examples
  Agent-only:       No-elicitation policy, tool sequence, completion artifact

──────────────────────────────────────────────────────────────────────
MODE DETECTION HEURISTICS
──────────────────────────────────────────────────────────────────────

The skill detects its mode using these signals in priority order:

1. Explicit env var (highest confidence):
   <SKILL_NAME>_AGENT_MODE=true → agent mode
   Not set → check next signal

2. Tool availability:
   bash_tool AND create_file both available → likely agent mode
   Conversational context only → human mode

3. Request structure:
   Structured task spec with file paths, env vars, artifact requirements → agent
   Natural language question or request → human

4. Fallback:
   Default to human mode when ambiguous.
   Agent mode activates only on clear signals. A human accidentally entering
   agent mode gets a failure artifact instead of an explanation — that is the
   worse failure direction.

──────────────────────────────────────────────────────────────────────
TOOL INTERFACE
──────────────────────────────────────────────────────────────────────

Tool name:     <tool-name>
Install:       <install command>
Auth:          <env vars, config file, token format>

Command syntax rule:
  <State the rule explicitly. Applies in BOTH modes — it is a
   correctness invariant regardless of who is consuming the skill.>

Key commands:
  <8-15 correct examples>

Commands that do NOT exist:
  <Wrong-syntax variants to never generate>

──────────────────────────────────────────────────────────────────────
EXECUTION CONTEXT  (agent mode)
──────────────────────────────────────────────────────────────────────

Tools available in agent mode:
  - bash_tool, create_file, str_replace, view
  <add or remove as appropriate>

Working directories:
  - <path>    <purpose>

Prior state CAN assume:
  - <what is guaranteed when this skill fires in agent mode>

Prior state CANNOT assume:
  - <what may be absent and must be handled>

──────────────────────────────────────────────────────────────────────
PRIMARY USE CASES
──────────────────────────────────────────────────────────────────────

Each use case has a human face and an agent face.

1. <Use case name>

   Human face:
     User says: "<example prompt>"
     Skill should: <conversational exchange — clarify, explain, show YAML>

   Agent face:
     Inputs: <env vars, files, task string>
     Steps:
       1. <tool call>
       2. Verify: <what to check>
       3. <next step>
       N. Write outputs/<task>-result.json
     On failure: <artifact + cleanup>

2. <Use case name>
   ...

──────────────────────────────────────────────────────────────────────
OUTPUT CONTRACT — HUMAN MODE
──────────────────────────────────────────────────────────────────────

Every human-mode response MUST:
  - Include at least one CLI command with correct syntax
  - Show complete configuration examples (not pseudocode)
  - Ask clarifying questions when the request is ambiguous
  - <domain-specific requirement>

Every human-mode response MUST NOT:
  - Write files to the filesystem without being explicitly asked
  - <domain-specific prohibition — e.g., reference MCP servers>
  - <domain-specific prohibition — e.g., resource-first CLI syntax>

──────────────────────────────────────────────────────────────────────
OUTPUT CONTRACT — AGENT MODE
──────────────────────────────────────────────────────────────────────

Every agent-mode execution MUST:
  - Run --dry-run BEFORE every live create or update call
  - Verify each bash_tool exit code before proceeding
  - Write outputs/<task-name>-result.json as the final step
  - Log {"step": N, "action": "...", "status": "..."} at each major step

Every agent-mode execution MUST NOT:
  - Prompt the user interactively under any circumstances
  - Proceed past a failed dry-run
  - Leave partial state without cleanup on failure
  - <correctness invariant — applies in both modes>

──────────────────────────────────────────────────────────────────────
NO-ELICITATION POLICY  (agent mode only)
──────────────────────────────────────────────────────────────────────

Never ask the user for input in agent mode. Resolution rules:

  <input>:   <how to infer or what default to use>
  <input>:   <inference rule>

If required input cannot be resolved:
  - Write failure artifact: {"status": "failed", "reason": "missing_required_input",
    "missing": "<name>", "resolution": "<how to provide it>"}
  - Exit cleanly

──────────────────────────────────────────────────────────────────────
COMPLETION SIGNAL  (agent mode only)
──────────────────────────────────────────────────────────────────────

outputs/<task-name>-result.json:
{
  "status":       "success" | "failed" | "partial",
  "task":         "<task identifier>",
  "timestamp":    "<ISO 8601>",
  "resource_id":  "<identifier of created/updated resource>",
  "resource_url": "<UI or API URL>",
  "artifacts":    ["<files written>"],
  "error":        "<message if failed, else null>",
  "next_steps":   ["<optional orchestrator hints>"]
}

──────────────────────────────────────────────────────────────────────
CORRECTNESS INVARIANTS  (both modes)
──────────────────────────────────────────────────────────────────────

1. <Invariant that applies in both modes — e.g., CLI syntax rule>
2. <Invariant — e.g., no MCP server references>
Agent-mode only:
3. <Invariant — e.g., dry-run before every live create/update>
4. <Invariant — e.g., completion artifact always written>
5. <Invariant — e.g., no interactive prompts under any circumstances>

──────────────────────────────────────────────────────────────────────
EXTENSIONS
──────────────────────────────────────────────────────────────────────

Extension 1: extensions/<name>/<NAME>.md
  Load when: <narrow trigger — same in both modes>
  Contains:  <org-specific content>

──────────────────────────────────────────────────────────────────────
SKILL BODY STRUCTURE
──────────────────────────────────────────────────────────────────────

Section 1 — Shared (always loaded, both modes)
  <tool auth, key commands, YAML patterns, anti-patterns, invariants>

Section 2 — Mode detection
  Detection heuristics and fallback rule

Section 3 — Human mode
  Entry points, conversational format, when to ask questions
  → Load references/human-guide.md for depth

Section 4 — Agent mode
  No-elicitation policy, execution contract, completion schema
  → Load references/agent-runbook.md for task runbooks

Target lengths:
  SKILL.md: ~400 lines
  human-guide.md: ~200 lines
  agent-runbook.md: ~200 lines

──────────────────────────────────────────────────────────────────────
DESCRIPTION AND TRIGGERING
──────────────────────────────────────────────────────────────────────

Description structure (two clauses in one string):
  Clause 1 — Human triggering: what a developer says when they need this skill
    Keywords: <list terms a human would use>
  Clause 2 — Agent triggering: what task context an agent would be in
    Keywords: <list task-type terms an agent would recognize>

Description optimization (run_loop.py):
  Run against evals-trigger.json (human trigger queries only).
  Verify agent triggering manually by running agent evals and
  confirming agent-mode behavior activates.

──────────────────────────────────────────────────────────────────────
TEST CASE SEEDS
──────────────────────────────────────────────────────────────────────

HUMAN SEEDS → evals/evals-human.json (prose + YAML assertions)

H1. "<natural language user request>"
    Expected: <prose description — YAML present, CLI command shown, etc.>

H2. "<natural language request covering anti-patterns or analysis>"
    Expected: <description>

H3. "<natural language request covering template or governance>"
    Expected: <description>

AGENT SEEDS → evals/evals-agent.json (programmatic assertions)

A1. Task: <task-identifier> (happy path)
    Starting context:
      - <files present>
      - <env vars set, including <SKILL>_AGENT_MODE=true>
    Task description: "<instruction string>"
    Expected tool call sequence:
      view → create_file <artifact> → bash --dry-run → bash live → create_file result.json
    Assertions:
      - <artifact> exists
      - dry-run called before live create (log order)
      - result.json exists with status="success"
      - No interactive prompts

A2. Task: <failure-path> (missing input)
    Starting context: <absent required input>
    Expected: failure artifact written immediately, no main execution
    Assertions:
      - result.json exists with status="failed"
      - result.json .reason describes missing input
      - Main task tool calls NOT made
      - No interactive prompts

──────────────────────────────────────────────────────────────────────
EVAL STRATEGY
──────────────────────────────────────────────────────────────────────

Run human and agent evals in SEPARATE iterations.
Grading criteria are incompatible — do not mix them.

evals-human.json:
  Grading: prose/text assertions; qualitative where needed
  Baseline: no skill
  Target: >=75% pass rate, >=+30pp lift over baseline

evals-agent.json:
  Grading: programmatic — file existence, JSON parsing, tool call log
  Baseline: no skill
  Target: >=80% overall; 100% on no-prompts and artifact assertions

evals-trigger.json:
  20 queries (10 should-trigger, 10 should-not-trigger)
  Run via run_loop.py for human triggering optimization only
  Verify agent triggering manually from A1/A2 results

QUALITY.md:
  Two separate benchmark tables (human mode + agent mode)
  Two separate release bars
```

---

---

# PROMPT B — Evaluate Agent-Only Skill

---

```
I have an agent-only skill drafted. Run the evaluation loop.
Skip creation — go straight to running evals.

──────────────────────────────────────────────────────────────────────
SKILL LOCATION
──────────────────────────────────────────────────────────────────────

Skill path: <path/to/skill-directory/>
Eval file:  <path/to/evals/evals-agent.json>  (or "none — please draft evals")

──────────────────────────────────────────────────────────────────────
WHAT THIS SKILL DOES
──────────────────────────────────────────────────────────────────────

<2-3 sentences. What autonomous task does it execute, what tool does it
wrap, what are the 2-3 primary operations it performs?>

──────────────────────────────────────────────────────────────────────
CORRECTNESS INVARIANTS
──────────────────────────────────────────────────────────────────────

Every eval assertion must check for each of these.

1. <e.g., "Verb-first CLI syntax. tool-name resource verb does not exist.">
2. <e.g., "--dry-run always precedes a live create or update call.">
3. <e.g., "Completion artifact always written, on success and on failure.">
4. <e.g., "No interactive prompts issued under any circumstances.">

──────────────────────────────────────────────────────────────────────
KNOWN WEAKNESSES
──────────────────────────────────────────────────────────────────────

<2-5 specific issues. Agent-specific patterns to watch for:>
  - Skill issues interactive prompts or "ask the user" language
  - Missing dry-run before live API calls
  - No verification step after tool calls
  - Completion artifact absent or missing required fields
  - Non-idempotent operations (running twice breaks things)
  - Stack traces exposed instead of structured failure artifact
  - Assumes specific directory structure without checking first
  - Partial state left on failure with no cleanup

──────────────────────────────────────────────────────────────────────
EVALUATION PRIORITIES
──────────────────────────────────────────────────────────────────────

Release blockers (must be 100%):
  - All evals: no interactive prompts issued
  - All evals: completion artifact written regardless of outcome
  - All evals: dry-run executed before every live create/update

Quality bar (target >=80%):
  - Correct tool call sequence (right order, right args)
  - result.json has all required fields
  - Failure path writes failed artifact with resolution hint

Timing gate (flag, don't block):
  Flag any eval where with-skill runs >2x longer than baseline.
  Skills should make agents faster and more correct, not slower.

──────────────────────────────────────────────────────────────────────
ASSERTION STYLE
──────────────────────────────────────────────────────────────────────

All assertions must be programmatically verifiable. Write scripts, not
qualitative checks.

Preferred:
  ✓ "File outputs/result.json exists"
  ✓ "result.json .status == 'success'"
  ✓ "artifact.yaml contains at least N <element>"
  ✓ "bash_tool called with --dry-run before live create (check log order)"
  ✓ "No call to any interactive input mechanism"

Avoid:
  ✗ "The agent explains what it is doing clearly"
  ✗ "The YAML includes appropriate comments"
  ✗ "The response is accurate"

──────────────────────────────────────────────────────────────────────
ITERATION GUIDANCE
──────────────────────────────────────────────────────────────────────

Iterations before pausing for review: 1
Target overall pass rate: >=80%
Additional evals to add: <prompts or "none">

──────────────────────────────────────────────────────────────────────
TRIGGERING
──────────────────────────────────────────────────────────────────────

Dispatch model: <keyword-triggered | injected | routed>

If keyword-triggered:
  After content quality reaches target, run description optimization:
  run_loop.py against evals-trigger.json
  Use agent-task-phrased queries (what the agent is doing, not what
  the user said).

If injected or routed:
  Skip run_loop.py. Description is documentation, not a trigger.

──────────────────────────────────────────────────────────────────────
QUALITY.md AND PACKAGING
──────────────────────────────────────────────────────────────────────

Before packaging:
  1. Copy aggregate pass rates into QUALITY.md (single agent benchmark table)
  2. Fill in iteration log and completion artifact coverage row
  3. Run package_skill.py — QUALITY.md bundled, evals/ excluded

QUALITY.md location: <path>
```

---

---

# PROMPT B — Evaluate Dual-Mode Skill

---

```
I have a dual-mode skill drafted. Run the evaluation loop.
Skip creation — go straight to running evals on both modes.

──────────────────────────────────────────────────────────────────────
SKILL LOCATION
──────────────────────────────────────────────────────────────────────

Skill path:        <path/to/skill-directory/>
Human eval file:   evals/evals-human.json
Agent eval file:   evals/evals-agent.json
Trigger eval file: evals/evals-trigger.json (for run_loop.py)

──────────────────────────────────────────────────────────────────────
WHAT THIS SKILL DOES
──────────────────────────────────────────────────────────────────────

<2-3 sentences covering both modes — what the human does with it and
what the agent does with it, what tool it wraps, primary operations.>

──────────────────────────────────────────────────────────────────────
CORRECTNESS INVARIANTS  (both modes)
──────────────────────────────────────────────────────────────────────

Shared (checked in every eval regardless of mode):
1. <e.g., "Verb-first CLI syntax in all responses and tool calls">
2. <e.g., "No MCP server references">

Agent-mode only (checked in agent evals):
3. <e.g., "--dry-run before every live create/update">
4. <e.g., "Completion artifact always written">
5. <e.g., "No interactive prompts">

──────────────────────────────────────────────────────────────────────
KNOWN WEAKNESSES
──────────────────────────────────────────────────────────────────────

Human mode:
  <e.g., template examples use pipeline-level vars instead of stage vars>

Agent mode:
  <e.g., missing dry-run; no completion artifact; issues prompts>

Mode detection:
  <e.g., detection triggers agent mode too aggressively; unclear fallback>

──────────────────────────────────────────────────────────────────────
EVALUATION PRIORITIES
──────────────────────────────────────────────────────────────────────

Run human and agent evals in SEPARATE iterations. Grading criteria
are incompatible — do not mix.

Human mode must pass (release blockers):
  - <eval name>: <why it is a release blocker>

Human mode quality bar (target >=75%):
  - <eval name>: <what correct looks like>

Agent mode must pass (100% required):
  - All agent evals: no interactive prompts
  - All agent evals: completion artifact written

Agent mode quality bar (target >=80%):
  - <eval name>: correct tool call sequence and order
  - <eval name>: result.json has all required fields

Mode detection validation:
  - H1 (human eval): must NOT trigger agent mode
  - A1 (agent eval): must trigger agent mode
  - These are the two most important mode detection checks

──────────────────────────────────────────────────────────────────────
ASSERTION STYLE
──────────────────────────────────────────────────────────────────────

Human evals: text/prose assertions acceptable where programmatic is not
  possible, but prefer text search over qualitative reading.

Agent evals: programmatic only.
  ✓ File exists at expected path
  ✓ JSON field equals expected value
  ✓ Tool call appears before other tool call in log
  ✓ No interactive input mechanism invoked

For the grader: write scripts for agent assertions, not manual reads.

──────────────────────────────────────────────────────────────────────
ITERATION GUIDANCE
──────────────────────────────────────────────────────────────────────

Iteration approach:
  1. Run human evals first (evals-human.json), review, fix
  2. Run agent evals (evals-agent.json), review, fix
  3. Verify mode detection using one H1 and one A1 seed
  4. Run description optimization (run_loop.py) against evals-trigger.json

Iterations per eval set before pausing for review: 1
Targets:
  Human: >=75% pass rate, >=+30pp lift
  Agent: >=80% overall; 100% on no-prompts and artifact assertions

──────────────────────────────────────────────────────────────────────
QUALITY.md AND PACKAGING
──────────────────────────────────────────────────────────────────────

QUALITY.md must contain TWO benchmark tables — one per mode.
Two separate minimum release bars.
Both tables must be filled before packaging.

Before packaging:
  1. Fill human benchmark table from benchmark.md (human iteration)
  2. Fill agent benchmark table from benchmark.md (agent iteration)
  3. Fill iteration log (one entry per iteration per mode)
  4. Fill extension coverage table and triggering accuracy row
  5. Run package_skill.py — QUALITY.md bundled, evals/ excluded

QUALITY.md location: <path>
```

---

---

# COMPLETED EXAMPLE — harness-platform-expert (Dual-Mode, Prompt A)

---

```
I want to create a dual-mode skill. It must serve both an interactive
developer in Claude Code and an autonomous pipeline agent from a single
SKILL.md. Skip the clarification interview. Go straight to drafting SKILL.md,
then propose both human and agent test cases.

──────────────────────────────────────────────────────────────────────
SKILL IDENTITY
──────────────────────────────────────────────────────────────────────

Name:       harness-platform-expert
Domain:     Harness CI/CD platform — pipeline design, governance, deployment
One-liner:  Help developers create and govern Harness pipelines interactively,
            or autonomously build and register pipelines as part of a CI/CD
            workflow — both using harness-cli

──────────────────────────────────────────────────────────────────────
SKILL MODE
──────────────────────────────────────────────────────────────────────

Dual-mode. One SKILL.md, two consumers:

Mode 1 — Human (conversational)
  Consumer:  Developer using Claude Code interactively
  Trigger:   Keyword match — "Harness pipeline", "CI/CD", "anti-pattern",
             "canary", "harness-cli", "OPA policy", "template", "deploy"
  Behavior:  Conversational; clarifying questions allowed; produces explanatory
             prose, YAML examples, and harness-cli commands to copy-run

Mode 2 — Agent (autonomous)
  Consumer:  Claude Code in agentic mode, or a custom workflow agent
  Trigger:   Keyword match (Claude Code) OR injected by orchestrator
  Behavior:  Runbook; no interactive prompts; writes pipeline.yaml and
             a structured completion artifact; self-verifies each step

Content split:
  Shared (~70%): harness-cli auth + commands, YAML schema, anti-patterns,
                 deployment strategies, OPA fundamentals, correctness invariants
  Human-only:    Three entry points, conversational format, clarifying questions
  Agent-only:    No-elicitation policy, execution contract, completion artifact

──────────────────────────────────────────────────────────────────────
MODE DETECTION HEURISTICS
──────────────────────────────────────────────────────────────────────

Detect mode using these signals in priority order:

1. Env var (highest confidence):
   HARNESS_AGENT_MODE=true → agent mode
   Not set → check next signal

2. Tool availability:
   bash_tool AND create_file both available → likely agent mode
   Conversational context only → human mode

3. Request structure:
   Structured task spec with file paths and env vars → agent
   Natural language question or request → human

4. Fallback:
   Default to human mode. A human entering agent mode by accident gets
   a failure artifact instead of a response — the worse failure direction.

──────────────────────────────────────────────────────────────────────
TOOL INTERFACE
──────────────────────────────────────────────────────────────────────

Tool name: harness-cli
Install:   pip install harness-cli  OR  pipx install harness-cli
Auth:
  Required: export HARNESS_API_KEY="pat.<accountId>.<tokenId>.<secret>"
  Optional: HARNESS_ACCOUNT_ID, HARNESS_BASE_URL, HARNESS_ORG,
            HARNESS_PROJECT, HARNESS_TOOLSETS

Command syntax rule:
  VERB FIRST, RESOURCE TYPE SECOND — ALWAYS.
  CORRECT:   harness-cli <verb> <resource_type> [flags]
  INCORRECT: harness-cli <resource_type> <verb>  (does not exist)

The 11 verbs: list, get, create, update, delete, execute, describe,
              schema, search, diagnose, status
Meta-commands: wizard, mcp-serve, config

Key commands:
  harness-cli list    pipeline
  harness-cli get     pipeline --id my_pipeline --format yaml
  harness-cli create  pipeline --file pipeline.yaml --dry-run
  harness-cli create  pipeline --file pipeline.yaml
  harness-cli update  pipeline --id my_pipeline --file pipeline.yaml
  harness-cli delete  pipeline --id my_pipeline --confirm "delete my_pipeline"
  harness-cli execute pipeline run --id my_pipeline --branch main
  harness-cli describe                          (lists all 139 resource types)
  harness-cli describe pipeline
  harness-cli schema  pipeline
  harness-cli search  "payment" --resources pipeline,service
  harness-cli diagnose pipeline --id my_pipeline
  harness-cli diagnose pipeline --id my_pipeline --run-id <run-id>
  harness-cli status
  harness-cli wizard  --list
  harness-cli wizard  build-deploy-app

Resource types: lowercase_snake_case — pipeline, service, environment,
  connector, secret, template, role, resource_group, user_group,
  feature_flag, gitops_app, chaos_experiment (139 total, 7 toolsets)

Commands that do NOT exist — never generate:
  harness-cli pipeline create    (resource-first — wrong)
  harness-cli pipeline run       (use: execute pipeline run)
  harness-cli pipeline validate  (use: create pipeline --dry-run)
  harness-cli template create    (resource-first — wrong)
  harness-cli rbac assign        (use: create role / resource_group)
  harness-cli pipeline logs      (use: diagnose pipeline)

──────────────────────────────────────────────────────────────────────
EXECUTION CONTEXT  (agent mode)
──────────────────────────────────────────────────────────────────────

Tools: bash_tool, create_file, str_replace, view
Working dirs:
  /home/claude/                  Generated artifacts (pipeline.yaml, etc.)
  /mnt/user-data/outputs/        Final deliverables (result.json)
Prior state CAN assume:
  HARNESS_API_KEY, HARNESS_ORG, HARNESS_PROJECT set in environment
  harness-cli installed (pip install harness-cli run by orchestrator)
Prior state CANNOT assume:
  Existing pipeline for this service
  Existing service, environment, or infrastructure definitions
  Specific files in working directory (check with view first)

──────────────────────────────────────────────────────────────────────
PRIMARY USE CASES
──────────────────────────────────────────────────────────────────────

1. Create a pipeline

   Human face:
     User says: "Create a CI/CD pipeline for my Node.js app deployed to K8s"
     Skill should: ask clarifying questions; generate modular multi-stage
     pipeline YAML; add failureStrategies; show harness-cli create pipeline

   Agent face:
     Inputs: package.json, Dockerfile in working dir; HARNESS_AGENT_MODE=true;
             task description from orchestrator
     Steps:
       1. view working directory — infer service name and language
       2. create_file pipeline.yaml with multi-stage Harness YAML
       3. bash: harness-cli create pipeline --dry-run (verify schema)
       4. If dry-run fails: write failed artifact, exit
       5. bash: harness-cli create service / environment if absent
       6. bash: harness-cli create pipeline --file pipeline.yaml
       7. create_file outputs/create-pipeline-result.json
     On failure at any step: write failed artifact with step and error

2. Analyze pipeline for anti-patterns

   Human face:
     User pastes pipeline YAML, asks "find anti-patterns"
     Skill should: detect patterns, report severity + YAML location +
     remediation code for each finding

   Agent face:
     Inputs: pipeline.yaml in working dir; task string "analyze pipeline"
     Steps:
       1. view pipeline.yaml
       2. Run detection against 35+ anti-pattern rules
       3. create_file outputs/antipattern-report.json with findings
       4. create_file outputs/analyze-result.json (completion artifact)
     Completion: report.json with findings array; result.json with
     status and artifact path

3. Diagnose pipeline failure

   Human face:
     User says "my K8s deploy step keeps timing out"
     Skill should: explain diagnosis, show harness-cli diagnose, provide YAML fix

   Agent face:
     Inputs: HARNESS_PIPELINE_ID in environment; task "diagnose failure"
     Steps:
       1. bash: harness-cli diagnose pipeline --id $HARNESS_PIPELINE_ID
       2. Parse output (stage, step, error, suggested fix)
       3. create_file outputs/diagnosis-report.json
       4. create_file outputs/diagnose-result.json

──────────────────────────────────────────────────────────────────────
OUTPUT CONTRACT — HUMAN MODE
──────────────────────────────────────────────────────────────────────

MUST:
  - Include at least one harness-cli command with verb-first syntax
  - Show complete YAML for any pipeline or template configuration
  - Use <+stage.variables.*> in template steps (not <+pipeline.variables.*>)
  - Ask clarifying questions if the request is ambiguous

MUST NOT:
  - Reference MCP servers, harness-mcp-v2, or any MCP tooling
  - Use resource-first CLI syntax (harness-cli pipeline create = wrong)
  - Write files to filesystem without being explicitly asked

──────────────────────────────────────────────────────────────────────
OUTPUT CONTRACT — AGENT MODE
──────────────────────────────────────────────────────────────────────

MUST:
  - Run harness-cli create --dry-run before every live create or update
  - Verify bash_tool exit code (0 = success) before proceeding
  - Write outputs/<task>-result.json as the final step, always
  - Log {"step": N, "action": "...", "status": "..."} at each major step

MUST NOT:
  - Prompt interactively under any circumstances
  - Proceed past a failed dry-run
  - Leave partial state without cleanup on failure
  - Use resource-first CLI syntax (invariant applies in both modes)
  - Reference MCP servers or harness-mcp-v2 (invariant applies in both modes)

──────────────────────────────────────────────────────────────────────
NO-ELICITATION POLICY  (agent mode)
──────────────────────────────────────────────────────────────────────

  service_name:      package.json "name" field → else directory name
  language:          package.json present → Node.js; pom.xml → Java;
                     requirements.txt → Python; go.mod → Go
  environment:       default "dev"; "prod" if task explicitly says production
  deploy_strategy:   default "rolling"; "canary" if environment is prod
  branch:            current git HEAD branch from repo context

  If required input unresolvable:
    Write: {"status": "failed", "reason": "missing_required_input",
            "missing": "<name>", "resolution": "<how to provide it>"}
    Exit cleanly — no main task execution

──────────────────────────────────────────────────────────────────────
COMPLETION SIGNAL  (agent mode)
──────────────────────────────────────────────────────────────────────

outputs/<task-name>-result.json:
{
  "status":       "success|failed|partial",
  "task":         "<task identifier>",
  "timestamp":    "<ISO 8601>",
  "pipeline_id":  "<Harness pipeline identifier>",
  "pipeline_url": "<Harness UI URL>",
  "artifacts":    ["pipeline.yaml", "outputs/create-pipeline-result.json"],
  "error":        null
}

──────────────────────────────────────────────────────────────────────
CORRECTNESS INVARIANTS  (both modes)
──────────────────────────────────────────────────────────────────────

Shared:
  1. Verb-first CLI syntax. harness-cli pipeline create does not exist.
  2. No MCP server or harness-mcp-v2 references.

Agent-mode only:
  3. harness-cli create --dry-run precedes every live create or update.
  4. outputs/<task>-result.json written on every execution, success or failure.
  5. No interactive prompts under any circumstances.

──────────────────────────────────────────────────────────────────────
EXTENSIONS
──────────────────────────────────────────────────────────────────────

ACME org:         extensions/acme/ACME.md
  Load when:      User explicitly mentions "ACME", ACME templates, or ACME
                  OPA policies; OR HARNESS_ORG starts with "acme-"
  Contains:       ACME standard template registry, 3 OPA policy sets,
                  OpenRewrite recipes, connector allowlist, RBAC model

Jenkins migration: extensions/jenkins-migration/JENKINS.md
  Load when:      User wants to migrate from Jenkins; OR task description
                  contains "Jenkinsfile", "jenkins.yml", "Jenkins pipeline"
  Contains:       25-row concept map, 6 translation patterns, checklist

──────────────────────────────────────────────────────────────────────
SKILL BODY STRUCTURE
──────────────────────────────────────────────────────────────────────

Section 1 — Shared (always loaded)
  harness-cli auth and installation
  The 11 verbs and verb-first syntax rule
  Resource type reference (139 types, 7 toolsets)
  YAML fundamentals (pipeline structure, expressions, failure strategies)
  Anti-patterns quick reference (top 10)
  Extension loading rules

Section 2 — Mode detection
  Heuristics and fallback rule

Section 3 — Human mode
  Three entry points (create, analyze, refactor)
  Conversational output format
  When to ask clarifying questions
  → Load references/human-guide.md for depth

Section 4 — Agent mode
  No-elicitation policy and resolution rules
  Execution contract (dry-run, verify, completion artifact)
  Task runbooks (create-pipeline, analyze-pipeline, diagnose-failure)
  → Load references/agent-runbook.md for full runbooks

Target lengths: SKILL.md ~400 lines; human-guide.md ~200; agent-runbook.md ~200

──────────────────────────────────────────────────────────────────────
DESCRIPTION AND TRIGGERING
──────────────────────────────────────────────────────────────────────

Two-clause description:
  Clause 1 (human): developer asks about Harness pipeline creation,
    anti-pattern detection, template design, OPA governance, canary
    deployment, harness-cli commands
  Clause 2 (agent): agent is generating Harness pipeline YAML, executing
    a CI/CD setup task, running harness-cli commands in a workflow,
    registering pipeline resources

Description optimization: run_loop.py against evals-trigger.json only.
Verify agent triggering manually: confirm A1 and A2 seeds activate agent mode.

──────────────────────────────────────────────────────────────────────
TEST CASE SEEDS
──────────────────────────────────────────────────────────────────────

HUMAN → evals/evals-human.json

H1. "Create a CI/CD pipeline for a Node.js microservice with npm builds,
     Jest tests, Kubernetes deployment, dev and prod environments,
     manual approval before prod"
     Expected: multi-stage pipeline YAML, Approval stage, failureStrategies,
     harness-cli create pipeline verb-first

H2. [User pastes pipeline with hardcoded AWS_SECRET_KEY, monolithic stage,
     no approval gate] "Analyze this for anti-patterns"
     Expected: >=4 patterns identified, HIGH severity for hardcoded secret,
     YAML locations, remediation code

H3. "How do I make a reusable K8s deploy template for dev (rolling)
     and prod (canary at 10%)?"
     Expected: template with versionLabel, <+input>, stage variables,
     <+stage.variables.*> not <+pipeline.variables.*>

AGENT → evals/evals-agent.json

A1. Task: create-nodejs-pipeline (happy path)
    Context: package.json (name: payment-service), Dockerfile present;
             HARNESS_API_KEY set; HARNESS_AGENT_MODE=true; no existing pipeline
    Input: "Create and register a CI/CD pipeline for this Node.js service
            with dev and prod, manual approval before prod"
    Expected tool call sequence:
      view → create_file pipeline.yaml →
      bash harness-cli create pipeline --dry-run →
      bash harness-cli create pipeline →
      create_file outputs/create-nodejs-pipeline-result.json
    Assertions:
      - pipeline.yaml exists with >=3 stages including Approval
      - dry-run called before live create (log order)
      - result.json exists with status="success"
      - No interactive prompts

A2. Task: missing-api-key (failure path)
    Context: HARNESS_API_KEY not set; HARNESS_AGENT_MODE=true
    Input: "Create a pipeline for this service"
    Expected: failure artifact written immediately
    Assertions:
      - result.json exists with status="failed"
      - result.json .reason mentions missing HARNESS_API_KEY
      - No harness-cli commands executed (dry-run or live)
      - No interactive prompts

──────────────────────────────────────────────────────────────────────
EVAL STRATEGY
──────────────────────────────────────────────────────────────────────

Run human and agent evals in SEPARATE iterations.

evals-human.json:
  Baseline: no skill; Target: >=75%, >=+30pp lift

evals-agent.json:
  Baseline: no skill; Target: >=80% overall
  100% required on: no-prompts, completion-artifact assertions

evals-trigger.json:
  20 queries for run_loop.py (human path optimization only)

QUALITY.md: two benchmark tables (human + agent); two release bars
```

---

---

# What Does NOT Change from Human-Only Skill Prompts

These sections are identical regardless of whether the skill is agent-only,
dual-mode, or human-only:

- **Skill identity** — name, domain, one-liner
- **Tool interface** — CLI syntax rules and correctness invariants
  (if anything, enforce more strictly for agents — they cannot self-correct)
- **Correctness invariants** — the shared ones appear in every eval
- **Extensions structure** — conditional loading works the same way in all modes
- **Packaging** — `evals/` excluded, `QUALITY.md` bundled, same `package_skill.py`

---

# Summary Table

| Prompt section | Human-only | Agent-only | Dual-mode |
|---|---|---|---|
| Skill identity | Same | Same | Same |
| Mode declaration | Not needed | Not needed | Required |
| Mode detection heuristics | Not needed | Not needed | Required |
| Trigger / dispatch | "user says X" | "agent is doing X" or injected | Both clauses |
| Execution context | Not present | Required | Required (agent section) |
| Primary use cases | Conversational | Input → steps → output | Both faces per use case |
| Output contract | Single (prose) | Single (tool calls + artifact) | Two labeled contracts |
| No-elicitation policy | Not present | Required | Required (agent section) |
| Completion signal | Not present | Required | Required (agent section) |
| Correctness invariants | Domain-specific | Domain + agent invariants | Shared + agent-only labeled |
| Extensions | Same | Same | Same |
| Skill body structure | Guide-style | Runbook-style (4 sections) | 4 sections: shared, detection, human, agent |
| Description | Human trigger phrase | Task-type phrase or documentation | Two-clause: human + agent |
| Test case seeds | User utterances | Task specs with context | H1/H2 (prose) + A1/A2 (task specs) |
| Eval files | evals.json | evals-agent.json | evals-human.json + evals-agent.json + evals-trigger.json |
| Grading style | Prose + text search | Programmatic only | Mixed: prose for human, programmatic for agent |
| Assertion style | Text-based | File/JSON/tool-log | Mode-appropriate per eval set |
| run_loop.py | Yes | Only if keyword-triggered; skip if injected | Human trigger evals only |
| QUALITY.md tables | One | One (agent) | Two (human + agent), separate release bars |
