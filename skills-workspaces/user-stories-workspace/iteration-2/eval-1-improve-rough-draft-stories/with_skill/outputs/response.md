Here are your three drafts rewritten in Apprendere house style. A couple of them needed more than a light touch — draft #2 reads as a task rather than a user story, and draft #3 is really four stories packed into one and needs to be split. Details are in the `**What Changed:**` blocks under each story.

One clarifying question before you take these further: draft #1 mentions "the new template engine" and "a signed S3 URL" — these are implementation details I've kept out of the rewritten narrative (they belong in acceptance criteria or tech notes). If either of those is actually a user-visible constraint rather than an implementation choice, let me know and I'll adjust.

---

## Story 1 — rewritten from draft #1

**Title:** Download completion certificate as PDF

**As a** learner,
**I can** download a PDF certificate once I've completed a course,
**so that** I have a shareable record of my achievement.

INVEST check:
- **I**ndependent — pass: the download flow can be built on its own; no prerequisite story.
- **N**egotiable — pass: the narrative states the goal (get a downloadable certificate), not the mechanism (template engine, S3, signed URLs).
- **V**aluable — pass: learners get tangible proof of completion they can keep and share.
- **E**stimable — pass: scope is bounded to "generate on demand, deliver to the learner".
- **S**mall — pass: single user action with a single observable outcome.
- **T**estable — pass: "learner completes course → requests certificate → receives a valid PDF" is one scenario.

**What Changed:**
- Role changed from "user" to "learner" — the more concrete Apprendere role.
- Stripped implementation detail from the narrative: "new template engine" and "signed S3 URL" are solution choices, not user needs. They belong in acceptance criteria or a tech-design note, not in the story.
- Reframed "so that learners can download it" (circular — the goal restated as the reason) into a real user benefit: having a shareable record of the achievement.
- Switched "I want" → "I can" per house style.

---

## Story 2 — rewritten from draft #2

**Title:** Add certificate-download button to completion page (flagged — not a user story)

**As a** developer,
**I can** add a button to the completion page that calls the `/certificate` endpoint,
**so that** the download action is wired up in the UI.

INVEST check:
- **I**ndependent — pass: standalone UI change.
- **N**egotiable — fail: the goal *is* the implementation ("add a button that calls this endpoint"), so there's nothing left to negotiate.
- **V**aluable — fail: the named user is a developer and the benefit sits entirely inside the team; no end-user-visible value is stated.
- **E**stimable — pass: narrow, concrete scope.
- **S**mall — pass: a single UI element.
- **T**estable — pass: the button exists and calls the endpoint, or it doesn't.

⚠ **Fake Story** — the need is internal implementation work, not a learner-facing outcome. The "developer adds a button" framing is a task dressed as a story. The actual user-facing behavior this enables ("a learner can download their certificate from the completion page") is already covered by Story 1 — the button is an implementation detail of that story, not a separate story. Recommend tracking this as a **sub-task of Story 1** (or dropping it entirely and letting Story 1's acceptance criteria specify that the action is reachable from the completion page).

**What Changed:**
- Kept the Connextra shape so you can see the flag applies, but flagged it as a Fake Story rather than silently rewriting it into something it isn't.
- Minimally cleaned the wording; deliberately did *not* invent a learner-facing narrative to disguise this as a user story.
- Called out the overlap with Story 1, which is where this work should actually live.

---

## Stories 3a–3d — split from draft #3

Draft #3 bundles four distinct learner actions ("download", "share on LinkedIn", "print", "email to HR") behind one "so that". Each is an independent user flow with its own integration surface (file system, LinkedIn, printer, email), different effort, and different risk. Per the skill's **split-by-workflow-step** strategy, I've broken them into four stories so they can be prioritised, estimated, and shipped independently. Story 3a is effectively a duplicate of Story 1 — I've left it in so the split is complete, but you'll likely want to merge it with Story 1 rather than track both.

---

**Title:** Download completion certificate as PDF

**As a** learner,
**I can** download my certificate as a PDF,
**so that** I can keep a personal copy of proof I completed the course.

INVEST check:
- **I**ndependent — pass: no prerequisite story.
- **N**egotiable — pass: "download a PDF" is the goal, not a prescribed mechanism.
- **V**aluable — pass: learner gets a keepable record.
- **E**stimable — pass: well-understood flow.
- **S**mall — pass: single action.
- **T**estable — pass: learner triggers download → receives a valid PDF.

**What Changed (applies to the whole 3a–3d split):**
- Split the original four-goal story along workflow-step / channel lines: download, LinkedIn share, print, email. Each is a separate user flow with its own integration and its own effort, so they shouldn't ride on one ticket.
- Replaced the blanket "so that I can demonstrate my achievements" with a channel-appropriate reason per story (personal record, professional visibility, physical display, HR evidence).
- Role stayed "learner" — already concrete.
- Switched "I want to be able to" → "I can" per house style.
- Note: **3a duplicates Story 1** from the earlier rewrite. Recommend merging rather than tracking both.

---

**Title:** Share certificate to LinkedIn

**As a** learner,
**I can** share my certificate to LinkedIn from the completion page,
**so that** my professional network can see the credential.

INVEST check:
- **I**ndependent — pass: can be built after download exists, but doesn't block or require other share channels.
- **N**egotiable — pass: "share to LinkedIn" is the goal; the integration mechanism (LinkedIn Add-to-Profile, OAuth share, image post, etc.) is open.
- **V**aluable — pass: visible professional credibility is a direct learner benefit.
- **E**stimable — partial: estimable once the LinkedIn integration approach is chosen; flag as a small unknown.
- **S**mall — pass: one channel, one action.
- **T**estable — pass: learner clicks share → certificate appears on their LinkedIn profile/feed.

⚠ **Dependency-locked (mild)** — deliverable depends on LinkedIn's external sharing API, which constrains options (e.g. Add-to-Profile vs. share dialog). Not a hard blocker, but flag it during estimation so the team picks the integration approach before committing.

---

**Title:** Print completion certificate

**As a** learner,
**I can** print my certificate directly from the completion page,
**so that** I can display or file a physical copy.

INVEST check:
- **I**ndependent — pass: can be delivered independently; typically reuses the PDF from the download story but doesn't require the other share channels.
- **N**egotiable — pass: the goal is "print", not a specific print-styling approach.
- **V**aluable — pass: learners who want a physical copy get one without extra steps.
- **E**stimable — pass: print-friendly layout is a bounded piece of work.
- **S**mall — pass: one action.
- **T**estable — pass: learner triggers print → print dialog opens with a correctly laid-out certificate.

---

**Title:** Email certificate to HR

**As a** learner,
**I can** email my certificate to my HR department from the completion page,
**so that** my employer has evidence of the training for their records.

INVEST check:
- **I**ndependent — pass: independent of the other share channels.
- **N**egotiable — pass: "email the certificate" is the goal; the mechanism (client `mailto:` vs. server-side send, attachment vs. link) is open.
- **V**aluable — pass: saves the learner a manual forwarding step and gets training on HR's record.
- **E**stimable — pass: once the send mechanism is chosen.
- **S**mall — pass: one channel, one action.
- **T**estable — pass: learner enters/selects an HR address → HR receives the certificate.

_Note: the source draft doesn't say whether "email to HR" means a client-side `mailto:` handoff (cheap, no backend work) or a server-side send with a stored HR address per learner (much bigger). Worth clarifying before estimating — the difference is roughly one story vs. a small epic._

---

## Summary of what I'd do with this set before sprinting it

- **Merge** Story 3a into Story 1 — they're the same story.
- **Drop or demote** Story 2 to a sub-task of Story 1.
- **Clarify** the "email to HR" mechanism (Story 3d) before estimating.
- **Resolve** my clarifying question at the top about whether "new template engine" / "signed S3 URL" are implementation choices or user-visible constraints.
