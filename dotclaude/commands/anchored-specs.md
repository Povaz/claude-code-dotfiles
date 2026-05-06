---
description: Drive the Context-Anchored Specifications pipeline (Triage → Dictionary → Stories → AC → review/propagate).
argument-hint: "[triage | dictionary | stories | ac | review | propagate <term> | assemble] [optional source spec path]"
---

# /anchored-specs — Context-Anchored Specifications orchestrator

You are driving the **Context-Anchored Specifications** pipeline (`docs/kb/context-anchored-specifications.md`). The framework prevents silent semantic drift by inserting a **Dictionary** (within named **Contexts**) between the unstructured source spec and the User Stories, and *anchors* Stories/AC to that Dictionary via Context tags and backtick-highlighted terms.

You do not re-derive the framework rules here — they live in the framework doc and in the three lane skills:

- `contexts-dictionaries` — owns Contexts and Dictionary entries.
- `user-stories` — owns Stories (anchoring rules included in its Anchoring section).
- `acceptance-criteria` — owns AC (anchoring rules included in its Anchoring section).

This command's job is **orchestration only**: figure out where the project is in the pipeline, route to the right skill, and ask the user for direction at the seams.

## Arguments

`$ARGUMENTS` is one of:

- *(empty)* — drive the next step from current state.
- `triage` — pre-dictionary spec health pass: mirror back the spec's intent, flag ambiguities and gaps, ask clarifying questions. Always runs first when starting from a brand-new spec.
- `dictionary` — focused dictionary phase (drafting, refining, splitting Contexts).
- `stories` — focused story phase (assumes `contexts.md` exists; produces anchored stories).
- `ac` — focused AC phase (assumes anchored stories exist).
- `review` — recurring spec review: prune the Dictionary, confirm anchoring on all stories, re-check multi-Context stories, ask about definitions changed since last review.
- `assemble` — pure Assembly trigger: rebuild `docs/anchored-specss/anchored-specs.md` from the current source artifacts. No review, no prune, no other side effects on the lane skills. Three motivators:
  - **First-run** — `anchored-specs.md` doesn't exist yet and you want to materialise it without driving a phase.
  - **Regenerate-after-manual-edits** — you edited `contexts.md` / `user-stories.md` / `acceptance-criteria.md` / the source spec by hand and want the unified doc refreshed.
  - **Foreign-source** — Contexts / Stories / AC originated outside this pipeline (different framework, different tool, manually authored elsewhere). `assemble` will normalize them to the canonical lane-skill formats before stitching.
- `propagate <term>` — definition-change propagation pass for a single term.


The source spec file is **user-supplied** — there is no fixed default. Resolution order on every invocation:

1. If the user passes a path as the second token (e.g. `/anchored-specs triage docs/anchored-specss/checkout.md`), use it.
2. Otherwise, read the `**Source:** <path>` line from the top of `docs/anchored-specss/anchored-specs.md` (see the Assembly subroutine for where this line is written).
3. Otherwise, ask the user for the path before proceeding.

Once known, the path is recorded as the `**Source:** <path>` line in `anchored-specs.md` on the next Assembly run, so subsequent invocations can resolve it without re-asking.

## Execution

### 1. Read the current state

Look at the relevant files (don't fail if they don't exist — that's part of the state):

- The **unified spec doc** `docs/anchored-specss/anchored-specs.md` if present (assembled by this command across phases — see the Assembly subroutine below). When present, its top-of-file `**Source:** <path>` line tells you where the source spec lives.
- The source spec file at the path resolved per the rules above. Read it after `anchored-specs.md` so the source path is already known.
- `docs/anchored-specss/triage.md` if present — its presence is the orchestrator's signal that the triage phase has been completed at least once.
- `docs/anchored-specss/contexts.md` if present.
- `docs/anchored-specss/user-stories.md` if present.
- `docs/anchored-specss/acceptance-criteria.md` if present.

Briefly summarise the state in one or two lines: which artifacts exist, whether triage has run, whether stories are anchored (search for `[Contexts:` tag lines), whether AC use backticked terms.

**Source-of-truth precedence.** When deriving state, prefer the unified `anchored-specs.md` if it exists — its `## Contexts & Dictionary`, `## User Stories`, and per-story AC sections are the live picture. Fall back to the per-skill files (`contexts.md` / `user-stories.md` / `acceptance-criteria.md`) when the unified doc does not exist (legacy / standalone-skill use). If both exist and visibly diverge (e.g., `user-stories.md` has a story that's missing from `anchored-specs.md`'s `## User Stories`), warn the user and ask which to treat as authoritative before proceeding — do not silently overwrite.

### 2. Route based on `$ARGUMENTS`

**Empty** — pick the next step from current state:

| State | Next step |
|---|---|
| No `triage.md` and no `contexts.md` | Run triage phase: see the Triage subroutine below. |
| `triage.md` exists, no `contexts.md` | Run dictionary phase: hand off to the `contexts-dictionaries` skill against the source spec. |
| `contexts.md` exists, stories not anchored | Run stories phase: hand off to the `user-stories` skill, applying anchoring. |
| Stories anchored, AC missing | Run AC phase: hand off to the `acceptance-criteria` skill. |
| All three exist and look healthy | Suggest `/anchored-specs review` and stop. |

Once `contexts.md` exists, the empty route does **not** regress to triage — the user has moved past it. They can always re-invoke `/anchored-specs triage` explicitly when they want a fresh ambiguity pass on the source spec.

**`triage`** — see the Triage subroutine below. Always re-runs (the user invoked it explicitly, so respect that), even if `triage.md` already exists.

**`dictionary`** — hand off to the `contexts-dictionaries` skill. State your intent, name the source spec path you'll read (resolved per the rules above), and let the skill take over.

**`stories`** — confirm `contexts.md` exists. If not, refuse and tell the user to run `/anchored-specs dictionary` first. Otherwise hand off to the `user-stories` skill, instructing it that the project is anchored (so it should apply the rules in its Anchoring section). Pass the next free `US-X` integer in the handoff prompt — compute as `max(existing US-X) + 1` across `user-stories.md` and `anchored-specs.md`; start at 1 if none exist. Codes are sticky, so gaps from prior deletions/splits are expected and must not be reused.

**`ac`** — confirm anchored stories exist (look for `[Contexts:` tag lines in `user-stories.md`). If not, refuse and tell the user to run `/anchored-specs stories` first. Otherwise hand off to the `acceptance-criteria` skill, anchored. Pass the parent story's `US-X` and the next free `Y` for that story — compute as `max(existing AC-X.Y for this X) + 1` across `acceptance-criteria.md` and `anchored-specs.md`; start at Y=1 if none exist for this X.

**`review`** — see the Recurring review subroutine below.

**`propagate <term>`** — see the Propagation subroutine below.

**`assemble`** — see the Assembly subroutine below. Run it directly with no preceding phase, review, or prune. If the source artifacts (per-skill files or whatever the user pointed at) diverge from the lane-skill canonical formats, the Assembly subroutine handles normalization — see its **Format normalization** clause.

### 3. Iterative refinement is the default

Any earlier artifact may be revised at any step. If during a phase you discover the Dictionary needs a new entry or a definition tweak, hand control to `contexts-dictionaries`, then return. Iteration is mandatory (Rule 8 of the framework).

### 4. Always show before write

Always show the user proposed changes before writing them to a file. The lane skills already follow this; reinforce it explicitly when handing off.

### 5. Run the Assembly subroutine after every phase

Once a phase finishes (and any iteration loop closes), run the **Assembly subroutine** below to refresh the cohesive document at `docs/anchored-specss/anchored-specs.md`. This is what makes `/anchored-specs` more than a sum of its lane skills — the unified doc is the deliverable a human reviewer reads. Do not skip it.

## Triage subroutine (`/anchored-specs triage`)

Triage is a **pre-dictionary spec health pass**. Its purpose is to surface internal inconsistency, ambiguity, and gaps in the source spec *before* the lane skills start mining it for vocabulary, stories, and AC. Lane skills are good at structuring what's already clear; they cannot rescue a spec that is genuinely under-specified. Triage catches that early and gives the user a focused list of things to clarify.

Triage runs:

- Automatically on empty `/anchored-specs` invocation when neither `triage.md` nor `contexts.md` exists.
- On explicit `/anchored-specs triage`, always — re-runnable for a freshened ambiguity check after the source spec has been edited.

### Procedure

1. **Resolve the source spec path** per the resolution order at the top of this command. If the path is unknown, ask before proceeding.
2. **Read the source spec end-to-end.** Don't skim. Look for cross-section consistency (does Section 3 contradict Section 7?), undefined roles, undefined terms used as if defined, references to behaviours not described, missing failure modes, missing thresholds.
3. **Produce the triage report** — show it to the user before writing. Sections (use the headings exactly):
   - **Mirror-back summary** — one paragraph, plain English, capturing what you understand the spec to be about. The user reads this first to confirm you didn't misread the document. If they correct you, fold the correction in before continuing.
   - **Ambiguous statements** — quote the offending sentence, give a section/line reference, and state in one line *why* it's ambiguous (multiple plausible interpretations, undefined term, contradicts another section, etc.).
   - **Missing details** — concrete gaps the lane skills will hit later (no error model, no thresholds, undefined user roles, no described failure mode for X, etc.). One bullet per gap.
   - **Clarifying questions** — grouped by topic (Roles / Data / Thresholds / Failure modes / etc.). Numbered within each topic. Phrase each question so the user can answer in one or two sentences; avoid open-ended "tell me about X".
4. **Wait for the user's answers.** Do not auto-fill. Capture answers under a **Captured answers** section in `triage.md`, mirroring the question numbering. The user may also choose to update the source spec inline — encourage this when the answer is short and stable; keep it in `triage.md` when it's a working note or still being negotiated.
5. **Write `docs/anchored-specss/triage.md`** once the user has answered (or explicitly chosen to defer some questions). The file is durable evidence the phase ran and is the orchestrator's signal in the empty-args routing table that triage is done.
6. **Hand off to dictionary** when the user signals readiness, or stop if they want to absorb answers into the source spec first.

### Output file shape

`docs/anchored-specss/triage.md`:

```markdown
# Spec Triage

**Source:** `<path>`
**Date:** <ISO date>

## Mirror-back summary

<one paragraph capturing the spec's apparent intent>

## Ambiguous statements

| # | Quote | Location | Why ambiguous |
|---|-------|----------|---------------|
| 1 | …     | §…       | …             |

## Missing details

- …

## Clarifying questions

### <Topic>

1. <question>
2. <question>

## Captured answers

### <Topic>

1. <user's answer to question 1>
2. deferred — to be revisited at next triage
```

### Things triage does **not** do

- It does not draft a Dictionary, Stories, or AC. Those are the lane skills' jobs; triage's value is keeping the input clean for them.
- It does not silently rewrite the source spec. If the user wants edits applied, they apply them or ask explicitly.
- It does not block the pipeline if the user judges the spec good enough. They can answer "deferred" on questions and proceed; triage records the deferral and moves on.

## Recurring review subroutine (`/anchored-specs review`)

1. Read `contexts.md` and list the terms by Context.
2. For each term, ask the user for a citation count if you can't get it confidently from grepping `user-stories.md` and `acceptance-criteria.md` (a manual grep across those files for `` `<term>` `` and `` `<term>[*]` `` is acceptable but flag the count as best-effort — automatic citation tracking is a documented future enhancement of the framework).
3. Hand off the pruning decision to the `contexts-dictionaries` skill with the citation counts.
4. Walk `user-stories.md`. Confirm every story has a `[Contexts: …]` tag line; flag any that don't as **unanchored** and offer to anchor them via the `user-stories` skill.
5. **Code health check.** Scan `user-stories.md` for duplicate `US-X` codes and `acceptance-criteria.md` for duplicate `AC-X.Y` codes. Flag duplicates as a real bug and ask the user which is canonical. Gaps in numbering are expected (codes are sticky after deletion or splits) and don't need attention.
6. For multi-Context stories, prompt the user to re-check them against the split-or-keep rubric (the `user-stories` skill knows the rubric).
7. Ask the user whether any term's definition changed since the last review. For each yes, run `/anchored-specs propagate <term>`.

Stop after each step and confirm with the user before moving on. The review is a conversation, not a unilateral rewrite.

## Propagation subroutine (`/anchored-specs propagate <term>`)

1. Grep `user-stories.md`, `acceptance-criteria.md`, **and** `anchored-specs.md` (the unified doc) for occurrences of `` `<term>` `` and `` `<term>[*]` `` (any inline-disambiguated form).
2. Show the user the list of affected artifacts using their codes (e.g. "affects US-3, AC-3.1, AC-3.4, US-7"). Codes are stable handles that survive renumbering and stay greppable, so they are the preferred citation form. Do not modify anything yet.
3. Ask the user to confirm which of those need re-review. For each confirmed, hand off to `user-stories` or `acceptance-criteria` to update the artifact under the new definition.
4. Do not silently rewrite artifacts. The user drives the propagation.
5. Once the user has approved the updated artifacts, re-run the **Assembly** subroutine (below) so the unified `anchored-specs.md` reflects the new content.

## Assembly subroutine (cohesive document)

This command's value-add over the lane skills is producing **one cohesive document** that a reviewer can read top-to-bottom without jumping between three files. Every time a phase completes (dictionary / stories / ac) and after any iterative refinement or propagation pass, run the Assembly subroutine to refresh the unified doc.

The assembly is **invisible to the lane skills** — they continue to write to their own per-skill default files (`contexts.md` / `user-stories.md` / `acceptance-criteria.md`) when called standalone. The orchestrator is what stitches them.

### Output path

`docs/anchored-specss/anchored-specs.md` (distinct from the **source spec** at the user-supplied path).

### Document structure

```markdown
# <Title — pulled from the source spec's H1, or asked of the user>

**Source:** `<path to source spec>`

<Brief intro — the first paragraph of the source spec, or one or two sentences summarising it. Confirm with the user on the first assembly.>

## Table of Contents
- [Contexts & Dictionary](#contexts--dictionary)
- [User Stories](#user-stories)
  - [US-1 — <Title>](#<anchor>)
  - [US-2 — <Title>](#<anchor>)
- [Non-Functional Requirements](#non-functional-requirements)
- [Unstructured Specs](#unstructured-specs)

## Contexts & Dictionary

### Context: <Title 1>

<short description>

#### Relationships

<…>

#### Dictionary

| Term | Definition |
|------|------------|
| …    | …          |

### Context: <Title 2>

<…>

## User Stories

### US-1 — <Title>

[Contexts: <…>]

**Title:** US-1 — <Title>

**As a** <role>, \
**I can** <goal>, \
**so that** <reason>.

INVEST check:
- **I**ndependent — <pass/fail>: <reason>.
- … (full per-principle block as the user-stories skill emits it)

#### AC-1.1 — <Scenario Name> — Happy/Sad Path

**Background:** (if any, shared across this story's scenarios; rendered with the AC skill's gherkin fence)

<scenario body inside a ` ```gherkin ` fence per the AC skill format>

#### AC-1.2 — <Scenario Name> — Happy/Sad Path

<…>

### US-2 — <Title>

<…>

## Non-Functional Requirements

### From: US-1 — <Title>

- [ ] **Performance:** <…>
- [ ] **Functionality (Security):** <…>

### From: US-2 — <Title>

- [ ] <…>

## Unstructured Specs

### <was H1 in the source spec>

#### <was H2 in the source spec>

…
```

### Heading-level remap rules

The lane skills emit at a flat heading depth (`# Context: …`, `**Title:** …`, `### Happy Path`). When stitched into the unified doc, the orchestrator remaps depths so the document forms a single coherent outline:

- **Contexts.** `# Context: <T>` → `### Context: <T>` (under `## Contexts & Dictionary`). The `## Relationships` and `## Dictionary` subheaders inside each Context become `#### Relationships` and `#### Dictionary` respectively.
- **User Stories.** Each story gets a `### <Title>` heading (using the story's `**Title:**` value as the heading text — which already includes the `US-X — ` prefix per the user-stories skill's Output format, so the heading reads e.g. `### US-1 — Reset password via emailed link` without orchestrator-side surgery). The `[Contexts: …]` tag, `**Title:**`, Connextra narrative, INVEST block, and any `**What Changed:**` block follow underneath, unchanged.
- **Acceptance Criteria.** AC are nested under their parent story. The lane skill's `### Happy Path` and `### Sad Path` headings are dropped; each scenario's bold `**Scenario:** AC-X.Y — <name> — Happy/Sad Path` label is promoted directly to a `#### AC-X.Y — <name> — Happy/Sad Path` heading. Both the `AC-X.Y` code prefix and the `— Happy Path` / `— Sad Path` suffix are part of the scenario label as the AC skill emits them — the orchestrator does not assign or infer either. The `**Background:**` block, if any, sits under the first scenario's heading or as its own `#### Background` heading at the top of the AC group, the user's call.
- **NFR.** NFR checklists from each story's AC are extracted out of the per-story AC section and grouped into a single `## Non-Functional Requirements` section at the bottom of the document, sub-grouped by parent story (`### From: US-X — <Title>` — using the parent story's full `US-X — Title` as the subheading text for stable cross-linking). **Do not dedupe automatically** — losing context on which story raised a given NFR is silent information loss; if the user wants dedupe, they ask for it explicitly.
- **Unstructured Specs.** The full body of the source spec (at the user-supplied path; the `**Source:**` line at the top of the unified doc records where it lives) is embedded verbatim under a final `## Unstructured Specs` H2 section, preserving the upstream prose the rest of the doc derives from. Because the unified doc already owns the document's H1 and the section's H2, **shift every heading in the source down by 2 levels** when embedding so the source's intra-document hierarchy stays intact but nests cleanly under the wrapper:

  | Source heading | Heading inside `## Unstructured Specs` |
  |---|---|
  | `# foo`   | `### foo` |
  | `## foo`  | `#### foo` |
  | `### foo` | `##### foo` |
  | `#### foo` | `###### foo` |

  Stop at H6 — Markdown does not support deeper headings. If a source uses `#####`+ headings, flag the conflict and ask the user how to handle it (typical answer: flatten the deepest source levels to bold prose, since spec files don't usually need that depth). Non-heading content (paragraphs, lists, code blocks, tables, blockquotes) is copied through unchanged.

  This embedding is **always re-pulled fresh** on every Assembly run. If the source spec is edited, the next Assembly reflects the edit; the unified doc is never the source of truth for unstructured prose, only the assembled view of it.

### Assembly mechanics

1. **Read the source artifacts.** If the per-skill files exist, read them. If only the unified `anchored-specs.md` exists from a previous assembly, read that as the source of truth instead. If the user passed paths for foreign-source artifacts, read those.
2. **Format normalization (enforce canonical lane-skill formats).** Source artifacts may not match the lane skills' canonical Output format specs — common when `assemble` is run on artifacts produced by a different framework, by hand, or by an older version of these skills. Before stitching, normalize each source artifact against the relevant lane skill's Output format spec:
   - **Contexts** — `# Context: <Title>` + Relationships + Dictionary table per the `contexts-dictionaries` skill.
   - **Stories** — Connextra format (one clause per line, **trailing backslash `\` on every non-final clause line** for CommonMark hard-line-break, bold `**As a**` / `**I can**` / `**so that**` keywords, no fence), per-principle INVEST block, optional `[Contexts: …]` tag line + backtick-highlighted Dictionary terms when the project is anchored, and a `US-X — ` code prefix on the `**Title:**` line, per the `user-stories` skill. If a foreign-source story has no `US-X` code, assign one using the next free integer (codes are sticky — never reuse retired numbers); show before writing.
   - **AC** — `**Scenario:** AC-X.Y — <name> — Happy/Sad Path` / `**Background:**` / `**Feature:**` bold labels (outside any fence) followed by the body wrapped in a ` ```gherkin ` fenced code block, with one clause per line, 4-space indent on `And` continuations, trailing comma on every clause except the final one, and **no bold inside the fence** (bold doesn't render in code blocks). Both the `AC-X.Y` code prefix and the `— Happy Path` / `— Sad Path` suffix on the Scenario label are mandatory and are what the Assembly subroutine uses to produce per-scenario headings without inference (see the heading-remap rules above). If a foreign-source AC has no `AC-X.Y` code, inherit X from the parent story and assign Y as the next free integer for that story (codes are sticky); show before writing. NFR as the FURPS+ checklist outside any fence, per the `acceptance-criteria` skill.
   When divergence is detected (run-on Connextra missing trailing `\`, AC body not wrapped in a `gherkin` fence, AC keywords bolded inside the fence, missing tag line, etc.), surface the divergence to the user, show the proposed normalized form **before** rewriting, and never silently transform. This is the "always show before write" rule. If you can't normalize confidently (e.g., the source is in a wholly unfamiliar shape), ask the user how to interpret it rather than guessing.
3. **Apply the remap rules above** — heading-level remap for Contexts/Stories/AC, NFR rollup, and the H1→H3 / H2→H4 / H3→H5 shift for the embedded source spec — to produce the new full content of `anchored-specs.md`.
4. **Show the proposed document to the user before writing.** For incremental updates (e.g., one new story added), it is acceptable to show only the diff against the current `anchored-specs.md`, but make the full new content available on request.
5. **Write `anchored-specs.md`** once the user approves.
6. **Per-skill files are not deleted by this subroutine.** They remain as the standalone-skill artifacts. If the user wants to consolidate (delete the per-skill files now that `anchored-specs.md` is canonical), they ask for it explicitly — destructive cleanup is not implicit in this command.

### When to assemble

Run Assembly:

- After the dictionary phase completes (initial draft of `contexts.md` written and approved).
- After the stories phase completes (any new or revised story).
- After the AC phase completes (any new or revised AC set).
- After a `/anchored-specs review` pass that resulted in any artifact change.
- After a `/anchored-specs propagate <term>` pass that resulted in any artifact change.
- **Always when invoked via `/anchored-specs assemble`**, regardless of whether anything changed — this is the explicit entry point for foreign-source assembly, regenerate-after-manual-edits, and first-run materialization.

For phase-completion and review/propagate cases, skip Assembly when nothing changed *and* `anchored-specs.md` already exists. If `anchored-specs.md` is missing, run Assembly to materialise it on first contact, even if no artifact changed.

## Default file paths

- **Source spec (input): user-supplied** — recorded as `**Source:** <path>` at the top of `anchored-specs.md` once known. No default; resolved per the rules in the Arguments section.
- Triage report: `docs/anchored-specss/triage.md`.
- Contexts/Dictionaries (per-skill): `docs/anchored-specss/contexts.md`.
- Stories (per-skill): `docs/anchored-specss/user-stories.md`.
- AC (per-skill): `docs/anchored-specss/acceptance-criteria.md`.
- **Cohesive output (assembled by this command): `docs/anchored-specss/anchored-specs.md`**.

If the user has the project laid out differently, accept the override they pass and use those paths consistently for the rest of the run.

## Things to avoid

- Don't re-explain the framework — point at `docs/kb/context-anchored-specifications.md` and the lane skills.
- Don't bypass a lane skill. If a phase belongs to one of the three skills, hand off; do not duplicate its logic here.
- Don't bulk-rewrite all artifacts in one shot during a `review` or `propagate` run. Walk the user through artifact-by-artifact.
- Don't assume `contexts.md` is up to date. If you smell drift between the Dictionary and the artifacts (e.g., a defined term is unused, an undefined term is highlighted), surface it.
