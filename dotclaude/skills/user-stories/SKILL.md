---
name: user-stories
description: Write, review, or rewrite user stories. Use this skill whenever the user (or a subagent you spawn) is asked to draft, improve, refine, split, rewrite, or review user stories, convert functional requirements into stories, or groom a backlog — even if they don't explicitly mention "user stories". Applies anywhere stories are being produced, including prompts like "turn these requirements into tickets", "clean up this backlog", "draft some stories from this spec", "break this epic down", "story map this", "refine the backlog", or "write tickets for this PRD". Output is English, always Connextra-formatted ("As a... I can... so that...") with a Title, an INVEST quality check, and anti-pattern warnings when relevant. This skill does NOT produce Acceptance Criteria — for AC, use the `acceptance-criteria` skill instead. Usable standalone, or as a step of the `/anchored-specs` pipeline.
---

# User Stories

Stories are **always in English**, regardless of input language. A story is a placeholder for a conversation (Jeffries' 3Cs — **Card**, **Conversation**, **Confirmation**): just enough on the Card to remember what to discuss, design happens in the Conversation, the Confirmation is the Acceptance Criteria written separately via the `acceptance-criteria` skill. This is why the format forbids embedded AC and implementation detail and insists the story stays negotiable.

A user story describes a feature **from the end user's perspective** — *what* they want and *why*, never *how*. A non-technical reader should be able to follow it. If the work has no user-visible outcome (e.g., "refactor the build pipeline", "automate DB restarts for QA"), it is a Task or Improvement Item — flag it; don't force it into Connextra.

## Output format

Two parts per story: **Title** and **Connextra narrative**.

```
**Title:** US-X — <short, concrete phrase — outcome, not implementation>

**As a** <type of user>, \
**I can** <some goal>, \
**so that** <some reason>.
```

Rules:

1. **One clause per line.**
2. **Trailing `\` on every non-final clause line.** This is CommonMark's hard-line-break — without it, many renderers (GitHub web, IDE preview) collapse the three lines into one paragraph. The final clause line has no `\`. (Two trailing spaces work in CommonMark too, but they're invisible and easily stripped by editors; `\` is visible and survives.)
3. **Bold the keywords** — `**As a**`, `**I can**`, `**so that**`. The bolding is the visual cue that this block is a Connextra story, not loose prose.
4. **No code fence.** Plain markdown — fences kill the bolding and the Dictionary backticks (see Anchoring).

Title:
- Under ~80 characters; reads like a headline.
- User-visible outcome, not technical task. Good: "Reset password via email link". Bad: "Add password-reset endpoint".

Narrative:
- Use **I can** (house convention), not "I want" / "I need".
- `<type of user>` is a concrete role ("learner", "course admin", "content editor"). Avoid "user" when something more specific fits.
- `<some goal>` is observable behavior the user can do, see, or get.
- `<some reason>` is the user/business benefit. If you can't articulate it, ask — don't invent.

### Code prefix `US-X`

- **Every story carries an immutable `US-X`** (X = positive integer), prefixed to the title with an em-dash: `**Title:** US-1 — Reset password via emailed link`.
- **Monotonic.** Pick `max(existing US-X) + 1` by scanning `user-stories.md` (or the unified spec doc the host process passed you). Start at 1 for a brand-new spec.
- **Sticky.** Once assigned, never renumber. If a story is removed, **retire** its code — don't reuse the integer. Gaps are expected and preserve historical reference.
- **Splits get fresh codes.** The original story's `US-X` is retired; each resulting split takes the next free integer at split time. Note the retirement and new codes in the **What Changed** block.
- If a host process supplies the next free code in its prompt, use it.

If the project uses **Context-Anchored Specifications** (a `contexts.md` is present), see **Anchoring** below for the additional `[Contexts: ...]` tag and backtick rules.

End each story with the INVEST check (next section). It's the main defence against low-value stories.

## INVEST check

Always reported as a **per-principle block**, even when every principle passes. A one-line "all criteria met" hides the reasoning and prevents reviewer sanity-checking; writing each line forces real thought and gives the reader an at-a-glance signal of where the story is strong or weak.

Required template — keep each reason to a clause or short sentence:

```
INVEST check:
- **I**ndependent — <pass/fail>: <reason>.
- **N**egotiable — <pass/fail>: <reason>.
- **V**aluable — <pass/fail>: <reason>.
- **E**stimable — <pass/fail>: <reason>.
- **S**mall — <pass/fail>: <reason>.
- **T**estable — <pass/fail>: <reason>.
```

| Letter | Question |
|---|---|
| **I**ndependent | Can it be built without first completing another story? If not, it's dependency-locked. |
| **N**egotiable | Phrased as a goal open to discussion, not a fixed implementation? |
| **V**aluable | Delivers observable value to the named user role? |
| **E**stimable | Enough clarity to ballpark the effort? |
| **S**mall | Realistically completable in **1–2 days**, certainly within a sprint? *Single source of truth for size — the Splitting section refers back here.* If larger, split it. |
| **T**estable | Outcome observable enough to tell whether it was delivered? (AC come later — story should be testable in principle.) |

INVEST is a lens, not a checklist to hide behind. If a story passes all six but still feels wrong, trust that instinct and flag it in a short note after the block.

## Anti-pattern detection (warn, don't block)

Systems-thinking frame (Gojko Adzic, *Fifty Quick Ideas to Improve Your User Stories*). A delivery team operates within three boundaries:

1. **Zone of Control** — what the team changes directly (code, schemas, configs).
2. **Sphere of Influence** — what the team affects but doesn't fully control (user behaviour, business outcomes).
3. **External Environment** — beyond the team's reach (regulation, vendor roadmaps).

A healthy story has its **need** in the Sphere of Influence and its **deliverable** in the Zone of Control. When a story breaks this pattern, it usually falls into one of four traps. Annotate with a ⚠ warning — do **not** silently rewrite or refuse. The user decides.

| Pattern | What's wrong | Warning to emit |
|---|---|---|
| 🚫 **Fake Story** | The need sits inside the Zone of Control — internal task dressed as a story. *Example: "As a QA, I can have automated DB restarts, so that I can test faster."* | "⚠ Looks like a Fake Story — the need is internal tooling. Consider tracking as a Task instead of a user story." |
| 🚫 **Misleading Story** (Solution Trap) | The user asks for a specific technical solution rather than the underlying problem. *Example: "As an operator, I can run query optimization, so that reports are faster."* — the real need might be "find data discrepancies quickly", which could be solved differently. | "⚠ Looks like a Misleading Story — `<goal>` reads as a prescribed solution. What is the underlying problem? (e.g., what does the operator actually need to accomplish?)" |
| 🚫 **Dependency-Locked** | Deliverable sits outside the team's Zone of Control (3rd-party vendor not yet contracted, cross-team API not yet contracted). The team cannot deliver it in a sprint no matter how well it is written. | "⚠ Dependency-locked — deliverable requires `<external thing>`. Consider splitting: keep the in-team work as the story; track the external dependency separately." |
| 🚫 **Micro-Story** | A large business story sliced so thin that a sub-story carries no business risk on its own. *Example: "As a learner, I can click the login button, so that the click is recorded."* Acceptable for short-term sequencing; in mid-to-long-term plans, regroup. | "⚠ Looks like a Micro-Story — no standalone business risk. Consider regrouping with sibling stories under a single user-value-carrying story." |

When in doubt, flag and explain. A false warning costs the user a few seconds; a missed warning costs them a bad story in the sprint.

## Anchoring (Context-Anchored Specifications)

When a `contexts.md` (or equivalent Contexts/Dictionary file) is present alongside the spec, every story should be **anchored**. A story without a Context tag is *unanchored* and must be anchored before the next recurring spec review. Framework reference: `~/.claude/kb/context-anchored-specifications.md` (synced default), or `docs/kb/context-anchored-specifications.md` if the project pins a local copy.

The `contexts-dictionaries` skill owns the Dictionary itself. This skill never edits Context blocks — it only tags stories and highlights terms inside them. If no Dictionary exists yet, draft unanchored and flag that the spec should run through the Dictionary phase first (via the `contexts-dictionaries` skill or a host pipeline that drives it).

### Output extension

Above the **Title**, add a tag line listing the story's Contexts:

```
[Contexts: <Context Title>, <another Context Title if applicable>]

**Title:** US-X — <as before>

**As a** <role>, \
**I can** <goal>, \
**so that** <reason>.
```

Inside the narrative, **wrap every defined term in backticks** when it is used in its dictionary sense — e.g., `` `Customer` ``, `` `Invoice` ``. Backticks are the framework's canonical highlight (Rule 1): they render as monospaced everywhere, survive format conversion as literal characters, and are mechanically greppable for impact analysis. Don't backtick a non-Dictionary word; don't skip a defined term used in its dictionary sense.

### Multi-Context: split-or-keep (framework Rule 6)

Most stories belong to exactly one Context. When a story genuinely spans multiple, default to **split** if any of these apply:

- **(a) Single-rephrase split** — the story can be cleanly stated using only one Context's vocabulary by removing or rephrasing one sentence.
- **(b) Independent terms** — the cross-Context terms refer to independent entities; they happen to appear together but aren't structurally entangled.
- **(c) Clean INVEST split** — splitting produces two stories that each pass INVEST.

Otherwise **keep** the story multi-Context, with all relevant Contexts in the tag. Override the default (split when none apply, or keep when one applies) only with explicit reasoning recorded inline as a short note after the INVEST block.

### Inline disambiguation

When a multi-Context story uses a term defined differently in two of its Contexts, annotate that occurrence: `` `term[Context]` ``. This is a "point of attention" for reviewers and is rare — most uses of plain `` `term` `` are unambiguous because only one of the story's Contexts defines that term in its dictionary sense.

### Iteration handoff

If you encounter a term that should be in the Dictionary but isn't — or one whose definition needs adjustment — invoke `contexts-dictionaries` to add or refine the entry, then return to finalise the story. Iteration is mandatory (framework Rule 8); do not finalise a story whose anchoring has unresolved Dictionary gaps.

### Missed highlights are spec bugs, not compliance failures

You will sometimes miss a highlight or backtick a non-term. Treat these as ordinary spec bugs caught at review — fix them and move on. Don't reject a story just because the highlighting isn't perfect.

### Worked anchoring examples

Single-Context (the common case):

```
[Contexts: Billing]

**Title:** US-1 — Download invoice PDF

**As a** `Customer`, \
**I can** download a PDF of any past `Invoice` from my account history, \
**so that** I can keep a record of my purchase for tax purposes.
```

Multi-Context with inline disambiguation:

```
[Contexts: Billing, Account Management]

**Title:** US-2 — Update billing address from account profile

**As a** `Customer`, \
**I can** update my `Billing` address using my `Account[Account Management]`, \
**so that** my future `Invoice`s are sent to the correct address.
```

## Splitting large stories — SPIDR + extras

If a story fails INVEST-**S**mall, split it before returning. Apply whichever axis fits the material. The canonical taxonomy is **SPIDR** (Mike Cohn); two extras are kept for convenience.

**SPIDR:**

- **S**pike — time-box a research spike when the story fails INVEST-Estimable (unknown tech, unclear domain). A spike delivers *knowledge*, not the feature; split the feature out once the spike lands.
- **P**aths — split along workflow steps or decision branches: "Search" → "Add to cart" → "Checkout".
- **I**nterface — split by UI surface or channel: web vs. mobile, REST vs. webhook, read view vs. edit view.
- **D**ata — split by data subset or variant: filter by price first, by category next; EUR accounts first, multi-currency later.
- **R**ules — extract each complex business rule into its own story: one rule = one story = one testable outcome.

**Extras (not strictly SPIDR but useful):**

- **CRUD** — Create / Read / Update / Delete as separate stories when each carries its own user value.
- **Happy path vs. edge cases** — deliver the core flow first; error handling, validation, recovery as follow-ups.

Return the resulting set with a one-line note on which axis you used. The original `US-X` is retired (do not reuse it); each split takes the next free integer at split time. Record the retirement and new codes in **What Changed**.

## Input flows

Two entry points; infer from the request, ask if genuinely ambiguous. If the user names a specific platform (backlog tool, docs platform, issue tracker), they supply platform context in the prompt — fetch the source with available tools, apply the rules below, and always show proposed stories before writing back to the platform.

**From scratch — raw functional requirements.** Extract the distinct user-facing capabilities, identify the relevant user roles, and produce one story per capability. If the requirements are vague (no clear role, no clear benefit), ask targeted questions rather than inventing details.

**From scratch — rough story drafts.** Preserve the original intent. Rewrite only what's necessary to match the format, fix anti-patterns, or split oversized stories.

**Explain the delta per story, inline.** After each rewritten story's INVEST block, add a `**What Changed:**` section (2–5 bullets) listing the concrete edits and why — role change, solution-trap extraction, split rationale, etc. Don't collect everything into a trailing summary table; the reviewer is scanning story-by-story and the context is most useful sitting next to the story it describes. When a story was split, place **What Changed** under the *first* split (or just above the group) and explain the split axis there; siblings don't each need their own block unless something unusual happened.

**Don't invent system components.** Only reference user roles, pages, endpoints, screens, integrations, or concepts that appear in the input. If a rewrite seems to need something the draft doesn't mention (e.g., "where does the learner do this from?"), do not fabricate it — ask one or two targeted questions at the top of your response. Much cheaper for the user to answer than to spot invented scope. Same rule for raw requirements: if the source is genuinely ambiguous about who the user is or what system they act within, ask.

## Worked examples

See [references/examples.md](references/examples.md) for full input → output traces of:

- a raw requirement turned into a clean story (happy path),
- a Fake Story flagged as not-a-user-story,
- a Misleading Story (Solution Trap) rewritten to outcome form,
- a Dependency-Locked story with split guidance,
- a Micro-Story flagged for regrouping.

## Style and voice

- Plain language. No jargon unless it's the user role's own jargon.
- Concrete roles over "user" — "learner", "course admin", "content editor" beat "user" every time.
- Don't pad. A crisp three-line story beats a paragraph.
- No Acceptance Criteria unless explicitly asked — AC are out of scope here.
- When flagging, be direct and brief: state the pattern, state the fix.

## When to push back

If the input is fundamentally not a user story (pure infrastructure, internal process, no end-user surface), say so. Don't contort it into Connextra. A one-line "This reads as a Task, not a user story — want me to draft it that way, or is there an end user I'm missing?" saves everyone time downstream.
