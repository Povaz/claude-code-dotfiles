---
name: user-stories
description: Write, review, or rewrite user stories. Use this skill whenever the user (or a subagent you spawn) is asked to draft, improve, refine, split, rewrite, or review user stories, convert functional requirements into stories, groom a backlog, translate a Confluence requirements page into stories, or create/update stories in Jira — even if they don't explicitly mention "user stories". Applies anywhere stories are being produced, including prompts like "turn these requirements into tickets", "clean up this backlog", "help me rewrite this Jira issue", "draft some stories from this spec", "break this epic down", "story map this", "refine the backlog", or "write tickets for this PRD". Output is English, always Connextra-formatted ("As a... I can... so that...") with a Title, an INVEST quality check, and anti-pattern warnings when relevant. This skill does NOT produce Acceptance Criteria — for AC, use the `acceptance-criteria` skill instead.
---

# User Stories

This skill is the house style for user stories. Any time stories are being written, rewritten, improved, or reviewed — whether from scratch, from a Confluence page, or from Jira — follow this guide. If you're a subagent that was handed a story-writing task, this skill applies to you too.

Stories are **always in English**, regardless of the source language of the input.

A story is not a specification; it is a **placeholder for a conversation** (Ron Jeffries' 3Cs: **Card**, **Conversation**, **Confirmation**). The Card carries just enough to remember what to discuss; the Conversation is where the real design happens; the Confirmation is the Acceptance Criteria, written separately (see the `acceptance-criteria` skill). This is why the format forbids embedded AC, forbids implementation detail, and insists the story remains negotiable.

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
- Use **I can** (by house convention), not "I want" or "I need".
- `<type of user>` is a concrete role (e.g., "learner", "course admin", "content editor"). Avoid vague terms like "user" when a more specific role fits.
- `<some goal>` is observable behavior from the user's side — something they can do, see, or get.
- `<some reason>` is the benefit to the user or business. If you can't articulate the reason, the story is probably missing its value and needs a conversation before you write it. Ask the user; do not invent a benefit.

After each story, include a short quality-check block (details below). Don't skip this — it's the main defense against low-value stories slipping through.

## The INVEST check

Every story you produce must be examined against INVEST, and the result is always reported as a **per-principle inline block** under the narrative. Each of the six letters gets its own line with a verdict and a one-sentence reason — even when every principle passes.

This format is non-negotiable. A one-line "all criteria met" summary hides the reasoning and makes it impossible for the reviewer to sanity-check your judgement. Writing out each principle forces you to actually think about it, and gives the reader an at-a-glance signal of where the story is strong or weak. Treat the block as part of the story, not as decorative output.

Required shape (use this template, keeping each reason brief — a clause or short sentence, not a paragraph):

```
INVEST check:
- **I**ndependent — <pass/fail>: <reason>.
- **N**egotiable — <pass/fail>: <reason>.
- **V**aluable — <pass/fail>: <reason>.
- **E**stimable — <pass/fail>: <reason>.
- **S**mall — <pass/fail>: <reason>.
- **T**estable — <pass/fail>: <reason>.
```

The principles themselves:

- **I**ndependent — can this story be built without first completing another story? If not, it's dependency-locked.
- **N**egotiable — is this phrased as a goal open to discussion, rather than a fixed implementation?
- **V**aluable — does it deliver observable value to the named user role?
- **E**stimable — is there enough clarity that the team could ballpark the effort?
- **S**mall — could this realistically be completed in **1–2 days**, and certainly within a sprint? This is the single source of truth for the size threshold; the Splitting section below refers back here. If it feels larger, split it.
- **T**estable — is the outcome observable enough that someone could tell whether it was delivered? (Acceptance criteria come later — but the story should be testable in principle.)

INVEST is a lens, not a checklist to hide behind. If a story passes all six but still feels wrong, trust that instinct and flag it in a short note after the block.

## Anti-pattern detection (warn, don't block)

This skill uses a **systems-thinking** frame (Gojko Adzic, *Fifty Quick Ideas to Improve Your User Stories*) to catch low-value stories. A delivery team operates within three boundaries:

1. **Zone of Control** — things the team changes directly (code, schemas, configs).
2. **Sphere of Influence** — things the team affects but doesn't fully control (user behavior, business outcomes).
3. **External Environment** — things beyond the team's reach (regulation, vendor roadmaps).

A healthy story has its **User Need** in the Sphere of Influence and its **Deliverable** in the Zone of Control. When a story breaks this pattern, it usually falls into one of four traps. If you detect one, annotate the story with a ⚠ warning — do **not** silently refuse or rewrite. The user gets to decide what to do.

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

### 🚫 Dependency-Locked Story
The deliverable sits outside the team's Zone of Control (e.g., blocked on a 3rd-party vendor or a cross-team API that isn't yet contracted).
- Example: "As a learner, I can pay with Klarna, so that I can split my course fee." — when the Klarna contract isn't signed yet.
- Why flag: the team cannot deliver this in a sprint no matter how well it is written. It will sit in "In Progress" until the external dependency unblocks.
- Your warning should say: "⚠ Dependency-locked — deliverable requires `<external thing>`. Consider splitting: keep the in-team work as the story; track the external dependency separately."

### 🚫 Micro-Story
A large business story was sliced so thin that a sub-story no longer carries any real business risk on its own — it is technically inside the Zone of Control but has lost its link to user value.
- Example: "As a learner, I can click the login button, so that the click is recorded." (split off from a full login story).
- Why flag: acceptable as short-term sequencing; in mid-to-long-term plans it should be rolled back into a story that still carries user-visible value. Micro-stories clutter the backlog and inflate velocity without delivering outcomes.
- Your warning should say: "⚠ Looks like a Micro-Story — this sub-story has no standalone business risk. Consider regrouping it with its sibling stories under a single user-value-carrying story."

When in doubt, flag and explain. A false warning costs the user a few seconds of reading; a missed warning costs them a bad story in the sprint.

## Splitting large stories — SPIDR + extras

If a story fails INVEST-**S**mall (see above), split it before returning it. Apply whichever axis fits the material. The canonical taxonomy is **SPIDR** (Mike Cohn); we keep two extras that are not strictly SPIDR but frequently useful.

**SPIDR:**

- **S**pike — time-box a research spike first when the story fails INVEST-Estimable (unknown tech, unclear domain). A spike delivers *knowledge*, not the feature; split the feature out once the spike lands.
- **P**aths — split along workflow steps or decision branches: "Search" → "Add to cart" → "Checkout".
- **I**nterface — split by UI surface or channel: web vs. mobile, REST vs. webhook, read view vs. edit view.
- **D**ata — split by data subset or variant: filter by price first, filter by category next; EUR accounts first, multi-currency later.
- **R**ules — extract each complex business rule into its own story: one rule = one story = one testable outcome.

**Extras (keep, not strictly SPIDR):**

- **CRUD** — Create / Read / Update / Delete as separate stories when each carries its own user value.
- **Happy path vs. edge cases** — deliver the core flow first, then error handling, validation, and recovery as follow-up stories.

When you split, return the set of resulting stories and a one-line note explaining which axis you used, so the user can tell whether you picked the right one.

## Input flows

The skill supports several entry points. Infer which one applies from the user's request; ask if genuinely ambiguous.

### From scratch — raw functional requirements
The user pastes or describes unformatted requirements. Extract the distinct user-facing capabilities, identify the relevant user roles, and produce one story per capability. If requirements are vague (no clear user role, no clear benefit), ask targeted questions rather than inventing details.

### From scratch — rough story drafts
The user pastes existing story drafts that need improvement. Preserve their intent. Rewrite only what's necessary to match the format, fix anti-patterns, or split oversized stories.

**Explain the delta per story, inline.** Right after each rewritten story's INVEST block, add a short `**What Changed:**` section that lists the concrete edits you made to that draft and why — role change, solution-trap extraction, split rationale, etc. Keep it to 2–5 bullets. Don't collect everything into one trailing summary table at the bottom of the response: the reviewer is scanning story-by-story and the context is most useful sitting next to the story it describes. When a story was split, put the `**What Changed:**` block under the *first* split (or just above the group if you prefer) and explain the split axis there; the subsequent splits don't each need their own block unless something unusual happened to one of them.

**Don't invent system components.** Only reference user roles, pages, endpoints, screens, integrations, or concepts that appear in the input. If a rewrite seems to need something the draft doesn't mention (e.g., "where does the learner do this from?"), do not fabricate it. Ask a clarifying question instead — one or two targeted questions at the top of the response is fine, and it is much cheaper for the user to answer them than to spot invented scope in a rewritten story. The same rule applies to raw requirements: if the source is genuinely ambiguous about who the user is or what system they're acting within, ask.

### From a Confluence page
When a Confluence page URL or page ID is provided, read the page with `mcp__claude_ai_Atlassian__getConfluencePage` (or locate it first with `mcp__claude_ai_Atlassian__searchConfluenceUsingCql`) and treat its content as either raw requirements or draft stories, per the rules above. If the page has both, treat each section appropriately. If the user asks you to write improved stories back to the page, do so only after they've reviewed your draft.

### From/to Jira
When existing Jira issues are referenced, read them with `mcp__claude_ai_Atlassian__getJiraIssue` (or locate them first with `mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql`), treat their current Summary + Description as draft material, and produce improved versions. **Do not update Jira issues silently** — always show the user the proposed changes first. Creation of new Jira stories (`mcp__claude_ai_Atlassian__createJiraIssue`) or updates to existing ones (`mcp__claude_ai_Atlassian__editJiraIssue`) is a separate, explicit step the user will ask for; the skill's job ends once correctly formatted text is produced.

When creating or updating Jira, map:
- Title → Summary
- Connextra narrative → Description
- INVEST / anti-pattern notes → post as a comment (`mcp__claude_ai_Atlassian__addCommentToJiraIssue`) or leave in the description's review section; don't let them pollute the final Description once the user has accepted the story.

## Worked example

**Input (raw requirement):**
> Users should be able to recover their password when they forget it. Send an email with a link, the link expires after 24h, and they can set a new password.

**Output:**

**Title:** Reset password via emailed link

**As a** learner,
**I can** request a password reset and receive a link by email to set a new password,
**so that** I can regain access to my account without contacting support.

INVEST check:
- **I**ndependent — pass: no dependency on an unbuilt story in this backlog; assumes the standard auth/account foundation exists.
- **N**egotiable — pass: the narrative states the user goal, not a specific implementation (email provider, token format, UI).
- **V**aluable — pass: a locked-out learner regains access without a support ticket.
- **E**stimable — pass: familiar pattern, scope is bounded to request + email + reset.
- **S**mall — pass: fits within a sprint; the three sub-steps are tight.
- **T**estable — pass: "learner requests reset → receives email → sets new password → logs in" is a single observable scenario.

_Note: the 24h link expiry is an acceptance-criterion concern, not a story concern. I kept it out of the narrative so the story stays focused on the user goal. The expiry, email template, and rate-limiting will belong in the AC when those are written._

---

**Input (fake story):**
> As a developer, I want a script that resets the test database, so that I can run tests faster.

**Output:**

**Title:** Test-DB reset script (flagged — not a user story)

**As a** developer,
**I can** reset the test database with a script,
**so that** I can run tests faster.

INVEST check:
- **I**ndependent — pass: standalone tooling change.
- **N**egotiable — fail: the goal *is* the implementation ("a script"), so there's nothing left to negotiate.
- **V**aluable — fail: no end-user-visible value; benefit sits inside the team.
- **E**stimable — pass: scope is narrow.
- **S**mall — pass: a script, not a feature.
- **T**estable — pass: the script either resets the DB or it doesn't.

⚠ **Fake Story** — the need ("run tests faster") is inside the team's Zone of Control. This is a developer-productivity improvement, not a user-facing feature. Recommend tracking as a Task or Improvement Item. If kept as a story, the team should ask: who is the actual end user, and what observable business value does this deliver to them?

---

**Input (misleading story):**
> As an operator, I can run query optimization on the reports DB, so that monthly reports load faster.

**Output:**

**Title:** Monthly report loads without manual intervention (needs problem clarification)

**As an** operator,
**I can** open the monthly report and have it render without waiting on my own action,
**so that** I can complete month-end review on time.

INVEST check:
- **I**ndependent — pass: no dependency on an unbuilt story.
- **N**egotiable — pass (after rewrite): the goal is now the outcome, not a prescribed fix; "query optimization", caching, pre-aggregation, or async loading are all on the table.
- **V**aluable — pass: the operator can finish month-end on time.
- **E**stimable — fail: the underlying cause of slowness is not established — could be a query, a network hop, or a report size blow-up.
- **S**mall — unknown: depends on root cause.
- **T**estable — pass: "the monthly report renders without the operator running a maintenance step" is observable.

⚠ **Misleading Story** — the original `<goal>` ("run query optimization") is a prescribed solution. What is the operator actually trying to accomplish? Likely "finish month-end review on time" or "get report results before the close-of-business deadline." Please confirm the underlying need before committing to a fix. Once confirmed, the story may need a Spike (see Splitting → SPIDR → Spike) to identify the real bottleneck before it becomes estimable.

---

**Input (dependency-locked story):**
> As a learner, I can pay my course fee with Klarna, so that I can split the payment across instalments.

**Output:**

**Title:** Pay course fee with Klarna instalments (dependency-locked)

**As a** learner,
**I can** choose Klarna at checkout and split my course fee across instalments,
**so that** I can enrol without paying the full amount up front.

INVEST check:
- **I**ndependent — fail: delivery is blocked on a signed Klarna contract and SDK access, neither of which the team owns.
- **N**egotiable — pass: the narrative is outcome-based.
- **V**aluable — pass: lowers the enrolment barrier for price-sensitive learners.
- **E**stimable — fail: SDK surface and compliance requirements are unknown until the contract is finalised.
- **S**mall — unknown: likely multi-sprint once unblocked.
- **T**estable — pass (in principle): "learner selects Klarna → is redirected → returns with a paid or failed state."

⚠ **Dependency-locked** — deliverable requires the Klarna contract and SDK. Consider splitting: keep the in-team work as the story (e.g., a "third-party instalment provider" abstraction at the checkout layer); track the Klarna integration and contract as a separate dependency, not inside this story.

---

**Input (micro-story split off a larger login story):**
> As a learner, I can click the "Log in" button, so that my click is recorded.

**Output:**

**Title:** Log-in button click (flagged — micro-story)

**As a** learner,
**I can** click the "Log in" button,
**so that** my click is recorded.

INVEST check:
- **I**ndependent — pass: trivially isolated.
- **N**egotiable — fail: no room to negotiate — the goal is one UI event.
- **V**aluable — fail: clicking a button is not a user outcome; the learner still cannot log in.
- **E**stimable — pass: narrow.
- **S**mall — pass: arguably too small.
- **T**estable — pass: the click either fires an event or it doesn't.

⚠ **Micro-Story** — this sub-story has no standalone business risk. Consider regrouping it with its sibling stories under a single user-value-carrying story (e.g., "Log in with email and password, so that I can access my enrolled courses"). Click-tracking alone belongs in acceptance criteria or analytics instrumentation, not as its own story.

## Style and voice

- Write plainly. No jargon unless it's the user role's own jargon.
- Prefer concrete roles over "user". "Learner", "course admin", "content editor" beat "user" every time.
- Don't pad. A crisp three-line story beats a paragraph.
- Don't add Acceptance Criteria unless the user explicitly asked for them — ACs are out of scope for this skill.
- When flagging, be direct and brief. State the pattern, state the fix.

## When to push back

If the input is fundamentally not a user story (pure infrastructure work, internal process changes with no end-user surface, etc.), say so. Don't contort it into Connextra just because the user asked. A one-line "This reads as a Task, not a user story — want me to draft it that way, or is there an end user I'm missing?" saves everyone time downstream.