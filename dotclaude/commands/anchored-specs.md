---
description: Drive the Context-Anchored Specifications pipeline (Triage → Dictionary → Stories → AC → review/propagate).
argument-hint: "[triage | dictionary | stories | ac | review | propagate <term> | assemble] [optional source spec path]"
---

# /anchored-specs — Context-Anchored Specifications orchestrator

You are driving the **Context-Anchored Specifications** pipeline (framework doc at `~/.claude/kb/context-anchored-specifications.md`, the synced default — or at `docs/kb/context-anchored-specifications.md` if the current project pins a local copy). The framework prevents silent semantic drift by inserting a **Dictionary** (within named **Contexts**) between the unstructured source spec and the User Stories, and *anchors* Stories/AC to that Dictionary via Context tags and backtick-highlighted terms.

You do not re-derive the framework rules here — they live in the framework doc and in the three lane skills:

- `contexts-dictionaries` — owns Contexts and Dictionary entries.
- `user-stories` — owns Stories (anchoring rules included in its Anchoring section).
- `acceptance-criteria` — owns AC (anchoring rules included in its Anchoring section).

This command's job is **orchestration only**: figure out where the project is in the pipeline, route to the right skill, and ask the user for direction at the seams.

## Arguments

`$ARGUMENTS` is one of:

- *(empty)* — drive the next step from current state.
- `triage` — pre-dictionary spec health pass: mirror back the source spec's intent, flag ambiguities and gaps, ask clarifying questions, and produce an improved unstructured-spec body that lands in `## Unstructured Specs` of `anchored-specs.md`. Always runs first when starting from a brand-new spec.
- `dictionary` — focused dictionary phase (drafting, refining, splitting Contexts). Output is written into `## Contexts & Dictionary` of `anchored-specs.md`.
- `stories` — focused story phase (assumes `## Contexts & Dictionary` exists; produces anchored stories written into `## User Stories` of `anchored-specs.md`).
- `ac` — focused AC phase (assumes anchored stories exist; produces AC nested under each story and NFRs rolled up into `## Non-Functional Requirements` of `anchored-specs.md`).
- `review` — recurring spec review: prune the Dictionary, confirm anchoring on all stories, re-check multi-Context stories, ask about definitions changed since last review.
- `assemble` — pure Assembly trigger: rebuild `docs/anchored-specss/anchored-specs.md` from current state. No phase, review, or prune. Three motivators:
  - **First-run** — `anchored-specs.md` doesn't exist yet and you want to materialise it without driving a phase.
  - **Regenerate-after-manual-edits** — the user edited `anchored-specs.md` or the source spec by hand and wants the unified doc refreshed (e.g., after a manual edit to `## Unstructured Specs`, the heading-remap and source-shift rules should be re-applied).
  - **Foreign-source** — Contexts / Stories / AC originated outside this pipeline (different framework, different tool, manually authored elsewhere). The user passes paths to those source artifacts; `assemble` normalizes them to the canonical lane-skill formats and stitches them into `anchored-specs.md`.
- `propagate <term>` — definition-change propagation pass for a single term.


The source spec file is **user-supplied** — there is no fixed default. Resolution order on every invocation:

1. If the user passes a path as the second token (e.g. `/anchored-specs triage docs/anchored-specss/checkout.md`), use it.
2. Otherwise, read the `**Source:** <path>` line from the top of `docs/anchored-specss/anchored-specs.md` (see the Assembly subroutine for where this line is written).
3. Otherwise, ask the user for the path before proceeding.

Once known, the path is recorded as the `**Source:** <path>` line in `anchored-specs.md` on the next Assembly run, so subsequent invocations can resolve it without re-asking.

## Execution

### 1. Read the current state

`anchored-specs.md` is the **single source of truth**. Pipeline state is derived from which sections are present inside it. Don't fail if the file doesn't exist — that's part of the state (it's the brand-new-spec case).

Read these (don't fail on missing):

- `docs/anchored-specss/anchored-specs.md` if present. Inspect for these signals:
  - top-of-file `**Source:** <path>` line — tells you where the source spec lives.
  - `**Triage:** done <ISO date>` marker line near the top — signal that triage has run at least once (presence of `## Unstructured Specs` is the substantive signal; the marker just records the date).
  - `## Contexts & Dictionary` section with at least one `### Context: …` block — dictionary phase has run.
  - `## User Stories` section with at least one `### US-X — …` block — stories phase has run.
  - At least one `#### AC-X.Y — …` heading nested under any story — AC phase has run.
  - `[Contexts: …]` tag lines on each story — anchoring is in place.
  - `## Unstructured Specs` section — triage's improved-spec output has been embedded.
- The source spec file at the path resolved per the rules above. Read it after `anchored-specs.md` so the source path is already known.

Briefly summarise the state in one or two lines: which sections exist inside `anchored-specs.md`, whether triage has run, whether stories are anchored, whether AC are present. **Per-skill files** (`triage.md`, `contexts.md`, `user-stories.md`, `acceptance-criteria.md`) — if you encounter them in the spec folder, they are legacy artifacts from older runs and **are not read or updated** by this command. Mention their presence to the user but do not delete them; migration is the user's call.

### 2. Route based on `$ARGUMENTS`

**Empty** — pick the next step from current state (state derived from sections inside `anchored-specs.md`):

| State | Next step |
|---|---|
| `anchored-specs.md` doesn't exist, or has no `## Unstructured Specs` and no `## Contexts & Dictionary` | Run triage phase: see the Triage subroutine below. |
| `## Unstructured Specs` present, no `## Contexts & Dictionary` (or it has no `### Context:` blocks) | Run dictionary phase: hand off to the `contexts-dictionaries` skill. |
| `## Contexts & Dictionary` populated, but `## User Stories` is missing or has no anchored stories (`### US-X — …` with `[Contexts: …]` tag lines) | Run stories phase: hand off to the `user-stories` skill, applying anchoring. |
| Stories anchored, no `#### AC-X.Y — …` headings under any story | Run AC phase: hand off to the `acceptance-criteria` skill. |
| All three sections present and look healthy | Suggest `/anchored-specs review` and stop. |

Once `## Contexts & Dictionary` exists, the empty route does **not** regress to triage — the user has moved past it. They can always re-invoke `/anchored-specs triage` explicitly when they want a fresh ambiguity pass on the source spec.

**`triage`** — see the Triage subroutine below. Always re-runs (the user invoked it explicitly, so respect that), even if `## Unstructured Specs` is already populated.

**`dictionary`** — hand off to the `contexts-dictionaries` skill. State your intent, name the source spec path you'll read (resolved per the rules above), and let the skill produce the Context blocks in its response. The skill does **not** write to disk; this command takes the response and inserts it into `## Contexts & Dictionary` of `anchored-specs.md` (creating the section if missing). Show the user the proposed insertion and write only after approval.

**`stories`** — confirm `## Contexts & Dictionary` exists in `anchored-specs.md` and has at least one `### Context:` block. If not, refuse and tell the user to run `/anchored-specs dictionary` first. Otherwise hand off to the `user-stories` skill, instructing it that the project is anchored (so it should apply the rules in its Anchoring section). Pass the next free `US-X` integer in the handoff prompt — compute as `max(existing US-X) + 1` by scanning the `### US-X — …` headings under `## User Stories` in `anchored-specs.md`; start at 1 if none exist. Codes are sticky, so gaps from prior deletions/splits are expected and must not be reused. The skill returns story content in its response; this command inserts/updates the matching `### US-X — …` block under `## User Stories`. Show before write.

**`ac`** — confirm at least one anchored story exists (look for `[Contexts: …]` tag lines under `## User Stories` in `anchored-specs.md`). If not, refuse and tell the user to run `/anchored-specs stories` first. Otherwise hand off to the `acceptance-criteria` skill, anchored. Pass the parent story's `US-X` and the next free `Y` for that story — compute as `max(existing AC-X.Y for this X) + 1` by scanning the `#### AC-X.Y — …` headings nested under that story; start at Y=1 if none exist for this X. The skill returns scenario + NFR content in its response; this command inserts/updates the matching `#### AC-X.Y — …` blocks under the parent story and rolls NFR bullets up into `## Non-Functional Requirements` § `### From: US-X — <Title>`. Show before write.

**`review`** — see the Recurring review subroutine below.

**`propagate <term>`** — see the Propagation subroutine below.

**`assemble`** — see the Assembly subroutine below. Run it directly with no preceding phase, review, or prune. If the user passes paths to foreign-source artifacts (Contexts / Stories / AC produced outside this pipeline), the Assembly subroutine handles normalization to the canonical lane-skill formats before stitching them into `anchored-specs.md` — see its **Format normalization** clause.

### 3. Iterative refinement is the default

Any earlier artifact may be revised at any step. If during a phase you discover the Dictionary needs a new entry or a definition tweak, hand control to `contexts-dictionaries`, then return. Iteration is mandatory (Rule 8 of the framework).

### 4. Always show before write

The lane skills produce content in their response; **this command** owns disk writes to `anchored-specs.md`. Always show the user the proposed insert/diff into `anchored-specs.md` before writing — the skill's response is the proposal, the command's edit is what reaches disk.

### 5. Run the Assembly subroutine after every phase

Once a phase finishes (and any iteration loop closes), run the **Assembly subroutine** below to refresh `docs/anchored-specss/anchored-specs.md`. For per-section updates produced by the lane skills (the typical phase-finish case), Assembly is a thin **section-level edit**: locate the matching section, replace or append the new content, re-apply the heading-remap rules. The full re-stitch path is for `assemble` (foreign-source / regenerate-after-manual-edits / first-run). Either way, the unified doc is the only artifact this command writes — there is no per-skill file output anywhere in the pipeline.

## Triage subroutine (`/anchored-specs triage`)

Triage is a **pre-dictionary spec health pass**. Its purpose is to surface internal inconsistency, ambiguity, and gaps in the source spec *before* the lane skills start mining it for vocabulary, stories, and AC. Lane skills are good at structuring what's already clear; they cannot rescue a spec that is genuinely under-specified. Triage catches that early and turns the source spec into an improved, unambiguous version.

Triage's persistent output is the **improved unstructured spec body** that lands in `## Unstructured Specs` of `anchored-specs.md`. There is no separate `triage.md` file; the clarifying-question Q&A is conversational. The user's original source spec is theirs to keep wherever they put it.

Triage runs:

- Automatically on empty `/anchored-specs` invocation when `anchored-specs.md` is missing or has no `## Unstructured Specs` and no `## Contexts & Dictionary`.
- On explicit `/anchored-specs triage`, always — re-runnable for a freshened ambiguity check after the source spec has been edited.

### Procedure

1. **Resolve the source spec path** per the resolution order at the top of this command. If the path is unknown, ask before proceeding.
2. **Read the source spec end-to-end.** Don't skim. Look for cross-section consistency (does Section 3 contradict Section 7?), undefined roles, undefined terms used as if defined, references to behaviours not described, missing failure modes, missing thresholds.
3. **Produce the triage report in your response** (no file written yet). Sections (use the headings exactly):
   - **Mirror-back summary** — one paragraph, plain English, capturing what you understand the spec to be about. The user reads this first to confirm you didn't misread the document. If they correct you, fold the correction in before continuing.
   - **Ambiguous statements** — quote the offending sentence, give a section/line reference, and state in one line *why* it's ambiguous (multiple plausible interpretations, undefined term, contradicts another section, etc.).
   - **Missing details** — concrete gaps the lane skills will hit later (no error model, no thresholds, undefined user roles, no described failure mode for X, etc.). One bullet per gap.
   - **Clarifying questions** — grouped by topic (Roles / Data / Thresholds / Failure modes / etc.). Numbered within each topic. Phrase each question so the user can answer in one or two sentences; avoid open-ended "tell me about X".
4. **Wait for the user's answers.** Do not auto-fill. The Q&A happens conversationally in this session — no separate file. The user may also choose to update the source spec inline; encourage this when the answer is short and stable. Deferred questions are noted and re-surfaced on the next triage run.
5. **Produce the improved unstructured-spec body.** Take the source spec verbatim as the baseline, fold in the user's answers as inline corrections / clarifications / additions, and emit the result in your response. This is what will populate `## Unstructured Specs` of `anchored-specs.md`. Show it to the user before writing.
6. **Run the Assembly subroutine** to write the improved body into `anchored-specs.md` (creating the file if missing) under `## Unstructured Specs`, with heading-shift applied (H1→H3, H2→H4, …) per the heading-remap rules. Also add or update a `**Triage:** done <ISO date>` marker line near the top of `anchored-specs.md` (just below the `**Source:** <path>` line) so re-runs can tell triage has been done.
7. **Hand off to dictionary** when the user signals readiness, or stop if they want to absorb answers into the source spec first.

### Things triage does **not** do

- It does not draft a Dictionary, Stories, or AC. Those are the lane skills' jobs; triage's value is keeping the input clean for them.
- It does not silently rewrite the source spec at the user's path. If the user wants edits applied to the original file, they apply them or ask explicitly. Triage's edits live inside `## Unstructured Specs` of `anchored-specs.md`, not in the source.
- It does not block the pipeline if the user judges the spec good enough. They can defer questions and proceed; deferrals are conversational and will resurface on the next triage run.

## Recurring review subroutine (`/anchored-specs review`)

All scans run on `anchored-specs.md` only — there are no per-skill files to consult.

1. Read `## Contexts & Dictionary` and list the terms by Context.
2. For each term, count citations by grepping the rest of `anchored-specs.md` (`## User Stories`, AC scenario bodies, NFR checklist) for `` `<term>` `` and `` `<term>[*]` ``. Flag the count as best-effort — automatic citation tracking is a documented future enhancement of the framework. Ask the user only when the count is genuinely ambiguous.
3. Hand off the pruning decision to the `contexts-dictionaries` skill with the citation counts. Take its response and edit `## Contexts & Dictionary` accordingly. Show before write.
4. Walk `## User Stories`. Confirm every `### US-X — …` block has a `[Contexts: …]` tag line; flag any that don't as **unanchored** and offer to anchor them via the `user-stories` skill.
5. **Code health check.** Scan `## User Stories` for duplicate `US-X` codes and per-story AC sections for duplicate `AC-X.Y` codes. Flag duplicates as a real bug and ask the user which is canonical. Gaps in numbering are expected (codes are sticky after deletion or splits) and don't need attention.
6. For multi-Context stories, prompt the user to re-check them against the split-or-keep rubric (the `user-stories` skill knows the rubric).
7. Ask the user whether any term's definition changed since the last review. For each yes, run `/anchored-specs propagate <term>`.

Stop after each step and confirm with the user before moving on. The review is a conversation, not a unilateral rewrite.

## Propagation subroutine (`/anchored-specs propagate <term>`)

1. Grep `anchored-specs.md` for occurrences of `` `<term>` `` and `` `<term>[*]` `` (any inline-disambiguated form). One file; one source of truth.
2. Show the user the list of affected artifacts using their codes (e.g. "affects US-3, AC-3.1, AC-3.4, US-7"). Codes are stable handles that survive renumbering and stay greppable, so they are the preferred citation form. Do not modify anything yet.
3. Ask the user to confirm which of those need re-review. For each confirmed, hand off to `user-stories` or `acceptance-criteria` with the affected story/AC text and the new definition. The skill returns the updated content in its response.
4. Do not silently rewrite artifacts. The user drives the propagation; this command edits `anchored-specs.md` only after explicit approval per artifact.
5. Once the user has approved the updates, write them into the matching sections of `anchored-specs.md` (re-applying heading-remap as needed). No separate Assembly pass is required — propagation is itself a series of section-level edits.

## Assembly subroutine (cohesive document)

This command's value-add over the lane skills is producing **one cohesive document**: `anchored-specs.md` is the only artifact the pipeline writes. Lane skills emit content in their response; this subroutine inserts that content into the matching section.

Two modes:

- **Section-level update** (the typical phase-finish case). One section of `anchored-specs.md` changes — `## Contexts & Dictionary`, a single `### US-X — …` block, a single story's AC group, or a single NFR rollup entry. Read the file, edit the matching section, write back. Don't re-stitch the whole document.
- **Full re-stitch** (used by `/anchored-specs assemble`). Foreign-source materialization, regenerate-after-manual-edits, or first-run from scratch. Read the source artifacts (the user-supplied source spec; whatever foreign-source content the user pointed at), normalize per the **Format normalization** clause below, apply the **Heading-level remap rules**, and produce the full content of `anchored-specs.md`.

Lane skills do **not** read or write per-skill files (`contexts.md`, `user-stories.md`, `acceptance-criteria.md`). If those files exist in the spec folder, they are legacy artifacts; this subroutine ignores them.

### Output path

`docs/anchored-specss/anchored-specs.md` (distinct from the **source spec** at the user-supplied path).

### Document structure

```markdown
# <Title — pulled from the source spec's H1, or asked of the user>

**Source:** `<path to source spec>`
**Triage:** done <ISO date>   <!-- present once triage has run; absent on a brand-new doc -->

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
- **Unstructured Specs.** The body embedded under `## Unstructured Specs` is the **post-triage improved version** of the source spec (the original prose with the user's clarifying-Q&A answers folded in as inline corrections / additions). The `**Source:** <path>` line at the top of `anchored-specs.md` records where the original lives. If triage has not run, embed the source verbatim until it does. Because the unified doc already owns the document's H1 and the section's H2, **shift every heading in the embedded body down by 2 levels** so the body's intra-document hierarchy stays intact but nests cleanly under the wrapper:

  | Embedded-body heading | Heading inside `## Unstructured Specs` |
  |---|---|
  | `# foo`   | `### foo` |
  | `## foo`  | `#### foo` |
  | `### foo` | `##### foo` |
  | `#### foo` | `###### foo` |

  Stop at H6 — Markdown does not support deeper headings. If the body uses `#####`+ headings, flag the conflict and ask the user how to handle it (typical answer: flatten the deepest levels to bold prose, since spec files don't usually need that depth). Non-heading content (paragraphs, lists, code blocks, tables, blockquotes) is copied through unchanged.

  Triage is the **only path** that updates this section. A full re-stitch (`/anchored-specs assemble`) preserves the existing `## Unstructured Specs` content if `anchored-specs.md` already has one — it does **not** silently overwrite the post-triage body with the raw source. To refresh from the raw source after editing it, the user re-runs `/anchored-specs triage`.

### Assembly mechanics

**Section-level update (phase-finish):**

1. Read the current `anchored-specs.md`.
2. Take the lane skill's response content (Contexts / a story / an AC group / NFRs).
3. Locate the matching section. Insert (if new) or replace (if updating). Apply the heading-remap rules below as you embed.
4. Show the user the diff. Write only after approval.

**Full re-stitch (`/anchored-specs assemble`):**

1. **Read the source artifacts.**
   - If the user passed paths for foreign-source artifacts, read those.
   - Otherwise, read the source spec at the resolved path and read the existing `anchored-specs.md` if present (so previously-assembled sections survive the re-stitch).
2. **Format normalization (enforce canonical lane-skill formats).** Source artifacts may not match the lane skills' canonical Output format specs — common when `assemble` is run on artifacts produced by a different framework, by hand, or by an older version of these skills. Before stitching, normalize each source artifact against the **single source of truth** for its shape — the owning lane skill's `## Output format` section. Do not restate the format here:
   - **Contexts** — follow the canonical Output format in `~/.claude/skills/contexts-dictionaries/SKILL.md` § Output format (the synced copy is symlinked from `dotclaude/skills/contexts-dictionaries/SKILL.md` in this repo).
   - **Stories** — follow the canonical Output format in `~/.claude/skills/user-stories/SKILL.md` § Output format. If a foreign-source story has no `US-X` code, assign one using the next free integer (codes are sticky — never reuse retired numbers); show before writing.
   - **AC** — follow the canonical Output format in `~/.claude/skills/acceptance-criteria/SKILL.md` § Output format. The `AC-X.Y` code prefix and `— Happy Path` / `— Sad Path` suffix on the Scenario label are what this command's Assembly subroutine uses to produce per-scenario headings without inference (see the heading-remap rules above) — the lane skill emits them; this command does not assign or infer them. If a foreign-source AC has no `AC-X.Y` code, inherit X from the parent story and assign Y as the next free integer for that story (codes are sticky); show before writing. NFR follows the same skill's checklist shape.
   When divergence is detected (run-on Connextra missing trailing `\`, AC body not wrapped in a `gherkin` fence, AC keywords bolded inside the fence, missing tag line, etc.), surface the divergence to the user, show the proposed normalized form **before** rewriting, and never silently transform. If you can't normalize confidently (e.g., the source is in a wholly unfamiliar shape), ask the user how to interpret it rather than guessing.
3. **Apply the remap rules above** — heading-level remap for Contexts/Stories/AC, NFR rollup, and the H1→H3 / H2→H4 / H3→H5 shift for the embedded source spec — to produce the new full content of `anchored-specs.md`.
4. **Show the proposed document to the user before writing.** It is acceptable to show only the diff against the current `anchored-specs.md`, but make the full new content available on request.
5. **Write `anchored-specs.md`** once the user approves.
6. **Legacy per-skill files are not touched.** If the spec folder still contains `triage.md`, `contexts.md`, `user-stories.md`, or `acceptance-criteria.md` from older runs, mention them to the user but do not delete or modify them. Migration of legacy content is the user's call; the pipeline itself produces only `anchored-specs.md` going forward.

### When to assemble

Run a **section-level update** at the end of every phase:

- Triage → write the improved unstructured-spec body into `## Unstructured Specs` (creating `anchored-specs.md` if missing) and add the `**Triage:** done <ISO date>` marker.
- Dictionary → write Context blocks into `## Contexts & Dictionary`.
- Stories → write each story block under `## User Stories`.
- AC → write each scenario group under its parent story; roll NFRs into `## Non-Functional Requirements`.
- After a `/anchored-specs review` pass that resulted in any artifact change.
- After a `/anchored-specs propagate <term>` pass that resulted in any artifact change.

Run a **full re-stitch** when:

- `/anchored-specs assemble` is invoked explicitly (foreign-source / regenerate-after-manual-edits / first-run-from-foreign-content).
- `anchored-specs.md` is missing on a phase-finish — materialise it from scratch, then apply the section-level update.

## Default file paths

- **Source spec (input): user-supplied** — recorded as `**Source:** <path>` at the top of `anchored-specs.md` once known. No default; resolved per the rules in the Arguments section.
- **Cohesive output (the only artifact this command writes): `docs/anchored-specss/anchored-specs.md`**.

There are **no per-skill output files**. Lane skills emit content in their response and this command writes it into the matching section of `anchored-specs.md` itself.

If the user has the project laid out differently, accept the override they pass and use that path consistently for the rest of the run. Legacy per-skill files (`triage.md`, `contexts.md`, `user-stories.md`, `acceptance-criteria.md`) from older runs are ignored — neither read nor written; mention them to the user if encountered, but don't delete.

## Things to avoid

- Don't re-explain the framework — point at the framework doc (`~/.claude/kb/context-anchored-specifications.md`, or `docs/kb/context-anchored-specifications.md` if the project pins a local copy) and the lane skills.
- Don't bypass a lane skill. If a phase belongs to one of the three skills, hand off; do not duplicate its logic here.
- Don't bulk-rewrite all artifacts in one shot during a `review` or `propagate` run. Walk the user through artifact-by-artifact.
- Don't assume `## Contexts & Dictionary` is up to date. If you smell drift between the Dictionary and the artifacts (e.g., a defined term is unused, an undefined term is highlighted), surface it.
