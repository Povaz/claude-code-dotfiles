Before I draft, a few quick questions — I don't want to invent thresholds or UX copy that a reviewer will assume was negotiated:

1. **Error copy.** What exact messages should we show for (a) code not found / typo, (b) expired code, (c) a second code attempted on the same order? I'll use placeholders below.
2. **Rounding and currency.** When 5–50% is applied to the order total, do we round the discount to the nearest cent, floor, or ceil? Is the discount applied to the pre-tax subtotal, the total including tax, or excluding shipping?
3. **Case sensitivity and whitespace.** Are codes case-insensitive, and do we trim leading/trailing whitespace on input?
4. **Persistence across cart edits.** If the customer adds/removes items after applying a code, does the discount stay applied and recompute automatically, or is it dropped and re-entered?
5. **Minimum order / eligibility constraints.** Any minimums or product-category restrictions per code, or is the 5–50% always applicable to the full order subtotal?

Draft below uses conservative assumptions; items depending on the answers are marked `??`.

## Acceptance Criteria

### Happy Path (Gherkin)

```gherkin
Feature: Apply a promo code at checkout
  A registered customer can apply one active percentage-based promo code
  at checkout to reduce the order total.

Background:
  Given a registered customer is logged in
    And the customer has at least one item in their cart
    And the customer is on the checkout page

Scenario: Customer applies a valid active promo code
  Given an active promo code "SPRING20" exists with a 20% discount
  When the customer enters "SPRING20" in the promo code field and confirms
  Then the order summary shows the discount labeled "SPRING20 (-20%)"
    And the order total is reduced by 20% of the eligible subtotal  # ?? confirm Q2 base
    And the discount line remains visible until checkout is completed or the code is removed

Scenario: Customer removes an applied promo code
  Given the customer has applied the active promo code "SPRING20"
  When the customer removes the applied code from the order summary
  Then the "SPRING20 (-20%)" line is no longer shown
    And the order total returns to the pre-discount amount
    And the customer can enter a different code
```

### Sad Path (Gherkin)

```gherkin
Scenario: Code does not exist
  Given no promo code "BOGUS" exists
  When the customer enters "BOGUS" and confirms
  Then the customer sees error "??"  # ?? confirm Q1a
    And the order total is unchanged
    And no discount line is shown

Scenario: Code exists but is expired
  Given a promo code "WINTER15" exists and is marked expired
  When the customer enters "WINTER15" and confirms
  Then the customer sees error "??"  # ?? confirm Q1b
    And the order total is unchanged
    And no discount line is shown

Scenario: Customer attempts to apply a second code on the same order
  Given the customer has already applied the active code "SPRING20" to the order
  When the customer enters a second active code "EXTRA10" and confirms
  Then the customer sees error "??"  # ?? confirm Q1c
    And "SPRING20 (-20%)" remains the only discount applied
    And the order total reflects only the SPRING20 discount

Scenario Outline: Discount percentage boundaries are respected
  Given an active promo code "<code>" exists with a <percent>% discount
  When the customer applies "<code>"
  Then the order summary shows "<code> (-<percent>%)"
    And the order total is reduced by <percent>% of the eligible subtotal

  Examples:
    | code      | percent |
    | EDGE_LOW  | 5       |
    | EDGE_HIGH | 50      |

Scenario: Network drop while applying a code
  Given the customer has entered an active promo code
  When the confirmation request fails due to a network error
  Then the customer sees a non-blocking error indicating the code could not be applied
    And the order total is unchanged
    And the customer can retry without reloading the page
```

### Non-Functional Requirements (Checklist)

- [ ] **Performance:** p95 time from code submission to updated order summary is under 500 ms on a 4G-Fast network profile.
- [ ] **Functionality (Security):** Promo code validation and discount calculation occur server-side; client-submitted discount amounts are never trusted.
- [ ] **Functionality (Security):** Attempts to apply codes are rate-limited per session and per account to mitigate code enumeration (threshold: ?? attempts per minute).
- [ ] **Functionality (Business rule):** At most one promo code is accepted per order; the server rejects any second code even if the client state is tampered with.
- [ ] **Functionality (Business rule):** Expired codes are not applicable at checkout but remain visible in the admin panel.
- [ ] **Usability (Cross-browser):** The checkout page — including the promo code field, confirm/remove actions, and the `<CODE> (-<percent>%)` label — is fully usable on the latest two major versions of Safari iOS and Chrome Android, at viewport widths from 320 px upward.
- [ ] **Usability (Accessibility):** The promo code field, its error messages, and the discount label conform to WCAG 2.1 Level AA, including keyboard operation, visible focus, and screen-reader announcement of applied discount and errors.
- [ ] **Reliability:** A failure to validate a promo code never blocks the customer from completing checkout at the undiscounted total.
- [ ] **Supportability:** Each promo code application attempt (success, invalid, expired, duplicate) emits a structured log with a correlation ID, the code identifier, outcome, and customer ID.
- [ ] **+ Constraint (Financial accuracy):** Discount amounts are computed with a consistent, documented rounding rule (?? confirm Q2), and the order total displayed to the customer always equals the amount charged.

**What to clarify (summary):**
1. Exact error copy for not-found, expired, and "second code" cases.
2. Rounding rule and the base the discount applies to (subtotal pre-tax / total / excl. shipping).
3. Case-insensitivity and whitespace trimming on the code input.
4. Whether an applied code survives cart edits or must be re-entered.
5. Any minimum order value or product-category restrictions per code.
6. Rate-limit threshold for code application attempts.
