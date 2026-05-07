# Billing Context Dictionary — Sprint Review Pruning

Based on your citation counts, here's my recommendation. The general rule for a healthy Dictionary at sprint review is: **keep terms that are actively pulling weight in the specs, drop terms nobody references.** Zero citations is the clearest signal; a single citation is a yellow flag worth a quick judgment call.

## Citation summary

| Term                  | Citations | Verdict        |
|-----------------------|-----------|----------------|
| Invoice               | 12        | Keep           |
| Customer              | 8         | Keep           |
| Reconciliation Window | 4         | Keep           |
| Credit Note           | 1         | Keep (with note) |
| Payment Term          | 1         | Drop (or keep — see below) |
| Dunning               | 0         | Drop           |

## Recommended pruned Dictionary

```markdown
## Dictionary

| Term                    | Definition |
|-------------------------|------------|
| Invoice                 | A formal request for payment. Once issued, immutable. |
| Customer                | An entity with an active commercial relationship; identified by Customer ID. |
| Credit Note             | An immutable supersede mechanism for an Invoice when amounts must change after issuance. |
| Reconciliation Window   | The monthly accounting close window during which Invoice/Payment matches are finalized. |
```

## Rationale per term

- **Invoice (12)** — Core noun of the Billing Context. Keep.
- **Customer (8)** — Heavily referenced; the actor side of most billing flows. Keep.
- **Reconciliation Window (4)** — Solid usage and the definition encodes a non-obvious time-bound constraint that specs lean on. Keep.
- **Credit Note (1)** — Only one citation, but the term carries real semantic weight: it's the *only* sanctioned way to mutate an issued Invoice's amount. Dropping it would leave that rule unwritten. **Keep**, and flag it for re-review next sprint — if it's still at 1 citation, consider whether the underlying rule belongs in the Invoice definition instead.
- **Payment Term (1)** — Borderline. The current definition ("A 30-day net default unless otherwise negotiated") is really a *default value*, not a term definition — it tells you the policy but not what a Payment Term *is*. I'd **drop it** unless an upcoming story explicitly needs to vary payment terms; in that case, rewrite the definition first ("The agreed schedule by which a Customer must settle an Invoice; defaults to net-30") before keeping it.
- **Dunning (0)** — Zero citations means no spec, story, or AC currently depends on this concept. **Drop it.** If/when an overdue-collections story enters the backlog, re-add it then with a definition tailored to that story's needs. Keeping unused terms rots the Dictionary — readers stop trusting that every entry matters.

## Things to double-check before you delete

1. **Confirm the grep was exhaustive** — did you search Stories, Acceptance Criteria, *and* any Relationships sections of neighboring Contexts? A term cited only by an upstream/downstream Context still earns its keep.
2. **Check for synonyms** — zero hits for "Dunning" could mask hits for "collections", "overdue process", "escalation", etc. If the concept is being referred to under another name, the fix is to standardize the name, not drop the term.
3. **Look at the trend, not just the snapshot** — if Dunning was at 5 last sprint and 0 now because those stories shipped and got archived, that's still a drop. But if it's 0 because a Dunning epic is queued for next sprint, hold off.

If items 1–3 all check out, ship the pruned table above.
