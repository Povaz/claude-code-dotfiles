---
name: contexts-dictionaries
description: Draft, refine, prune, split, or rewrite Contexts and Dictionaries for the Context-Anchored Specifications framework. Use this skill whenever the user is asked to define a Context, draft a Dictionary from a Spec File, refine or prune terms, document Relationships between Contexts, or split a Context — even if they don't explicitly mention "Context" or "Dictionary". Applies anywhere project vocabulary is being established or maintained, including prompts like "this term is ambiguous, define it", "two teams use this word differently", "draft the bounded contexts", "the glossary needs an entry for X", or "prune the dictionary". Output is English, in the framework's `# Context: <Title>` + Relationships + Dictionary table format. This skill does NOT add backticks or Context tags inside User Stories or Acceptance Criteria — for that, use the `user-stories` or `acceptance-criteria` skills respectively. Usable standalone, or as a step of the `/anchored-specs` pipeline.
---

# Contexts and Dictionaries

This skill is the house style for **Contexts** and **Dictionaries** in the Context-Anchored Specifications framework (see the framework doc at `~/.claude/kb/context-anchored-specifications.md`, the synced default — or at `docs/kb/context-anchored-specifications.md` if the current project pins a local copy). Any time a Context or Dictionary is being drafted, refined, pruned, split, or reviewed — whether from scratch off a Spec File or against an existing `contexts.md` — follow this guide. If you're a subagent that was handed a vocabulary task, this skill applies to you too.

This skill owns Contexts and the Dictionary entries inside them. It does **not** add backtick highlights or Context tags inside User Stories or Acceptance Criteria — those are the `user-stories` and `acceptance-criteria` skills' jobs respectively.

## What a Context is (and isn't)

A **Context** is a named scope within the project with its own coherent vocabulary. It has:

- a **Title**;
- a **short description** of what the Context covers;
- a **Dictionary** — a deliberately small set of `(term, definition)` pairs;
- optionally, **Relationships** to other Contexts written in plain prose.

A Context is not a code module, a service boundary, or a folder layout. It's a *vocabulary scope*. Two Contexts may live in the same codebase or even the same file. The line is drawn by language coherence: when stakeholders use a word and a single shared definition fits, that's one Context. When the same word legitimately means two different things in two parts of the business, that's two Contexts.

## What a Dictionary entry is (and isn't)

A **Dictionary entry** is a `(term, definition)` pair, written for humans to remove ambiguity. It is not a documentation glossary covering every word in the Spec File, not an API reference, and not a thesaurus.

A term is worth defining when at least one is true:

- **Ambiguity / divergence** — different stakeholders or readers would interpret it differently, with concrete mistake potential (a reasonable engineer building from the Spec File without the definition would build the wrong thing).
- **Domain weight** — the term carries business, legal, or operational meaning beyond its everyday sense (Invoice, Refund, Cancellation Window, Eligible Customer).
- **Recurrence** — the term appears across multiple Stories or AC; centralising the definition prevents drift.

A term is *not* worth defining when it is an ordinary English word with the same meaning to everyone, or a one-off label that doesn't recur, or already has an obvious shared meaning in the team. Hold this bar — a bloated Dictionary dilutes the signal that justifies highlighting in Stories and AC.

## Output format

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

When multiple Contexts coexist, write each as its own `# Context: <Title>` block in the same file, separated by a blank line. The default storage path is `docs/anchored-specss/contexts.md` (single file, one block per Context). Override the path by user request only.

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

**Do not fabricate definitions.**

If the Spec File is genuinely ambiguous about what a term means, ask the user 1–3 targeted questions at the top of your response and produce a draft only for the terms you're confident about. Leave ambiguous entries with a placeholder like `?? — pending clarification` and call them out explicitly. When asking, be specific: state which term, why it's ambiguous, and the candidate interpretations.

A fabricated definition reads authoritative. A reviewer skimming `contexts.md` will assume each entry was negotiated — when in fact you guessed. That definition then becomes the silent source of bugs at acceptance time. One minute of the user's time answering a question is worth far more than a confident hallucination.

Things you must ask about if not explicit in the Spec File:

- What stakeholders mean by a term they obviously use but never define.
- The precise scope of a domain word (Invoice vs. Receipt vs. Bill — pick one and define each separately if both exist).
- Whether two terms used interchangeably are actual synonyms or distinct concepts that happen to look alike.
- Whether a term that appears in multiple sections of the Spec File means the same thing in all of them — if not, that's a multi-Context signal.

Only for clearly innocuous wording (a phrasing tweak the reviewer can easily correct) is it acceptable to fill in without asking.

## Smells — review prompts, not failures

A smell means *"this deserves attention"* — not that the artifact is wrong. State the smell, why it deserves attention, and let the user decide. Common smells:

- **Single-citation term** — defined in the Dictionary but referenced by only one Story. May be fine; may indicate the term isn't recurrent enough to warrant a definition.
- **Hard-to-define term** — when no one on the team agrees on the wording without splitting hairs, the term may actually represent two distinct concepts that need separating.
- **Same word, two Contexts** — allowed (Rule 5 of the framework) but flags that Stories spanning both Contexts will need inline disambiguation. Keep an eye on these.
- **Multi-Context Story** — a Story whose Context tags span more than one Context. Often legitimate, but always re-check against the `user-stories` skill's split-or-keep rubric.
- **Circular definition** — Term A defined in terms of Term B, Term B defined in terms of Term A. Rewrite at least one to ground in a non-Dictionary concept.
- **Definition longer than two sentences** — usually a sign the term is hiding two concepts. Split it.

## Pruning at recurring spec review

At the team's regular review cadence (typically sprint review), walk the Dictionary:

- Terms with **zero citations** across Stories and AC → remove.
- Terms with **one citation** → keep only if the team judges them important. *Important* is intentionally undefined; favour lean.
- Terms with **two or more citations** → keep, but re-check definitions for drift since last review.

**Citation tracking is judgement-based today.** An automatic citation index is a documented future enhancement (see the framework doc § Future Enhancements — path above). When pruning, ask the user about citation counts you cannot verify, or skim the Stories/AC manually. Don't pretend to know counts you didn't check.

The framework deliberately does not define a "freeze" or "snapshot" event. Stable-state moments (releases, customer handoffs) are sales/management artifacts and live outside the framework.

## Iteration

Iteration is part of the framework (Rule 8): a definition change typically forces re-review of dependent Stories/AC (Rule 9). When called mid-Story or mid-AC drafting because a term needs adding, refining, or splitting:

1. Add or update the entry in the relevant Context's Dictionary.
2. List affected Stories/AC if you can identify them; otherwise flag the propagation question to the user.
3. Return control to the host skill (`user-stories` or `acceptance-criteria`) so the artifact can be finalised.

Do not touch the Story or AC text directly — that's the host skill's job.

## Input flows

### From a Spec File

Spec → Dictionary checklist:

- [ ] Read the source Spec File (path from caller, else ask).
- [ ] Draft per Output format using the inclusion criteria; one Context per coherent vocabulary, multiple Contexts when distinct vocabularies coexist.
- [ ] Show the user the draft; flag any term you weren't sure about and any definition where you guessed.

### From an existing `contexts.md`

Refining or pruning. Read the file, decide what's being asked (add a term / update a definition / remove a term / split a Context / reword Relationships), and produce a focused diff. Do not silently rewrite definitions the user didn't ask about.

### Platform pass-through

If the user mentions a specific platform (Confluence page, Jira issue, Notion doc, Google Doc, etc.), they supply the platform context in the prompt and you use whatever tools are available to fetch the source material. The skill itself does not assume any toolchain.

## Worked examples

See [references/examples.md](references/examples.md) for full traces of:

- drafting a Dictionary from a raw Spec File,
- adding a term mid-Story (handed off from `user-stories`),
- pruning at sprint review with citation counts.

## When to push back

| Trigger | Response template |
|---|---|
| User asks to define an ordinary English word with no domain weight | *"The term `foo` doesn't seem to carry domain weight in this Spec File — it's used in its everyday sense. Adding it would dilute the Dictionary. Want to skip, or is there a domain meaning I'm missing?"* |
| Spec File too vague to ground definitions | *"I can't confidently define these terms from the Spec File alone. Could you walk me through what `<term>` means to the team, and how you use it in practice?"* |
| User asks to anchor Stories/AC (backticks, `[Contexts: …]` tags) | *"That's the `user-stories` / `acceptance-criteria` skill's job — this skill only owns Contexts and Dictionaries. Want me to update the Dictionary first, then hand back?"* |
