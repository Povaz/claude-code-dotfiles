# Acceptance Criteria Review: Course Catalogue Keyword Search

Below is a review of each existing AC, the anti-pattern it exhibits, and a rewritten set of criteria at the end.

---

## Review of Existing AC

### 1. "The backend hits Elasticsearch and caches the result in Redis for 60 seconds."

**Anti-pattern: Implementation leakage / solution bias.**

Acceptance criteria describe *observable behavior*, not internal architecture. Naming Elasticsearch, Redis, or specific TTLs locks the team into a design decision that belongs in a tech spec or ADR — not in a story owned by a PO. If the infra team later switches to OpenSearch or an in-process cache, this AC becomes false even though the user-visible behavior is unchanged.

What this is probably *trying* to say is a non-functional requirement about latency/load. Express it that way.

---

### 2. "Search should be fast."

**Anti-pattern: Subjective / untestable.**

"Fast" has no pass/fail threshold. Two reviewers can disagree forever. Every non-functional AC needs a number, a percentile, and the conditions under which it's measured (cold cache? warm cache? p50 vs p95? what payload size?).

---

### 3. "When the user types a keyword and hits Enter AND the filter panel is open, the results update and the filter panel closes."

**Anti-pattern: Compound / multi-behavior AC + hidden UX decision.**

Two problems:
- It bundles two behaviors (results update, panel closes) into one criterion, so a partial pass is ambiguous.
- Auto-closing the filter panel on search is a debatable UX choice that deserves its own story or explicit product decision — learners often *want* to refine filters *and* keyword simultaneously. Burying it inside a keyword-search AC hides the decision from review.

Split the behaviors; promote the panel-close behavior to its own AC (or drop it) so it gets scrutinized on its own merits.

---

### 4. "Code is peer-reviewed and deployed to staging before merging."

**Anti-pattern: Process / Definition-of-Done masquerading as AC.**

Peer review and staging deploys apply to *every* story and belong in the team's Definition of Done, not per-story acceptance criteria. Mixing DoD into AC dilutes the story, creates copy-paste noise, and makes it unclear what's actually being signed off.

(Also: "deployed to staging *before merging*" implies deploy-from-branch, which is a workflow policy — again, team-level, not story-level.)

---

### 5. "The page is user-friendly."

**Anti-pattern: Vague / unverifiable.**

"User-friendly" is a value, not a criterion. It can't be demonstrated in a review. If there are concrete usability requirements (keyboard accessibility, empty-state messaging, loading indicator, screen-reader support), list them individually and make each testable.

---

## Rewritten Acceptance Criteria

Given the story *"As a learner, I can search the course catalogue by keyword, so that I can find relevant courses,"* here is a tightened set. I've kept them behavior-focused, independently testable, and free of implementation detail.

**AC1 — Keyword entry returns matching courses**
Given I am on the course catalogue page,
When I enter a non-empty keyword in the search input and submit (Enter key or search button),
Then I see a list of courses whose title, description, or tags match the keyword,
And each result shows at least the course title, short description, and a link to the course detail page.

**AC2 — No results state**
Given I have submitted a keyword that matches no courses,
When the search completes,
Then I see an empty-state message ("No courses match '<keyword>'") and a suggestion to clear or refine the search.

**AC3 — Empty / whitespace input**
Given the search input is empty or contains only whitespace,
When I submit,
Then no search is performed and the current catalogue view is unchanged (no error, no spinner flicker).

**AC4 — Loading state**
Given I have submitted a search,
When results have not yet returned,
Then a loading indicator is visible and the previous results remain on screen until replaced (no layout flash).

**AC5 — Performance (NFR)**
The search results endpoint returns within **500 ms at p95** and **1 s at p99**, measured at the API boundary, for catalogues up to 50,000 courses under expected peak load (defined in the perf test plan). Cold-cache vs. warm-cache behavior is documented; neither path may exceed the p99 budget.

**AC6 — Search interaction with active filters**
Given one or more filters are active,
When I submit a keyword search,
Then results reflect the intersection of the keyword and the active filters,
And the filter panel state (open/closed) is **not** changed by the search action.
*(Note: the original AC auto-closed the filter panel. I've inverted that default because it hurts the common "refine + search" flow. If product wants the auto-close, raise it as its own story with rationale.)*

**AC7 — Accessibility**
- The search input has a visible label and an accessible name.
- Submitting via keyboard (Enter) and via the search button produce identical behavior.
- Results region uses `aria-live="polite"` so screen readers announce result count changes.
- Focus order is preserved after results render (focus does not jump unexpectedly).

**AC8 — URL / shareability** *(optional — confirm with PO)*
The active keyword is reflected in the URL query string so that a learner can bookmark or share a search result, and reloading the page restores the same results.

---

## Removed / relocated items

- **Elasticsearch + Redis caching detail** → moved to the technical design doc. AC5 captures the user-visible constraint (latency) without prescribing the solution.
- **"Peer-reviewed and deployed to staging"** → belongs in the team **Definition of Done**, not this story.
- **"User-friendly"** → decomposed into AC2 (empty state), AC4 (loading), AC7 (a11y).
- **"Filter panel closes on search"** → intentionally inverted in AC6; flagged for separate product decision.

---

## Summary of anti-patterns flagged

| # | Anti-pattern | Where it appeared |
|---|---|---|
| 1 | Implementation leakage | Original AC1 (Elasticsearch/Redis/60s) |
| 2 | Subjective / unmeasurable NFR | Original AC2 ("fast") |
| 3 | Compound AC + smuggled UX decision | Original AC3 |
| 4 | Definition-of-Done as AC | Original AC4 |
| 5 | Vague / unverifiable quality claim | Original AC5 ("user-friendly") |

Good acceptance criteria are: **independently testable, behavior-focused, free of solution detail, and each one capable of a clean pass/fail verdict.** The rewrite above aims for that bar.
