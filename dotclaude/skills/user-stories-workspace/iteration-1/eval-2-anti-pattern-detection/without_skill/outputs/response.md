# Sprint User Stories

## Story 1: Database Query Optimization for Reporting Service

**As an** ops engineer,
**I want** database query optimization on the reporting service
**So that** monthly reports run faster.

### Acceptance Criteria
- Identify and optimize slow-running queries in the reporting service.
- Monthly report generation time is measurably reduced compared to the current baseline.
- Query changes are reviewed and tested against production-scale data before deployment.
- No regressions in report accuracy or completeness.

---

## Story 2: VendorX Video Encoding Integration

**As a** content editor,
**I want** the new video encoding from VendorX integrated
**So that** I can upload 4K videos to courses.

### Acceptance Criteria
- The platform accepts and processes 4K video uploads using VendorX's encoding pipeline.
- Uploaded 4K videos play back correctly across supported devices and browsers.
- Upload errors from the encoding service are surfaced clearly to the editor.
- Existing video upload workflows for lower resolutions remain unaffected.

---

## Story 3: Push Notification for New Lessons

**As a** learner,
**I want** to receive a push notification when my enrolled course has a new lesson
**So that** I don't miss content.

### Acceptance Criteria
- A push notification is sent to all enrolled learners when a new lesson is published in a course.
- The notification includes the course name and lesson title.
- Learners can opt out of these notifications in their notification preferences.
- Notifications are delivered on both mobile and web platforms.
