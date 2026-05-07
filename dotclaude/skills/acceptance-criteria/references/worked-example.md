# Worked examples — `acceptance-criteria`

Two examples illustrating how the skill applies the rules in `SKILL.md` to real input.

## Example 1 — Vague story → clarifying questions → AC with `??` placeholders

**Input (user story):**
> **Title:** Reset password via emailed link
> **As a** learner, **I can** request a password reset and receive a link by email to set a new password, **so that** I can regain access to my account without contacting support.

**Response:**

Before I draft, a couple of quick questions — I don't want to invent thresholds:

1. How long should the reset link remain valid? (The story mentions 24 h elsewhere in your guide, but I want to confirm that's the target here.)
2. Should the learner be rate-limited on reset requests (e.g., N requests per hour) to mitigate abuse?
3. What happens if the learner submits the reset form for an **unknown** email — do we reveal "no account found" or always show the same neutral confirmation? (Security trade-off.)

Below is a draft using the conservative assumptions; sections depending on answers are marked `??`.

### Happy Path

**Background:**

```gherkin
Given a learner account exists with email "lea@example.com"
```

**Scenario:** AC-1.1 — Learner requests a password reset and sets a new password — Happy Path

```gherkin
Given the learner is on the "Forgot password" page,
When the learner submits the form with email "lea@example.com",
Then the learner sees a confirmation "If an account exists, a reset link has been sent.",
    And a reset email is delivered to "lea@example.com" within 1 minute,
    And the email contains a single-use link valid for 24 hours
```

_?? confirm 24h duration_

**Scenario:** AC-1.2 — Learner completes the reset from the emailed link — Happy Path

```gherkin
Given the learner has received a valid reset link,
When the learner opens the link and submits a new password meeting the password policy,
Then the password is updated,
    And the learner is redirected to the login page with a success message,
    And the reset link is invalidated for future use
```

### Sad Path

**Scenario:** AC-1.3 — Reset link has expired — Sad Path

```gherkin
Given the learner has a reset link issued more than 24 hours ago,
When the learner opens the link,
Then the learner sees error "This reset link has expired. Please request a new one.",
    And no password change is performed
```

_?? confirm 24h duration_

**Scenario:** AC-1.4 — Reset link has already been used — Sad Path

```gherkin
Given the learner has a reset link that was used once to set a new password,
When the learner opens the same link again,
Then the learner sees error "This reset link is no longer valid."
```

**Scenario:** AC-1.5 — New password fails the password policy — Sad Path

```gherkin
Given the learner has opened a valid reset link,
When the learner submits a new password that does not meet the password policy,
Then the password is not changed,
    And the learner sees the policy violations listed
```

**Scenario:** AC-1.6 — Unknown email submitted — Sad Path

_?? behavior depends on Q3_

```gherkin
Given no learner account exists with email "ghost@example.com",
When the learner submits the form with email "ghost@example.com",
Then the same neutral confirmation is shown,
    And no email is sent
```

### Non-Functional Requirements (Checklist)

- [ ] **Performance:** p95 time from form submission to email delivery is under 60 s.
- [ ] **Functionality (Security):** Reset tokens are single-use, ≥128 bits of entropy, and bound to the requesting account and user-agent.
- [ ] **Functionality (Security):** Reset requests are rate-limited to ?? requests per IP per hour and ?? per email per hour.  # ?? confirm Q2
- [ ] **Usability (Accessibility):** "Forgot password" and reset pages conform to WCAG 2.1 Level AA and are fully operable via keyboard only.
- [ ] **Reliability:** A transient email-provider failure is retried with exponential backoff for up to 5 min; the user sees no degraded experience below that threshold.
- [ ] **Supportability:** All reset events emit a structured log with a correlation ID; no plaintext tokens appear in logs or error payloads.
- [ ] **+ Constraint (Legal/Compliance):** Reset emails comply with the tenant's notification-language policy; all PII in transit uses TLS 1.2+.

**What to clarify (summary):**
1. Reset link validity duration (currently assumed 24 h).
2. Rate-limit thresholds per IP / per email.
3. Behavior on unknown email (neutral confirmation vs. "no account found").

---

## Example 2 — Anchoring with Dictionary terms

Assume a Billing Context defining `Customer`, `Invoice`, and `Account`.

**Feature:** Invoice download

**Background:**

```gherkin
Given a `Customer` is logged in
```

**Scenario:** AC-1.1 — `Customer` downloads a past `Invoice` — Happy Path

```gherkin
Given the `Customer` has at least one paid `Invoice` on their `Account`,
When the `Customer` opens the invoice history page and clicks "Download" on a row,
Then the corresponding `Invoice` PDF is delivered to the browser,
    And the file name matches the `Invoice` number
```

NFR checklist with highlighting (outside any fence — terms render as monospaced):

- [ ] **Performance:** p95 time from "Download" click to first byte under 500 ms for `Invoice`s issued in the last 12 months.
- [ ] **Functionality (Security):** `Invoice` PDFs are served only to the `Customer` whose `Account` issued them.

_Note: backticked terms inside the fence (`` `Customer` ``, `` `Invoice` ``, `` `Account` ``) render as literal text — the trade-off documented in SKILL.md's "Highlighting inside scenarios and NFR" section. The same terms inside the bold `**Scenario:**` label and in the NFR checklist render as proper monospaced highlights._
