---
name: user-stories
description: Write, review, or rewrite user stories following Apprendere's agile practices guide. Use this skill whenever the user (or a subagent you spawn) is asked to draft, improve, refine, split, rewrite, or review user stories, convert functional requirements into stories, groom a backlog, translate a Confluence requirements page into stories, or create/update stories in Jira — even if they don't explicitly mention "user stories" or the guide. Applies anywhere stories are being produced, including prompts like "turn these requirements into tickets", "clean up this backlog", "help me rewrite this Jira issue", or "draft some stories from this spec". Output is English, always Connextra-formatted ("As a... I can... so that...") with a Title, an INVEST quality check, and anti-pattern warnings when relevant.
---

# User Stories — Apprendere Agile Practices

This skill is the house style for user stories at Apprendere. Any time stories are being written, rewritten, improved, or reviewed — whether from scratch, from a Confluence page, or from Jira — follow this guide. If you're a subagent that was handed a story-writing task, this skill applies to you too.

Stories are **always in English**, regardless of the source language of the input.

## What a user story is (and isn't)

A user story describes a feature **from the perspective of the end user**. It states **what** the user wants to achieve and **why** — not **how** it will be built. A well-written story is understandable by any stakeholder without technical background. If a non-technical reader can't follow it, it's not done.

Stories are not tasks, work items, or implementation notes. If the work has no user-visible outcome (e.g., "refactor the build pipeline", "automate DB restarts for QA"), it is a Task or Improvement Item, not a user story. Don't force such work into Connextra format — flag it instead.

## Output format

Every story you produce has two parts: a **Title** and a **Connextra narrative**. These map cleanly to Jira's Summary and Description fields.

```
**Title:** <short, concrete phrase — the feature or outcome, not the implementation>

**As a** <type of user>,
**I can** <some goal>,
**so that** <some reason>.
```

Title guidance:
- Keep it under ~80 characters. It should read like a headline.
- Phrase it around the user-visible outcome, not the technical task.
- Good: "Reset password via email link". Bad: "Add password-reset endpoint".

Narrative guidance:
- Use **I can** (per Apprendere house style), not "I want" or "I need".
- `<type of user>` is a concrete role (e.g., "learner", "course admin", "content editor"). Avoid vague terms like "user" when a more specific role fits.
- `<some goal>` is observable behavior from the user's side — something they can do, see, or get.
- `<some reason>` is the benefit to the user or business. If you can't articulate the reason, the story is probably missing its value and needs a conversation before you write it.

After each story, include a short quality-check block (details below). Don't skip this — it's the main defense against low-value stories slipping through.

## The INVEST check

Every story you produce must be examined against INVEST. Report the result in a compact block under the narrative. If all six pass, a single "✓ INVEST: all criteria met" line is enough. If any fail, call out which one and briefly say why.

- **I**ndependent — can this story be built without first completing another story? If not, it's dependency-locked.
- **N**egotiable — is this phrased as a goal open to discussion, rather than a fixed implementation?
- **V**aluable — does it deliver observable value to the named user role?
- **E**stimable — is there enough clarity that the team could ballpark the effort?
- **S**mall — could this realistically be completed in 1–2 days, and certainly within a sprint? If it feels larger, split it (see "Splitting" below).
- **T**estable — is the outcome observable enough that someone could tell whether it was delivered? (Acceptance criteria come later — but the story should be testable in principle.)

INVEST is a lens, not a checklist to hide behind. If a story passes all six but still feels wrong, trust that instinct and flag it in the quality block.

## Anti-pattern detection (warn, don't block)

Apprendere uses a **system-thinking** frame to catch low-value stories. A delivery team operates within three boundaries:

1. **Zone of Control** — things the team changes directly (code, schemas, configs).
2. **Sphere of Influence** — things the team affects but doesn't fully control (user behavior, business outcomes).
3. **External Environment** — things beyond the team's reach (regulation, vendor roadmaps).

A healthy story has its **User Need** in the Sphere of Influence and its **Deliverable** in the Zone of Control. When a story breaks this pattern, it usually falls into one of three traps. If you detect one, annotate the story with a ⚠ warning — do **not** silently refuse or rewrite. The user gets to decide what to do.

### 🚫 Fake Story
The user need is inside the Zone of Control — there's no business risk, just an internal task dressed as a story.
- Example: "As a QA, I can have automated DB restarts, so that I can test faster."
- Why flag: this is a tooling improvement, not a story. It belongs as a Task or Improvement Item.
- Your warning should say: "⚠ Looks like a Fake Story — the need is internal tooling. Consider tracking as a Task instead of a user story."

### 🚫 Misleading Story (Solution Trap)
The user asks for a specific technical solution rather than stating the underlying problem.
- Example: "As an operator, I can run query optimization, so that reports are faster."
- Why flag: "query optimization" is a solution, not a need. The real need might be "find data discrepancies quickly" — which could be solved differently.
- Your warning should say: "⚠ Looks like a Misleading Story — `<goal>` reads as a prescribed solution. What is the underlying problem? (e.g., what does the operator actually need to accomplish?)"

### ⚠ Dependency-Locked Story
The deliverable sits outside the team's Zone of Control (e.g., blocked on a 3rd-party vendor).
- Your warning should say: "⚠ Dependency-locked — deliverable requires `<external thing>`. Consider splitting: keep the in-team work as the story; track the external dependency separately."

When in doubt, flag and explain. A false warning costs the user a few seconds of reading; a missed warning costs them a bad story in the sprint.

## Splitting large stories

If a story would take more than ~1–2 days, or spans multiple user actions or business rules, split it before returning it. Apply whichever of these strategies fits the material:

- **By workflow step**: "Search" → "Add to cart" → "Checkout"
- **By data variation**: filter by price vs. filter by category
- **By business rule**: extract each complex rule into its own story
- **By CRUD**: Create / Read / Update / Delete as separate stories
- **By platform**: web vs. mobile as separate stories
- **By happy path vs. edge cases**: deliver the core flow first, then error handling

When you split, return the set of resulting stories and a one-line note explaining the split strategy used, so the user can tell whether you picked the right axis.

## Input flows

The skill supports several entry points. Infer which one applies from the user's request; ask if genuinely ambiguous.

### From scratch — raw functional requirements
The user pastes or describes unformatted requirements. Extract the distinct user-facing capabilities, identify the relevant user roles, and produce one story per capability. If requirements are vague (no clear user role, no clear benefit), ask targeted questions rather than inventing details.

### From scratch — rough story drafts
The user pastes existing story drafts that need improvement. Preserve their intent. Rewrite only what's necessary to match the format, fix anti-patterns, or split oversized stories. Call out what you changed and why, in a brief note after the output — this keeps the review cheap for the user.

### From a Confluence page
When a Confluence page URL or page ID is provided, read the page (via the Atlassian MCP when available) and treat its content as either raw requirements or draft stories, per the rules above. If the page has both, treat each section appropriately. If the user asks you to write improved stories back to the page, do so only after they've reviewed your draft.

### From/to Jira
When existing Jira issues are referenced, read them, treat their current Summary + Description as draft material, and produce improved versions. **Do not update Jira issues silently** — always show the user the proposed changes first. Creation of new Jira stories from a drafted set is a separate, explicit step the user will ask for; the skill's job ends once correctly formatted text is produced.

When creating or updating Jira, map:
- Title → Summary
- Connextra narrative → Description
- INVEST / anti-pattern notes → post as a comment or leave in the description's review section; don't let them pollute the final Description once the user has accepted the story.

## Worked example

**Input (raw requirement):**
> Users should be able to recover their password when they forget it. Send an email with a link, the link expires after 24h, and they can set a new password.

**Output:**

**Title:** Reset password via emailed link

**As a** learner,
**I can** request a password reset and receive a link by email to set a new password,
**so that** I can regain access to my account without contacting support.

✓ INVEST: all criteria met. Story is independent, deliverable within a sprint, and outcome is observable (user regains access).

_Note: the 24h link expiry is an acceptance-criterion concern, not a story concern. I kept it out of the narrative so the story stays focused on the user goal. The expiry, email template, and rate-limiting will belong in the AC when those are written._

---

**Input (fake story):**
> As a developer, I want a script that resets the test database, so that I can run tests faster.

**Output:**

**Title:** Test-DB reset script (flagged — not a user story)

**As a** developer,
**I can** reset the test database with a script,
**so that** I can run tests faster.

⚠ **Fake Story** — the need ("run tests faster") is inside the team's Zone of Control. This is a developer-productivity improvement, not a user-facing feature. Recommend tracking as a Task or Improvement Item. If kept as a story, the team should ask: who is the actual end user, and what observable business value does this deliver to them?

## Style and voice

- Write plainly. No jargon unless it's the user role's own jargon.
- Prefer concrete roles over "user". "Learner", "course admin", "content editor" beat "user" every time.
- Don't pad. A crisp three-line story beats a paragraph.
- Don't add Acceptance Criteria unless the user explicitly asked for them — ACs are out of scope for this skill.
- When flagging, be direct and brief. State the pattern, state the fix.

## When to push back

If the input is fundamentally not a user story (pure infrastructure work, internal process changes with no end-user surface, etc.), say so. Don't contort it into Connextra just because the user asked. A one-line "This reads as a Task, not a user story — want me to draft it that way, or is there an end user I'm missing?" saves everyone time downstream.