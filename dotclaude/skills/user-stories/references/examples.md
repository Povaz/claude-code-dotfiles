# Worked examples — `user-stories`

Read this file when you need to see a full input → output trace (Title + Connextra narrative + INVEST per-principle block + ⚠ warning where relevant). The canonical format and rules live in `SKILL.md` § Output format and § INVEST check — this file does not repeat them.

---

**Input (raw requirement):**
> Users should be able to recover their password when they forget it. Send an email with a link, the link expires after 24h, and they can set a new password.

**Output:**

**Title:** US-1 — Reset password via emailed link

**As a** learner, \
**I can** request a password reset and receive a link by email to set a new password, \
**so that** I can regain access to my account without contacting support.

INVEST check:
- **I**ndependent — pass: no dependency on an unbuilt story; assumes the standard auth/account foundation.
- **N**egotiable — pass: states the user goal, not a specific implementation (email provider, token format, UI).
- **V**aluable — pass: a locked-out learner regains access without a support ticket.
- **E**stimable — pass: familiar pattern, scope bounded to request + email + reset.
- **S**mall — pass: fits within a sprint; the three sub-steps are tight.
- **T**estable — pass: "request reset → receive email → set new password → log in" is a single observable scenario.

_Note: the 24h expiry is an AC concern, not a story concern. Kept out of the narrative so the story stays focused on the user goal. Expiry, email template, and rate-limiting belong in AC._

---

**Input (fake story):**
> As a developer, I want a script that resets the test database, so that I can run tests faster.

**Output:**

**Title:** US-2 — Test-DB reset script (flagged — not a user story)

**As a** developer, \
**I can** reset the test database with a script, \
**so that** I can run tests faster.

INVEST check:
- **I**ndependent — pass: standalone tooling change.
- **N**egotiable — fail: the goal *is* the implementation ("a script"); nothing left to negotiate.
- **V**aluable — fail: no end-user-visible value; benefit sits inside the team.
- **E**stimable — pass: scope is narrow.
- **S**mall — pass: a script, not a feature.
- **T**estable — pass: the script either resets the DB or it doesn't.

⚠ **Fake Story** — the need ("run tests faster") is inside the team's Zone of Control. Recommend tracking as a Task or Improvement Item. If kept as a story, the team should ask: who is the actual end user, and what observable business value does this deliver to them?

---

**Input (misleading story):**
> As an operator, I can run query optimization on the reports DB, so that monthly reports load faster.

**Output:**

**Title:** US-3 — Monthly report loads without manual intervention (needs problem clarification)

**As an** operator, \
**I can** open the monthly report and have it render without waiting on my own action, \
**so that** I can complete month-end review on time.

INVEST check:
- **I**ndependent — pass: no dependency on an unbuilt story.
- **N**egotiable — pass (after rewrite): "query optimization", caching, pre-aggregation, or async loading are all on the table.
- **V**aluable — pass: the operator can finish month-end on time.
- **E**stimable — fail: underlying cause of slowness is not established — could be a query, a network hop, or a report-size blow-up.
- **S**mall — unknown: depends on root cause.
- **T**estable — pass: "the report renders without the operator running a maintenance step" is observable.

⚠ **Misleading Story** — the original `<goal>` ("run query optimization") is a prescribed solution. What is the operator actually trying to accomplish? Likely "finish month-end review on time" or "get report results before close-of-business." Confirm the underlying need before committing to a fix; the story may then need a Spike (Splitting → SPIDR → Spike) to identify the real bottleneck before it becomes estimable.

---

**Input (dependency-locked story):**
> As a learner, I can pay my course fee with Klarna, so that I can split the payment across instalments.

**Output:**

**Title:** US-4 — Pay course fee with Klarna instalments (dependency-locked)

**As a** learner, \
**I can** choose Klarna at checkout and split my course fee across instalments, \
**so that** I can enrol without paying the full amount up front.

INVEST check:
- **I**ndependent — fail: blocked on a signed Klarna contract and SDK access — neither owned by the team.
- **N**egotiable — pass: outcome-based.
- **V**aluable — pass: lowers the enrolment barrier for price-sensitive learners.
- **E**stimable — fail: SDK surface and compliance requirements are unknown until the contract is finalised.
- **S**mall — unknown: likely multi-sprint once unblocked.
- **T**estable — pass (in principle): "select Klarna → redirect → return paid/failed."

⚠ **Dependency-locked** — deliverable requires the Klarna contract and SDK. Consider splitting: keep the in-team work (e.g., a "third-party instalment provider" abstraction at the checkout layer) as the story; track the Klarna integration and contract separately, not inside this story.

---

**Input (micro-story split off a larger login story):**
> As a learner, I can click the "Log in" button, so that my click is recorded.

**Output:**

**Title:** US-5 — Log-in button click (flagged — micro-story)

**As a** learner, \
**I can** click the "Log in" button, \
**so that** my click is recorded.

INVEST check:
- **I**ndependent — pass: trivially isolated.
- **N**egotiable — fail: no room — the goal is one UI event.
- **V**aluable — fail: clicking a button is not a user outcome; the learner still cannot log in.
- **E**stimable — pass: narrow.
- **S**mall — pass: arguably too small.
- **T**estable — pass: the click either fires an event or it doesn't.

⚠ **Micro-Story** — no standalone business risk. Regroup with siblings under a single user-value-carrying story (e.g., "Log in with email and password, so that I can access my enrolled courses"). Click-tracking belongs in AC or analytics instrumentation, not as its own story.
