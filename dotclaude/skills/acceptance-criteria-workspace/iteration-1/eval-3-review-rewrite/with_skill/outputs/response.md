Before I rewrite, a few of the existing AC depend on thresholds and behaviors I can't see from the story. I'll draft with conservative assumptions and mark the gaps `??` — please confirm or correct:

1. **"Fast" target** — what's the target search latency? A common baseline is p95 under 300 ms server-side / under 500 ms end-to-end. Confirm or provide your own number.
2. **Empty / no-match results** — what should the learner see when the keyword matches zero courses? (Empty-state copy, suggestions, recent searches?)
3. **Minimum keyword length / allowed characters** — is there a minimum (e.g., 2 chars)? Are special characters / non-Latin scripts supported?
4. **Filter-panel coupling** — existing AC #3 bundles two behaviors into one trigger (search + close panel). Is closing the filter panel on Enter actually desired UX, or did that slip in from a prototype? I've flagged it below.
5. **Auth** — is catalogue search available to anonymous visitors, or only to authenticated learners?

---

## Review of existing AC — anti-patterns found

1. ⚠ **"The backend hits Elasticsearch and caches the result in Redis for 60 seconds."** — *Prescribes the implementation.* AC must describe **what** the system does, not **how**. Elasticsearch and Redis are implementation choices that can change without altering the story. The user-observable intent is "repeated searches feel instant"; rewritten as an NFR below.
2. ⚠ **"Search should be fast."** — *Unmeasurable.* "Fast" is an adjective, not a criterion. Replaced with a measurable latency threshold in the NFR checklist (pending your answer to Q1).
3. ⚠ **"When the user types a keyword and hits Enter AND the filter panel is open, the results update and the filter panel closes."** — *Multi-trigger `When` and conflated behaviors.* One action (Enter) is asked to drive two unrelated outcomes (search + close panel). If both are truly desired, they should be two scenarios. Also: closing the panel on Enter is a UX decision that's easy to get wrong — flagged in Q4. I've kept the search behavior and dropped the panel-closing side effect pending confirmation.
4. ⚠ **"Code is peer-reviewed and deployed to staging before merging."** — *Definition of Done, not AC.* This is a team-wide quality gate that applies to every story; it doesn't belong in this story's AC. Removed.
5. ⚠ **"The page is user-friendly."** — *Unmeasurable.* Replaced with concrete, testable usability/accessibility assertions (WCAG AA, keyboard operability).

Also: the existing set has **zero Sad Path** coverage (empty results, very long queries, backend unavailability) and **zero explicit NFRs beyond the hand-wavy "fast" and "user-friendly"**. Added below.

---

## Acceptance Criteria

### Happy Path (Gherkin)

```gherkin
Feature: Course catalogue keyword search
  Learners can search the catalogue by keyword to find relevant courses.

Background:
  Given the course catalogue is available           # ?? confirm: anonymous access or learner-only?
    And the learner is on the catalogue page

Scenario: Learner searches by keyword and sees matching courses
  Given the catalogue contains a course titled "Intro to Statistics"
  When the learner submits the search query "statistics"
  Then the learner sees a results list that includes "Intro to Statistics"
    And each result shows at least the course title, short description, and thumbnail
    And the learner's query is preserved in the search input
```

### Sad Path (Gherkin)

```gherkin
Scenario: Keyword matches no courses
  Given no course in the catalogue matches the keyword "xyzzy"
  When the learner submits the search query "xyzzy"
  Then the learner sees an empty-state message "No courses match your search."   # ?? confirm copy and whether suggestions are shown

Scenario: Keyword is shorter than the minimum length
  Given the minimum keyword length is 2 characters                                # ?? confirm minimum
  When the learner submits the search query "a"
  Then the learner sees a validation message "Please enter at least 2 characters."
    And no search is performed

Scenario: Search backend is temporarily unavailable
  Given the search service is returning errors
  When the learner submits the search query "statistics"
  Then the learner sees an error message "Search is temporarily unavailable. Please try again."
    And the previously displayed results, if any, are preserved
```

### Non-Functional Requirements (Checklist)

- [ ] **Performance:** p95 end-to-end time from submitting the query to first results rendered is under ?? ms for queries on a catalogue of up to ?? courses.  # ?? confirm Q1 and catalogue scale
- [ ] **Performance (perceived latency):** A repeated identical query within 60 s of the first returns consistent results with perceived latency under 50 ms. *(Replaces "caches in Redis for 60 s" — same outcome, no implementation leakage.)*
- [ ] **Usability (Accessibility):** The search input, submit action, results list, and empty/error states conform to WCAG 2.1 Level AA and are fully operable via keyboard alone, including screen-reader announcement of result counts.
- [ ] **Usability:** Search results appear without a full page reload; the input retains focus after submission so a follow-up query can be typed immediately.
- [ ] **Reliability:** When the search backend is unavailable, the catalogue page itself remains usable (browsing, navigation) and a clear error state is shown in the search area.
- [ ] **Supportability:** Each search emits a structured log with correlation ID, anonymized learner ID (if authenticated), query length, and result count; raw query strings are redacted per PII policy.  # ?? confirm PII stance on queries
- [ ] **+ Constraint (Internationalization):** Keyword search handles non-Latin scripts and diacritics (e.g., "café" matches "cafe").  # ?? confirm locale coverage

---

**What Changed:**
- **Removed AC #1** (Elasticsearch + Redis): implementation detail. Replaced with an outcome-based perceived-latency NFR that preserves the "repeat searches feel instant" intent without dictating the tech.
- **Removed AC #2** ("fast"): unmeasurable. Replaced with a quantified latency NFR (threshold pending confirmation).
- **Split AC #3**: dropped the filter-panel-close side effect (multi-trigger `When`, and a UX choice I'd like to confirm), kept the search-on-Enter behavior as the Happy Path scenario.
- **Removed AC #4** (peer review + staging deploy): Definition of Done, not story-level AC. Belongs in the team's DoD, not this ticket.
- **Removed AC #5** ("user-friendly"): unmeasurable. Replaced with concrete WCAG AA and keyboard-operability NFRs.
- **Added** Sad Path coverage (no matches, too-short query, backend failure) and explicit NFRs — the original set covered none of these.

**What to clarify (summary):**
1. Latency threshold and catalogue scale.
2. Empty-state UX copy and whether suggestions are offered.
3. Minimum keyword length and character/script support.
4. Is the "close filter panel on Enter" behavior actually desired? If yes, it becomes its own scenario.
5. Anonymous vs. authenticated access to search.
