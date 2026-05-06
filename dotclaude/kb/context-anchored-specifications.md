# Context-Anchored Specifications

> **Naming history.** Earlier drafts called this "Lean DDD" and then "Vocabulary-Indexed Specifications." Both names had problems: the first overclaimed DDD heritage; the second rebranded the host process under one inserted feature. "Context-Anchored Specifications" describes what the framework actually does to an existing User Stories + Acceptance Criteria pipeline: it anchors artifacts to a Context's Dictionary. The verb *anchor* and the property *anchored* (vs. *unanchored*) are used throughout.

---

## Table of Contents

- [Introduction](#introduction)
  - [The problem: silent semantic drift](#the-problem-silent-semantic-drift)
  - [The framework in one paragraph](#the-framework-in-one-paragraph)
  - [Three artifacts, three jobs](#three-artifacts-three-jobs)
  - [Relation to Domain-Driven Design](#relation-to-domain-driven-design)
- [The Framework](#the-framework)
  - [Building blocks](#building-blocks)
  - [Rules](#rules)
  - [User Story Maps](#user-story-maps)
  - [Output format](#output-format)
- [The Process](#the-process)
- [Lineage](#lineage)
  - [What's borrowed from DDD](#whats-borrowed-from-ddd)
  - [What's deliberately left out](#whats-deliberately-left-out)
  - [Honest divergence](#honest-divergence)
- [Future Enhancements](#future-enhancements)

---

## Introduction

### The problem: silent semantic drift

The framework exists to prevent **silent semantic drift**: the case where two stakeholders use the same word in good faith, agree they understand each other, and only discover at implementation or acceptance time that they meant different things. The smallest case it targets is a single term where the developer's reasonable interpretation produces working code that fails acceptance because the business meaning was different.

This drift almost always surfaces — the question is *when*. Without a shared vocabulary, it surfaces late: in QA, in UAT, in production, or in the meeting where someone says "wait, that's not what I meant by that." The framework is a **shift-left** intervention: it forces the disagreement into the open during specification, when fixing it costs a sentence rather than a sprint.

### The framework in one paragraph

Between an unstructured Spec File and the User Stories that derive from it, insert a **Dictionary**: a deliberately small set of `(term, definition)` pairs covering the words that carry ambiguity, domain risk, business meaning, legal or operational weight, or cross-team misunderstanding. User Stories and Acceptance Criteria are then **anchored** to the Dictionary — each Story tagged with one or more **Contexts**, and every defined term highlighted within the artifact's text. A Story without any Context tag is an **unanchored** User Story; a Story with at least one is **anchored**. Highlighting is mandatory — not for aesthetic reasons, but because it makes the mapping from term to affected artifacts mechanically rigorous: when a definition changes, the exact set of artifacts to re-review is the set whose highlighted text contains that term. The whole process is iterative and lean, and the framework prefers judgment over rigid rules everywhere except this one mechanical guarantee.

### Three artifacts, three jobs

The framework operates on top of an existing spec → user-story → acceptance-criteria pipeline. The three artifacts are **orthogonal** — each prevents a distinct class of failure, and removing any one brings that class back.

| Artifact | Question answered | Failure mode prevented |
|---|---|---|
| **Dictionary** | What are we talking about? | Semantic drift |
| **User Stories** | Who needs what, and why? | Building the wrong thing |
| **Acceptance Criteria** | How must it behave? | Building it incorrectly |

This division of labor is also what keeps the framework lean. Vocabulary alignment is the Dictionary's job and only the Dictionary's job. Behavioral disputes that survive vocabulary alignment are not a Dictionary failure — they are a signal that an Acceptance Criterion is missing or underspecified. Disagreement about whether the system should *do this thing at all* is a Story-level question. Each artifact stays in its lane.

The Connextra format (`As a <role>, I want <capability>, so that <benefit>`) is not arbitrary in this scheme: its three-slot structure is precisely what keeps Stories in the *purpose* lane without bleeding into vocabulary or behavior.

### Relation to Domain-Driven Design

The framework borrows two ideas from DDD — **Ubiquitous Language** (the Dictionary) and **Bounded Contexts** (the Contexts). Almost everything else in DDD is deliberately left out: no Aggregates, no Domain Events, no Context Map relationship patterns, no tactical design patterns. The framework is a specification layer, not a code design methodology. A full discussion of what is borrowed, what is dropped, and where the framework honestly diverges from DDD is in the [Lineage](#lineage) section.

---

## The Framework

### Building blocks

**Context** — A named scope within the project with its own coherent vocabulary. Each Context has a **title**, a **short description**, a **Dictionary** (a deliberately small set of `(term, definition)` pairs), and optionally **Relationships** to other Contexts written in plain prose. If two Contexts share a term with different meanings, the divergence is acknowledged and explained in the Relationships section.

**Dictionary entry** — A `(term, definition)` pair. Definitions are written for humans, to remove ambiguity, not to satisfy a schema. A term is worth including when it is ambiguous, domain-specific, carries business/legal/operational weight, affects business rules, is used differently by different stakeholders, is likely to recur across Stories, or could cause implementation mistakes if misunderstood. The Dictionary should not attempt to define every ordinary word in the spec.

**Anchoring** — The act of binding a User Story to one or more Contexts. A Story is **anchored** when it has been tagged with at least one Context and its uses of defined terms are highlighted per Rule 1. A Story without any Context tag is **unanchored** — typically because it has not yet been processed through the framework, or because its Context tags were removed during a refactor and not replaced. Acceptance Criteria are anchored *transitively*: they inherit all of their parent Story's Contexts (Rule 4) and carry their own highlighted terms, but they are not anchored independently of the Story they belong to.

### Rules

1. **Highlighting is mandatory.** Every use of a defined term *in its dictionary sense* must be highlighted in User Stories and Acceptance Criteria. The canonical notation is **backticks**: a defined term `Invoice` is written as `` `Invoice` ``. Backticks are chosen because they render as monospaced text in every markdown viewer, survive format conversion as literal characters, and are mechanically greppable. Mistakes will happen — they are corrected at review and treated as a normal source of bugs in the spec, not as compliance failures. The cost of mandatory highlighting is low; the value compounds across search, review, and impact analysis.

2. **Smells are review prompts, not failures.** A smell means *"this deserves attention"* — not that the artifact is wrong. Examples: a Story drawing on multiple Contexts; a term with only one citation; a term hard to define cleanly; two Contexts using the same word differently. Smells trigger discussion and judgment, not automatic rejection. The framework supports shared understanding; it is not a compliance checklist.

3. **Each anchored Story has at least one Context.** A Story's Context tags determine which Dictionaries apply to it. Most Stories should belong to exactly one Context — this keeps them linguistically coherent and discourages oversized Stories that mix multiple areas of the domain. A Story with no Context is unanchored and must be anchored before the next recurring spec review.

4. **Acceptance Criteria inherit all of their parent Story's Contexts.** Terms in Acceptance Criteria are interpreted according to the union of the parent Story's Dictionaries. In the rare case where a term is defined differently across two of those Contexts, the disambiguation rule from Rule 5 applies.

5. **Multi-Context Stories are allowed; ambiguous terms are disambiguated inline.** A Story should normally belong to one Context. If it genuinely belongs to more than one, all relevant Contexts are listed in the Story's tags, and Dictionary terms are highlighted as usual. **When a Story belongs to multiple Contexts and a highlighted term is defined differently in two or more of those Contexts**, the term must be annotated with the Context inside the backticks, as `` `term[Context]` ``, to indicate which definition applies at that occurrence. In all other cases — including most uses of terms in multi-Context Stories — plain backtick highlighting is sufficient. A Story that requires the inline annotation is a **point of attention** for reviewers, since same-term divergence across Contexts is rare and often a signal that the Story is doing too much.

6. **Multi-Context Stories follow a split-or-keep rubric.** When a Story has more than one Context tag, the default decision is to **split** it if any of the following hold:
   - **(a) Single-rephrase split:** the Story can be cleanly stated using only one Context's vocabulary by removing or rephrasing one sentence.
   - **(b) Independent terms:** the cross-Context terms refer to independent entities that don't share an underlying concept — they happen to appear together but aren't structurally entangled.
   - **(c) Clean INVEST split:** splitting produces two Stories that each pass INVEST.

   Otherwise, **keep** the Story multi-Context. Override the default (split when none apply, or keep when one applies) only with explicit reasoning recorded alongside the Story. The rubric exists to make the decision fast and consistent — not to remove judgment, but to bound where judgment is needed.

7. **Pruning happens at recurring spec reviews.** Pruning is not a special event — it happens at the team's regular review cadence, alongside other ongoing spec work. Sprint reviews are the most common form of this cadence, but any recurring team review where Stories and Criteria are already being discussed is a natural pruning moment. At each review, the team scans the Dictionary: terms with zero citations are removed; terms with one citation are kept only if judged important. *"Important"* is intentionally undefined — the core value is lean, *cum grano salis*. The framework deliberately does not define a special "freeze" or "snapshot" event. Stable-state moments (releases, customer handoffs, stakeholder approvals) exist outside the framework as sales or management artifacts; the development team continues iterating, and exceptional changes with budget or timeline impact get exceptional treatment by definition.

8. **Iteration is mandatory, not optional.** If, while drafting a Story or Acceptance Criterion, a Dictionary term needs adjustment or a new term needs adding, that adjustment happens before the artifact is finalized. Dictionary, Stories, and Criteria evolve together continuously.

9. **Definition changes propagate backwards.** This is the structural counterpart of iteration and the property that makes the framework worth its overhead. Because highlighting is mandatory (Rule 1), the set of artifacts affected by a definition change is **mechanically identifiable**: it is exactly the set of Stories and Acceptance Criteria whose highlighted text contains that term. When a term's definition changes, all such artifacts must be re-read and revised if their meaning shifts — or the definition change must be reconsidered. This is not a recommendation; it is the contract that justifies the highlighting rule. The mapping is only as reliable as the highlighting itself, so missed highlights are treated like any other spec bug — caught at review, fixed, and not allowed to accumulate. Without this propagation, highlighting is decorative; with it, the Dictionary becomes a navigable index of the spec.

10. **Code-level usage is encouraged, not enforced.** Teams are strongly advised to carry Dictionary terms into class names, function names, variables, module names, API names, database concepts, and UI labels. No syntactic check is performed by the framework.

### User Story Maps

Once Contexts exist, User Story Maps are built **per Context** by default — this preserves linguistic coherence. Cross-context journey maps are the exception, used when end-to-end product flow requires a holistic view.

### Output format

Each Context is presented as:

```markdown
# Context: <Title>

<Short description of what this Context covers.>

## Relationships
<Plain-text description of how this Context relates to others.
 If terms overlap with other Contexts but mean different things,
 explain the divergence here.>

## Dictionary

| Term   | Definition   |
|--------|--------------|
| <term> | <definition> |
| <term> | <definition> |
```

User Stories and Acceptance Criteria carry:

- one or more **Context tags**;
- Dictionary terms wrapped in backticks within their text;
- in the rare case of same-term ambiguity across the Story's Contexts, the Context name is added inside the backticks as `` `term[Context]` `` on the ambiguous occurrences.

Example (single Context, the common case):

```text
[Contexts: Billing]

As a `Customer`, I want to download an `Invoice` so that I can keep
a record of my purchase.
```

Example (multi-Context with inline disambiguation, rare):

```text
[Contexts: Billing, Account Management]

As a `Customer`, I want to update my `Billing Profile` using my
`Account[Account Management]` so that my invoices are sent to the
correct address.
```

That is the entire output contract. There is no required tooling, no schema validation, no enforced file layout.

---

## The Process

The framework above is the abstract layer. Below is the concrete process this layer is being grafted onto. The two are intentionally separate: the framework could be inserted into a different process without modification.

1. **Spec File** — An unstructured natural-language document describing what is being built and why. Written by humans, optionally with AI assistance.

2. **Dictionary draft** — Before User Stories are written, the team drafts an initial Dictionary based on the Spec File. If the project has clearly distinct vocabularies, multiple Contexts are defined here. The draft remains deliberately small — focused on important terms that reduce ambiguity, not on completeness for its own sake.

3. **User Stories** — Written in **Connextra format** (`As a <role>, I want <capability> so that <benefit>`) and evaluated against **INVEST** (Independent, Negotiable, Valuable, Estimable, Small, Testable). Each Story is then **anchored**: tagged with one or more Contexts, with Dictionary terms highlighted throughout its text. Most Stories will have a single Context tag; multi-Context Stories are reviewed against the split-or-keep rubric (Rule 6). A Story may be drafted unanchored and anchored later in the same session, but it must be anchored before the next recurring spec review.

4. **Acceptance Criteria** — Written for each User Story in **BDD Gherkin** (`Given / When / Then`). Criteria inherit all of the parent Story's Contexts, highlight Dictionary terms with backticks, and use the inline `` `term[Context]` `` annotation when same-term ambiguity surfaces only at the Criteria level.

5. **Iterative refinement** — At every step, any earlier artifact may be revised: Spec File, Dictionary, Context boundaries, Stories, Criteria, highlighted terms, Context tags. There is no formal change-control gate; iteration is the default mode.

6. **Recurring spec review** — At the team's regular review cadence (typically sprint review), the Dictionary is pruned (per Rule 7), all Stories are confirmed anchored, multi-Context Stories are re-checked against the split-or-keep rubric, and definition changes from the period are propagated to affected artifacts (per Rule 9). The framework treats this as ongoing maintenance, not a milestone.

The pipeline is a mix of manual writing and AI-assisted writing. The framework adds the Dictionary as a shared artifact that both humans and AI assistants reference. AI-generated output still requires review — especially for unhighlighted Dictionary terms, accidental synonyms, invented terminology, and cross-context vocabulary leakage.

---

## Lineage

The framework is inspired by Domain-Driven Design (Eric Evans, 2003), but is deliberately a small subset of it. This section makes the borrowing, the omissions, and the divergences explicit.

### What's borrowed from DDD

- **Ubiquitous Language.** The single most valuable idea in DDD: that the words used in conversation, specs, and code should mean the same thing to every stakeholder, and that ambiguity in language is a primary source of defects. This becomes the **Dictionary**.
- **Bounded Contexts.** The recognition that a single word legitimately means different things in different parts of the same business, and that pretending otherwise produces broken software. This becomes the framework's notion of **Context**.
- **Iterative refinement of language.** DDD treats language as a living artifact that evolves alongside understanding. The Dictionary is treated the same way: it evolves continuously and is pruned at recurring spec reviews rather than frozen at any point.

### What's deliberately left out

- **Strategic Design machinery.** DDD provides Context Maps with formal relationship patterns (Shared Kernel, Customer/Supplier, Conformist, Anticorruption Layer, etc.). This framework allows free-text descriptions of context relationships and does not impose these patterns.
- **Tactical Design patterns.** Aggregates, Entities, Value Objects, Domain Events, Repositories, Factories — none of these appear here.
- **Domain Events and Event Storming workshops.** Not part of this process.
- **Hard separation between Domain Model and infrastructure.** Out of scope.

### Honest divergence

A purist DDD reading would object that *ubiquitous language not reaching code is not really ubiquitous*. That objection is fair. The framework's position: spec-level alignment is itself a meaningful win, and a syntax-checked code-level rollout is a future enhancement, not a precondition. Teams are strongly encouraged to carry the Dictionary into their code, but the framework does not check it.

---

## Future Enhancements

Documented rather than hidden, in keeping with the lean ethos of preferring visible debt over false confidence. Each entry describes a gap in the current framework and the enhancement that would close it. None are adopted yet.

- **Code-level Dictionary enforcement.** Rule 10 makes Dictionary use in code advisory only. A linter that verifies code identifiers against the active Dictionary — analogous to how Gherkin scenarios can be connected to executable tests — would close the gap between spec-level and code-level vocabulary alignment. This is the most-discussed enhancement.
- **Unhighlighted-term checker.** Rule 1 makes highlighting mandatory, but enforcement is currently human-only. A document checker that flags Dictionary terms appearing without backticks would convert the discipline problem into a tooling problem. Near-term priority given Rule 1's reliance on highlighting completeness.
- **Automatic `term → affected artifacts` index.** Rule 9's mapping is mechanically identifiable but currently computed by hand at review time. A tool that generates the index automatically from the spec would make impact analysis cheap rather than disciplined.
- **Multi-Context Story patterns.** Multi-Context Stories are currently handled via flat Context tags, the split-or-keep rubric (Rule 6), and inline disambiguation (Rule 5). DDD's Context Map relationship patterns (Shared Kernel, Customer/Supplier, Anticorruption Layer, etc.) offer a more nuanced answer. Adopting a subset becomes worthwhile once recurring patterns are observed in practice.
- **Dictionary quality guidance.** The current framework gives only inclusion criteria. Deeper guidance on definition specificity, avoiding circularity, handling synonyms and aliases, plurals and multi-word terms, and worked examples of good versus bad entries would help teams new to the framework.
- **Aliases, synonyms, and term versioning.** The Dictionary currently treats each term as a single canonical form with one current definition. Optional support for aliases (different surface forms pointing to the same definition), synonyms (related terms that should be cross-referenced), and versioning (definition changes tracked over time) would make the Dictionary more expressive without forcing complexity on teams that don't need it.
- **AI review prompts.** The framework already contemplates AI-assisted authoring. Dedicated review prompts that check Stories and Acceptance Criteria against the active Dictionary — flagging unhighlighted terms, accidental synonyms, invented terminology, and cross-context vocabulary leakage — would systematize what is currently ad-hoc human review.
