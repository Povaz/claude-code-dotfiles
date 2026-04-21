Here are the three tickets rewritten in Apprendere's house style. Two of them trip anti-pattern checks — I've flagged them rather than silently reshaping them, since the call on what to do is yours.

---

**Title:** Faster monthly reports from the reporting service

**As an** ops engineer,
**I can** run the monthly reports on the reporting service and get results in an acceptable timeframe,
**so that** I can deliver monthly reporting to stakeholders without the run blocking my day.

INVEST check:
- **I**ndependent — pass: no dependency on other stories in this batch.
- **N**egotiable — fail: the original draft fixes the solution ("database query optimization"); the narrative above opens it back up, but the source ticket is prescriptive.
- **V**aluable — pass: faster monthly reporting is observable value to ops and to report consumers.
- **E**stimable — fail: "acceptable timeframe" is undefined, and without knowing which queries or reports are slow the team can't ballpark effort.
- **S**mall — unknown: depends heavily on which reports and queries are in scope; could easily exceed a sprint if broad.
- **T**estable — fail: no target duration means "faster" can't be objectively verified.

**What Changed:**
- Reframed from the prescribed solution ("database query optimization") to the user-visible outcome (monthly reports finishing in acceptable time). The original is a classic Solution Trap.
- Kept the role as "ops engineer" since that's the named user, though it's worth confirming ops is the actual end consumer rather than an internal proxy.

⚠ **Misleading Story (Solution Trap)** — "database query optimization" is a prescribed implementation, not a user need. What's the underlying problem? E.g., "the monthly report takes 6 hours and blocks ops for a workday" would give the team room to consider caching, pre-aggregation, incremental rollups, or query tuning — whichever is cheapest. Before committing this to the sprint, get a concrete target ("monthly reports complete in under X minutes") and identify which report(s) are painful today.

---

**Title:** Upload 4K videos to courses

**As a** content editor,
**I can** upload 4K videos when authoring a course,
**so that** I can publish high-resolution video content to learners.

INVEST check:
- **I**ndependent — fail: delivery depends on the VendorX encoding integration being available; blocked on an external party.
- **N**egotiable — pass: the narrative states the user goal (upload 4K); the encoding vendor is an implementation choice, not part of the story.
- **V**aluable — pass: content editors gain a capability they don't have today, and learners see higher-quality video.
- **E**stimable — partial: the in-team integration work is estimable; the vendor-side readiness and API maturity are not.
- **S**mall — unknown: a first vendor integration typically spans more than a sprint once auth, webhooks, error handling, and playback are included.
- **T**estable — pass: a content editor either can or can't upload a 4K file and see it play back in a course.

**What Changed:**
- Removed the vendor name from the narrative — "VendorX" is an implementation choice, not part of the user goal.
- Reframed from "integrate the encoder" (a task) to "upload 4K videos" (the user-visible outcome).

⚠ **Dependency-Locked Story** — the deliverable requires VendorX's encoding integration, which sits outside the team's Zone of Control. Recommend splitting: keep "Upload 4K videos to courses" as the user-facing story, and track "Integrate VendorX encoding pipeline" separately as a technical enabler/spike with its own timeline. That way the sprint commitment isn't hostage to vendor responsiveness, and the user story can land the moment the enabler is ready.

---

**Title:** Notify me when my enrolled course has a new lesson

**As a** learner,
**I can** receive a push notification when a course I'm enrolled in publishes a new lesson,
**so that** I don't miss new content in courses I'm following.

INVEST check:
- **I**ndependent — pass: can be built without waiting on another story in this batch.
- **N**egotiable — pass: the narrative describes the outcome (a notification on new-lesson publish), not the transport, template, or timing policy.
- **V**aluable — pass: clear learner-facing value — staying current with enrolled courses without manually checking.
- **E**stimable — pass: familiar pattern (event → notification), scope is bounded to one trigger and one channel.
- **S**mall — pass: single trigger, single channel, single user role; fits within a sprint.
- **T**estable — pass: publish a new lesson in an enrolled course, confirm the enrolled learner's device receives a push.

This is the cleanest of the three — no anti-pattern warning. Worth confirming up front whether push is the only channel (vs. also email / in-app), and whether learners need an opt-out preference; both are natural follow-ups but not needed in the story itself.

---

**Summary of flags:**
- Story 1 (reporting): Misleading Story — needs the underlying problem surfaced before it's sprint-ready.
- Story 2 (4K video): Dependency-Locked — recommend splitting the vendor integration out as a separate enabler.
- Story 3 (push notifications): Clean. Ready to refine into acceptance criteria when you want.
