# Agent Skills Catalog

This file is a guide to the skills currently installed for this environment. Each skill is stored at:

```text
~/.agents/skills/<skill-name>/SKILL.md
```

Pi exposes those skills through `~/.pi/agent/skills/`. The entries there are symlinks to the canonical files above.

Use a skill when its **when to use** condition matches the work. The skills are workflows and references, not just prompts: many of them define the order of investigation, the artifacts to create, and the completion criteria.

## Quick routing guide

| Situation | Start with |
| --- | --- |
| You have an idea or feature to shape in a repository | `/grill-with-docs` |
| You have an idea or design question outside a repository | `/grill-me` |
| You are not sure which skill or workflow fits | `/ask-matt` |
| A large, unclear effort will take several sessions | `/wayfinder` |
| A raw issue or incoming request needs evaluation | `/triage` |
| Something is broken, flaky, slow, or hard to reproduce | `/diagnosing-bugs` |
| You have a settled spec or ticket to build | `/implement` |
| You want to build behavior test-first | `/tdd` |
| You want to review a branch, PR, or diff | `/code-review` |
| You want to improve a module's design or testability | `/codebase-design` |
| You want to find architectural improvement opportunities | `/improve-codebase-architecture` |
| You need to clarify domain terms or record a meaningful decision | `/domain-modeling` |
| You need a runnable answer to a logic or UI design question | `/prototype` |
| You need facts from external documentation or primary sources | `/research` |
| You need to turn an unresolved question into questions for another person | `/to-questionnaire` |
| You need to turn settled discussion into a spec | `/to-spec` |
| You need to split a spec into independently buildable tickets | `/to-tickets` |
| You need to move work between sessions, directories, harnesses, or people | `/handoff` |
| The previous explanation did not land | `/wait-what` |
| You need to learn a topic over multiple sessions | `/teach` |
| You need to perform a human-only setup or migration procedure | `/wizard` |
| You need to resolve an active merge or rebase conflict | `/resolving-merge-conflicts` |
| You want to discover and install another skill | `/find-skills` |
| You need to configure this repository for the engineering workflows | `/setup-matt-pocock-skills` |
| You need guidance for writing skills or agent-facing instructions | `/writing-for-agents` |

## The main idea-to-ship flow

For ordinary feature work in a repository:

```text
/grill-with-docs
      |
      +-- design question needs a runnable answer --> /handoff -> /prototype -> /handoff
      |
      +-- one-session build -----------------------> /implement
      |
      +-- multi-session build ---------------------> /to-spec -> /to-tickets -> /implement
                                                                  |
                                                                  +-- uses /tdd
                                                                  +-- closes with /code-review
```

The main flow starts with clarification instead of implementation. `/grill-with-docs` keeps the domain glossary and architectural decisions current while the idea is sharpened. `/to-spec` and `/to-tickets` are for work that needs to survive a context change. `/implement` is the execution skill and uses test-first vertical slices where possible.

## On-ramps and supporting disciplines

- **Incoming work:** `/triage` turns an issue or request into a categorized, verified, agent-ready brief.
- **Hard bugs:** `/diagnosing-bugs` builds a tight red-capable feedback loop before allowing hypotheses or fixes.
- **Large, unclear work:** `/wayfinder` maps decisions as tracker tickets until the route to implementation is clear, then hands off to `/to-spec`.
- **Codebase health:** `/improve-codebase-architecture` finds deepening opportunities; `/codebase-design` supplies the vocabulary and design principles for choosing a seam.
- **Domain language:** `/domain-modeling` maintains `CONTEXT.md` and ADRs when terminology or hard-to-reverse decisions change.

## Skill reference

### `/ask-matt`

**Description:** A router over the installed skills and their workflows. It explains the main idea-to-ship flow, the on-ramps for bugs and incoming requests, the wayfinder path for large efforts, and the standalone skills.

**Use when:** You do not remember which skill fits the situation, or you want to understand how several skills fit together before starting work.

**Typical result:** A recommended path such as `/grill-with-docs -> /to-spec -> /to-tickets -> /implement`, rather than a code change itself.

**Related material:** `PHASE-BOUNDARIES.md` explains whether to continue, clear, hand off, delegate to a subagent, or compact at a phase boundary.

### `/code-review`

**Description:** Reviews the diff from a user-supplied fixed point along two separate axes: repository standards and specification fidelity. It runs those reviews independently and reports them side by side.

**Use when:** You want to review a branch, pull request, work in progress, or changes since a commit, tag, branch, or merge base.

**What it checks:**

- Standards documented by the repository.
- A baseline of common code smells, treated as judgment calls unless repository standards make them hard violations.
- Whether the change satisfies the originating issue or specification.
- Scope creep, missing requirements, and implementations that appear to satisfy a requirement incorrectly.

**Typical result:** Separate `Standards` and `Spec` findings with file, hunk, rule, and requirement references.

### `/codebase-design`

**Description:** A shared vocabulary and set of principles for designing deep modules: substantial behavior behind a small interface at a clean seam.

**Use when:** You are designing or restructuring a module, deciding where a seam belongs, making code more testable or AI-navigable, or evaluating whether an abstraction earns its place.

**Key ideas:**

- A **module** has an **interface** and an implementation.
- **Depth** means useful behavior per unit of interface a caller must learn.
- A **seam** is where behavior can be changed without editing the caller at that location.
- An **adapter** satisfies an interface at a seam.
- Depth creates **leverage** for callers and **locality** for maintainers.
- The deletion test asks whether removing a module concentrates complexity or merely moves it.

**Typical result:** A clearer interface, a more useful seam, or a decision not to introduce a hypothetical abstraction.

**Related material:** `DEEPENING.md` and `DESIGN-IT-TWICE.md`.

### `/diagnosing-bugs`

**Description:** A disciplined diagnosis loop for difficult bugs, intermittent failures, regressions, and performance problems.

**Use when:** A bug resists a first glance, is intermittent, is slow, or has an unclear cause. It is especially appropriate when there is a risk of guessing before reproducing the user's symptom.

**Workflow:**

1. Build and run one tight, deterministic, red-capable feedback loop.
2. Reproduce and minimize the user's exact failure.
3. Generate three to five ranked, falsifiable hypotheses.
4. Instrument one hypothesis at a time.
5. Write a regression test at the correct seam before applying the fix.
6. Re-run the original repro and remove temporary instrumentation.

**Typical result:** A verified root cause, a regression test, a fix, and a record of any architectural seam that prevented the bug from being tested properly.

### `/domain-modeling`

**Description:** Actively builds and sharpens a project's domain model, vocabulary, glossary, and meaningful architectural decisions.

**Use when:** A domain term is vague or overloaded, the code and conversation disagree, a relationship needs edge-case clarification, or a hard-to-reverse trade-off should be recorded as an ADR.

**Behavior:** It challenges terminology against `CONTEXT.md`, checks domain claims against code, uses concrete scenarios to expose ambiguity, and updates the glossary inline as decisions become clear.

**Typical result:** An updated `CONTEXT.md`, a carefully justified ADR when warranted, and shared language for subsequent specs and implementation work.

**Related material:** `CONTEXT-FORMAT.md` and `ADR-FORMAT.md`.

### `/find-skills`

**Description:** Discovers and installs skills from the open agent skills ecosystem.

**Use when:** You ask whether a skill exists for a task, want to extend the agent's capabilities, or need a specialized workflow such as React, deployment, testing, design, or documentation help.

**Workflow:** Check the skills.sh leaderboard, search with `npx skills find`, verify install counts and source reputation, present options, and offer an install command.

**Typical result:** A small set of verified skill recommendations with their source, install count, link, and `npx skills add` command.

### `/grill-me`

**Description:** Runs the relentless design and planning interview without writing repository documents.

**Use when:** You need to sharpen a plan, design, or idea but are not working in a repository or explicitly want a stateless conversation.

**Typical result:** A shared understanding of the design tree and its decisions, without a `CONTEXT.md` or ADR trail.

**Implementation note:** This is a lightweight entry point that delegates to `/grilling`.

### `/grill-with-docs`

**Description:** Runs the design and planning interview while also keeping the project's glossary and architectural decisions current.

**Use when:** You are working in a repository and have an idea, plan, or design that needs clarification before implementation.

**Typical result:** A shared understanding plus updates to `CONTEXT.md` and, when justified, ADRs.

**Implementation note:** This combines `/grilling` with `/domain-modeling`. Prefer it over `/grill-me` when there is a repository to leave a durable paper trail in.

### `/grilling`

**Description:** The core interview primitive for stress-testing a plan, decision, or idea.

**Use when:** The work contains unresolved decisions and you want to interview one frontier of decisions at a time instead of silently assuming answers.

**Workflow:** Model the topic as a design tree, ask every currently answerable frontier question in a round, recommend an answer for each, wait for the user's decisions, and repeat until the frontier is empty.

**Typical result:** Every branch of the design tree has been visited, with facts researched by the agent and decisions explicitly made by the user.

**Related skills:** `/grill-me` wraps it without documents; `/grill-with-docs` pairs it with `/domain-modeling`; `/triage`, `/wayfinder`, and `/improve-codebase-architecture` may invoke it as part of their own workflow.

### `/handoff`

**Description:** Compresses the current conversation into a portable Markdown handoff for another agent or session.

**Use when:** Moving to a new harness, directory, repository, colleague, or forked side task. It is not the default for an ordinary phase transition in the same session and workspace.

**Typical result:** A redacted handoff file in the operating system's temporary directory containing the current state, relevant artifacts, next steps, and suggested skills.

**Important:** It references existing specs, plans, ADRs, issues, commits, and diffs instead of duplicating them.

### `/implement`

**Description:** Executes a settled spec or set of tickets.

**Use when:** The problem and intended behavior are clear enough to build, either directly from the conversation or from a spec/ticket.

**Workflow:** Use `/tdd` at pre-agreed seams where possible, typecheck and run focused tests during implementation, run the full suite at the end, then use `/code-review` to review the result.

**Typical result:** A tested implementation, a review of the diff, and a commit on the current branch.

**Best preceded by:** `/grill-with-docs` for a small feature, or `/to-spec -> /to-tickets` for a multi-session effort.

### `/improve-codebase-architecture`

**Description:** Scans a codebase for deepening opportunities, presents candidates as a visual report, and then grills through the candidate the user selects.

**Use when:** You want to improve codebase health, testability, locality, or AI navigability without starting from a specific feature request.

**Workflow:**

1. Inspect recent code hotspots, the domain glossary, and relevant ADRs.
2. Find shallow modules, leaky seams, hard-to-test paths, and duplicated complexity.
3. Create a visual HTML report with before/after diagrams and recommendations.
4. Ask which candidate to explore.
5. Use `/grilling` and `/domain-modeling` to shape the chosen improvement.

**Typical result:** A selected, well-understood architectural improvement that can enter the main idea-to-ship flow.

### `/prototype`

**Description:** Builds throwaway code to answer one design question concretely.

**Use when:** Conversation and code reading are not enough to decide whether a state model, business rule, interaction, or UI feels right.

**Choose a branch:**

- Logic or state question: build a single shareable HTML demonstration with controls and visible state.
- UI question: build several radically different UI variations on one route.

**Typical result:** A runnable prototype that exposes the decision, followed by a captured verdict and a pointer to the prototype as a primary source. The production branch keeps the validated decision, not accidental prototype complexity.

**Related material:** `LOGIC.md` and `UI.md`.

### `/research`

**Description:** Delegates research to a background agent, using high-trust primary sources, and records the findings in one cited Markdown file in the repository.

**Use when:** A decision depends on external documentation, a third-party API, a standard, source code, or another authoritative source outside the current working context.

**Typical result:** A repository Markdown note with sourced claims that can be used during `/grill-with-docs`, `/to-spec`, or implementation.

### `/resolving-merge-conflicts`

**Description:** Resolves an active merge or rebase conflict by tracing the intent behind both sides rather than mechanically choosing one version.

**Use when:** Git is already in a merge or rebase conflict state.

**Workflow:** Inspect the operation, read the histories and primary sources for each side, resolve each hunk by preserving intent where possible, run the repository's checks, and finish the merge or rebase.

**Typical result:** A completed merge or rebase with conflicts resolved according to the purpose of each change and with verification performed.

**Important:** It does not abort the operation.

### `/setup-matt-pocock-skills`

**Description:** Configures a repository for the engineering workflows by setting up the issue tracker, triage label vocabulary, and domain-document layout.

**Use when:** You are about to use the engineering skills in a repository for the first time, or their required tracker and domain-doc configuration is missing or wrong.

**Workflow:** Explore the repository, confirm the issue tracker and label choices, choose a single-context or multi-context domain layout, then write the configuration under `docs/agents/` and add the `## Agent skills` block to the existing `CLAUDE.md` or `AGENTS.md`.

**Typical result:** `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, and possibly `docs/agents/triage-labels.md`, plus a pointer in the repository's agent instructions.

### `/tdd`

**Description:** Test-driven development guidance for writing durable behavior tests through public interfaces and agreed seams.

**Use when:** You want to build a feature or fix a bug test-first, want a red-green-refactor loop, or need integration tests that survive implementation refactors.

**Workflow:**

1. Agree on the public seam to test.
2. Write one behavior test that fails.
3. Implement only enough to make it pass.
4. Repeat in vertical slices.
5. Leave refactoring for review rather than expanding the current red-green slice.

**Test quality rules:** Tests describe external behavior, avoid implementation coupling and tautological assertions, and use independent expected values. Tests should be placed at pre-agreed seams.

**Related material:** `tests.md` and `mocking.md`.

### `/teach`

**Description:** Teaches a user a concept or skill over multiple sessions using the current directory as a stateful learning workspace.

**Use when:** The user wants durable understanding rather than a one-off answer, especially when the topic needs practice and spaced learning.

**Workspace artifacts:**

- `MISSION.md` for why the user is learning.
- `RESOURCES.md` for high-trust source material.
- `lessons/*.html` for short, interactive lessons.
- `reference/*.html` for reusable reference material.
- `learning-records/*.md` for durable insights.
- `assets/*` for shared lesson components.
- `NOTES.md` for teaching preferences and working notes.

**Typical result:** A sequence of focused lessons grounded in the user's mission, with retrieval practice and a record of what has been learned.

### `/to-questionnaire`

**Description:** Turns a knowledge gap into a questionnaire for someone else to answer asynchronously or in a meeting.

**Use when:** Another person holds facts or decisions that the user cannot determine alone.

**Workflow:** Ask who the questionnaire is for, determine exactly what the user needs back, then write a recipient-appropriate Markdown questionnaire ordered by importance.

**Typical result:** `to-questionnaire-<slug>.md` containing context, answering guidance, focused questions, answer stubs, and a catch-all section.

### `/to-spec`

**Description:** Synthesizes the current conversation and codebase understanding into a feature specification and publishes it to the configured issue tracker.

**Use when:** A feature has been discussed and clarified, and it needs a durable, buildable spec. It does not restart the interview.

**Workflow:** Explore the codebase, agree on the highest useful testing seams, write the spec, publish it, and apply the `ready-for-agent` label.

**Spec sections:** Problem Statement, Solution, extensive User Stories, Implementation Decisions, Testing Decisions, Out of Scope, and Further Notes.

**Typical result:** A tracker issue containing a complete spec, with testing seams and scope boundaries explicit.

### `/to-tickets`

**Description:** Breaks a spec, plan, or conversation into tracer-bullet tickets with explicit blocking edges and publishes them to the configured tracker.

**Use when:** The work is too large for one implementation session or needs parallelizable, independently verifiable slices.

**Ticket rules:** Each ticket should cut a complete vertical path through the relevant layers, be demoable or verifiable on its own, fit in one fresh context window, and identify only genuine blockers. Wide mechanical refactors use an expand-migrate-contract sequence instead.

**Typical result:** A dependency-ordered set of agent-ready tickets, with tracker-native blocking relationships where supported.

### `/triage`

**Description:** Moves incoming issues and, when configured, external pull requests through a state machine of category, verification, clarification, and readiness.

**Use when:** A raw bug report, feature request, or incoming external PR needs evaluation before implementation or human action.

**Categories:** `bug` and `enhancement`.

**States:** `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, and `wontfix`.

**Workflow:** Discover what needs attention, recommend a category and state, check the claim against the codebase, grill for missing detail when needed, and apply the outcome with a durable brief or triage notes.

**Typical result:** A verified issue with exactly one category role and one state role, an agent or human brief, or a documented and closed rejection.

**Important:** Triage is for work that arrived raw. Tickets already produced by `/to-tickets` are agent-ready and should not be triaged again.

### `/wait-what`

**Description:** Re-pitches the previous explanation in plain, simplified technical English using the repository's domain vocabulary.

**Use when:** The user says or implies that the explanation did not land, the context was unclear, or the agent has lost the thread.

**Typical result:** A shorter explanation with the relevant context restored and jargon reduced. It changes the explanation, not the underlying work.

### `/wayfinder`

**Description:** Plans a very large or unclear effort as a shared map of decision tickets on the issue tracker.

**Use when:** The effort is too large for one session and the route to the destination is not visible yet. Do not use it for a well-scoped feature whose decisions can be settled directly.

**Workflow:**

1. Name the destination.
2. Map the current decision frontier and the fog of war.
3. Create a labeled map issue and sharp child decision tickets.
4. Resolve one decision ticket per session, adding newly surfaced tickets as the map clears.
5. When the route is clear, hand off to `/to-spec`, then `/to-tickets` and `/implement`.

**Ticket types:** Research, Prototype, Grilling, and Task. Each ticket records a decision or the work needed to unblock a decision, not an implementation slice.

**Typical result:** A tracker map with decisions, dependencies, unresolved fog, and an explicit destination. The map is for planning, not for quietly turning into implementation work.

### `/wizard`

**Description:** Generates an interactive Bash wizard for steps that only a human can perform.

**Use when:** Provisioning infrastructure, configuring credentials or CI secrets, navigating an unfamiliar third-party dashboard, or performing a one-off migration or cutover that requires human clicks or judgment.

**Workflow:** Identify the manual stages and captured values, map each stage to concrete instructions and URLs, copy the shared wizard template, and statically verify the script with `bash -n` and `shellcheck` when available.

**Typical result:** A staged script with confirmations, hidden secret entry, `.env` updates, GitHub secret or variable writes, and a final summary. It should not be used for work the agent can perform directly.

**Related material:** `template.sh`.

### `/writing-for-agents`

**Description:** Guidance for writing documents that agents consume, including skills, `AGENTS.md`, `CLAUDE.md`, and documents reached through context pointers.

**Use when:** Creating or editing a skill, maintaining agent instructions, or designing a durable document that should reliably trigger the right behavior without loading unnecessary material.

**Key ideas:**

- Use precise context pointers with explicit trigger conditions.
- Separate ordered steps from reference material.
- Use progressive disclosure for branch-specific detail.
- Give every step a clear, exhaustive completion criterion.
- Keep one meaning in one source of truth and prune stale or redundant material.
- Prefer positive instructions and established leading words over long prohibitions.

**Typical result:** A shorter, more predictable agent-facing document with clear invocation rules and completion gates.

**Related material:** `SKILL-MECHANICS.md` for skill frontmatter, invocation choices, and router skills.

## Skill metadata and supporting files

Some skills have `disable-model-invocation: true` in their frontmatter. These are intended to be invoked explicitly by the user or by another workflow rather than selected automatically by the model.

The skill directory may contain more than `SKILL.md`:

- `agents/openai.yaml` contains subagent metadata where present.
- Companion Markdown files contain branch-specific reference material.
- Scripts and templates support skills such as `/diagnosing-bugs` and `/wizard`.

To inspect or edit a skill, use its canonical path:

```bash
nvim ~/.agents/skills/<skill-name>/SKILL.md
```

To list installed skills:

```bash
find ~/.agents/skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \\; | sort
```

This catalog is an overview. The `SKILL.md` file remains the authoritative definition of each skill's behavior.
