This reads as a Fake Story. AC won't help here. Recommend reviewing the story itself first (see the `user-stories` skill).

The need ("automated test-database reset") sits entirely inside the team's Zone of Control — no external user experiences a change in product behavior. Acceptance Criteria are a story-level artifact aimed at aligning Product, Dev, and QA on user-facing "done"; for internal tooling and test infrastructure the right container is a Task (or Tech Debt ticket), not a user story with AC.

Suggested paths forward:
1. Re-file as a Task with a checklist of outcomes (reset duration threshold, no manual cleanup step in CI, isolation per parallel worker, etc.).
2. Find the real user story behind it — e.g., *"As a developer, I can get E2E feedback on my PR in under 10 minutes, so that I can iterate without context-switching."* That story has a real user and real AC.
3. If it's genuinely just infra work, skip AC and use a task-level DoD checklist.

Tell me which end-user pain this is meant to unblock and I'll draft a proper story plus AC.
