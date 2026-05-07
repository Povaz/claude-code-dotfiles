# Worked examples — `contexts-dictionaries`

Three illustrative traces showing the skill in action. Read this file when you need to see a full call-and-response, not for the canonical block shape — that lives in `SKILL.md` § Output format.

## Example 1 — initial draft from a Spec File

**Input (raw Spec File snippet):**

> Course learners can request a refund within the **return window**. The return window is 14 days for individual purchases and 30 days for B2B purchases. Refunds are processed against the original payment method. Some courses are flagged as **non-refundable** (typically live cohort programmes); these display a banner at checkout. Restocking fees do not apply.

**Response:**

Two terms in this snippet carry domain weight (`Return Window`, `Non-Refundable Course`) and one is a candidate but borderline (`Refund` itself — defined or assumed?). Quick clarifying question:

1. Should `Refund` be in the Dictionary, or is everyone aligned that it means "money back to the original payment method, full amount"? I'd default to *not* including it since the snippet treats it as obvious, but flag if your team has been arguing about partial refunds.

Below is a draft assuming one Context (`Returns`).

```markdown
# Context: Returns

The Returns Context covers how learners request and receive refunds for course purchases, including the eligibility rules and the cohort-programme exception.

## Relationships

None yet — this is the first Context.

## Dictionary

| Term                    | Definition |
|-------------------------|------------|
| Return Window           | The period during which a learner may request a refund for a purchased course. 14 days from purchase for individual purchases; 30 days for B2B purchases. Outside this window, no refund is granted regardless of reason. |
| Non-Refundable Course   | A course explicitly flagged at the catalogue level as ineligible for refund — typically live cohort programmes. The flag must be visible to the learner at checkout. |
```

## Example 2 — adding a term mid-Story

**Input (handed off from `user-stories` skill mid-draft):**

> The story uses the term `NPS Score` but it isn't in the Dictionary. Can you add it?

**Response:**

Adding to the Survey Context (assuming that's where it belongs — flag if you'd rather it lives elsewhere).

```markdown
| Term      | Definition |
|-----------|------------|
| NPS Score | The Net Promoter Score for a learner survey response — an integer from -100 to +100 computed from the standard 0-10 likelihood-to-recommend question. We use the canonical Bain & Company scoring (% Promoters minus % Detractors); we do not bucket by course or instructor in the score itself. |
```

Side effect: definition changes here would propagate to any Story or AC mentioning `NPS Score`. None today (this is the first use), so no re-review needed. Returning control to `user-stories` to finalise the Story.

## Example 3 — pruning at a sprint review

**Input:**

> Run a pruning pass on `contexts.md`. Here are the citation counts (I grepped them by hand): Invoice 12, Customer 8, Dunning 0, Credit Note 1, Payment Term 1, Reconciliation Window 4.

**Response:**

```
- Invoice (12 citations) — keep.
- Customer (8 citations) — keep.
- Reconciliation Window (4 citations) — keep.
- Dunning (0 citations) — REMOVE. Was added during last quarter's collections discussion; the dunning epic was descoped, so the term is dormant. Confirm before I delete.
- Credit Note (1 citation) — KEEP recommended. Single citation but the term carries legal/accounting weight (immutable supersede mechanism for Invoices) and is likely to recur as soon as we tackle the partial-refund stories. Cheap to keep, expensive to recreate the consensus.
- Payment Term (1 citation) — REMOVE recommended. Single citation, the one Story that uses it could be rephrased to "30-day net" inline without losing meaning. No regulatory weight. Confirm.
```

Two removal candidates flagged for your confirmation; nothing rewritten yet.
