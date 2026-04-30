## Pruning pass — Billing Context Dictionary

Walking the citation counts you provided against the Rule 7 / skill pruning policy (zero → remove; one → keep only if judged important; two-plus → keep, re-check definition for drift). Nothing rewritten yet — these are recommendations for your confirmation.

### Per-term verdicts

- **Invoice (12 citations) — KEEP.** Core domain term, well above the recurrence threshold. Definition currently reads *"A formal request for payment. Once issued, immutable."* That's tight, but worth a glance: the existing `Credit Note` entry says Credit Notes are the immutable supersede mechanism for an Invoice — i.e. Invoice immutability is not absolute, it's "no in-place edits, supersede via Credit Note." If your team agrees, consider tightening to something like *"A formal request for payment issued to a Customer. Once issued, an Invoice cannot be edited — only superseded by a Credit Note."* Flagging as a drift check, not a required change.

- **Customer (8 citations) — KEEP.** Recurrent, domain-weighted, no obvious drift in the current definition. No action.

- **Reconciliation Window (4 citations) — KEEP.** Above the recurrence bar; definition is crisp and operationally specific. No action.

- **Dunning (0 citations) — REMOVE recommended.** Zero citations is the unambiguous "remove" case under Rule 7. Confirm before I delete — sometimes a zero-citation term is parked deliberately because an epic is imminent. If the dunning workstream is genuinely on the roadmap for the next sprint or two, you may prefer to leave it; otherwise it's dormant noise and should go.

- **Credit Note (1 citation) — KEEP recommended.** Single citation, but this is exactly the "judged important" case the rule carves out. The term carries legal/accounting weight (it is the immutable supersede mechanism for Invoices), it is structurally entangled with `Invoice` (which has 12 citations and arguably leans on `Credit Note` to make sense of its own immutability claim), and the consensus around its definition is expensive to recreate if dropped. Cheap to keep. I'd keep it unless you actively want to lean it out.

- **Payment Term (1 citation) — REMOVE recommended, with caveat.** Single citation and the current definition (*"A 30-day net default unless otherwise negotiated."*) reads more like a business rule than a vocabulary entry — the one Story that uses it could plausibly say "30-day net" inline. Two reasons to pause before deleting, though: (1) if "Payment Term" is an actual negotiated field on contracts/invoices in your domain (not just a default value), it carries domain weight and should stay even at one citation; (2) if the current definition is wrong — i.e. `Payment Term` is the *concept* and "30-day net" is its *default*, not the term itself — then the entry needs rewording, not removal. Confirm which case applies.

### Smells worth flagging while we're here

- **`Invoice` ↔ `Credit Note` definitional dependency.** Not a circular definition (Credit Note grounds in Invoice; Invoice doesn't currently mention Credit Note), but the two are tightly coupled in meaning. If you keep Credit Note, the suggested Invoice tightening above closes the loop without introducing circularity.
- **`Payment Term` definition smell.** As noted above, the current wording defines the *default value* rather than the *concept*. That's a "definition shape" smell independent of the citation count — worth fixing whether you keep or remove.

### Clarifying questions before I touch the file

1. Is the **dunning** workstream genuinely descoped/dormant, or is there a roadmap item that will revive it soon? (Drives keep vs. remove on `Dunning`.)
2. For **Payment Term** — is it a negotiated contractual field in your business, or just shorthand for "we default to 30-day net"? (Drives remove vs. reword vs. keep.)
3. Do you want me to also apply the **Invoice** definition tightening (mentioning Credit Note as the supersede mechanism), or leave that out of scope for this pruning pass?

### Proposed next step

Once you answer the three questions above, I'll produce the post-prune Dictionary as a single diff against the current block — no silent rewrites of definitions you didn't ask about.
