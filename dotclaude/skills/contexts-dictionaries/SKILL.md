---
name: contexts-dictionaries
description: Draft, refine, prune, split, or rewrite Contexts and Dictionaries for the Context-Anchored Specifications framework. Use this skill whenever the user (or a subagent you spawn) is asked to define a Context, draft an initial Dictionary from a Spec File, add or refine a term and its definition, prune the Dictionary at a recurring spec review, document Relationships between Contexts, or split a Context — even if they don't explicitly mention "Context" or "Dictionary". Applies anywhere project vocabulary is being established or maintained, including prompts like "what does X mean in this project", "this term is ambiguous, define it", "two teams use this word differently", "draft the bounded contexts", "what's our shared vocabulary here", "the glossary needs an entry for X", or "prune the dictionary". Output is English, in the framework's `# Context: <Title>` + Relationships + Dictionary table format. This skill does NOT add backticks or Context tags inside User Stories or Acceptance Criteria — for that, use the `user-stories` or `acceptance-criteria` skills respectively.
---

# Contexts and Dictionaries

This skill is the house style for **Contexts** and **Dictionaries** in the Context-Anchored Specifications framework (see `docs/kb/context-anchored-specifications.md`). Any time a Context or Dictionary is being drafted, refined, pruned, split, or reviewed — whether from scratch off a Spec File or against an existing `contexts.md` — follow this guide. If you're a subagent that was handed a vocabulary task, this skill applies to you too.

This skill owns Contexts and the Dictionary entries inside them. It does **not** add backtick highlights or Context tags inside User Stories or Acceptance Criteria — those are the `user-stories` and `acceptance-criteria` skills' jobs respectively.

Output is **always in English**, regardless of the source language of the input.

## What a Context is (and isn't)

A **Context** is a named scope within the project with its own coherent vocabulary. It has:

- a **Title**;
- a **short description** of what the Context covers;
- a **Dictionary** — a deliberately small set of `(term, definition)` pairs;
- optionally, **Relationships** to other Contexts written in plain prose.

A Context is not a code module, a service boundary, or a folder layout. It's a *vocabulary scope*. Two Contexts may live in the same codebase or even the same file. The line is drawn by language coherence: when stakeholders use a word and a single shared definition fits, that's one Context. When the same word legitimately means two different things in two parts of the business, that's two Contexts.

## What a Dictionary entry is (and isn't)

A **Dictionary entry** is a `(term, definition)` pair, written for humans to remove ambiguity. It is not a documentation glossary covering every word in the spec, not an API reference, and not a thesaurus.

A term is worth defining when at least one is true:

- **Ambiguity** — different stakeholders use the term to mean different things, or the term has multiple plausible interpretations.
- **Domain weight** — the term carries business, legal, or operational meaning beyond its everyday sense (Invoice, Refund, Cancellation Window, Eligible Customer).
- **Cross-stakeholder divergence** — Sales, Engineering, and Support each say "Account" but mean different things.
- **Recurrence** — the term appears across multiple Stories or AC; centralising the definition prevents drift.
- **Mistake potential** — a reasonable engineer reading the spec without the definition would build the wrong thing.

A term is *not* worth defining when it is an ordinary English word with the same meaning to everyone, or a one-off label that doesn't recur, or already has an obvious shared meaning in the team. Hold this bar — a bloated Dictionary is worse than a missing one, because it dilutes the signal that justifies highlighting in Stories and AC.

## Output format — non-negotiable

Each Context is presented as a single Markdown block. Use this exact shape (the framework's canonical output spec):

```markdown
# Context: <Title>

<Short description of what this Context covers — one or two sentences.>

## Relationships

<Plain-text description of how this Context relates to others. If terms overlap with another Context but mean different things, explain the divergence here. If there are no other Contexts yet, write "None yet — this is the first Context.">

## Dictionary

| Term   | Definition |
|--------|------------|
| <term> | <definition> |
| <term> | <definition> |
```

When multiple Contexts coexist, write each as its own `# Context: <Title>` block in the same file, separated by a blank line. The default storage path is `docs/specs/contexts.md` (single file, one block per Context). Override the path by user request only.

### Worked example — single Context

```markdown
# Context: Billing

The Billing Context covers everything related to invoicing, payment collection, and dunning.

## Relationships

None yet — this is the first Context.

## Dictionary

| Term     | Definition |
|----------|------------|
| Invoice  | A formal request for payment issued to a Customer for a specific Order. Identified by an immutable invoice number; once issued, an Invoice cannot be edited — only superseded by a Credit Note. |
| Customer | An entity that has an active commercial relationship with the company, identifiable by a unique Customer ID. A Customer may hold multiple Accounts. |
| Dunning  | The escalation process applied to overdue Invoices. Has formal stages (reminder → demand → final notice) with regulated timing per jurisdiction. |
```

### Worked example — multiple Contexts with overlapping term

```markdown
# Context: Billing

The Billing Context covers invoicing, payment collection, and dunning.

## Relationships

Shares the term `Account` with the Account Management Context. In Billing, an Account is a financial ledger associated with a Customer. Stories that mix both senses must use inline disambiguation in their text (the `user-stories` skill handles that).

## Dictionary

| Term    | Definition |
|---------|------------|
| Account | A financial ledger associated with a Customer, against which Invoices and Payments are recorded. A Customer may hold multiple Accounts (e.g., one per legal entity). |
| Invoice | A formal request for payment issued against an Account. Once issued, immutable. |

# Context: Account Management

The Account Management Context covers user authentication, profile data, and login state.

## Relationships

Shares the term `Account` with the Billing Context — different concept entirely. In Account Management, an Account is a login identity associated with one or more Users; it has nothing to do with money.

## Dictionary

| Term    | Definition |
|---------|------------|
| Account | A login identity backed by an email + password (or SSO). Distinct from a Billing Account; see Relationships. |
| User    | The human behind an Account. One Account = one User; a User cannot have multiple Accounts. |
```

## Question, don't invent

This is the most important behaviour in this skill. **Do not fabricate definitions.**

If the Spec File is genuinely ambiguous about what a term means, ask the user 1–3 targeted questions at the top of your response and produce a draft only for the terms you're confident about. Leave ambiguous entries with a placeholder definition like `?? — pending clarification` and call them out explicitly.

A fabricated definition reads authoritative. A reviewer skimming `contexts.md` will assume each entry was negotiated — when in fact you guessed. That definition then becomes the silent source of bugs at acceptance time. One minute of the user's time answering a question is worth far more than a confident hallucination.

Things you must ask about if not explicit in the Spec File:

- What stakeholders mean by a term they obviously use but never define.
- The precise scope of a domain word (Invoice vs. Receipt vs. Bill — pick one and define each separately if both exist).
- Whether two terms used interchangeably are actual synonyms or distinct concepts that happen to look alike.
- Whether a term that appears in multiple sections of the Spec File means the same thing in all of them — if not, that's a multi-Context signal.

Only for clearly innocuous wording (a phrasing tweak the reviewer can easily correct) is it acceptable to fill in without asking.

## Smells — review prompts, not failures

A smell means *"this deserves attention"* — not that the artifact is wrong. Common smells:

- **Single-citation term** — defined in the Dictionary but referenced by only one Story. May be fine; may indicate the term isn't recurrent enough to warrant a definition.
- **Hard-to-define term** — when no one on the team agrees on the wording without splitting hairs, the term may actually represent two distinct concepts that need separating.
- **Same word, two Contexts** — allowed (Rule 5 of the framework) but flags that Stories spanning both Contexts will need inline disambiguation. Keep an eye on these.
- **Multi-Context Story** — a Story whose Context tags span more than one Context. Often legitimate, but always re-check against the `user-stories` skill's split-or-keep rubric.
- **Circular definition** — Term A defined in terms of Term B, Term B defined in terms of Term A. Rewrite at least one to ground in a non-Dictionary concept.
- **Definition longer than two sentences** — usually a sign the term is hiding two concepts. Split it.

Smells trigger discussion and judgement, not automatic rejection. Annotate them when you spot them; let the user decide.

## Pruning at recurring spec review

At the team's regular review cadence (typically sprint review), walk the Dictionary:

- Terms with **zero citations** across Stories and AC → remove.
- Terms with **one citation** → keep only if the team judges them important. *Important* is intentionally undefined; favour lean.
- Terms with **two or more citations** → keep, but re-check definitions for drift since last review.

**Citation tracking is judgement-based today.** An automatic citation index is a documented future enhancement (see `docs/kb/context-anchored-specifications.md` § Future Enhancements). When pruning, ask the user about citation counts you cannot verify, or skim the Stories/AC manually. Don't pretend to know counts you didn't check.

The framework deliberately does not define a "freeze" or "snapshot" event. Stable-state moments (releases, customer handoffs) are sales/management artifacts and live outside the framework.

## Multi-Context handling

When the Spec File covers genuinely distinct vocabularies, draft multiple Contexts:

- One Context per coherent vocabulary scope.
- Each Context gets its own `# Context: <Title>` block.
- If two Contexts share a term with different meanings, document the divergence in **each** Context's Relationships section, pointing to the other.

Splitting a *Story* across Contexts is the `user-stories` skill's call (its split-or-keep rubric). This skill provides the Contexts and Dictionary; the stories skill decides how Stories relate to them. Stay in your lane.

## Iteration

Iteration is mandatory, not optional (Rule 8 of the framework). When called mid-Story or mid-AC drafting because a term needs adding, refining, or splitting:

1. Add or update the entry in the relevant Context's Dictionary.
2. Note any side effects: a definition change means Stories/AC referencing the term may need re-review (Rule 9 of the framework). List the affected artifacts if you can identify them; otherwise flag the propagation question to the user.
3. Return control to the host skill (`user-stories` or `acceptance-criteria`) so the artifact can be finalised.

Do not touch the Story or AC text directly — that's the host skill's job.

## Input flows

The skill supports two entry points, plus a generic platform pass-through.

### From a Spec File

The typical first call. The Spec File is unstructured prose; your job is to draft an initial Dictionary that captures the cross-stakeholder-risky terms.

1. Read the Spec File (default `docs/specs/specs.md` unless the user names another path).
2. Identify candidate terms using the inclusion criteria. Skip ordinary words.
3. Decide whether one Context or several is appropriate. If the Spec File covers obviously distinct vocabularies, draft multiple Contexts.
4. Write a short description and a Relationships section for each Context (use "None yet — this is the first Context" if applicable).
5. Write the Dictionary entries. Each definition should be one or two sentences; lean short and crisp.
6. Show the user the draft and ask for review before writing to the file. Highlight any term you weren't sure should be included or any definition where you guessed.

### From an existing `contexts.md`

Refining or pruning an existing Context. Read the file, decide what's being asked (add a term / update a definition / remove a term / split a Context / reword Relationships), and produce a focused diff. Do not silently rewrite definitions the user didn't ask about.

### Platform pass-through

If the user mentions a specific platform (Confluence page, Jira issue, Notion doc, Google Doc, etc.), they supply the platform context in the prompt and you use whatever tools are available to fetch the source material. The skill itself does not assume any toolchain.

## Worked examples

### Example 1 — initial draft from a spec

**Input (raw spec snippet):**

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

### Example 2 — adding a term mid-Story

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

### Example 3 — pruning at a sprint review

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

## Style and voice

- Plain English. No jargon unless it's the domain's own.
- Definitions are short — usually one or two sentences. If a definition runs to a paragraph, the term is probably hiding two concepts.
- Don't over-define. The Dictionary's value is signal-to-noise.
- A 5-term Dictionary that nails the cross-stakeholder-risky terms beats a 30-term Dictionary that tries to cover everything.
- When asking clarifying questions, be direct and specific. State which term, state why it's ambiguous, state the candidate interpretations.
- When flagging a smell, state the smell, state why it deserves attention, and let the user decide.

## When to push back

If the user asks you to define a term that is clearly an ordinary English word with no domain weight, push back: *"The term `foo` doesn't seem to carry domain weight in this spec — it's used in its everyday sense. Adding it would dilute the Dictionary. Want to skip, or is there a domain meaning I'm missing?"*

If the Spec File is so vague that you cannot ground definitions in anything, refuse to draft and ask for the missing context: *"I can't confidently define these terms from the Spec File alone. Could you walk me through what `<term>` means to the team, and how you use it in practice?"*

If the user asks you to anchor Stories or AC (add backticks, add `[Contexts: …]` tags), redirect: *"That's the `user-stories` / `acceptance-criteria` skill's job — this skill only owns Contexts and Dictionaries. Want me to update the Dictionary first, then hand back?"*
