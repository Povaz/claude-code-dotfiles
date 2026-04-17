# Certificate-Download Feature — Rewritten Stories

Below are your three draft stories rewritten to follow Apprendere house style. After each story I note what changed and why.

---

## Story 1

**Title:** Download course-completion certificate as PDF

**As a** learner,
**I can** download a PDF certificate after completing a course,
**so that** I have a portable, verifiable record of my achievement.

INVEST: all criteria met. Story is independent, deliverable within a sprint, and the outcome is directly observable (learner receives a downloadable PDF).

**What changed:** The original story ("As a user, I want the system to generate a PDF certificate using the new template engine and make it available via a signed S3 URL...") had three problems:

1. **Vague role** — "user" was replaced with "learner," which is the actual person who benefits.
2. **Solution trap** — the goal prescribed implementation details (template engine, signed S3 URL). Those are engineering decisions, not user needs. The story now states the user-visible outcome ("download a PDF certificate") and leaves the how to the team.
3. **"I want" wording** — changed to "I can" per house style.

---

## Story 2

**Title:** Certificate download button on completion page (flagged -- not a user story)

**As a** developer,
**I can** add a certificate-download button to the completion page,
**so that** learners can retrieve their certificate.

**Fake Story** — the role is "developer" and the goal ("add a button that calls an endpoint") is inside the team's Zone of Control. This is an implementation task, not a user-facing story. Recommend tracking as a Task under Story 1 instead. If there is a genuine end-user angle here, the story is already covered by Story 1 above (learner downloads a certificate). The UI placement and endpoint wiring are delivery details, not separate stories.

**What changed:** Reformatted into Connextra for reference, but flagged it as a Fake Story. The original had no "so that" clause and described a technical task ("calls the /certificate endpoint"), not a user outcome.

---

## Story 3

The original story ("download certificates, share them on LinkedIn, print them, and email them to my HR department") bundles at least four distinct user actions into one story. That is too large for a single sprint item and violates the **S** (Small) criterion of INVEST. Split **by workflow step** — each action is an independent capability a learner can use separately.

### Story 3a

**Title:** Download course-completion certificate as PDF

**As a** learner,
**I can** download my course-completion certificate as a PDF,
**so that** I have an offline copy of my credential.

INVEST: all criteria met. Note — this overlaps with Story 1 above. If both are kept, consolidate them into a single story.

### Story 3b

**Title:** Share certificate on LinkedIn

**As a** learner,
**I can** share my certificate directly to LinkedIn from the completion page,
**so that** I can showcase my achievement to my professional network.

INVEST: all criteria met.

### Story 3c

**Title:** Print certificate

**As a** learner,
**I can** print my certificate,
**so that** I have a physical copy for my records or to present in person.

INVEST: all criteria met.

### Story 3d

**Title:** Email certificate to a third party

**As a** learner,
**I can** email my certificate to a specified recipient (e.g., my HR department),
**so that** I can provide proof of completion without needing to download and forward it manually.

INVEST: all criteria met.

**Split strategy used:** by workflow step. Each action (download, share, print, email) is independently valuable and can be built and delivered separately.

---

## Summary of changes across all three drafts

| Issue | Where found | Fix applied |
|---|---|---|
| Vague role ("user") | Story 1 | Changed to "learner" |
| Solution in the goal (template engine, S3 URL, /certificate endpoint) | Stories 1 and 2 | Rewritten around user-visible outcome |
| "I want" instead of "I can" | All three | Changed to "I can" per house style |
| Missing "so that" clause | Story 2 | Added benefit clause |
| Fake Story (developer task dressed as story) | Story 2 | Flagged; recommend tracking as a Task |
| Too large / multiple capabilities in one story | Story 3 | Split into four independent stories |
| Overlap between stories | Stories 1 and 3a | Noted; recommend consolidating |
