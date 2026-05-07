# Project Specification: `claude-code-dotfiles`

`claude-code-dotfiles` is a portable, Git-managed template for Claude Code configuration. It lets users keep global Claude Code instructions, custom commands, agents, skills, and a statusline script under version control, and expose them to Claude Code through symlinks into `~/.claude/`.

## Table of Contents

- [Contexts & Dictionary](#contexts--dictionary)
  - [Context: Sync Lifecycle](#context-sync-lifecycle)
- [User Stories](#user-stories)
  - [Install a portable Claude Code configuration on a new machine](#install-a-portable-claude-code-configuration-on-a-new-machine)
  - [Check the current state of my Claude Code configuration](#check-the-current-state-of-my-claude-code-configuration)
  - [Uninstall without losing the configuration I'm currently using](#uninstall-without-losing-the-configuration-im-currently-using)
  - [Out of scope for user stories](#out-of-scope-for-user-stories)
- [Non-Functional Requirements](#non-functional-requirements)
- [Unstructured Specs](#unstructured-specs)

---

## Contexts & Dictionary

### Context: Sync Lifecycle

Covers how `claude-code-dotfiles` provisions, observes, and removes Claude Code configuration under `~/.claude/`: the sync manifest, the lifecycle scripts, and the backup behaviour that protects user data.

#### Dictionary

| Term | Definition |
|------|------------|
| Sync Manifest | The complete, authoritative set of items synced into `~/.claude/`: every top-level entry under `dotclaude/`. Today the typed entries are `CLAUDE`, `StatusLine`, `subagent`, `command`, and `skill`. Placement under `dotclaude/` *is* the manifest — there is no include/exclude list. |
| User-Local Drift | Configuration that varies per machine or per user — `settings.local.json`, sessions, telemetry, project history, credentials, and non-statusline keys that may appear inside `dotclaude/settings.json` at any moment — and is therefore not maintained by this project. Lifecycle Scripts must never touch this state. |
| Lifecycle Script | One of the three repo-root Bash scripts — `setup.sh` (creates symlinks, prompts for confirmation, makes Backup Snapshots), `status.sh` (read-only report of managed items and snapshots), `teardown.sh` (removes repo-owned symlinks and replaces them with standalone copies of the current repo content). All three are idempotent. |
| Backup Snapshot | A timestamped directory at `~/.claude/backups/YYYYMMDD_HHMMSS/` holding entries that `setup.sh` displaced before creating a symlink in their place. Snapshots accumulate and are never auto-restored or auto-deleted; their preservation is part of the project's safety guarantee. |
| CLAUDE | The default global Claude Code instructions file, `dotclaude/CLAUDE.md`, synced to `~/.claude/CLAUDE.md`. Holds project-agnostic guidance Claude Code loads in every session. |
| StatusLine | The Claude Code statusline shipped by this project: the script `dotclaude/statusline.sh` together with the `dotclaude/settings.json` entry that points Claude Code at it. Only the script and the wiring entry are kept in sync verbatim; other keys present in `settings.json` are `User-Local Drift`. |
| subagent | A Claude Code subagent definition file, stored under `dotclaude/agents/`. A Claude Code platform concept (an entity with its own tools and system prompt, invocable via the Task tool). |
| command | A Claude Code slash-command definition under `dotclaude/commands/`, invoked by the user typing `/<name>` in a session. |
| skill | A Claude Code skill bundle under `dotclaude/skills/<name>/` (containing at minimum a `SKILL.md`), auto-invoked when its description matches user intent. |

---

## User Stories

The repository's core feature is **syncing** configuration, not prescribing its contents. What each user puts inside their `CLAUDE.md`, agents, commands, skills, or statusline is their own call; the stories below focus on the repository's job of installing, verifying, and uninstalling that configuration.

### Install a portable Claude Code configuration on a new machine

[Contexts: Sync Lifecycle]

**Title:** Install a portable Claude Code configuration on a new machine

**As a** Claude Code user, \
**I can** run a setup step that links the `Sync Manifest` — my `CLAUDE` file, my `subagent`s, `command`s, `skill`s, and the `StatusLine` — into my `~/.claude/` directory, creating `Backup Snapshot`s for anything that would be overwritten, \
**so that** I can get a repeatable Claude Code configuration on any machine without losing the files that were already there.

INVEST check:
- **I**ndependent — pass: standalone adoption flow; does not depend on any other story in this backlog.
- **N**egotiable — pass: the narrative names the user outcome (repeatable config, no data loss) and the high-level categories being synced, not the symlink/backup mechanism or the specific content of any category.
- **V**aluable — pass: new adopters get a working `~/.claude/` in one step and keep their pre-existing files safe.
- **E**stimable — pass: the scope is clearly bounded to a one-shot install flow over a known directory.
- **S**mall — pass: fits well within a sprint; the moving parts (discover, back up, link, confirm) are tight.
- **T**estable — pass: "after running setup, every item under the synced manifest — `CLAUDE.md`, agents, commands, skills, and statusline — is linked into `~/.claude/`, and any pre-existing entries are preserved in a backup location" is observable.

#### Background

```gherkin
Given the repository is checked out locally,
    And the user has confirmed the setup prompt
```

#### First-time install on a clean home directory — Happy Path

```gherkin
Given `~/.claude/` does not exist,
When the user runs the setup step,
Then `~/.claude/` is created,
    And every entry of the `Sync Manifest` exists in `~/.claude/` as a symlink pointing into the repository
```

#### Install preserves pre-existing files via backup — Happy Path

```gherkin
Given `~/.claude/` already contains a regular file or directory named the same as a `Sync Manifest` entry,
When the user runs the setup step,
Then the conflicting entry is moved into a `Backup Snapshot` before being replaced,
    And the corresponding `~/.claude/` entry is now a symlink into the repository
```

#### Re-running setup is idempotent for already-correct links — Sad Path

```gherkin
Given setup has previously linked every `Sync Manifest` entry,
When the user runs the setup step again,
Then no new `Backup Snapshot`s are created,
    And every existing symlink still points to the same repository target
```

_Note: "user declines confirmation → no changes" is covered implicitly by the Background step and does not need its own scenario._

### Check the current state of my Claude Code configuration

[Contexts: Sync Lifecycle]

**Title:** Check the current state of my Claude Code configuration

**As a** Claude Code user, \
**I can** run a read-only status check that reports which entries of the `Sync Manifest` are correctly linked, which are not, and which are missing, along with the `Backup Snapshot`s on disk, \
**so that** I can confirm my setup is healthy before relying on it in a Claude Code session.

INVEST check:
- **I**ndependent — pass: reads state; does not require install or teardown to have happened in any particular order.
- **N**egotiable — pass: the goal is "I can tell whether my configuration is healthy", not a prescribed output format.
- **V**aluable — pass: gives users confidence that the configuration they expect is actually the one Claude Code will load.
- **E**stimable — pass: narrow, read-only scope.
- **S**mall — pass: a single diagnostic command with a handful of output cases.
- **T**estable — pass: given a known `~/.claude/` state, the reported linked / not-linked / missing sets are observable.

#### Status reports a fully-linked configuration — Happy Path

```gherkin
Given setup has been run against the current repository,
When the user runs the status step,
Then every `Sync Manifest` entry is reported as linked,
    And the list of `Backup Snapshot`s under `~/.claude/backups/` is shown,
    And no filesystem changes are made
```

#### Status distinguishes linked, not-linked, and missing entries — Happy Path

```gherkin
Given some `Sync Manifest` entries are symlinked into `~/.claude/` correctly,
    And some `Sync Manifest` entries are present in `~/.claude/` as regular files or wrong-target symlinks,
    And some `Sync Manifest` entries have no counterpart in `~/.claude/`,
When the user runs the status step,
Then each `Sync Manifest` entry is reported under the correct category: linked, not linked, or missing
```

_No Sad Path applicable: status is read-only and has no failure mode beyond missing prerequisites, which the tool simply surfaces via the "not linked" / "missing" categories above._

### Uninstall without losing the configuration I'm currently using

[Contexts: Sync Lifecycle]

**Title:** Uninstall without losing the configuration I'm currently using

**As a** Claude Code user, \
**I can** run a teardown step that removes the repo-owned symlinks from `~/.claude/` and replaces each one with a standalone copy of the current content, leaving any `User-Local Drift` untouched, \
**so that** I can stop syncing through this repository without losing the configuration I'm currently working with.

INVEST check:
- **I**ndependent — pass: does not depend on other stories beyond the install story having ever been run, which is a natural prerequisite rather than a backlog dependency.
- **N**egotiable — pass: the user outcome is "clean exit, no data loss"; the underlying mechanics (how symlinks are resolved, how copies are materialised) remain open.
- **V**aluable — pass: makes the repo safe to adopt by removing the fear of lock-in; users can opt out at any time.
- **E**stimable — pass: bounded by the set of links the install step creates.
- **S**mall — pass: single command, mirror of install's scope.
- **T**estable — pass: "after teardown, no symlinks into this repo remain in `~/.claude/`, the configuration files are still present as standalone copies, and unrelated `~/.claude/` content is unchanged" is observable.

#### Teardown replaces repo-owned symlinks with standalone copies — Happy Path

```gherkin
Given `~/.claude/` contains symlinks that point into this repository,
When the user runs the teardown step,
Then each such symlink is removed,
    And the current content of its repository target is copied back into `~/.claude/` as a standalone file or directory,
    And any `User-Local Drift` in `~/.claude/` is left untouched
```

#### Teardown is safe to run when nothing matches — Sad Path

```gherkin
Given `~/.claude/` contains no symlinks that point into this repository,
When the user runs the teardown step,
Then the step completes without error,
    And `~/.claude/` is unchanged
```

### Out of scope for user stories

These items are in the source spec but are **not** written as user stories, because they are either internal invariants or workflow conventions without a standalone user-visible outcome:

- The `dotclaude/` sync-manifest boundary, the `setup.sh` / `status.sh` behavioural alignment, and `teardown.sh` using `readlink` as the source of truth. These are safety/quality requirements that belong in every story's acceptance criteria, not a separate story. ⚠ Would otherwise be **Fake Stories** — the "user need" lives inside the team's Zone of Control.
- The `main` vs `<username>/main` branch convention. This is a Git workflow for maintainers, not a feature the repository delivers; it does not require code to exist. ⚠ Would otherwise be a **Fake Story**.
- Shipping empty `agents/`, `commands/`, `skills/` placeholder folders on `main`. This is a structural invariant of the clean-template branch, covered under the install story's expected state.
- Verification expectations (`bash -n`, end-to-end lifecycle checks). These are quality gates for contributors, not user-facing capabilities.

---

## Non-Functional Requirements

_No NFR section. There are no meaningful cross-cutting quality thresholds for a shell/Python dotfiles helper: no latency budgets, no throughput targets, no auth surface, no accessibility concerns. The only cross-cutting quality attribute — **not touching user data** — is already enforced by Sad Path scenarios (backup on conflict, idempotent re-runs, leaving unrelated `~/.claude/` content alone). Adding an NFR checklist would be ceremony, not value._

---

## Unstructured Specs

### Project Specification: `claude-code-dotfiles`

#### 1. Product Intent

`claude-code-dotfiles` is a portable, Git-managed template for Claude Code configuration. It lets users keep global Claude Code instructions, custom commands, agents, skills, and a statusline script under version control, and expose them to Claude Code through symlinks into `~/.claude/`.

The project must be safe to adopt as a clean starting point, easy to fork for personal configuration, and explicit about what is synced versus what remains local machine state.

#### 2. Users and Outcomes

- **Claude Code user**: installs the repo once and gets a repeatable `~/.claude/` configuration across machines.
- **Power user / maintainer**: adds personal agents, commands, and skills under `dotclaude/`, commits them, and syncs them through Git.

Success means a user can clone, run setup, verify status, work normally in Claude Code, sync changes with Git, and uninstall without losing the current configuration.

#### 3. Scope

##### In Scope

- Symlink every top-level entry under `dotclaude/` into `~/.claude/`.
- Treat `dotclaude/` as the complete sync manifest; no hardcoded include/exclude list.
- Back up conflicting `~/.claude/` entries before replacing them with symlinks.
- Provide a read-only status command for link and backup state.
- Provide teardown that removes repo-owned symlinks and leaves standalone local copies behind.
- Version a default global `CLAUDE.md`, a `settings.json` whose sole responsibility is to wire the synced statusline, a `statusline.sh`, and placeholder folders for agents/commands/skills.
- Maintain a clean-template branch (`main`) separate from personal-config branches (`<username>/main`).
- Document clean-template usage and fork-based personalisation.

##### Out of Scope

- Managing credentials, `settings.local.json`, sessions, telemetry, project history, or other machine-local Claude Code state.
- Synchronising `settings.json` keys beyond the statusline wiring. General Claude Code preferences (plugin toggles, effort level, TUI mode, permission-prompt behaviour) are user-local state that changes often and must not become part of the sync contract.
- Restoring backups automatically.
- Shipping personal agents, commands, or skills on the clean-template branch.
- Managing remote branches, pull requests, or merge workflows for users.
- Providing a general dotfiles framework beyond Claude Code configuration.

#### 4. Current Product Surface

##### Repository Boundary

- `dotclaude/` is the authoritative synced configuration.
- Repo plumbing that must never be synced: `setup.sh`, `status.sh`, `teardown.sh`, `README.md`, `LICENSE`, the repo-root `CLAUDE.md`, the repo-root `.claude/` project config, and the `docs/` directory (repo-internal studies/notes).
- Adding a new synced capability means placing it under `dotclaude/` and rerunning `setup.sh` if it is a new top-level entry.

##### Branches

- **`main`** — the clean template. Contains the lifecycle scripts, default `CLAUDE.md`, statusline-only `settings.json`, `statusline.sh`, and empty `agents/`, `commands/`, and `skills/` placeholders (kept with `.gitkeep`). Intended starting point for anyone adopting the repo.
- **`<username>/main`** — personal-config branches layered on top of `main`. Personal agents, commands, and skills live here. `povaz/main` is the author's personal configuration.
- The `<username>/main` naming is a convention, not a requirement.

##### Lifecycle Scripts

- `setup.sh`
  - Requires Bash.
  - Shows resolved source, target, and backup paths before changing files.
  - Requires explicit confirmation.
  - Creates `~/.claude/` when needed.
  - Discovers all top-level entries under `dotclaude/`.
  - Backs up conflicting target entries to `~/.claude/backups/YYYYMMDD_HHMMSS/`.
  - Creates symlinks from `~/.claude/<name>` to `dotclaude/<name>`.
  - Is idempotent for already-correct links.

- `status.sh`
  - Requires Bash.
  - Makes no filesystem changes.
  - Uses the same `dotclaude/` discovery behaviour as `setup.sh`.
  - Reports each managed item as linked, not linked, or missing.
  - Lists backup snapshots.

- `teardown.sh`
  - Requires Bash.
  - Finds symlinks in `~/.claude/` that point into this repo.
  - Removes those symlinks and copies the current repo version back as standalone files/directories.
  - Leaves unrelated `~/.claude/` content untouched.
  - Is safe to rerun when no matching symlinks exist.

##### Synced Claude Code Configuration

- `dotclaude/CLAUDE.md`: default global instructions placeholder.
- `dotclaude/settings.json`: its sole spec-level responsibility is to wire Claude Code to `~/.claude/statusline.sh`. Any additional keys present in the file at a given moment are user-local drift and are not part of the sync contract.
- `dotclaude/statusline.sh`: reads Claude Code JSON from stdin and prints the model name, context-window usage (with a braille-dot bar), rate-limit usage when present, token counts (input/output), cache-read tokens, an estimated session cost, and the project directory plus current git branch.
- `dotclaude/agents/`, `dotclaude/commands/`, `dotclaude/skills/`: template folders. Empty on the clean `main` branch (kept with `.gitkeep`); may contain personal content on `<username>/main` branches.

#### 5. Safety and Quality Requirements

- Scripts must preserve user data by backing up or leaving unrelated files untouched.
- Setup and status discovery must remain behaviourally aligned.
- Teardown must use symlink targets as the source of truth (via `readlink`) instead of assuming a fixed layout.
- Commands must handle filenames safely using null-separated `find` loops where applicable.
- Re-running setup, status, or teardown must not create inconsistent state.
- The clean-template branch (`main`) must stay free of personal configuration content; `agents/`, `commands/`, and `skills/` on `main` contain only `.gitkeep` files.
- The sync contract for `dotclaude/settings.json` covers only the statusline wiring; other keys present in the file must not be relied upon as synced configuration.
- `~/.claude/` entries outside the synced set (sessions, projects, statsig, todos, shell-snapshots, credentials, `settings.local.json`) must never be touched by lifecycle scripts.
- README and project instructions must reflect the actual repository structure.

#### 6. Verification Expectations

- Syntax check shell scripts after edits:

  ```bash
  bash -n setup.sh && bash -n teardown.sh && bash -n status.sh
  ```

- For lifecycle changes, verify setup, status, idempotent setup, teardown, and setup again against a controlled `~/.claude/` state.
- For statusline changes, test with representative Claude Code JSON payloads covering present and missing context-window and rate-limit fields.
