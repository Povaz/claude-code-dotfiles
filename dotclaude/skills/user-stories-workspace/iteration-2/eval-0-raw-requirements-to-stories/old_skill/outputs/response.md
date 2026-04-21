Here are the user stories extracted from the PM's requirements. I split them by user role (learner vs. course admin) and then by CRUD/capability so each story stays small, independent, and testable. Mobile is explicitly deferred per the PM, so I haven't drafted mobile stories — the web stories below are scoped to web only.

---

**Title:** Leave a star rating and comment on a lesson

**As a** learner,
**I can** give a lesson a 1–5 star rating and optionally add a short written comment,
**so that** I can share my reaction to the lesson and help improve the course.

✓ INVEST: all criteria met. The rating-plus-optional-comment pair is one user action; splitting them would produce an artificial half-feature. The 500-character limit is an acceptance-criterion concern, not a story concern.

---

**Title:** Edit my own lesson feedback shortly after posting

**As a** learner,
**I can** edit the star rating or comment I left on a lesson within a limited window after posting,
**so that** I can correct mistakes or refine my feedback while it's still fresh.

✓ INVEST: all criteria met. Independent of the delete story — users may want to fix typos without removing the whole entry. The exact 24h window is an AC detail.

---

**Title:** Delete my own lesson feedback shortly after posting

**As a** learner,
**I can** delete feedback I left on a lesson within a limited window after posting,
**so that** I can retract feedback I no longer stand behind.

✓ INVEST: all criteria met. Kept separate from editing so each can be built, tested, and released independently.

---

**Title:** See aggregated lesson feedback on the course dashboard

**As a** course admin,
**I can** see the average star rating, total number of ratings, and the latest comments for each lesson on the course dashboard,
**so that** I can quickly gauge how learners are responding to the course content.

✓ INVEST: all criteria met. The specific "latest 20" count is an AC concern, not a story concern — keeping it negotiable leaves room for UX to tune the number.

---

**Title:** Hide a learner comment that violates content policy

**As a** course admin,
**I can** hide an individual learner comment from the course dashboard and any learner-visible views,
**so that** comments violating our content policy don't remain visible while preserving the original text for audit.

✓ INVEST: all criteria met. The explicit "admins cannot edit learner text" rule reinforces that this is a visibility action, not an editorial one — that's captured in the "hide" verb and belongs in the AC as a negative check.

---

_Notes on choices made:_

- **Split strategy:** primarily by CRUD (create / edit / delete on the learner side) and by user role (learner vs. admin). Edit and delete are separate stories because they're independently valuable and independently testable — a learner benefits from being able to delete even if editing ships later, and vice versa.
- **Kept out of the narratives (belongs in Acceptance Criteria):** the 500-character comment limit, the 24-hour edit/delete window and post-lock behavior, the "latest 20 comments" count, the exact admin hide/unhide UX, and audit-log retention for hidden comments. These are important but are AC-level detail; putting them in the story narrative would make the stories less negotiable and harder to keep small.
- **Platform scoping:** the PM called out "web first, mobile can come later." I've written these as web stories implicitly (they're the first delivery). When mobile is picked up, the same stories should be re-drafted per-platform or the existing ones extended with mobile ACs — worth a conversation then.
- **No anti-patterns detected:** each story has its user need in the Sphere of Influence (learner satisfaction, admin oversight, content-policy compliance) and its deliverable in the Zone of Control (feedback UI, dashboard widgets, moderation action).
