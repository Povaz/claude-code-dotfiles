Here are the stories I extracted from the PM's requirements. I split by user role (learner vs. course admin) and by CRUD / distinct capability, and kept the scope to **web only** per the "mobile can come later" note. The 24h edit/delete window and the 500-char cap are acceptance-criterion concerns — I kept them out of the narratives so each story stays focused on the user-visible goal.

---

**Title:** Leave a rating and comment on a lesson

**As a** course learner,
**I can** leave a star rating and an optional written comment on a lesson I'm taking,
**so that** I can share my experience of the lesson with the course team and other learners.

INVEST check:
- **I**ndependent — pass: the submit flow can be built before edit/delete or the admin views exist.
- **N**egotiable — pass: the narrative names the goal (leave feedback on a lesson), not a specific UI or storage design.
- **V**aluable — pass: gives the learner a voice in the course experience.
- **E**stimable — pass: one form, one submit action, one lesson context — scope is bounded.
- **S**mall — pass: single capability, fits comfortably in a sprint.
- **T**estable — pass: "learner opens lesson → submits rating (+ optional comment) → feedback is recorded" is one observable scenario.

**What Changed:**
- Extracted "submit feedback" as the first story so the rest of the backlog can build on it; the PM note bundled submit, edit, delete, and admin views into one paragraph.
- Kept the 1–5 scale and 500-char cap out of the narrative — those are acceptance criteria, not story-level concerns.
- Scoped to web per the PM's "web first" direction; a mobile counterpart can be cloned later.

---

**Title:** Edit my lesson feedback shortly after posting

**As a** course learner,
**I can** edit the rating and comment I left on a lesson for a short window after posting,
**so that** I can correct a mistake or refine my wording before it's locked in.

INVEST check:
- **I**ndependent — fail: depends on "Leave a rating and comment on a lesson" existing first.
- **N**egotiable — pass: the exact window length (24h) and the locked-state UX are open for discussion.
- **V**aluable — pass: learners can fix typos or misclicks without needing support.
- **E**stimable — pass: a scoped edit action on an existing record.
- **S**mall — pass: single action, single rule (the time window).
- **T**estable — pass: "within the window the learner can save changes; after the window the edit control is unavailable" is observable.

---

**Title:** Delete my lesson feedback shortly after posting

**As a** course learner,
**I can** delete the feedback I left on a lesson for a short window after posting,
**so that** I can retract it if I've changed my mind.

INVEST check:
- **I**ndependent — fail: depends on "Leave a rating and comment on a lesson".
- **N**egotiable — pass: retention rules, soft vs. hard delete, and confirmation UX are all open.
- **V**aluable — pass: gives the learner control over their own contribution.
- **E**stimable — pass: narrow scope — one destructive action gated by the same time rule.
- **S**mall — pass: trivially fits in a sprint.
- **T**estable — pass: "within window, delete succeeds and feedback disappears from aggregates; after window, delete is unavailable" is observable.

---

**Title:** See aggregated feedback for my course on the dashboard

**As a** course admin,
**I can** see the average star rating, the total number of ratings, and the most recent comments for my course on the course dashboard,
**so that** I can quickly gauge how learners are experiencing the course.

INVEST check:
- **I**ndependent — pass in principle: the admin view can be built against whatever feedback data exists, even a small seed set; in practice it follows the submit story.
- **N**egotiable — pass: "latest 20 comments" and the exact layout are open — the goal is "quickly gauge learner sentiment".
- **V**aluable — pass: gives course admins a single place to monitor learner feedback.
- **E**stimable — pass: one dashboard panel with three known elements (average, count, recent comments list).
- **S**mall — pass: one read-only view; no write paths.
- **T**estable — pass: "admin opens course dashboard → sees average, total, and recent comments that reflect actual submissions" is observable.

**What Changed:**
- Split admin scope into two stories: this read-only aggregation view, and the moderation action below. The PM paragraph merged them, but they have different risk profiles (read vs. destructive) and different release urgency.
- Left "latest 20" out of the narrative — it's a reasonable default but belongs in AC, not in the story text.

---

**Title:** Hide a learner comment that violates content policy

**As a** course admin,
**I can** hide an individual learner comment on a lesson,
**so that** content that violates our policy stops being visible to other learners and stakeholders.

INVEST check:
- **I**ndependent — fail: depends on learners being able to post comments, and on the admin aggregated view where the comment is surfaced.
- **N**egotiable — pass: the narrative names the outcome (stop showing the comment), not a specific mechanism (soft-delete, flag, moderation queue).
- **V**aluable — pass: protects learners and the course brand from policy-violating content.
- **E**stimable — pass: one moderation action on an existing comment record.
- **S**mall — pass: single action with a clear rule — admins can hide but cannot edit learner text.
- **T**estable — pass: "admin hides a comment → comment is no longer visible in the dashboard or to other learners; rating may or may not still count, per AC" is observable.

_Note: the PM explicitly called out "admins can't edit learner text" — that's a guardrail belonging in acceptance criteria, not a separate story. I've kept it out of the narrative but flagged it here so the AC author doesn't miss it._

---

_Split strategy: by user role (learner / course admin) and then by CRUD — Create, Update, Delete for the learner; Read (aggregated) and a bounded moderation action for the admin. Mobile is deliberately not represented; when it's picked up, clone the learner-side stories with a platform qualifier._
