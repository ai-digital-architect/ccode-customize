# Structured Prompts for the Anthropic Skill Creator

Two templates are provided:

- **Prompt A** — Create a skill from scratch (you have a domain and a tool, no SKILL.md yet)
- **Prompt B** — Evaluate and iterate an existing skill (you already have a SKILL.md and evals)

A completed example of each is shown using the `harness-platform-expert` skill.

---

## Why structure matters

Skill-creator is conversational — it will interview you if you give it nothing. That
is fine for simple skills. For a complex skill with correctness invariants (like CLI
syntax rules), an external tool interface, or layered extensions, an unstructured
start causes wasted turns and shallow evals. A structured prompt front-loads the
context skill-creator needs so it can go straight to drafting or running evals.

The goal is not to write the skill for skill-creator. The goal is to give it:
1. The domain and use cases (what it does and when to trigger)
2. The tool contract (the external interface it must get right)
3. The correctness invariants (what must never be wrong)
4. The output contract (what every response must include)
5. The anti-patterns (what the skill must never produce)
6. Seeds for test cases (real user prompts, not abstract descriptions)

---

---

# PROMPT A — Create a Skill from Scratch

Use this when you have a domain and tool in mind but no SKILL.md yet.

---

```
I want to create a new skill. Here is everything you need to get started.
Skip the clarification interview — I have provided all the context below.
Go straight to drafting SKILL.md, then propose the first set of test cases.

──────────────────────────────────────────────────────────────────────
SKILL IDENTITY
──────────────────────────────────────────────────────────────────────

Name:         <skill-identifier-in-kebab-case>
Domain:       <one sentence — what problem space this skill covers>
One-liner:    <what Claude will be able to do with this skill>

Trigger when: <list of user phrases or situations that should load the skill>
Do NOT trigger for: <adjacent queries that should not trigger this skill>

──────────────────────────────────────────────────────────────────────
TOOL INTERFACE  (the external CLI/API/system the skill wraps)
──────────────────────────────────────────────────────────────────────

Tool name:     <tool-name>
Install:       <how to install it>
Auth:          <how to authenticate, env vars, config files>

Command syntax rule:
  <State the fundamental syntax pattern the skill must always follow.
   Be explicit — this becomes a correctness invariant in every eval.
   Example: "verb first, resource type second: tool-name <verb> <resource> [flags]">

Key commands the skill must teach:
  <List 8-15 example commands with correct syntax. These become the
   reference the skill uses to generate all examples.>

Commands that do NOT exist (common mistakes to prevent):
  <List invented or wrong-syntax commands so the skill never generates them.
   Example: "tool-name resource verb  (wrong — verb must come first)">

──────────────────────────────────────────────────────────────────────
PRIMARY USE CASES  (the 3-5 things users will ask the skill to do)
──────────────────────────────────────────────────────────────────────

1. <Use case name>
   User says things like: "<example prompt 1>", "<example prompt 2>"
   Skill should: <describe what a good response looks like>

2. <Use case name>
   User says things like: "<example prompt>"
   Skill should: <describe the response>

3. <Use case name>
   ...

──────────────────────────────────────────────────────────────────────
OUTPUT CONTRACT  (what every skill response must include)
──────────────────────────────────────────────────────────────────────

Every response MUST:
  - <requirement 1 — e.g., "include at least one CLI command the user can run">
  - <requirement 2 — e.g., "show YAML examples for any pipeline configuration">
  - <requirement 3>

Every response MUST NOT:
  - <prohibition 1 — e.g., "reference MCP servers or external auth systems">
  - <prohibition 2 — e.g., "use resource-first command syntax">
  - <prohibition 3>

──────────────────────────────────────────────────────────────────────
CORRECTNESS INVARIANTS  (things that are wrong, not just style issues)
──────────────────────────────────────────────────────────────────────

<List 2-5 invariants that, if violated, make a response objectively wrong.
These will become assertions in every eval.
Example: "The skill must never generate 'tool-name pipeline create' —
          it does not exist. The correct form is 'tool-name create pipeline'.">

──────────────────────────────────────────────────────────────────────
STRUCTURE  (layered extensions if needed)
──────────────────────────────────────────────────────────────────────

Core skill:        Always loaded. Contains <describe the core content>.
Extension 1 path:  extensions/<name>/<NAME>.md
  Load when:       <exact trigger — be narrow>
  Contains:        <what org/context-specific content lives here>
Extension 2 path:  extensions/<name>/<NAME>.md
  Load when:       <exact trigger>
  Contains:        <migration patterns, org templates, etc.>

──────────────────────────────────────────────────────────────────────
TEST CASE SEEDS  (real user prompts, not descriptions)
──────────────────────────────────────────────────────────────────────

Expand these into a full evals.json. Add assertions based on the output
contract and correctness invariants above.

1. "<realistic user prompt — use natural language, not abstract>
    Expected: <prose description of what a good response looks like>"

2. "<realistic user prompt>
    Expected: <description>"

3. "<realistic user prompt — ideally covers an extension trigger>
    Expected: <description>"

4. "<realistic user prompt — a diagnosis/troubleshooting scenario>
    Expected: <description>"

5. "<realistic user prompt — covers a correctness invariant directly>
    Expected: <description>"

──────────────────────────────────────────────────────────────────────
SKILL DIRECTORY  (if you have existing files to use as input)
──────────────────────────────────────────────────────────────────────

Skill path: <path to skill directory, or "none — create from scratch">
Existing files: <list any existing SKILL.md, references/, examples/ if present>
```

---

### Notes on Prompt A

**On the tool interface section:** This is the most important section for skills that
wrap a CLI or API. Spell out the syntax rule explicitly — skill-creator will carry it
into the SKILL.md body and into assertions. If you leave this vague, the first round
of evals will surface syntax errors and you will spend an iteration fixing them instead
of improving content quality.

**On test case seeds:** Write actual user prompts, not descriptions of user prompts.
`"Create a CI/CD pipeline for my Node.js app"` is useful. `"A pipeline creation prompt"`
is not. Skill-creator uses these as the starting point for its eval set; concrete seeds
produce better assertions.

**On extensions:** Only include this section if you have genuine layered content (org-
specific templates, migration patterns). If everything belongs in the core skill, omit
the section entirely.

**On "must not" vs "must":** The must-not list in the output contract becomes the source
of the correctness invariant assertions. Be explicit — `"never reference harness-mcp-v2"`
is more useful than `"use the right tools"`.

---

---

# PROMPT B — Evaluate and Iterate an Existing Skill

Use this when you already have a SKILL.md (and optionally evals/evals.json) and want
skill-creator to run the evaluation loop.

---

```
I have a skill already drafted and I want to run the evaluation and iteration loop.
Skip the creation phase — go straight to running evals.

──────────────────────────────────────────────────────────────────────
SKILL LOCATION
──────────────────────────────────────────────────────────────────────

Skill path: <path/to/skill-directory/>
Eval file:  <path/to/evals/evals.json>  (or "none — please draft evals first")

──────────────────────────────────────────────────────────────────────
WHAT THIS SKILL DOES  (brief context for grading)
──────────────────────────────────────────────────────────────────────

<2-3 sentences. What domain does it cover, what tool does it wrap,
what are the 3 primary things users ask it to do?>

──────────────────────────────────────────────────────────────────────
CORRECTNESS INVARIANTS  (grading must catch violations of these)
──────────────────────────────────────────────────────────────────────

These are not style preferences — they are objectively wrong if violated.
Every eval assertion must check for these.

1. <Invariant — e.g., "All harness-cli commands must use verb-first syntax:
   harness-cli <verb> <resource_type>. The pattern harness-cli <resource_type> <verb>
   does not exist and must never appear in a response.">

2. <Invariant — e.g., "harness-cli create pipeline --dry-run is how YAML is validated.
   harness-cli pipeline validate does not exist.">

3. <Invariant — e.g., "No response may reference MCP servers or harness-mcp-v2.">

──────────────────────────────────────────────────────────────────────
KNOWN WEAKNESSES  (what you already suspect needs fixing)
──────────────────────────────────────────────────────────────────────

<List 2-5 things you already know are wrong or missing based on your review.
This tells skill-creator where to focus the first iteration.
Example: "The skill is missing the diagnose and status commands entirely.
          Template examples reference pipeline-level variables instead of
          stage-level variables.">

──────────────────────────────────────────────────────────────────────
EVALUATION PRIORITIES  (which evals matter most)
──────────────────────────────────────────────────────────────────────

Must pass (release blockers):
  - Eval <N>: <name> — <why it's a release blocker>
  - Eval <N>: <name>

Good to pass (quality bar):
  - Eval <N>: <name>
  - Eval <N>: <name>

Extension evals (test conditional loading):
  - Eval <N>: <name> — should trigger <extension-name> extension
  - Eval <N>: <name> — should NOT trigger any extension

──────────────────────────────────────────────────────────────────────
ITERATION GUIDANCE  (how you want the loop to run)
──────────────────────────────────────────────────────────────────────

Number of iterations before pausing for my review: <N, suggest 1-2>
Target pass rate before packaging: <% — suggest 75%>
Any evals I want to add beyond the existing set: <prompts or "none">

──────────────────────────────────────────────────────────────────────
PACKAGING AND QUALITY.md
──────────────────────────────────────────────────────────────────────

After the final iteration:
1. Copy aggregate pass rates into QUALITY.md (it lives at the skill root and
   ships with the .skill package — the evals/ folder does not ship).
2. Package the skill using package_skill.py.
3. Present the .skill file.

QUALITY.md location: <path/to/skill/QUALITY.md>
```

---

### Notes on Prompt B

**On known weaknesses:** This section is the highest-value input you can give. Skill-
creator will discover issues on its own through evals, but naming what you already know
is wrong lets it write sharper assertions and makes iteration 1 more targeted. Don't
try to be comprehensive — 2-3 concrete issues beat a long vague list.

**On correctness invariants:** Re-state them here even if they are already in QUALITY.md.
Grader subagents read `eval_metadata.json`, not QUALITY.md. Spelling out the invariants
in the prompt ensures they are translated into assertions rather than left as background context.

**On "number of iterations before pausing":** If you set this to 1, skill-creator will
run evals, show you the viewer, and wait for your feedback before changing anything. This
is good for the first session on a new skill. Setting it to 2-3 is useful when you trust
skill-creator's judgment and want faster iteration, but you will need to review the viewer
between each one to give useful feedback.

**On QUALITY.md:** Remind skill-creator explicitly that QUALITY.md ships with the package
and evals/ does not. The default packaging step often forgets to update it, and it is
confusing for installers to receive a skill with blank benchmark tables.

---

---

# COMPLETED EXAMPLE — Prompt A for harness-platform-expert

This is what Prompt A looks like fully filled in for the skill we built.

---

```
I want to create a new skill. Here is everything you need to get started.
Skip the clarification interview — I have provided all the context below.
Go straight to drafting SKILL.md, then propose the first set of test cases.

──────────────────────────────────────────────────────────────────────
SKILL IDENTITY
──────────────────────────────────────────────────────────────────────

Name:         harness-platform-expert
Domain:       Harness CI/CD platform — pipeline design, governance, and deployment
One-liner:    Help developers create, analyze, and govern Harness CI/CD pipelines
              using the harness-cli tool

Trigger when:
  - User mentions Harness pipelines, stages, or CI/CD with Harness
  - User asks about pipeline anti-patterns or best practices
  - User wants to create or refactor a Harness pipeline
  - User mentions OPA policies, RBAC, or governance in a Harness context
  - User wants deployment strategies (rolling, canary, blue-green) in Harness
  - User wants to troubleshoot or diagnose a Harness pipeline failure
  - User mentions harness-cli

Do NOT trigger for:
  - Generic CI/CD questions not involving Harness
  - Kubernetes questions with no Harness context
  - GitHub Actions, GitLab CI, or other CI systems (unless migrating TO Harness)

──────────────────────────────────────────────────────────────────────
TOOL INTERFACE
──────────────────────────────────────────────────────────────────────

Tool name:  harness-cli
Install:    pip install harness-cli   OR   pipx install harness-cli
Auth:
  Required: export HARNESS_API_KEY="pat.<accountId>.<tokenId>.<secret>"
  Optional: export HARNESS_ACCOUNT_ID, HARNESS_BASE_URL, HARNESS_ORG,
            HARNESS_PROJECT, HARNESS_TOOLSETS

Command syntax rule:
  VERB FIRST, RESOURCE TYPE SECOND — ALWAYS.
  Correct:   harness-cli <verb> <resource_type> [flags]
  Incorrect: harness-cli <resource_type> <verb>       ← does not exist

The 11 fixed verbs (do not invent others):
  list, get, create, update, delete, execute, describe, schema, search,
  diagnose, status

Plus meta-commands: wizard, mcp-serve, config

Key commands:
  harness-cli list     pipeline
  harness-cli get      pipeline --id my_pipeline --format yaml
  harness-cli create   pipeline --file pipeline.yaml --dry-run
  harness-cli create   pipeline --file pipeline.yaml
  harness-cli update   pipeline --id my_pipeline --file pipeline.yaml
  harness-cli delete   pipeline --id my_pipeline --confirm "delete my_pipeline"
  harness-cli execute  pipeline run --id my_pipeline --branch main
  harness-cli describe                              (lists all 139 resource types)
  harness-cli describe pipeline                     (pipeline resource detail)
  harness-cli schema   pipeline
  harness-cli search   "payment" --resources pipeline,service
  harness-cli diagnose pipeline --id my_pipeline
  harness-cli diagnose pipeline --id my_pipeline --run-id <run-id>
  harness-cli status
  harness-cli wizard   --list
  harness-cli wizard   build-deploy-app

Resource types use lowercase_snake_case:
  pipeline, service, environment, connector, secret, template, trigger,
  input_set, role, resource_group, user, user_group, feature_flag,
  gitops_app, chaos_experiment, ccm_perspective, organization, project
  (139 types total, grouped into toolsets: cicd, governance, flags, gitops,
   chaos, ccm, platform)

Commands that do NOT exist — never generate these:
  harness-cli pipeline create        (wrong: resource-first)
  harness-cli pipeline list          (wrong: resource-first)
  harness-cli pipeline run           (wrong: use execute pipeline run)
  harness-cli pipeline validate      (wrong: use create pipeline --dry-run)
  harness-cli pipeline logs          (wrong: use diagnose pipeline)
  harness-cli template create        (wrong: resource-first)
  harness-cli rbac assign            (wrong verb: use create role/resource_group)
  harness-cli policy create          (wrong: policy is managed via resource types)

──────────────────────────────────────────────────────────────────────
PRIMARY USE CASES
──────────────────────────────────────────────────────────────────────

1. Create a pipeline
   User says: "Create a CI/CD pipeline for my Node.js app deployed to Kubernetes"
   Skill should: ask clarifying questions if needed; generate modular multi-stage
   pipeline YAML (CI build → deploy dev → approval → deploy prod); add
   failureStrategies to critical steps; show the harness-cli create pipeline command

2. Analyze a pipeline for anti-patterns
   User says: "Find anti-patterns in my pipeline" [pastes YAML]
   Skill should: identify patterns (monolithic stage, hardcoded secrets, missing
   approval gate, no failure strategies, wrong deployment strategy); report with
   severity, YAML location, and remediation code for each

3. Design reusable templates
   User says: "How do I make a reusable K8s deploy template for dev and prod?"
   Skill should: generate a stage template with <+input> for service/env/infra;
   use stage variables (not pipeline variables); add versionLabel; show
   harness-cli create template

4. Diagnose pipeline failures
   User says: "My K8s deploy step keeps timing out — how do I fix it?"
   Skill should: explain diagnosis approach using harness-cli diagnose; show the
   YAML fix (timeout increase, Retry failureStrategy); mention readiness probes

5. Author OPA governance policies
   User says: "Write an OPA policy that requires approval before prod deploys"
   Skill should: generate valid Rego with package declaration and deny[] rules;
   explain On Save vs On Run; show harness-cli create command for the policy

──────────────────────────────────────────────────────────────────────
OUTPUT CONTRACT
──────────────────────────────────────────────────────────────────────

Every response MUST:
  - Include at least one harness-cli command with correct verb-first syntax
  - Show complete YAML examples (not pseudocode) for any pipeline configuration
  - Use <+input> for environment-specific values in templates (never hardcode)
  - Reference <+stage.variables.*> in template steps (not <+pipeline.variables.*>)

Every response MUST NOT:
  - Reference MCP servers, harness-mcp-v2, or TypeScript MCP tooling of any kind
  - Use resource-first command syntax (e.g., harness-cli pipeline create)
  - Use commands that do not exist (harness-cli pipeline validate, pipeline run, etc.)
  - Hardcode secrets, account IDs, or environment-specific values in pipeline YAML

──────────────────────────────────────────────────────────────────────
CORRECTNESS INVARIANTS
──────────────────────────────────────────────────────────────────────

1. All harness-cli commands use verb-first syntax. harness-cli pipeline create,
   harness-cli template list, harness-cli service create — these do not exist and
   must never appear in skill output.

2. YAML validation is done with: harness-cli create pipeline --file f.yaml --dry-run
   The command harness-cli pipeline validate does not exist.

3. Pipeline execution is triggered with: harness-cli execute pipeline run --id <id>
   The command harness-cli pipeline run does not exist.

4. Pipeline failures are diagnosed with: harness-cli diagnose pipeline --id <id>
   Not with any pipeline logs or executions list command.

5. No response may reference MCP servers, harness-mcp-v2, or any MCP tooling.

──────────────────────────────────────────────────────────────────────
STRUCTURE
──────────────────────────────────────────────────────────────────────

Core skill: Always loaded. Covers harness-cli commands, pipeline YAML patterns,
            anti-pattern detection, best practices, deployment strategies.

Extension 1: extensions/acme/ACME.md
  Load when: User explicitly mentions "ACME", "ACME standards", ACME-specific
             templates (acme-ci-standard, acme-cd-k8s, etc.), or ACME OPA policies
  Contains:  ACME standard template registry, 3 OPA policy sets (Rego),
             OpenRewrite recipes, connector allowlist, RBAC model, tagging standard

Extension 2: extensions/jenkins-migration/JENKINS.md
  Load when: User wants to migrate from Jenkins — mentions Jenkinsfile, Jenkins
             pipeline, jenkins.yml, or explicitly says "migrate from Jenkins"
  Contains:  25-row Jenkins→Harness concept map, 6 translation patterns
             with side-by-side YAML, plugin mapping table, migration checklist

──────────────────────────────────────────────────────────────────────
TEST CASE SEEDS
──────────────────────────────────────────────────────────────────────

1. "Create a CI/CD pipeline for a Node.js microservice that builds with npm, tests
    with Jest, and deploys to Kubernetes. We have dev and prod environments. Prod
    needs a manual approval before deploy."
    Expected: multi-stage pipeline YAML, Approval stage present, failureStrategies
    on critical steps, harness-cli create pipeline command shown, verb-first syntax

2. [User pastes a 50-step monolithic pipeline YAML with kubectl shell commands,
    hardcoded AWS_SECRET_KEY value, and no failureStrategies]
    "Analyze this for anti-patterns."
    Expected: report identifying at least 4 patterns including HIGH severity for
    the hardcoded secret, specific YAML locations, remediation code for each

3. "Create a Kubernetes deploy stage template I can reuse for dev (rolling) and
    prod (canary at 10%). It should accept the environment and service as inputs."
    Expected: template with versionLabel, <+input> for service/env/infra,
    stage variables for strategy, <+stage.variables.*> in steps,
    harness-cli create template verb-first

4. "I want to migrate this Jenkins pipeline to Harness" [pastes a Jenkinsfile with
    credentials(), junit step, docker build, and post{failure{slackSend}}]
    Expected: Harness YAML with credentials() → <+secrets.getValue()>,
    BuildAndPushECR step, notificationRules, BUILD_NUMBER → <+pipeline.sequenceId>,
    concept mapping table — Jenkins extension loaded

5. "Write an OPA policy that blocks prod deployments without an approval stage,
    prevents Run steps in prod, and requires a timeout configuration."
    Expected: valid Rego with package and deny[] rules, On Save vs On Run explained,
    harness-cli create command with verb-first syntax

6. "My K8s rolling deploy step fails with a timeout after 10 minutes but the pods
    take 8 minutes to start because of JVM warm-up."
    Expected: increase timeout YAML, Retry failureStrategy for Timeout error type,
    mention readiness probes, harness-cli update pipeline with verb-first syntax

7. "I'm new to harness-cli. How do I discover what resource types are available
    and understand what I can do with the feature_flag resource?"
    Expected: harness-cli describe (no args), harness-cli describe feature_flag,
    mention of 139 types and toolset grouping, verb-first syntax throughout

8. "How do I monitor pipeline health across my project and diagnose a failure
    when one happens?"
    Expected: harness-cli status with dashboard description, harness-cli diagnose
    pipeline --id with structured output description, --run-id for specific runs

──────────────────────────────────────────────────────────────────────
SKILL DIRECTORY
──────────────────────────────────────────────────────────────────────

Skill path:     ~/harness-platform-skill/
Existing files: SKILL.md, QUALITY.md, evals/evals.json,
                extensions/acme/ACME.md,
                extensions/jenkins-migration/JENKINS.md
Note: The skill already exists — use the evals and iterate from the current state.
      Don't re-draft SKILL.md from scratch, just improve it.
```

---

# COMPLETED EXAMPLE — Prompt B for harness-platform-expert

This is what Prompt B looks like when you have the skill already built and want
to run the first evaluation loop.

---

```
I have a skill already drafted and I want to run the evaluation and iteration loop.
Skip the creation phase — go straight to running evals.

──────────────────────────────────────────────────────────────────────
SKILL LOCATION
──────────────────────────────────────────────────────────────────────

Skill path: ~/harness-platform-skill/
Eval file:  ~/harness-platform-skill/evals/evals.json

──────────────────────────────────────────────────────────────────────
WHAT THIS SKILL DOES
──────────────────────────────────────────────────────────────────────

Helps developers build, analyze, and govern Harness CI/CD pipelines using a
custom CLI tool called harness-cli. Primary use cases: create pipelines, detect
anti-patterns in existing pipelines, design reusable templates, author OPA
governance policies, and diagnose pipeline failures. Two conditional extensions
handle ACME org-specific templates and Jenkins-to-Harness migration.

──────────────────────────────────────────────────────────────────────
CORRECTNESS INVARIANTS
──────────────────────────────────────────────────────────────────────

1. All harness-cli commands must use verb-first syntax:
   harness-cli <verb> <resource_type> [flags]
   The pattern harness-cli <resource_type> <verb> does not exist.
   Specific violations to catch: "harness-cli pipeline create",
   "harness-cli pipeline list", "harness-cli template create".

2. YAML validation uses: harness-cli create pipeline --file f.yaml --dry-run
   The command "harness-cli pipeline validate" does not exist.

3. Triggering a run uses: harness-cli execute pipeline run --id <id>
   The command "harness-cli pipeline run" does not exist.

4. Failure diagnosis uses: harness-cli diagnose pipeline --id <id>
   Not "harness-cli pipeline logs" or "harness-cli pipeline executions list".

5. No response may reference MCP servers, harness-mcp-v2, or any MCP tooling.

──────────────────────────────────────────────────────────────────────
KNOWN WEAKNESSES
──────────────────────────────────────────────────────────────────────

1. The diagnose, status, describe, schema, search, and wizard commands are
   likely undertaught — the skill was drafted before the full harness-cli spec
   was incorporated.

2. Template examples may use <+pipeline.variables.*> in step references instead
   of the required <+stage.variables.*>.

3. The Jenkins migration extension may not load reliably — trigger condition
   may be too narrow.

──────────────────────────────────────────────────────────────────────
EVALUATION PRIORITIES
──────────────────────────────────────────────────────────────────────

Must pass (release blockers):
  - Eval 1 (pipeline creation): verb-first syntax, Approval stage, failureStrategies
  - Eval 2 (anti-pattern detection): catches hardcoded secret as HIGH severity
  - All evals: zero MCP references, zero resource-first CLI syntax

Good to pass (quality bar, 75% overall target):
  - Eval 3 (template design): uses <+stage.variables.*> not <+pipeline.variables.*>
  - Eval 5 (OPA policy): valid Rego, On Save vs On Run explained

Extension evals:
  - Eval 4 (Jenkins migration): MUST trigger jenkins-migration extension
                                 (should produce concept mapping table)
  - Eval 1, 5 (not Jenkins or ACME): must NOT trigger any extension

──────────────────────────────────────────────────────────────────────
ITERATION GUIDANCE
──────────────────────────────────────────────────────────────────────

Number of iterations before pausing for my review: 1
Target pass rate before packaging: 75% overall
Additional evals to add: the evals.json already has 8 — no additions needed yet

──────────────────────────────────────────────────────────────────────
PACKAGING AND QUALITY.md
──────────────────────────────────────────────────────────────────────

After the final iteration:
1. Copy aggregate pass rates from benchmark.md into QUALITY.md
   (QUALITY.md ships with the .skill package; evals/ does not)
2. Fill in the "Iteration Log" and "Extension Coverage" sections of QUALITY.md
3. Package with package_skill.py and present the .skill file

QUALITY.md location: ~/harness-platform-skill/QUALITY.md
```

---

---

# When to Use Which Prompt

| Situation | Use |
|---|---|
| You have a domain and tool in mind, no files yet | Prompt A |
| You have a rough idea but no SKILL.md | Prompt A (skill-creator will interview you for any gaps) |
| You have SKILL.md and evals, want to test | Prompt B |
| You have SKILL.md but no evals | Prompt B (set eval file to "none — please draft evals first") |
| You want to improve an existing packaged skill | Prompt B, note the skill path and "this is an update — preserve the name" |
| You want description optimization only | Prompt B, add "skip eval loop, go straight to description optimization" |

# Common Mistakes to Avoid in Your Prompts

**Too vague on the tool interface.** Saying "it uses harness-cli" without specifying
the syntax rule produces evals that don't catch syntax errors. Always state the rule
explicitly and give both correct and incorrect examples.

**Describing test cases instead of writing them.** `"A prompt about pipeline creation"`
tells skill-creator nothing useful. Write the actual user prompt in natural language.

**Listing every feature as a use case.** Three to five primary use cases is enough.
Skill-creator will discover edge cases through eval results — you don't need to
enumerate them upfront.

**Omitting the must-not list.** What the skill must never produce is as important as
what it must produce. If you have correctness invariants (like CLI syntax rules or
external system names to avoid), put them in the output contract explicitly.

**Setting the iteration count too high.** Start with 1 iteration before review.
Skill-creator's judgment on what to fix is good, but your review of the eval viewer
is what catches the things it misses. Two iterations between your reviews means you
might miss a regression.
