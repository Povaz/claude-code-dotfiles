# Acceptance Criteria: Apply a promo code at checkout

Below are the acceptance criteria for this story, written in Gherkin-style (Given/When/Then) and grouped by behavior. They cover the happy path, validation, edge cases, UI display, and the cross-device constraint called out by the PO.

---

## 1. Applying a valid, active promo code (happy path)

**Given** I am a registered customer on the checkout page with items in my cart
**And** I have not yet applied any promo code
**When** I enter an active promo code into the promo code field
**And** I submit/apply the code
**Then** the discount is calculated as `cart_subtotal * (percent / 100)` where `percent` is in the 5–50 range
**And** the order total is reduced by the discount amount
**And** a confirmation of the applied code is shown inline in the format `<CODE> (-<percent>%)` (e.g., `SPRING20 (-20%)`)
**And** the new total is visible before I confirm payment.

## 2. Rejecting an expired promo code

**Given** I am on the checkout page
**When** I enter a promo code whose status is `expired`
**And** I submit the code
**Then** no discount is applied to the order
**And** the order total remains unchanged
**And** I see an error message indicating the code is no longer valid (e.g., "This promo code has expired")
**And** the code is **not** persisted on the order.

Note: expired codes still appear in the admin panel — this AC only concerns the customer-facing checkout.

## 3. Rejecting an unknown/invalid promo code

**Given** I am on the checkout page
**When** I enter a code that does not exist in the system
**And** I submit the code
**Then** no discount is applied
**And** I see an error message indicating the code is invalid (e.g., "Invalid promo code")
**And** the order total remains unchanged.

## 4. Only one promo code can be stacked per order

**Given** I have already applied an active promo code to my order
**When** I attempt to apply a second promo code
**Then** the second code is not applied
**And** I see a message explaining that only one promo code can be used per order
**And** the originally applied code and its discount remain in effect.

## 5. Replacing a previously applied code

**Given** I have already applied an active promo code to my order
**When** I explicitly remove the applied code
**And** I then apply a different active code
**Then** the new code is applied and its discount replaces the previous one
**And** the inline label updates to `<NEW_CODE> (-<percent>%)`
**And** the order total is recalculated accordingly.

## 6. Removing an applied promo code

**Given** I have an active promo code applied to my order
**When** I remove the code (e.g., via a remove/clear action next to the label)
**Then** the discount is removed from the order
**And** the inline label is cleared
**And** the order total returns to the pre-discount amount.

## 7. Discount label display format

**Given** an active promo code has been successfully applied
**Then** the discount is displayed inline in the exact format `<CODE> (-<percent>%)`
  - `<CODE>` matches the code the customer entered (rendered in its canonical casing, e.g., uppercase)
  - `<percent>` is an integer in the 5–50 range
**And** the label is visible in the order summary alongside the discounted total.

## 8. Percentage bounds

**Given** any promo code available in the system
**Then** its discount percent is between 5 and 50 (inclusive)
**And** the checkout will not apply a percent outside this range, even if the code's stored value is misconfigured (the system should reject it and surface an error rather than charge an incorrect total).

## 9. Empty / whitespace input

**Given** I am on the checkout page
**When** I click Apply with an empty or whitespace-only promo code field
**Then** no request is sent (or the request is rejected) and no discount is applied
**And** I see a prompt to enter a code
**And** the order total is unchanged.

## 10. Case-insensitive matching (recommended default)

**Given** a promo code exists as `SPRING20`
**When** I enter it as `spring20`, `Spring20`, or `SPRING20`
**Then** the code is recognized and applied identically in all cases
**And** the inline label renders the code in its canonical stored form (`SPRING20 (-20%)`).

## 11. Guest / non-registered users

**Given** I am not a registered customer (guest checkout, if supported)
**When** I attempt to apply a promo code
**Then** the behavior matches whatever the PO has specified for guests.

*Open question for PO:* The story restricts the feature to **registered** customers — should the promo field be hidden for guests, or shown with a prompt to sign in? Flagging as an ambiguity rather than assuming.

## 12. Mobile browser usability — Safari iOS

**Given** I am on the checkout page in Safari on iOS (latest and latest-1 major versions)
**Then** the promo code input is visible without horizontal scroll
**And** the input accepts text entry without zoom-jank (font-size ≥ 16px on the input to prevent iOS auto-zoom)
**And** the Apply control is tappable with a minimum 44x44pt hit target
**And** the inline discount label `<CODE> (-<percent>%)` is fully visible in the order summary.

## 13. Mobile browser usability — Chrome Android

**Given** I am on the checkout page in Chrome on Android (latest and latest-1 major versions)
**Then** the promo code input, Apply control, and inline discount label are all visible and usable without horizontal scroll
**And** the Apply control has a minimum 48x48dp hit target
**And** applying/removing a code does not cause layout shift that displaces the Pay button out of view.

## 14. Discount is reflected in the final charge

**Given** I have successfully applied an active promo code
**When** I complete payment
**Then** the amount charged equals the displayed discounted total (not the pre-discount total)
**And** the order record stores the applied code and the percent used, for later reference (receipts, refunds, reporting).

---

## Non-functional / out-of-scope notes

- **Stacking rule is "at most one":** zero codes is a valid state; this is already covered by the happy path and removal flows.
- **Admin visibility of expired codes** is out of scope for this story (customer-facing checkout only), but mentioned here so QA doesn't flag it as a gap.
- **Analytics / fraud limits** (e.g., rate-limiting repeated invalid attempts) are not mentioned by the PO and are not included. Flag to PO if needed.
- **Currency/rounding rules** for the computed discount (e.g., round half-up to 2 decimals) are not specified. Recommend confirming with PO before implementation.
