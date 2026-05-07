Here's an initial Dictionary draft for the returns flow. Before finalising, I have a few targeted questions where the spec is genuinely ambiguous — I'd rather ask than fabricate definitions that look authoritative.

## Clarifying questions

1. **`Date of purchase` — which date exactly?** The return window is "measured from the date of purchase," but for B2B that could be order placement, invoice issuance, payment confirmation, or course-access provisioning. These can be days or weeks apart. Which one anchors the window?
2. **`B2B purchase` vs. `individual purchase` — how is each identified at refund time?** Is the distinction based on the purchaser type (account flag), the payment method (PO/invoice vs. card), or the SKU/contract? The 14 vs. 30 day rule depends on classifying every purchase unambiguously.
3. **`Manual override` scope — what can a support agent actually override?** Just the return-window check, just the `Non-Refundable` flag, both, or anything in the eligibility decision? And does the override require a reason code or approval level? This shapes what the term means in the Dictionary.
4. **`Refund` itself — worth defining?** The spec treats refunds as obviously meaning "money back to the original payment method, full amount" with no restocking fee. I'd default to *not* including `Refund` in the Dictionary unless your team has been arguing about partial refunds, currency at refund time, or refund timing. Flag if so.

I've drafted entries for the terms I'm confident about, and left placeholders for the ones above.

## Draft

```markdown
# Context: Returns

The Returns Context covers how learners request and receive refunds for course purchases, including the eligibility window, the cohort-programme exception, and the automated-vs-manual decision path.

## Relationships

None yet — this is the first Context.

## Dictionary

| Term                          | Definition |
|-------------------------------|------------|
| Return Window                 | The period during which a learner may request a refund for a purchased course, measured from the date of purchase. 14 days for individual purchases; 30 days for B2B purchases. Outside this window, no refund is granted unless a support agent applies a Manual Override. |
| Individual Purchase           | A course purchase made by a learner on their own behalf, subject to the 14-day Return Window. ?? — pending clarification on how Individual vs. B2B is distinguished at the data layer (purchaser type, payment method, or contract). |
| B2B Purchase                  | A course purchase made under a business-to-business arrangement, subject to the 30-day Return Window. ?? — pending clarification (see Individual Purchase). |
| Date of Purchase              | ?? — pending clarification. Candidates: order placement, invoice issuance, payment confirmation, or course-access provisioning. Anchors the start of the Return Window, so the choice is load-bearing. |
| Non-Refundable Course         | A course explicitly flagged at the catalogue level as ineligible for refund — typically live cohort programmes. The flag must be visible to the learner via a banner at checkout. A Non-Refundable Course is excluded from the automated refund path; only a Manual Override can refund one. |
| Eligibility Decision          | The outcome (eligible / not eligible) of evaluating a refund request against the Return Window and the Non-Refundable flag. Produced automatically by default; replaceable by a Manual Override when a support agent is involved. |
| Manual Override               | A Refund Eligibility Decision made by a support agent in place of the automated one, triggered when the learner contacts support. ?? — pending clarification on exactly what the override can bypass (Return Window only, Non-Refundable flag only, or both) and whether a reason code is required. |
| Original Payment Method       | The payment instrument used at the time of purchase (card, PO/invoice, etc.). Refunds are always processed back to this instrument; alternative refund destinations are out of scope. |
```

## Notes / smells to keep an eye on

- **`Individual Purchase` and `B2B Purchase` look like distinct concepts but are differentiated only by a duration today.** If question 2 reveals they share an underlying classifier (e.g., a `purchaser_type` field), they may collapse into a single concept with a parameter. If they diverge structurally (different payment flows, different contract terms, different support paths), the divergence will likely grow and the Dictionary entries will earn their keep.
- **`Manual Override` is a candidate for splitting** depending on the answer to question 3 — "override the window" and "override the non-refundable flag" are arguably two different policies with different approval implications.
- **`Refund` is intentionally omitted** for now. If you want it in, easiest add — but I'd rather hold the bar.

Once you've answered the four questions above, I'll firm up the placeholders and we can move on to drafting Stories against this Context.
