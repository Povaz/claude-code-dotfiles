# User Stories: Lesson Feedback Feature

## Epic: Lesson Feedback (Web)

Allow course learners to leave ratings and comments on lessons, with time-limited editing and admin moderation capabilities.

---

### Story 1: Submit Lesson Feedback

**As a** course learner,
**I want to** leave a star rating (1-5) and an optional text comment on a lesson,
**so that** I can share my experience and help improve the course content.

**Acceptance Criteria:**

- Learner can select a rating from 1 to 5 stars (whole numbers only; rating is required).
- Learner can optionally add a text comment of up to 500 characters.
- A character counter is displayed showing remaining characters as the learner types.
- The system prevents submission if the comment exceeds 500 characters.
- Learner can only submit one feedback entry per lesson (subsequent submissions are blocked with a clear message).
- On successful submission, the learner sees a confirmation and their posted feedback.
- The feedback is timestamped with the date and time of submission.

---

### Story 2: Edit Own Feedback Within 24 Hours

**As a** course learner,
**I want to** edit my feedback (rating and/or comment) within 24 hours of posting,
**so that** I can correct mistakes or update my thoughts while they are still fresh.

**Acceptance Criteria:**

- An "Edit" option is visible on the learner's own feedback when it is less than 24 hours old.
- The learner can modify the star rating, the comment text, or both.
- The 500-character limit is enforced during editing.
- After 24 hours from the original posting time, the "Edit" option is no longer available and the feedback is locked.
- The system displays the remaining time the learner has to edit (e.g., "You can edit this for another 3 hours").
- Edited feedback retains the original submission timestamp but displays an "edited" indicator.

---

### Story 3: Delete Own Feedback Within 24 Hours

**As a** course learner,
**I want to** delete my feedback within 24 hours of posting,
**so that** I can remove it entirely if I change my mind.

**Acceptance Criteria:**

- A "Delete" option is visible on the learner's own feedback when it is less than 24 hours old.
- The learner is shown a confirmation prompt before deletion proceeds.
- After deletion, the feedback (rating and comment) is fully removed.
- After 24 hours from the original posting time, the "Delete" option is no longer available.
- Once feedback is deleted, the learner can submit new feedback for the same lesson.

---

### Story 4: Aggregated Feedback View on Course Dashboard (Admin)

**As a** course admin,
**I want to** see an aggregated feedback summary for each lesson on the course dashboard,
**so that** I can quickly assess learner sentiment and identify areas for improvement.

**Acceptance Criteria:**

- The course dashboard displays, per lesson:
  - Average star rating (rounded to one decimal place).
  - Total number of ratings received.
  - The 20 most recent comments, ordered newest first.
- The aggregated view updates in near real-time as new feedback is submitted (or on page refresh at minimum).
- If a lesson has no feedback, the dashboard shows a "No feedback yet" state.
- Hidden comments (see Story 5) are excluded from the latest-comments list but their ratings still count toward the average and total.

---

### Story 5: Hide Policy-Violating Comments (Admin)

**As a** course admin,
**I want to** hide individual comments that violate content policy,
**so that** inappropriate content is not visible to other learners while preserving the original learner text unaltered.

**Acceptance Criteria:**

- Admins see a "Hide" action on each comment in the aggregated feedback view.
- Hiding a comment removes it from the learner-facing view but does not delete it from the system.
- Admins cannot edit the text of any learner comment.
- Hidden comments are visually distinguished in the admin view (e.g., flagged or greyed out) so admins know which comments have been hidden.
- The associated star rating of a hidden comment still contributes to the lesson's average rating and total count.
- Admins can unhide a previously hidden comment to restore its visibility.

---

### Story 6: Feedback Locked State Indicator

**As a** course learner,
**I want to** see a clear indication when my feedback is locked and can no longer be edited or deleted,
**so that** I understand why the edit and delete options are unavailable.

**Acceptance Criteria:**

- After the 24-hour window expires, the feedback displays a "Locked" or equivalent indicator in place of edit/delete actions.
- The learner can still view their own locked feedback.

---

## Out of Scope (Documented for Future Iterations)

- Mobile application support (planned for a subsequent iteration).
- Learner-to-learner visibility of individual feedback or comments.
- Admin ability to respond to or reply to feedback.
- Notification system for new feedback.
- Bulk moderation tools for admins.
