# Acceptance Criteria: Automated test-database reset

**Story**
- Title: Automated test-database reset
- As a QA engineer, I can have the test database reset automatically between test runs, so that I can run the end-to-end suite faster without manual cleanup steps.

## Assumptions
- "Test database" is a dedicated DB instance used by the E2E suite (not production, not shared dev).
- "Between test runs" covers two granularities: (a) before the full suite starts, and (b) between individual tests/specs where isolation matters.
- "Reset" means restoring the DB to a known baseline (schema + seed data) with no residue from prior runs.

## Acceptance Criteria (Given / When / Then)

**AC1 — Automatic reset before the E2E suite starts**
- Given the E2E suite is triggered (locally or in CI)
- And the test database contains leftover data from a previous run
- When the suite initializes
- Then the test database is automatically reset to the known baseline (schema + seed data)
- And no manual cleanup command is required from the QA engineer
- And a log entry records the reset with a timestamp and baseline version

**AC2 — Per-test isolation**
- Given the E2E suite contains multiple tests that mutate data
- When one test completes and the next begins
- Then each test sees the baseline dataset (or its declared fixture state), independent of prior tests' mutations
- And test execution order does not affect outcomes

**AC3 — Deterministic, versioned baseline**
- Given the reset depends on a defined baseline (migrations + seed data)
- When the reset runs
- Then the resulting DB state is identical across runs for the same baseline version
- And the baseline version is recorded in run artifacts/logs

**AC4 — Performance: no suite-runtime regression**
- Given the suite previously required a manual cleanup step
- When the automated reset replaces it
- Then total wall-clock time of the E2E suite is equal to or less than the prior (manual-cleanup) baseline
- And the reset itself completes within an agreed budget (e.g., < 10s suite-level, < 500ms per-test)

**AC5 — Works in all supported environments**
- Given the suite runs on local dev machines and in CI
- When the automated reset is invoked in either environment
- Then it succeeds without environment-specific manual steps
- And config is sourced from environment variables, never hard-coded

**AC6 — Safety: cannot touch non-test databases**
- Given the reset tool is configured with a DB connection
- When the target DB is not the designated test DB (e.g., production, staging, shared dev)
- Then the reset aborts with a clear error before any destructive operation
- And an allow-list or naming convention (e.g., DB name suffix `_test`) gates execution

**AC7 — Failure handling**
- Given the reset step fails (migration error, connectivity issue, etc.)
- When the suite is starting
- Then the suite does not run
- And the failure surfaces with a clear, actionable error identifying the reset step
- And the CI job is marked failed

**AC8 — Observability**
- Given the automated reset has executed
- When a QA engineer inspects the run output
- Then they can see: start/end timestamps, duration, baseline version, target DB identifier, success/failure status
- And these details are available in both local and CI logs

**AC9 — Opt-out for debugging**
- Given a QA engineer is debugging a specific failure and needs to preserve state
- When they run the suite with a documented flag/env var (e.g., `SKIP_DB_RESET=1`)
- Then the automatic reset is bypassed for that run
- And a prominent warning is logged indicating the reset was skipped

## Edge cases
- Concurrent access: the reset terminates other sessions safely or fails fast — never leaves the DB half-reset.
- Partial failure: the next run detects inconsistent state and performs a full rebuild rather than an incremental reset.
- Seed drift: updated seed files are picked up automatically on the next reset.

## Definition of Done
- [ ] Automated reset wired into the E2E suite's setup lifecycle (and teardown where per-test isolation is required).
- [ ] Manual cleanup instructions removed from README/runbook; replaced with a note that reset is automatic.
- [ ] CI pipeline runs the suite with no manual DB step; green build demonstrated.
- [ ] Local run on a fresh clone executes the suite without the developer touching the DB.
- [ ] Documentation updated: how the reset works, how to override it, safety guarantees.
- [ ] Runtime benchmark captured before/after; no regression.
- [ ] Safety guard (non-test-DB abort) covered by an automated test.
