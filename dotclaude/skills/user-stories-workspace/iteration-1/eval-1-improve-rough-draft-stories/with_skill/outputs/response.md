Here are your three draft stories reviewed and rewritten to match our house style. I preserved your intent in each case but made adjustments for format, role specificity, anti-patterns, and sizing. See the notes after the stories for a summary of what changed and why.

---

## Story 1 (rewritten)

**Title:** Download course-completion certificate as PDF

**As a** learner,
**I can** download a PDF certificate from my course-completion page,
**so that** I have a portable record of my achievement.

✓ INVEST: all criteria met. The story is independent, sized to a sprint, negotiable (doesn't prescribe the PDF engine or delivery mechanism), and testable (learner clicks download, gets a valid PDF).

---

## Story 2 (flagged -- not a user story)

**Title:** Certificate-download endpoint wiring (flagged -- not a user story)

**As a** developer,
**I can** call a `/certificate` endpoint from the completion page,
**so that** the front-end can trigger certificate generation.

⚠ **Fake Story** -- the named role is "developer" and the need ("call an endpoint") is inside the team's Zone of Control. There is no end-user-visible outcome here; this is implementation work that supports Story 1. Recommend tracking as a Task or sub-task of Story 1 rather than a standalone user story. If there is a genuine end-user need hiding behind this draft, let's surface it -- otherwise drop the Connextra format and file it as a Task.

---

## Story 3 (split -- original was too broad)

The original draft packed four distinct user actions into one story (download, share on LinkedIn, print, email to HR). Each involves different integrations, UI flows, and acceptance criteria, so I split along **workflow step / channel**.

### Story 3a

**Title:** Download course-completion certificate as PDF

**As a** learner,
**I can** download my course-completion certificate as a PDF,
**so that** I have an offline copy of my credential.

✓ INVEST: all criteria met. Note: this overlaps with Story 1 above. If they describe the same capability, consolidate into a single story.

### Story 3b

**Title:** Share certificate on LinkedIn

**As a** learner,
**I can** share my certificate directly to LinkedIn from the completion page,
**so that** I can showcase my achievement to my professional network.

✓ INVEST: all criteria met.

### Story 3c

**Title:** Print certificate from completion page

**As a** learner,
**I can** print my certificate from the completion page,
**so that** I have a physical copy for my records.

✓ INVEST: all criteria met. Likely a small story (browser print dialog on the PDF), but worth keeping separate so the team can prioritize it independently.

### Story 3d

**Title:** Email certificate to a specified address

**As a** learner,
**I can** email my certificate to an address I specify (e.g., my HR department),
**so that** I can provide proof of completion to people who need it.

✓ INVEST: all criteria met. This is the most complex of the four splits (email delivery, input validation, confirmation UX), so it deserves its own estimation.

*Split strategy: by channel/action -- each delivery method (download, LinkedIn, print, email) is an independent capability with different implementation work and value.*

---

## Summary of changes

| Draft | Key changes | Reason |
|-------|------------|--------|
| **1** | Removed implementation details (template engine, signed S3 URL). Changed role from "user" to "learner". Changed "I want" to "I can". Rephrased the goal as observable user behavior. | The original prescribed a technical solution (template engine, S3 signed URLs) -- that belongs in implementation notes, not the story narrative. "User" is too vague; "learner" matches our domain. "I can" is house style. |
| **2** | Flagged as Fake Story. | The role is "developer" and the goal is an internal wiring task with no end-user outcome. Should be a Task. |
| **3** | Split into four stories (download, LinkedIn share, print, email). Changed "I want to be able to" to "I can". Gave each split a concrete title. | The original violated the **S**mall criterion in INVEST -- four unrelated features in one story make it unestimable and hard to deliver incrementally. Each split is independently valuable and deployable. |
