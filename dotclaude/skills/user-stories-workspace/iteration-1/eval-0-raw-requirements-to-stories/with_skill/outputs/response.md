# Lesson Feedback -- User Stories

Below are the user stories extracted from the PM's requirements. I split along **CRUD operations** (submit / edit / delete) and **by role** (learner vs. course admin), since each capability is independently valuable and deliverable. Platform scope is web only for now; mobile is explicitly deferred.

---

## Story 1

**Title:** Submit star rating and optional comment on a lesson

**As a** learner,
**I can** rate a lesson from 1 to 5 stars and optionally leave a text comment (up to 500 characters),
**so that** I can share my feedback on the lesson's quality with course staff.

INVEST: all criteria met. Story is independent, clearly estimable (single form submission), and testable (rating persists and is visible).

_Note: the 500-character limit and the 1-5 star constraint are acceptance-criteria details. They're mentioned in the narrative for context because they shape the user's interaction, but the precise validation rules belong in ACs._

---

## Story 2

**Title:** Edit own lesson feedback within 24 hours

**As a** learner,
**I can** edit my star rating and comment on a lesson within 24 hours of posting,
**so that** I can correct or refine my feedback while it is still fresh.

INVEST: all criteria met. Independent of the delete story; the 24h window is a single, clear business rule; outcome is observable (edited feedback is saved, edit is blocked after 24h).

---

## Story 3

**Title:** Delete own lesson feedback within 24 hours

**As a** learner,
**I can** delete my feedback on a lesson within 24 hours of posting,
**so that** I can withdraw feedback I no longer want associated with my account.

INVEST: all criteria met. Separate from edit -- a learner may want to remove feedback entirely rather than revise it. Testable: feedback disappears, and deletion is blocked after 24h.

---

## Story 4

**Title:** View aggregated lesson feedback on course dashboard

**As a** course admin,
**I can** see the average star rating, total number of ratings, and the 20 most recent comments for each lesson on the course dashboard,
**so that** I can quickly gauge learner sentiment and spot lessons that need attention.

INVEST: all criteria met. Independent (read-only view over submitted data). Estimable and small enough for a sprint. Testable: dashboard displays correct averages and comment list.

---

## Story 5

**Title:** Hide a policy-violating lesson comment

**As a** course admin,
**I can** hide an individual learner comment that violates content policy,
**so that** inappropriate content is removed from view without altering the learner's original text.

INVEST: all criteria met. Independent of the aggregated view (hiding is a separate action). The constraint that admins cannot edit learner text is a business rule for ACs. Testable: hidden comment no longer appears to other users; original text is preserved in the system.

---

## Split rationale

| Axis | Reason |
|---|---|
| **By CRUD** | Submit, edit, and delete are distinct learner actions with different business rules (the 24h lock applies to edit and delete but not to the initial submit). Keeping them separate lets the team ship "submit" first and layer in edit/delete afterward. |
| **By role** | Learner-facing and admin-facing capabilities have different UI surfaces (lesson page vs. course dashboard) and can be built and tested independently. |

## Additional notes

- **Mobile is out of scope for this iteration.** The PM explicitly deferred mobile. When it's picked up, a platform split (web vs. mobile) would produce parallel stories for each capability above.
- **24h lock-out rule:** This appears in both the edit and delete stories. If the team later finds the rule complex enough to warrant its own spike or technical story, it can be extracted -- but for now it reads as a straightforward time check, not a separate deliverable.
- **"Admins can't edit learner text"** is a constraint, not a story. It doesn't describe something a user can do; it restricts what they can't do. It belongs in acceptance criteria for Story 5 (and possibly as a broader platform policy note).
- **No acceptance criteria included** -- per Apprendere practice, ACs are a separate step. The stories above are ready for backlog grooming where the team can write ACs together.
