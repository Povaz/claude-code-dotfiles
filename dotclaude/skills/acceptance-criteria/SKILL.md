---
name: acceptance-criteria
description: Write, review, or rewrite Acceptance Criteria for user stories. Use this skill whenever the user (or a subagent you spawn) is asked to draft, improve, refine, rewrite, or review acceptance criteria, turn a user story into AC, translate behavior specs into Given/When/Then, critique existing Gherkin scenarios, define the "definition of done" for a story, or expand on a story's expected behavior — even if they don't explicitly say "acceptance criteria", "AC", or "Gherkin". Applies anywhere AC are produced or reviewed, including prompts like "what tests should we have for this story?", "flesh out this ticket", "how do we know when this is done?", or "check my BDD scenarios". Output format is strict: Happy Path and Sad Path as Gherkin scenarios, Non-Functional Requirements as a measurable checklist (FURPS+). Output is English regardless of input language.
---

# Acceptance Criteria

This skill is the house style for Acceptance Criteria (AC). Any time AC are being written, rewritten, improved, or reviewed — from a user story or from existing AC — follow this guide. If you're a subagent that was handed an AC-writing task, this skill applies to you too.

AC are **always in English**, regardless of the source language of the input.

## What Acceptance Criteria are (and aren't)

Acceptance Criteria are the set of conditions a user story must satisfy to be considered complete. Each criterion is a statement with a **binary, unambiguous pass/fail outcome** that describes both functional and non-functional expectations.

AC serve three purposes at once — hold all three in mind as you write:

1. **Shared understanding** — they align Product, Development, and QA on *what "done" means* for this story before a line of code is written.
2. **Scope boundary** — they define the story's edges and make *out-of-scope* explicit.
3. **Test contract** — each criterion should be directly executable (Gherkin) or directly verifiable (checklist) so QA and automation can act on them.

AC are **not** the Definition of Done (team-wide quality gates like "code reviewed") and **not** the Definition of Ready (entry criteria for grooming). Don't mix them in.

## The golden rule: question, don't invent

This is the most important behavior in this skill. **Do not fabricate context you were not given.**

If the input user story is vague, has an unclear user role, has no observable outcome, or implies system behavior you can't see (endpoints, screens, integrations, data shapes, thresholds, error codes, time limits…), **ask 1–3 targeted questions at the top of your response and produce AC only for the parts you're sure about.** Leave placeholders marked `??` for the parts that depend on the answers.

Why this matters: an invented AC reads authoritative. A reviewer skimming the ticket will assume the numbers and scenarios were negotiated, when in fact you made them up. That AC then becomes the silent source of bugs later. One minute of the user's time answering a question is worth far more than a confident hallucination.

Things you must ask about if not explicit in the input:
- **Concrete thresholds** for any NFR ("fast" → how fast?; "secure" → against what?).
- **Error codes and messages** for Sad Path scenarios.
- **Boundary conditions** and what happens just past them.
- **Pre-conditions** that the Background step would cover (authenticated? which role? which data?).
- **External dependencies** whose failure modes matter (payment gateway, email provider…).
- **Which user role** owns the behavior if the story names a vague "user".

Only for **clearly innocuous details** (e.g., the exact wording of a placeholder you can invent and the reviewer can easily correct) is it acceptable to fill in without asking. When in doubt, ask.

## Output format — non-negotiable

Every AC set you produce has **three sections**, matching the Three Dimensions of Quality. Use the exact headings below. Skip a section only when genuinely not applicable, and say so explicitly ("No Sad Path applicable for this story because …").

```
## Acceptance Criteria

### Happy Path
<one or more Scenario blocks in bold-keyword markdown>

### Sad Path
<one or more Scenario blocks in bold-keyword markdown for validation, invalid input, external failure, recovery, boundary>

### Non-Functional Requirements (Checklist)
- [ ] <measurable criterion mapped to a FURPS+ dimension>
```

### Scenario format — bold-keyword markdown, no fence

The house style for Happy Path and Sad Path scenarios is **plain markdown with bolded keywords**, *not* a fenced ` ```gherkin ` block. The shape is BDD-Gherkin (Given/When/Then/And); the rendering is markdown so backtick-highlighted Dictionary terms render as monospaced text per Rule 1 of the framework, and so the keywords themselves get the visual weight bold gives them. This matches the reference at `docs/specs/acceptance-criteria.md`.

Required shape:

```
**Scenario:** <short, outcome-focused name>

**Given** <pre-condition>,
    **And** <additional pre-condition>,
**When** <single triggering action>,
**Then** <observable outcome>,
    **And** <additional outcome>.
```

Rules:

- **No fence.** Don't wrap the scenario in ` ``` ` or ` ```gherkin ` — the bolding wouldn't render and backtick-highlighted Dictionary terms would display as literal characters instead of monospaced highlights.
- **Bold all keywords.** `**Scenario:**`, `**Background:**`, `**Given**`, `**When**`, `**Then**`, `**And**` are always bolded. Bolding is the visual cue that tells a reviewer this block is BDD, not loose prose.
- **One clause per line.** Each `Given/When/Then/And` clause occupies its own source line.
- **Indent `**And**` continuations with 4 spaces.** This visually attaches the continuation to the parent `Given` / `Then` clause it extends. Plain `Given/When/Then` lines have no leading indent.
- **Trailing punctuation.** Use commas at the end of `Given`/`When`/intermediate `Then`/`And` lines, and a period on the final line of the scenario. This keeps the scenario readable as one English sentence broken across lines.
- **Blank line between the `**Scenario:**` header and the body.** This makes the scenario header stand out and keeps rendering consistent across viewers.
- **`When` must contain exactly one action.** If two things happen, write two scenarios.
- Use **`**Background:**`** for pre-conditions shared across all scenarios in the story (e.g., "Given a registered customer is logged in"). The Background's body uses the same one-clause-per-line bold-keyword shape.
- Use a **table-driven scenario** when the same scenario differs only by data: write one scenario whose `**Given**` references a table immediately after, and inline an Examples-style markdown table. Don't copy-paste when a data table would do it cleaner.
- Optionally include a `**Feature:**` line at the top if the AC will end up in a `.feature` file (see `.feature` export below) — a 1–3 line narrative describing the capability.
- Scenarios must describe **what** the system does, not **how**. No "the backend caches in Redis", no "the POST endpoint returns 200"; describe user-visible behavior.

#### `.feature` export

If a downstream Cucumber/`behave`/`pytest-bdd` run needs a real `.feature` file, the bold/indent decoration is purely presentational — strip it before handing to the parser:

- Remove the `**` markers around keywords.
- Replace 4-space `**And**` indents with the Gherkin-conventional 2-space indent.
- Drop trailing commas on lines and the final period if your tooling is strict.
- Keep backticks around Dictionary terms — Cucumber-family parsers read them as plain step text and step-matching is unaffected.

This is a tooling concern, not a content concern. The skill always emits the bold-keyword markdown form; format conversion happens at the integration boundary.

### Happy Path

Positive flow: inputs valid, the system behaves as intended. Write each flow as a `**Scenario:**` block per the format above. The Given/When/Then shape preserves the BDD structure and stays directly executable once exported (see `.feature` export above) via `behave`, `pytest-bdd`, Cucumber, SpecFlow, etc.

### Sad Path

Negative flow: invalid input, validation boundaries, external failures, race conditions, recovery. Same `**Scenario:**` block format — one scenario per failure mode. Keeping each failure in its own scenario preserves the triggering context and outcome and makes each independently testable.

Cover, at minimum, whichever of these apply to the story:
- **Invalid input** (expired, malformed, missing, too long, out of range)
- **External failure** (3rd-party timeout, downstream error)
- **Recovery** (session lost, network drop, partial upload)
- **Boundary** (0, 1, max, max+1; empty collection, single item, full list)

If none apply, state so explicitly. A story with *only* a Happy Path is almost always under-specified — push back.

### Non-Functional Requirements — Checklist

Cross-cutting quality attributes. Frame using **FURPS+**: **F**unctionality (incl. security, auditing), **U**sability (incl. accessibility), **R**eliability (availability, recoverability), **P**erformance (response time, throughput), **S**upportability (observability, maintainability), **+** constraints (legal, compliance, physical).

**Write NFRs as a Checklist, not as Gherkin.** An NFR is a declarative threshold that applies across the whole feature — it has no single triggering action, so Given/When/Then adds ceremony without clarity. A checklist of measurable assertions is the right fit.

Every NFR **must be measurable**. Replace adjectives ("fast", "secure", "intuitive") with numbers, percentiles, standards, or pass/fail checks. If you can't quantify it, ask the user for the threshold — do not write "should be fast."

Template:

```
### Non-Functional Requirements (Checklist)
- [ ] **Performance:** <measurable assertion, e.g., "p95 response time under 200 ms at 1,000 RPS">
- [ ] **Functionality (Security):** <measurable assertion>
- [ ] **Usability (Accessibility):** <measurable assertion>
- [ ] **Reliability:** <measurable assertion>
- [ ] **Supportability:** <measurable assertion>
- [ ] **+ Constraint (Legal/Compliance):** <measurable assertion>
```

Not every story needs every FURPS+ category. Include only those that apply, but always consider each — a quick mental pass through the six is the main guard against shipping a feature that's fast and pretty but, say, logs plaintext credit-card numbers.

## Anchoring (Context-Anchored Specifications)

When the project uses the **Context-Anchored Specifications** framework — i.e., a `contexts.md` (or equivalent Contexts/Dictionary file) is present alongside the spec — every AC set you produce is anchored. See `docs/kb/context-anchored-specifications.md` for the full framework; the rules summarised below are what changes about your output.

The `contexts-dictionaries` skill owns the Dictionary itself. This skill never edits Context blocks, but it *does* highlight defined terms inside Gherkin steps and the NFR checklist.

### Transitive inheritance

AC inherit **all** of their parent story's Contexts (Rule 4 of the framework) — no separate `[Contexts: …]` tag line on the AC themselves. The story's tag line is what sets scope; AC operate inside that scope.

### Highlighting inside scenarios and NFR

Wrap every defined term in backticks when it appears in its dictionary sense — inside `**Given**`, `**When**`, `**Then**`, `**And**` clauses, scenario titles, data tables, and NFR checklist text alike. Backticks are the framework's canonical highlight (Rule 1): they render as monospaced text everywhere, survive format conversion as literal characters, and are mechanically greppable for impact analysis.

Because scenarios are written in plain markdown (no ` ```gherkin ` fence), backticks render as proper monospaced text — the framework's Rule 1 is honored visually, not just at the source level. If a `.feature` export is needed for Cucumber/`behave`/`pytest-bdd`, the backticks pass through as plain step text and step-matching is unaffected (see `.feature` export above).

### Inline disambiguation

If the parent story spans multiple Contexts and an AC uses a term defined differently in two of them, annotate that occurrence with the Context name inside the backticks: `` `term[Context]` ``. This is rare — most AC stay inside one Context's vocabulary. When it does happen, treat it as a "point of attention": the parent story may be doing too much, and the `user-stories` skill's split-or-keep rubric should be re-applied.

### Iteration handoff

If, while drafting AC, you encounter a term that should be in the Dictionary but isn't — or one whose definition needs adjustment — invoke the `contexts-dictionaries` skill to add or refine the entry, then return to finalise the AC. Iteration is mandatory (Rule 8); do not finalise AC whose anchoring has unresolved Dictionary gaps.

### Missed highlights are spec bugs, not compliance failures

You will sometimes miss a highlight, or backtick a word that isn't actually a Dictionary term. Treat these as ordinary spec bugs caught at review — fix them and move on. Don't reject an AC set just because the highlighting isn't perfect.

### Worked anchoring example

Assume a Billing Context defining `Customer`, `Invoice`, and `Account`.

**Feature:** Invoice download

**Background:**

**Given** a `Customer` is logged in.

**Scenario:** `Customer` downloads a past `Invoice`

**Given** the `Customer` has at least one paid `Invoice` on their `Account`,
**When** the `Customer` opens the invoice history page and clicks "Download" on a row,
**Then** the corresponding `Invoice` PDF is delivered to the browser,
    **And** the file name matches the `Invoice` number.

NFR checklist with highlighting:

- [ ] **Performance:** p95 time from "Download" click to first byte under 500 ms for `Invoice`s issued in the last 12 months.
- [ ] **Functionality (Security):** `Invoice` PDFs are served only to the `Customer` whose `Account` issued them.

## Principles for good AC

- **Testable** — each criterion is objectively verifiable as pass/fail.
- **Concise and unambiguous** — plain business language, no room for interpretation.
- **Implementation-independent** — describe *what* the system does, never *how*.
- **Measurable** — vague terms are replaced with numbers, ranges, or concrete thresholds.
- **Right-sized** — healthy stories usually have **1–3 Gherkin scenarios**; exceeding 4–5 is a signal the story is probably too large and should be split (flag this to the user).

These operationalize **T** (*Testable*) in INVEST and **M** (*Measurable*) in SMART.

## Anti-patterns to avoid and flag

🚫 **Prescribing the implementation.**
Bad: "The backend caches results in Redis for 60 s."
Good: "Repeated identical searches within 60 s return consistent results with perceived latency under 50 ms."

🚫 **Vague, unmeasurable language.**
Bad: "The page should be fast and user-friendly."
Good: "First Contentful Paint under 1.5 s on a 3G-Fast profile."

🚫 **Too many criteria.**
More than ~5 Gherkin scenarios is a signal the story is actually several stories in disguise. Flag it.

🚫 **Conflating AC with the Definition of Done.**
"Code is peer-reviewed" is a DoD item, not an AC. AC are story-specific; DoD is team-wide.

🚫 **Covering only the Happy Path.**
A story without Sad Path or NFR criteria is half-specified. Push back before producing.

🚫 **Writing AC after implementation.**
AC drive the build; they are not retroactive documentation. If the user is writing AC for work already shipped, say so — it should be recorded differently.

🚫 **Multi-trigger `When` clauses.**
`When` must describe exactly one action. Two things happening = two scenarios.

When you detect one of these patterns in input AC, annotate with ⚠ in the rewrite and explain the fix. Don't silently "correct" without telling the user.

## Critical story issues — refuse and flag

If the input is a **Fake Story** (need is entirely inside the team's Zone of Control — e.g., "As QA, I want faster DB restarts") or a **Misleading Story** (the "need" is actually a prescribed technical solution), **refuse to produce AC** and flag the issue in one line:

> "⚠ This reads as a <Fake Story / Misleading Story>. AC won't help here. Recommend reviewing the story itself first (see `user-stories` skill)."

For other story weaknesses (sub-optimal wording, slightly too large, etc.), produce the AC as normal but add a one-line note after the AC block: *"Note: the story could also be split by <axis> — consider doing so before sprint planning."*

Trust the story for everything else. You are not the user-stories skill; don't duplicate its INVEST check.

## Input flows

The skill supports two entry points. Infer which applies; ask if genuinely ambiguous. If the user names a specific platform (a backlog tool, a docs platform, an issue tracker), they supply the platform context in the prompt — fetch the source material with whatever tools are available, apply the rules below, and always show the user the proposed AC before writing back to that platform.

### From a user story (raw text)
User pastes a Connextra story and asks for AC. Read the story, identify the user role, the goal, and the benefit. If anything about the system context (screens, data, thresholds, error states, auth) is missing, **ask before writing**. Do not invent.

### Reviewing/rewriting existing AC
User pastes existing AC — Gherkin, checklist, or free-form text. Your job:
1. Classify each criterion as Happy Path / Sad Path / NFR, or flag as DoD-mixed / story-mixed.
2. Identify anti-patterns (implementation leakage, unmeasurable language, multi-trigger When, missing dimensions).
3. Rewrite into the canonical format.
4. Under the rewritten AC, add a **`What Changed:`** block of 2–5 bullets explaining the edits and why. Do not bury the delta at the bottom — keep it adjacent to the AC it describes, as the user-stories skill does.

When the input contains both a story narrative and existing AC, apply the "reviewing/rewriting" flow to the AC; only touch the story itself if it exhibits a critical issue per the previous section.

## Worked example

**Input (user story):**
> **Title:** Reset password via emailed link
> **As a** learner, **I can** request a password reset and receive a link by email to set a new password, **so that** I can regain access to my account without contacting support.

**Response:**

Before I draft, a couple of quick questions — I don't want to invent thresholds:

1. How long should the reset link remain valid? (The story mentions 24 h elsewhere in your guide, but I want to confirm that's the target here.)
2. Should the learner be rate-limited on reset requests (e.g., N requests per hour) to mitigate abuse?
3. What happens if the learner submits the reset form for an **unknown** email — do we reveal "no account found" or always show the same neutral confirmation? (Security trade-off.)

Below is a draft using the conservative assumptions; sections depending on answers are marked `??`.

### Happy Path

**Background:**

**Given** a learner account exists with email "lea@example.com".

**Scenario:** Learner requests a password reset and sets a new password

**Given** the learner is on the "Forgot password" page,
**When** the learner submits the form with email "lea@example.com",
**Then** the learner sees a confirmation "If an account exists, a reset link has been sent.",
    **And** a reset email is delivered to "lea@example.com" within 1 minute,
    **And** the email contains a single-use link valid for 24 hours. _?? confirm duration_

**Scenario:** Learner completes the reset from the emailed link

**Given** the learner has received a valid reset link,
**When** the learner opens the link and submits a new password meeting the password policy,
**Then** the password is updated,
    **And** the learner is redirected to the login page with a success message,
    **And** the reset link is invalidated for future use.

### Sad Path

**Scenario:** Reset link has expired

**Given** the learner has a reset link issued more than 24 hours ago, _?? confirm duration_
**When** the learner opens the link,
**Then** the learner sees error "This reset link has expired. Please request a new one.",
    **And** no password change is performed.

**Scenario:** Reset link has already been used

**Given** the learner has a reset link that was used once to set a new password,
**When** the learner opens the same link again,
**Then** the learner sees error "This reset link is no longer valid.".

**Scenario:** New password fails the password policy

**Given** the learner has opened a valid reset link,
**When** the learner submits a new password that does not meet the password policy,
**Then** the password is not changed,
    **And** the learner sees the policy violations listed.

**Scenario:** Unknown email submitted _?? behavior depends on Q3_

**Given** no learner account exists with email "ghost@example.com",
**When** the learner submits the form with email "ghost@example.com",
**Then** the same neutral confirmation is shown,
    **And** no email is sent.

### Non-Functional Requirements (Checklist)

- [ ] **Performance:** p95 time from form submission to email delivery is under 60 s.
- [ ] **Functionality (Security):** Reset tokens are single-use, ≥128 bits of entropy, and bound to the requesting account and user-agent.
- [ ] **Functionality (Security):** Reset requests are rate-limited to ?? requests per IP per hour and ?? per email per hour.  # ?? confirm Q2
- [ ] **Usability (Accessibility):** "Forgot password" and reset pages conform to WCAG 2.1 Level AA and are fully operable via keyboard only.
- [ ] **Reliability:** A transient email-provider failure is retried with exponential backoff for up to 5 min; the user sees no degraded experience below that threshold.
- [ ] **Supportability:** All reset events emit a structured log with a correlation ID; no plaintext tokens appear in logs or error payloads.
- [ ] **+ Constraint (Legal/Compliance):** Reset emails comply with the tenant's notification-language policy; all PII in transit uses TLS 1.2+.

**What to clarify (summary):**
1. Reset link validity duration (currently assumed 24 h).
2. Rate-limit thresholds per IP / per email.
3. Behavior on unknown email (neutral confirmation vs. "no account found").

---

## Style and voice

- Write plainly. Business-readable first, BDD-executable second — if the sentence wouldn't make sense to a PO, rewrite.
- Prefer concrete values over placeholders; when you must placeholder, use `??` *and* list the question explicitly.
- Don't pad. A crisp three-scenario set beats a ten-scenario set that repeats itself.
- Don't add INVEST analysis of the story — that's the `user-stories` skill's job.
- When flagging anti-patterns in existing AC, be direct and brief. State the pattern, state the fix.
- If the user asks for AC on something that's not a user story (pure infra, internal tooling with no end-user surface), say so — "AC are a story-level artifact; this reads as a Task. Want to describe it as acceptance conditions anyway, or track it differently?"
