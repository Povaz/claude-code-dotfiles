Here are your three tickets formatted as user stories per Apprendere's agile practices. Two of the three triggered anti-pattern warnings — read the flags carefully before pulling them into the sprint.

---

### Story 1

**Title:** Faster monthly report generation (flagged — solution prescribed)

**As an** ops engineer,
**I can** generate monthly reports in less time,
**so that** I can identify and act on operational data without long waits.

⚠ **Misleading Story (Solution Trap)** — the original draft asks for "database query optimization," which is a prescribed technical solution, not a user need. The real question is: what does the ops engineer actually need to accomplish with those reports? If the answer is "find data discrepancies quickly" or "meet an SLA for report delivery," the story should say that. Query optimization may or may not be the right fix — that decision belongs to the team during implementation, not in the story.

Also worth asking: is the ops engineer the right role here, or is someone else (e.g., a finance analyst, a team lead) the actual consumer of these reports? Clarifying the real end user will sharpen the value statement.

✓ INVEST (post-rewrite): Independent, negotiable, valuable, estimable, small (depends on scope — may need splitting once root cause is understood), testable (report generation time is measurable).

---

### Story 2

**Title:** Upload 4K videos to courses (flagged — dependency-locked and solution prescribed)

**As a** content editor,
**I can** upload 4K videos to courses,
**so that** learners have access to high-resolution course content.

⚠ **Misleading Story (Solution Trap)** — the original draft names a specific vendor solution ("new video encoding from VendorX"). The user need is uploading 4K video; *how* the encoding works is an implementation detail. Stating the vendor in the story locks the team into one approach before alternatives are explored.

⚠ **Dependency-Locked** — deliverable requires VendorX's encoding integration, which sits outside the team's Zone of Control. Consider splitting: (1) an in-team story for the upload and playback experience, and (2) a separate tracked dependency for the VendorX integration work and any contract/timeline coordination.

INVEST check:
- **I**ndependent: fails — blocked on VendorX integration.
- **N**egotiable: fails as originally written (vendor is baked in); passes after rewrite.
- **V**aluable: yes — content editors gain a concrete new capability.
- **E**stimable: partially — depends on VendorX delivery timeline.
- **S**mall: likely needs splitting (upload flow vs. encoding pipeline vs. playback support).
- **T**estable: yes — "can a content editor upload a 4K video and have it play back correctly?"

---

### Story 3

**Title:** Push notification for new lessons in enrolled courses

**As a** learner,
**I can** receive a push notification when a new lesson is added to a course I'm enrolled in,
**so that** I stay up to date and don't miss new content.

✓ INVEST: all criteria met. Story is independent, negotiable (notification channel and timing are open to discussion), valuable (learner gets timely awareness), estimable, small enough for a sprint, and testable (enroll in course, add lesson, verify notification arrives).

---

### Notes on changes made

- **"I want" changed to "I can"** across all three stories, per Apprendere house style.
- **Story 1** was rewritten to remove the prescribed solution ("database query optimization") from the goal. The title and narrative now focus on the user-visible outcome. I left a question about whether "ops engineer" is really the right role.
- **Story 2** was rewritten to remove the vendor name and focus on the content editor's actual capability. Two anti-pattern flags were raised (solution trap + dependency lock), and a splitting suggestion was provided.
- **Story 3** required only the "I want" to "I can" fix. No anti-patterns detected.
