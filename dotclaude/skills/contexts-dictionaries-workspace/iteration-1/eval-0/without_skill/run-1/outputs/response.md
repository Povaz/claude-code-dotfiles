Here is an initial dictionary drafted from your returns flow spec. I've pulled out the domain terms that show up in the text (or are clearly implied) and given each a working definition. Anything I had to assume is flagged so you can correct it.

## Returns Flow — Dictionary (v0.1)

| Term | Definition | Notes / Assumptions |
|---|---|---|
| **Learner** | The end user who has purchased a course and may request a refund. | Assumed to be the actor who initiates a return. Distinct from a B2B buyer (see below) — confirm whether an individual learner inside a B2B account can request directly, or only the B2B buyer can. |
| **Purchase** | A completed transaction in which a learner (or B2B buyer) acquires access to one or more courses. | The "date of purchase" is the anchor for the return window. Confirm whether this is the order/payment timestamp or the access-grant timestamp (these can differ for invoiced B2B deals). |
| **Individual Purchase** | A purchase made by a single learner using a consumer payment method, on their own behalf. | Triggers the 14-day return window. |
| **B2B Purchase** | A purchase made by or on behalf of an organization (e.g. via invoice, PO, or seat allocation). | Triggers the 30-day return window. Need to define what classifies a purchase as B2B — account type? payment method? order channel? |
| **Course** | A unit of learning content that can be purchased and, in some cases, refunded. | Some courses are flagged non-refundable (see below). |
| **Live Cohort Programme** | A course delivered on a fixed schedule with a live instructor and/or a defined cohort of learners. | Spec says these are "typically" non-refundable — implying the non-refundable flag is set per course, not derived automatically from the delivery type. Worth confirming. |
| **Non-Refundable Flag** | A boolean attribute on a course indicating it is excluded from the refund process regardless of return window. | Drives the checkout banner and blocks refund eligibility. |
| **Checkout Banner** | A UI notice shown at checkout when the cart contains a non-refundable course, informing the buyer that the course cannot be refunded. | Spec doesn't say whether explicit acknowledgement (e.g. a checkbox) is required — flagging as a likely follow-up. |
| **Return Window** | The time period during which a refund may be requested, measured from the date of purchase. | 14 days for individual purchases, 30 days for B2B purchases. |
| **Refund Request** | An action initiated by a learner to ask for their money back for a given purchase. | Entry point to the returns flow. |
| **Refund Eligibility Decision** | The outcome of evaluating a refund request against the rules (return window, non-refundable flag, etc.), resulting in approve or deny. | Automated by default; can be overridden by a support agent. |
| **Automated Eligibility Check** | The system-driven evaluation of a refund request against the rules. | Default path. Inputs are at least: purchase date, purchase type (individual/B2B), and the course's non-refundable flag. |
| **Manual Override** | A decision made by a support agent that supersedes the automated eligibility outcome. | Triggered when a learner contacts support. Worth defining whether overrides can go both ways (approve a denied request *and* deny an auto-approved one) and what audit trail is kept. |
| **Support Agent** | An internal staff user authorized to review refund cases and apply manual overrides. | Implies a role/permission — confirm whether any agent can override or only specific tiers. |
| **Refund** | The actual return of funds to the buyer once a request is approved. | Always processed against the original payment method. |
| **Original Payment Method** | The payment instrument used at the time of purchase (card, invoice, etc.) to which any refund must be returned. | Edge cases to clarify: expired cards, closed accounts, invoice-based B2B refunds (credit note vs. bank transfer?). |
| **Restocking Fee** | A fee historically deducted from a refund. In this system, explicitly **not applied** — refunds are always for the full amount. | Included so the rule is recorded explicitly. |

## Open questions worth resolving before the dictionary is final

1. **What makes a purchase "B2B"?** Account type, payment method, or order channel? This determines which return window applies.
2. **Date of purchase semantics** — payment date vs. access-grant date? Important for invoiced B2B orders where these can be weeks apart.
3. **Mixed carts** — what happens when a single order contains both refundable and non-refundable courses? Per-line eligibility, or whole-order?
4. **Override scope** — can a support agent override in both directions, and is there a reason code / audit trail?
5. **Partial refunds / partial consumption** — does progress through a course affect eligibility or amount? Spec is silent.
6. **Currency / FX** — is the refund always in the original currency at the original amount, or recomputed?

Want me to extend this into a glossary entry per term (with examples and "not to be confused with"), or to feed it into user stories / acceptance criteria for the flow?
