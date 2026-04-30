---
description: Drive the Context-Anchored Specifications pipeline (Dictionary → Stories → AC → review/propagate).
argument-hint: "[dictionary | stories | ac | review | propagate <term> | assemble] [optional spec path]"
---

# /spec — Context-Anchored Specifications orchestrator

You are driving the **Context-Anchored Specifications** pipeline (`docs/kb/context-anchored-specifications.md`). The framework prevents silent semantic drift by inserting a **Dictionary** (within named **Contexts**) between the unstructured Spec File and the User Stories, and *anchors* Stories/AC to that Dictionary via Context tags and backtick-highlighted terms.

You do not re-derive the framework rules here — they live in the framework doc and in the three lane skills:

- `contexts-dictionaries` — owns Contexts and Dictionary entries.
- `user-stories` — owns Stories (anchoring rules included in its Anchoring section).
- `acceptance-criteria` — owns AC (anchoring rules included in its Anchoring section).

This command's job is **orchestration only**: figure out where the project is in the pipeline, route to the right skill, and ask the user for direction at the seams.

## Arguments

`$ARGUMENTS` is one of:

- *(empty)* — drive the next step from current state.
- `dictionary` — focused dictionary phase (drafting, refining, splitting Contexts).
- `stories` — focused story phase (assumes `contexts.md` exists; produces anchored stories).
- `ac` — focused AC phase (assumes anchored stories exist).
- `review` — recurring spec review: prune the Dictionary, confirm anchoring on all stories, re-check multi-Context stories, ask about definitions changed since last review.
- `assemble` — pure Assembly trigger: rebuild `docs/specs/spec.md` from the current source artifacts. No review, no prune, no other side effects on the lane skills. Three motivators:
  - **First-run** — `spec.md` doesn't exist yet and you want to materialise it without driving a phase.
  - **Regenerate-after-manual-edits** — you edited `contexts.md` / `user-stories.md` / `acceptance-criteria.md` / `specs.md` by hand and want the unified doc refreshed.
  - **Foreign-source** — Contexts / Stories / AC originated outside this pipeline (different framework, different tool, manually authored elsewhere). `assemble` will normalize them to the canonical lane-skill formats before stitching.
- `propagate <term>` — definition-change propagation pass for a single term.


If the user passes an alternative path as the second token, treat it as the Spec File path (e.g. `/spec stories docs/specs/checkout.md`). Otherwise the default is `docs/specs/specs.md`.

## Execution

### 1. Read the current state

Look at the relevant files (don't fail if they don't exist — that's part of the state):

- The Spec File (default `docs/specs/specs.md`).
- The **unified spec doc** `docs/specs/spec.md` if present (assembled by this command across phases — see the Assembly subroutine below).
- `docs/specs/contexts.md` if present.
- `docs/specs/user-stories.md` if present.
- `docs/specs/acceptance-criteria.md` if present.

Briefly summarise the state in one or two lines: which artifacts exist, whether stories are anchored (search for `[Contexts:` tag lines), whether AC use backticked terms.

**Source-of-truth precedence.** When deriving state, prefer the unified `spec.md` if it exists — its `## Contexts & Dictionary`, `## User Stories`, and per-story AC sections are the live picture. Fall back to the per-skill files (`contexts.md` / `user-stories.md` / `acceptance-criteria.md`) when the unified doc does not exist (legacy / standalone-skill use). If both exist and visibly diverge (e.g., `user-stories.md` has a story that's missing from `spec.md`'s `## User Stories`), warn the user and ask which to treat as authoritative before proceeding — do not silently overwrite.

### 2. Route based on `$ARGUMENTS`

**Empty** — pick the next step from current state:

| State | Next step |
|---|---|
| No `contexts.md` | Run dictionary phase: hand off to the `contexts-dictionaries` skill against the Spec File. |
| `contexts.md` exists, stories not anchored | Run stories phase: hand off to the `user-stories` skill, applying anchoring. |
| Stories anchored, AC missing | Run AC phase: hand off to the `acceptance-criteria` skill. |
| All three exist and look healthy | Suggest `/spec review` and stop. |

**`dictionary`** — hand off to the `contexts-dictionaries` skill. State your intent, name the Spec File you'll read, and let the skill take over.

**`stories`** — confirm `contexts.md` exists. If not, refuse and tell the user to run `/spec dictionary` first. Otherwise hand off to the `user-stories` skill, instructing it that the project is anchored (so it should apply the rules in its Anchoring section).

**`ac`** — confirm anchored stories exist (look for `[Contexts:` tag lines in `user-stories.md`). If not, refuse and tell the user to run `/spec stories` first. Otherwise hand off to the `acceptance-criteria` skill, anchored.

**`review`** — see the Recurring review subroutine below.

**`propagate <term>`** — see the Propagation subroutine below.

**`assemble`** — see the Assembly subroutine below. Run it directly with no preceding phase, review, or prune. If the source artifacts (per-skill files or whatever the user pointed at) diverge from the lane-skill canonical formats, the Assembly subroutine handles normalization — see its **Format normalization** clause.

### 3. Iterative refinement is the default

Any earlier artifact may be revised at any step. If during a phase you discover the Dictionary needs a new entry or a definition tweak, hand control to `contexts-dictionaries`, then return. Iteration is mandatory (Rule 8 of the framework).

### 4. Always show before write

Always show the user proposed changes before writing them to a file. The lane skills already follow this; reinforce it explicitly when handing off.

### 5. Run the Assembly subroutine after every phase

Once a phase finishes (and any iteration loop closes), run the **Assembly subroutine** below to refresh the cohesive document at `docs/specs/spec.md`. This is what makes `/spec` more than a sum of its lane skills — the unified doc is the deliverable a human reviewer reads. Do not skip it.

## Recurring review subroutine (`/spec review`)

1. Read `contexts.md` and list the terms by Context.
2. For each term, ask the user for a citation count if you can't get it confidently from grepping `user-stories.md` and `acceptance-criteria.md` (a manual grep across those files for `` `<term>` `` and `` `<term>[*]` `` is acceptable but flag the count as best-effort — automatic citation tracking is a documented future enhancement of the framework).
3. Hand off the pruning decision to the `contexts-dictionaries` skill with the citation counts.
4. Walk `user-stories.md`. Confirm every story has a `[Contexts: …]` tag line; flag any that don't as **unanchored** and offer to anchor them via the `user-stories` skill.
5. For multi-Context stories, prompt the user to re-check them against the split-or-keep rubric (the `user-stories` skill knows the rubric).
6. Ask the user whether any term's definition changed since the last review. For each yes, run `/spec propagate <term>`.

Stop after each step and confirm with the user before moving on. The review is a conversation, not a unilateral rewrite.

## Propagation subroutine (`/spec propagate <term>`)

1. Grep `user-stories.md`, `acceptance-criteria.md`, **and** `spec.md` (the unified doc) for occurrences of `` `<term>` `` and `` `<term>[*]` `` (any inline-disambiguated form).
2. Show the user the list of affected artifacts (story titles, AC scenarios) — do not modify anything yet.
3. Ask the user to confirm which of those need re-review. For each confirmed, hand off to `user-stories` or `acceptance-criteria` to update the artifact under the new definition.
4. Do not silently rewrite artifacts. The user drives the propagation.
5. Once the user has approved the updated artifacts, re-run the **Assembly** subroutine (below) so the unified `spec.md` reflects the new content.

## Assembly subroutine (cohesive document)

This command's value-add over the lane skills is producing **one cohesive document** that a reviewer can read top-to-bottom without jumping between three files. Every time a phase completes (dictionary / stories / ac) and after any iterative refinement or propagation pass, run the Assembly subroutine to refresh the unified doc.

The assembly is **invisible to the lane skills** — they continue to write to their own per-skill default files (`contexts.md` / `user-stories.md` / `acceptance-criteria.md`) when called standalone. The orchestrator is what stitches them.

### Output path

`docs/specs/spec.md` (singular, deliberately distinct from the input Spec File `docs/specs/specs.md` plural).

### Document structure

```markdown
# <Title — pulled from the input Spec File's H1, or asked of the user>

<Brief intro — the first paragraph of the input Spec File, or one or two sentences summarising it. Confirm with the user on the first assembly.>

## Table of Contents
- [Contexts & Dictionary](#contexts--dictionary)
- [User Stories](#user-stories)
  - [<US1 Title>](#<anchor>)
  - [<US2 Title>](#<anchor>)
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

### <US1 Title>

[Contexts: <…>]

**Title:** <as before>

**As a** <role>,
**I can** <goal>,
**so that** <reason>.

INVEST check:
- **I**ndependent — <pass/fail>: <reason>.
- … (full per-principle block as the user-stories skill emits it)

#### <AC1 Scenario Name> — Happy/Sad Path

**Background:** (if any)

**Given** <…>.

**Scenario:** <name>

**Given** <…>,
**When** <…>,
**Then** <…>,
    **And** <…>.

#### <AC2 Scenario Name> — Happy/Sad Path

<…>

### <US2 Title>

<…>

## Non-Functional Requirements

### From: <US1 Title>

- [ ] **Performance:** <…>
- [ ] **Functionality (Security):** <…>

### From: <US2 Title>

- [ ] <…>

## Unstructured Specs

### <was H1 in the source Spec File>

#### <was H2 in the source Spec File>

…
```

### Heading-level remap rules

The lane skills emit at a flat heading depth (`# Context: …`, `**Title:** …`, `### Happy Path`). When stitched into the unified doc, the orchestrator remaps depths so the document forms a single coherent outline:

- **Contexts.** `# Context: <T>` → `### Context: <T>` (under `## Contexts & Dictionary`). The `## Relationships` and `## Dictionary` subheaders inside each Context become `#### Relationships` and `#### Dictionary` respectively.
- **User Stories.** Each story gets a `### <Title>` heading (using the story's `**Title:**` value as the heading text). The `[Contexts: …]` tag, `**Title:**`, Connextra narrative, INVEST block, and any `What Changed:` block follow underneath, unchanged.
- **Acceptance Criteria.** AC are nested under their parent story. The lane skill's `### Happy Path` and `### Sad Path` headings are dropped; instead each *scenario* becomes a `#### <Scenario Name> — Happy/Sad Path` heading (the suffix names which path it is). The `**Background:**` block, if any, sits under the first scenario's heading or as its own `#### Background` heading at the top of the AC group, the user's call.
- **NFR.** NFR checklists from each story's AC are extracted out of the per-story AC section and grouped into a single `## Non-Functional Requirements` section at the bottom of the document, sub-grouped by parent story title (`### From: <US Title>`). **Do not dedupe automatically** — losing context on which story raised a given NFR is silent information loss; if the user wants dedupe, they ask for it explicitly.
- **Unstructured Specs.** The full body of the input Spec File (default `docs/specs/specs.md`) is embedded verbatim under a final `## Unstructured Specs` H2 section, preserving the upstream prose the rest of the doc derives from. Because the unified doc already owns the document's H1 and the section's H2, **shift every heading in the source down by 2 levels** when embedding so the source's intra-document hierarchy stays intact but nests cleanly under the wrapper:

  | Source heading | Heading inside `## Unstructured Specs` |
  |---|---|
  | `# foo`   | `### foo` |
  | `## foo`  | `#### foo` |
  | `### foo` | `##### foo` |
  | `#### foo` | `###### foo` |

  Stop at H6 — Markdown does not support deeper headings. If a source uses `#####`+ headings, flag the conflict and ask the user how to handle it (typical answer: flatten the deepest source levels to bold prose, since spec files don't usually need that depth). Non-heading content (paragraphs, lists, code blocks, tables, blockquotes) is copied through unchanged.

  This embedding is **always re-pulled fresh** on every Assembly run. If `docs/specs/specs.md` is edited, the next Assembly reflects the edit; the unified doc is never the source of truth for unstructured prose, only the assembled view of it.

### Assembly mechanics

1. **Read the source artifacts.** If the per-skill files exist, read them. If only the unified `spec.md` exists from a previous assembly, read that as the source of truth instead. If the user passed paths for foreign-source artifacts, read those.
2. **Format normalization (enforce canonical lane-skill formats).** Source artifacts may not match the lane skills' canonical Output format specs — common when `assemble` is run on artifacts produced by a different framework, by hand, or by an older version of these skills. Before stitching, normalize each source artifact against the relevant lane skill's Output format spec:
   - **Contexts** — `# Context: <Title>` + Relationships + Dictionary table per the `contexts-dictionaries` skill.
   - **Stories** — Connextra format (one clause per line, **trailing backslash `\` on every non-final clause line** for CommonMark hard-line-break, bold `**As a**` / `**I can**` / `**so that**` keywords, no fence), per-principle INVEST block, optional `[Contexts: …]` tag line + backtick-highlighted Dictionary terms when the project is anchored, per the `user-stories` skill.
   - **AC** — `**Scenario:**` / `**Background:**` / `**Feature:**` bold labels (outside any fence) followed by the body wrapped in a ` ```gherkin ` fenced code block, with one clause per line, 4-space indent on `And` continuations, trailing comma on every clause except the final one, and **no bold inside the fence** (bold doesn't render in code blocks). NFR as the FURPS+ checklist outside any fence, per the `acceptance-criteria` skill.
   When divergence is detected (run-on Connextra missing trailing `\`, AC body not wrapped in a `gherkin` fence, AC keywords bolded inside the fence, missing tag line, etc.), surface the divergence to the user, show the proposed normalized form **before** rewriting, and never silently transform. This is the "always show before write" rule. If you can't normalize confidently (e.g., the source is in a wholly unfamiliar shape), ask the user how to interpret it rather than guessing.
3. **Apply the remap rules above** — heading-level remap for Contexts/Stories/AC, NFR rollup, and the H1→H3 / H2→H4 / H3→H5 shift for the embedded Spec File — to produce the new full content of `spec.md`.
4. **Show the proposed document to the user before writing.** For incremental updates (e.g., one new story added), it is acceptable to show only the diff against the current `spec.md`, but make the full new content available on request.
5. **Write `spec.md`** once the user approves.
6. **Per-skill files are not deleted by this subroutine.** They remain as the standalone-skill artifacts. If the user wants to consolidate (delete the per-skill files now that `spec.md` is canonical), they ask for it explicitly — destructive cleanup is not implicit in this command.

### When to assemble

Run Assembly:

- After the dictionary phase completes (initial draft of `contexts.md` written and approved).
- After the stories phase completes (any new or revised story).
- After the AC phase completes (any new or revised AC set).
- After a `/spec review` pass that resulted in any artifact change.
- After a `/spec propagate <term>` pass that resulted in any artifact change.
- **Always when invoked via `/spec assemble`**, regardless of whether anything changed — this is the explicit entry point for foreign-source assembly, regenerate-after-manual-edits, and first-run materialization.

For phase-completion and review/propagate cases, skip Assembly when nothing changed *and* `spec.md` already exists. If `spec.md` is missing, run Assembly to materialise it on first contact, even if no artifact changed.

## Default file paths

- Spec File (input): `docs/specs/specs.md`
- Contexts/Dictionaries (per-skill): `docs/specs/contexts.md`
- Stories (per-skill): `docs/specs/user-stories.md`
- AC (per-skill): `docs/specs/acceptance-criteria.md`
- **Cohesive output (assembled by this command): `docs/specs/spec.md`**

If the user has the project laid out differently, accept the override they pass and use those paths consistently for the rest of the run.

## Things to avoid

- Don't re-explain the framework — point at `docs/kb/context-anchored-specifications.md` and the lane skills.
- Don't bypass a lane skill. If a phase belongs to one of the three skills, hand off; do not duplicate its logic here.
- Don't bulk-rewrite all artifacts in one shot during a `review` or `propagate` run. Walk the user through artifact-by-artifact.
- Don't assume `contexts.md` is up to date. If you smell drift between the Dictionary and the artifacts (e.g., a defined term is unused, an undefined term is highlighted), surface it.
