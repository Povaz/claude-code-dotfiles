---
name: acceptance-criteria
description: Write, review, or rewrite Acceptance Criteria for user stories. Use this skill whenever the user (or a subagent you spawn) is asked to draft, improve, refine, rewrite, or review acceptance criteria, turn a user story into AC, translate behavior specs into Given/When/Then, critique existing Gherkin scenarios, define the "definition of done" for a story, or expand on a story's expected behavior — even if they don't explicitly say "acceptance criteria", "AC", or "Gherkin". Applies anywhere AC are produced or reviewed, including prompts like "what tests should we have for this story?", "flesh out this ticket", "how do we know when this is done?", or "check my BDD scenarios". Output format is strict: Happy Path and Sad Path as Gherkin scenarios, Non-Functional Requirements as a measurable checklist (FURPS+). Output is English regardless of input language.
---

# Acceptance Criteria

AC are **always in English**, regardless of input language.

## What Acceptance Criteria are (and aren't)

AC are conditions a user story must satisfy to be considered complete. Each criterion has a **binary, unambiguous pass/fail outcome**. They serve three purposes simultaneously:

- **Shared understanding** — align Product, Dev, QA on *what "done" means* before code is written.
- **Scope boundary** — define the story's edges; make *out-of-scope* explicit.
- **Test contract** — each criterion is directly executable (Gherkin) or directly verifiable (checklist).

AC are **not** the Definition of Done (team-wide quality gates) and **not** the Definition of Ready (entry criteria for grooming). Don't mix them in.

## The golden rule: question, don't invent

**Do not fabricate context you were not given.** An invented AC reads authoritative — a reviewer skimming the ticket assumes the numbers were negotiated, when in fact you made them up. One minute of the user's time is worth more than a confident hallucination.

If the input is vague (unclear role, no observable outcome, missing endpoints/screens/data shapes/thresholds/error codes/time limits), **ask 1–3 targeted questions at the top of your response and produce AC only for the parts you're sure about**. Mark unanswered parts with `??`.

Always ask if not explicit:
- **Concrete thresholds** for any NFR ("fast" → how fast?; "secure" → against what?).
- **Error codes and messages** for Sad Path scenarios.
- **Boundary conditions** and what happens just past them.
- **Pre-conditions** for the Background step (authenticated? which role? which data?).
- **External dependencies** whose failure modes matter (payment gateway, email provider…).
- **Which user role** owns the behavior if the story names a vague "user".

Innocuous details (placeholder wording a reviewer can fix in seconds) may be filled in without asking. When in doubt, ask.

## Output format

Every AC set has **three sections**, matching the Three Dimensions of Quality. Use these exact headings — a downstream assembler depends on them. Skip a section only when genuinely not applicable, and say so explicitly ("No Sad Path applicable for this story because …").

```
## Acceptance Criteria

### Happy Path
<one or more Scenario blocks>

### Sad Path
<one or more Scenario blocks for validation, invalid input, external failure, recovery, boundary>

### Non-Functional Requirements (Checklist)
- [ ] <measurable criterion mapped to a FURPS+ dimension>
```

### Scenario format — fenced gherkin with bold scenario label

The shape: a bold `**Scenario:**` label on its own line, then the scenario body inside a ` ```gherkin ` fence.

**Why this shape.** Code fences preserve every newline exactly across all renderers and unlock Gherkin syntax highlighting in PyCharm/IntelliJ, GitHub, VS Code, Obsidian. Keeping `**Scenario:**` / `**Background:**` / `**Feature:**` labels *outside* the fence lets a downstream assembler promote them into `#### <name> — Happy/Sad Path` headings without re-parsing the fenced body, and keeps their bold rendering. The trade-off — backticks-around-Dictionary-terms inside the fence render as literal characters, not monospaced — is addressed in the Anchoring section.

Required shape (Sad Path uses ` — Sad Path` in place of ` — Happy Path`):

````
**Scenario:** AC-X.Y — <short, outcome-focused name> — Happy Path

```gherkin
Given <pre-condition>,
    And <additional pre-condition>,
When <single triggering action>,
Then <observable outcome>,
    And <additional outcome>
```
````

Rules:

- Use a `gherkin` fence for the body. Fence opener is exactly ` ```gherkin ` (lowercase, no space).
- Keep `**Scenario:**`, `**Background:**`, `**Feature:**` labels **outside** the fence.
- Every `**Scenario:**` label ends with ` — Happy Path` or ` — Sad Path`. `**Background:**` carries no suffix (shared pre-conditions, not a path-specific scenario). A `Scenario Outline:` block's bold label carries the same suffix.
- Inside the fence, keywords are plain `Given` / `When` / `Then` / `And` — no `**bold**` (it would render literally inside a code block; the Gherkin syntax highlighter applies the visual weight).
- One clause per line.
- `And` continuations indented 4 spaces; `Given` / `When` / `Then` lines have no leading indent.
- Comma at the end of every clause line *except the final one*. The final clause has **no trailing punctuation** (matches `.feature`-parser expectations; the commas are a doc-only readability convention, stripped at export).
- Blank line between the `**Scenario:**` label and the opening fence — keeps rendering consistent across viewers.
- `When` contains exactly one action. Two actions = two scenarios.
- Use a `**Background:**` label for pre-conditions shared across all scenarios in the story. Body uses the same fenced-gherkin shape.
- Use a `Scenario Outline:` + `Examples:` block (inside the fence) when scenarios differ only by data — don't copy-paste.
- Optionally include a `**Feature:**` label (1–3 line narrative) above the first Scenario if the AC will end up in a `.feature` file.
- Describe **what** the system does, never **how**. No "the backend caches in Redis", no "the POST endpoint returns 200" — describe user-visible behavior.

### `AC-X.Y` codes

The `AC-X.Y` prefix on every `**Scenario:**` label is what a downstream assembler promotes into per-scenario headings (`#### AC-X.Y — <name> — Happy/Sad Path`); the assembler does not assign or infer the code. Rules:

- **X = parent story's `US-X`.** Always inherited; never invented. If you don't know the parent's `US-X`, ask before writing.
- **Y = per-story ordinal**, starting at 1, counting across both Happy and Sad sections in source order — no separate sub-sequences.
- **Sticky.** Once assigned, an `AC-X.Y` never moves. Deleted AC retire their Y; new AC take `max(existing Y for this X) + 1`. Gaps are expected and acceptable.
- **Standalone vs. host-process.** If a host process supplies the next free Y, use it. Otherwise scan the AC file for the highest existing Y under this X; if none exists yet, start at Y=1.
- **A `Scenario Outline:`** counts as one AC code regardless of Examples-table length.
- **`**Background:**`** carries no code.
- **NFR has no per-bullet codes.** The whole NFR checklist belongs to the parent `US-X`; bullets are checklist items, not standalone testable artifacts.

### `.feature` export

The fenced body is already close to a real `.feature` file. To export for Cucumber / `behave` / `pytest-bdd`:

- Strip fence markers (` ```gherkin ` open, ` ``` ` close).
- Strip trailing commas if your tooling is strict.
- Pull bold labels (`**Scenario:**`, `**Background:**`, `**Feature:**`) out as bare `Scenario:` / `Background:` / `Feature:` lines.
- Keep backticks around Dictionary terms — Cucumber-family parsers read them as plain step text and step-matching is unaffected.

This is a tooling concern, not a content concern. The skill always emits the fenced-gherkin form; conversion happens at the integration boundary.

### Sad Path

Negative flow: invalid input, validation boundaries, external failures, race conditions, recovery. One scenario per failure mode — keeping each failure independent preserves the triggering context and makes each independently testable.

Cover, at minimum, whichever of these apply:
- **Invalid input** (expired, malformed, missing, too long, out of range)
- **External failure** (3rd-party timeout, downstream error)
- **Recovery** (session lost, network drop, partial upload)
- **Boundary** (0, 1, max, max+1; empty collection, single item, full list)

If none apply, state so explicitly. A story with *only* a Happy Path is almost always under-specified — push back.

### Non-Functional Requirements — Checklist

Cross-cutting quality attributes. Frame using **FURPS+**: **F**unctionality (incl. security, auditing), **U**sability (incl. accessibility), **R**eliability (availability, recoverability), **P**erformance (response time, throughput), **S**upportability (observability, maintainability), **+** constraints (legal, compliance, physical).

**Write NFRs as a Checklist, not as Gherkin.** An NFR is a declarative threshold across the whole feature — no single triggering action, so Given/When/Then adds ceremony without clarity.

Every NFR **must be measurable**. Replace adjectives ("fast", "secure", "intuitive") with numbers, percentiles, standards, or pass/fail checks. If you can't quantify, ask the user — do not write "should be fast."

Template (include only the categories that apply, but mentally pass through all six — that's the main guard against shipping a feature that's fast and pretty but logs plaintext credit-card numbers):

```
### Non-Functional Requirements (Checklist)
- [ ] **Performance:** <measurable assertion, e.g., "p95 response time under 200 ms at 1,000 RPS">
- [ ] **Functionality (Security):** <measurable assertion>
- [ ] **Usability (Accessibility):** <measurable assertion>
- [ ] **Reliability:** <measurable assertion>
- [ ] **Supportability:** <measurable assertion>
- [ ] **+ Constraint (Legal/Compliance):** <measurable assertion>
```

## Anchoring (Context-Anchored Specifications)

When the project uses the **Context-Anchored Specifications** framework — a `contexts.md` (or equivalent Contexts/Dictionary file) is present alongside the spec — every AC set you produce is anchored. See the framework doc at `~/.claude/kb/context-anchored-specifications.md` (synced default), or `docs/kb/context-anchored-specifications.md` if the project pins a local copy.

The `contexts-dictionaries` skill owns the Dictionary itself. This skill never edits Context blocks, but it *does* highlight defined terms inside Gherkin steps and the NFR checklist.

### Transitive inheritance

AC inherit **all** of their parent story's Contexts (Rule 4 of the framework) — no separate `[Contexts: …]` tag line on the AC themselves. The story's tag line sets scope; AC operate inside that scope.

### Highlighting inside scenarios and NFR

Wrap every defined term in backticks when used in its dictionary sense — inside `Given` / `When` / `Then` / `And` clauses, scenario titles, data tables, and NFR checklist text alike. Backticks are the framework's canonical highlight (Rule 1): they survive format conversion and are mechanically greppable for impact analysis when a definition changes.

**Trade-off inside the fence.** Markdown does not process inline syntax inside code blocks, so `` `Customer` `` inside a ` ```gherkin ` fence renders as **literal backticks**, not monospaced text. The framework's actual mechanical requirement (Rule 1) is *greppability* — a backtick around a defined term in source — and that is satisfied even when rendering is literal. Outside the fence (in `**Scenario:**` / `**Background:**` / `**Feature:**` labels, prose around the AC block, and the NFR checklist) backticks render as proper monospaced highlights. In `.feature` exports backticks pass through as plain step text and step-matching is unaffected.

### Inline disambiguation

If the parent story spans multiple Contexts and an AC uses a term defined differently in two of them, annotate that occurrence with the Context name inside the backticks: `` `term[Context]` ``. This is rare — most AC stay inside one Context's vocabulary. When it does happen, treat it as a "point of attention": the parent story may be doing too much, and the `user-stories` skill's split-or-keep rubric should be re-applied.

### Iteration handoff

If, while drafting AC, you encounter a term that should be in the Dictionary but isn't — or one whose definition needs adjustment — invoke the `contexts-dictionaries` skill to add or refine the entry, then return to finalise the AC. Iteration is mandatory (Rule 8); do not finalise AC whose anchoring has unresolved Dictionary gaps.

### Missed highlights are spec bugs, not compliance failures

You will sometimes miss a highlight, or backtick a word that isn't actually a Dictionary term. Treat these as ordinary spec bugs caught at review — fix and move on. Don't reject an AC set because the highlighting isn't perfect.

## Principles for good AC

- **Testable** — each criterion is objectively verifiable as pass/fail.
- **Concise and unambiguous** — plain business language, no room for interpretation.
- **Implementation-independent** — describe *what* the system does, never *how*.
- **Measurable** — vague terms replaced with numbers, ranges, or concrete thresholds.
- **Right-sized** — healthy stories have **1–3 Gherkin scenarios**; exceeding 4–5 is a signal the story is too large and should be split (flag this to the user).

These operationalize **T** (*Testable*) in INVEST and **M** (*Measurable*) in SMART.

## Anti-patterns to avoid and flag

When you detect one of these patterns in input AC, annotate with ⚠ in the rewrite and explain the fix. Don't silently "correct" without telling the user.

🚫 **Prescribing the implementation.**
Bad: "The backend caches results in Redis for 60 s."
Good: "Repeated identical searches within 60 s return consistent results with perceived latency under 50 ms."

🚫 **Vague, unmeasurable language.**
Bad: "The page should be fast and user-friendly."
Good: "First Contentful Paint under 1.5 s on a 3G-Fast profile."

🚫 **Too many criteria.**
More than ~5 Gherkin scenarios is a signal the story is actually several stories in disguise. Flag it.

🚫 **Writing AC after implementation.**
AC drive the build; they are not retroactive documentation. If the user is writing AC for work already shipped, say so — it should be recorded differently.

## Critical story issues — refuse and flag

If the input is a **Fake Story** (need is entirely inside the team's Zone of Control — e.g., "As QA, I want faster DB restarts") or a **Misleading Story** (the "need" is actually a prescribed technical solution), **refuse to produce AC** and flag in one line:

> "⚠ This reads as a <Fake Story / Misleading Story>. AC won't help here. Recommend reviewing the story itself first (see `user-stories` skill)."

For other story weaknesses (sub-optimal wording, slightly too large), produce the AC as normal and add a one-line note after the AC block: *"Note: the story could also be split by <axis> — consider doing so before sprint planning."*

Trust the story for everything else. You are not the user-stories skill; don't duplicate its INVEST check.

## Input flows

The skill supports two entry points. Infer which applies; ask if genuinely ambiguous. If the user names a specific platform (backlog tool, docs platform, issue tracker), they supply the platform context — fetch the source material with whatever tools are available, apply the rules below, and **always show the user the proposed AC before writing back to that platform**.

### From a user story (raw text)

User pastes a Connextra story and asks for AC. Read the story; identify the user role, goal, and benefit. If anything about system context (screens, data, thresholds, error states, auth) is missing, **ask before writing**. Do not invent.

### Reviewing/rewriting existing AC

User pastes existing AC — Gherkin, checklist, or free-form text. Your job:

1. Classify each criterion as Happy Path / Sad Path / NFR, or flag as DoD-mixed / story-mixed.
2. Identify anti-patterns (implementation leakage, unmeasurable language, multi-trigger When, missing dimensions).
3. Rewrite into the canonical format.
4. Under the rewritten AC, add a **`What Changed:`** block of 2–5 bullets explaining the edits and why. Keep this delta adjacent to the AC, as the `user-stories` skill does.

When the input contains both a story narrative and existing AC, apply the "reviewing/rewriting" flow to the AC; only touch the story itself if it exhibits a critical issue per the previous section.

## Worked example

For a fully-worked walkthrough — vague story → clarifying questions → Happy/Sad scenarios → NFR checklist with `??` placeholders, plus an anchoring example showing Dictionary-term highlighting inside and outside the fence — see [`references/worked-example.md`](references/worked-example.md).

## Style and voice

- Write plainly. Business-readable first, BDD-executable second — if the sentence wouldn't make sense to a PO, rewrite.
- Prefer concrete values over placeholders; when you must placeholder, use `??` *and* list the question explicitly.
- Don't pad. A crisp three-scenario set beats a ten-scenario set that repeats itself.
- Don't add INVEST analysis of the story — that's the `user-stories` skill's job.
- When flagging anti-patterns in existing AC, be direct and brief. State the pattern, state the fix.
- If the user asks for AC on something that's not a user story (pure infra, internal tooling with no end-user surface), say so — "AC are a story-level artifact; this reads as a Task. Want to describe it as acceptance conditions anyway, or track it differently?"
