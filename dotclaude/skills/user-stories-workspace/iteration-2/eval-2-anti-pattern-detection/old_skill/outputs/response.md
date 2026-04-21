Here are the three tickets formatted as user stories per Apprendere house style. Two of them triggered anti-pattern warnings worth discussing with the team before they go into the sprint.

---

**Title:** Faster monthly reports for ops engineers

**As an** ops engineer,
**I can** run the monthly reports from the reporting service and get results in a timeframe that fits my workflow,
**so that** I can deliver month-end data to stakeholders without waiting on long-running queries.

⚠ **Misleading Story (Solution Trap)** — the original goal ("database query optimization") reads as a prescribed technical solution rather than a user need. I rewrote the narrative around the underlying problem (reports are too slow), but the team should confirm with the ops engineer what "faster" actually means (target runtime? specific report? a particular pain point?). Query optimization is one possible fix; indexing, pre-aggregation, caching, or scheduling changes might be equally valid. Keep the *what* here; move the *how* to the implementation discussion.

---

**Title:** Upload 4K videos to courses

**As a** content editor,
**I can** upload 4K videos to a course and have them play back for learners at full quality,
**so that** I can publish high-fidelity video content without quality loss or manual workarounds.

⚠ **Dependency-locked** — deliverable requires the new VendorX video encoding integration, which sits outside the team's Zone of Control. Consider splitting: keep "Upload 4K videos to courses" as the user-facing story, and track the VendorX integration work as a separate technical dependency (Task or spike) so the story isn't blocked end-to-end on a vendor milestone. Also worth confirming: is VendorX already contracted and available, or is this still in evaluation?

---

**Title:** Notify learners when a new lesson is published

**As a** learner,
**I can** receive a push notification when a course I'm enrolled in publishes a new lesson,
**so that** I stay up to date with my learning without having to check the course manually.

✓ INVEST: all criteria met. The user role is concrete, the benefit is clear, the outcome is observable (notification arrives), and the scope is sprint-sized. Acceptance criteria (notification content, opt-out, delivery channel specifics, handling of learners who disabled notifications) should be captured separately when the story is groomed.

---

_Note on changes: I reworded story 1 to de-couple it from the proposed solution, and flagged story 2 as dependency-locked so the sprint doesn't inherit vendor risk silently. Story 3 was already well-shaped — I only adjusted the phrasing to match the "I can" house style and tightened the benefit clause._
