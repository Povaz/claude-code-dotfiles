Here are the rewritten stories in our house style. I kept the original intent where possible, dropped implementation details from the narratives, and flagged anti-patterns rather than silently rewriting them.

---

## Story 1 — rewritten

**Title:** Download completion certificate as PDF

**As a** learner,
**I can** download a PDF certificate once I complete a course,
**so that** I have a shareable record of my achievement.

✓ INVEST: all criteria met. Story is independent, deliverable within a sprint, and the outcome is observable (learner ends up with a PDF in hand).

_What I changed:_ the original draft named the template engine and the signed S3 URL in the narrative. Those are implementation choices (the "how"), so I moved them out. The learner's observable goal is "I got my PDF"; the delivery mechanism is an acceptance-criterion / tech-design concern. Role shifted from "user" to "learner" per house style.

---

## Story 2 — rewritten (and flagged)

**Title:** Download button on completion page (flagged — reads as a task)

**As a** learner,
**I can** trigger the certificate download directly from the course-completion page,
**so that** I don't have to hunt for my certificate after finishing a course.

⚠ **Misleading Story (Solution Trap)** — the original draft ("add a button to the completion page that calls the /certificate endpoint") is phrased entirely as an implementation task from a developer's point of view. I rewrote it around the learner's underlying need: a frictionless way to get to their certificate the moment they've earned it. If the real intent was purely "wire up the button" as a dev task, this should be tracked as a Task, not a story — or folded into Story 1's acceptance criteria.

_What I changed:_ role flipped from "developer" to "learner" (a developer isn't the end user here). Dropped the button and the `/certificate` endpoint from the narrative — both are "how". Reframed the benefit around discoverability/friction rather than the technical wiring.

---

## Story 3 — split

The original draft bundles four distinct learner actions (download, share to LinkedIn, print, email to HR). That's too large for one story and blends very different delivery surfaces (a file download vs. a LinkedIn integration vs. a print layout vs. an email flow). Splitting **by user action / workflow step**:

### 3a

**Title:** Download completion certificate as PDF

**As a** learner,
**I can** download my certificate as a PDF,
**so that** I can keep a personal copy of my achievement.

✓ INVEST: all criteria met.

_Note:_ this overlaps with Story 1. In the final backlog they should be merged — I've kept it here so the split is visible.

### 3b

**Title:** Share certificate to LinkedIn

**As a** learner,
**I can** share my certificate to my LinkedIn profile,
**so that** I can showcase my achievement to my professional network.

⚠ **Dependency-locked** — deliverable depends on LinkedIn's "Add to profile" certification API and its current terms. Consider splitting: keep the in-team work (button, metadata payload, success/failure UX) as the story, and track the LinkedIn integration / credentials as a separate dependency.

### 3c

**Title:** Print-friendly certificate layout

**As a** learner,
**I can** print my certificate with a layout designed for standard paper sizes,
**so that** I can display a physical copy.

✓ INVEST: all criteria met. Small, testable (the printed output either fits the page cleanly or it doesn't).

### 3d

**Title:** Email certificate to a chosen recipient

**As a** learner,
**I can** email my certificate to an address I choose (e.g. my HR department),
**so that** I can submit proof of completion without downloading and re-attaching the file myself.

✓ INVEST: all criteria met.

_What I changed on Story 3 overall:_ removed "HR department" from the role/goal and made it an example of a recipient — the underlying capability ("email it to someone") is the real need and doesn't need to hard-code HR. Split strategy: **by user action**, because each action has a different delivery surface and can ship independently.

---

## Summary of edits

- Story 1: stripped implementation detail (template engine, signed S3 URL) out of the narrative.
- Story 2: flagged as a Solution-Trap / possible Task; rewrote from the learner's perspective.
- Story 3: split into four stories by user action; flagged 3b as dependency-locked on LinkedIn; noted 3a overlaps with Story 1 and should be merged.
- Applied house style throughout: **I can** phrasing, concrete role ("learner") instead of "user", English, Title + Connextra + INVEST block per story.
