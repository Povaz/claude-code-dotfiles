# claude-code-dotfiles

Portable Claude Code configuration — sync agents, commands, settings & skills across machines and subscriptions.

## Contents

- [How It Works](#how-it-works)
- [Branches: clean template vs. personal configs](#branches-clean-template-vs-personal-configs)
- [Repo Structure](#repo-structure)
- [Quick Start](#quick-start)
  - [Syncing Between Machines](#syncing-between-machines)
  - [Uninstalling](#uninstalling)
  - [Backups](#backups)
  - [What Gets Synced](#what-gets-synced)
  - [Setting up your own personal branch](#setting-up-your-own-personal-branch)
- [What's currently on `povaz/main`](#whats-currently-on-povazmain)

## How It Works

Claude Code stores its configuration in `~/.claude/`. This repo turns that directory into a Git-managed set of **symlinks**: each entry under `dotclaude/` gets linked into `~/.claude/`, so changes you commit here are instantly picked up by Claude Code on any machine where you've run `setup.sh`.

No files are copied — the symlinks point directly into your clone. Edit in the repo, commit, push, and every linked machine sees the update on the next `git pull`.

## Branches: clean template vs. personal configs

This repo is published in two states:

- **`main`** — the **clean template**. Setup scripts plus empty `dotclaude/` placeholders (`.gitkeep` files under `agents/`, `commands/`, `skills/`, a minimal `CLAUDE.md`, and default `settings.json` / `statusline.sh`). No personal agents, commands, or skills. This is the intended starting point for anyone adopting these dotfiles.
- **`povaz/main`** — the **author's personal config**, layered on top of the template. Adds personal agents, commands, and skills. Browse [`povaz/main`](https://github.com/Povaz/claude-code-dotfiles/tree/povaz/main) for a working example, but don't check it out as your own — [create your own branch](#setting-up-your-own-personal-branch) off `main` instead.

The naming convention `<username>/main` is a hint, not a requirement — any branch name works.

## Repo Structure

```
claude-code-dotfiles/
├── setup.sh           # Creates symlinks from ~/.claude/ → dotclaude/
├── teardown.sh        # Removes symlinks, leaves standalone local copies
├── status.sh          # Dev utility — shows current symlink state
├── README.md
├── LICENSE
├── .gitignore
├── CLAUDE.md          # Project-level instructions for working on THIS repo
├── .claude/           # Project-level Claude config for THIS repo (commitable)
└── dotclaude/         # << everything in here is synced to ~/.claude/ >>
    ├── CLAUDE.md      # Global instructions Claude reads every session
    ├── settings.json  # Claude Code settings
    ├── statusline.sh  # Status bar script invoked by Claude Code
    ├── commands/      # Custom slash commands
    ├── agents/        # Custom agent definitions
    └── skills/        # Custom skills
```

`dotclaude/` **is** the sync manifest. `setup.sh` doesn't maintain an ignore list — it links every entry under `dotclaude/` and nothing else. Anything outside `dotclaude/` is repo plumbing (scripts, docs, the project-level `CLAUDE.md` / `.claude/` used when Claude Code runs inside this repo) and is never synced. Add a new file or directory under `dotclaude/`, re-run `setup.sh`, and it gets linked automatically.

## Quick Start

```bash
git clone https://github.com/<your-username>/claude-code-dotfiles.git
cd claude-code-dotfiles
./setup.sh
```

`setup.sh` symlinks every entry under `dotclaude/` into `~/.claude/`, backing up any conflicting files into `~/.claude/backups/<timestamp>/` and skipping already-correct links. It's idempotent, so re-running it is safe.

### Syncing Between Machines

```bash
# On machine A — push your changes
git add -A && git commit -m "Update settings" && git push

# On machine B — pull the latest
cd ~/claude-code-dotfiles
git pull
# That's it — symlinks already point here, so changes are live immediately.
```

No need to re-run `setup.sh` after pulling. The symlinks point into the repo, so any file changes from `git pull` are picked up instantly.

### Uninstalling

```bash
./teardown.sh
```

This removes every symlink in `~/.claude/` that points into this repo and replaces each one with a **copy of the current repo version**. After teardown, `~/.claude/` contains standalone local files — not old backups, not dangling links. You can safely delete the repo afterward.

### Backups

Whenever `setup.sh` would overwrite something in `~/.claude/`, it moves the pre-existing file into `~/.claude/backups/YYYYMMDD_HHMMSS/` first. One directory per run, timestamped to the second — so repeated runs never clobber earlier backups.

Backups are a one-way safety net, not a restore mechanism: nothing in this repo reads them back. If you want an old config, pull it out manually. Prune the `backups/` directory yourself whenever it gets noisy — the scripts will never touch it.

### What Gets Synced

| Synced (everything under `dotclaude/`) | NOT Synced (private/local) |
|---|---|
| `dotclaude/CLAUDE.md` | `.credentials.json` |
| `dotclaude/settings.json` | `settings.local.json` |
| `dotclaude/statusline.sh` | `projects/` |
| `dotclaude/commands/` | `statsig/` |
| `dotclaude/agents/` | `backups/` |
| `dotclaude/skills/` | Cache, sessions, telemetry, etc. |
| Any file/dir you add under `dotclaude/` | |

Anything **outside** `dotclaude/` — including the scripts, the repo-root `CLAUDE.md`, and the repo-root `.claude/` — is repo plumbing and is never synced into `~/.claude/`. Credentials and machine-local state are never touched by `setup.sh` or `teardown.sh`.

### Setting up your own personal branch

`main` is intentionally clean so anyone can clone it as a fresh starting point. To layer your own agents, commands, and skills on top, branch off `main`:

```bash
git clone https://github.com/Povaz/claude-code-dotfiles.git
cd claude-code-dotfiles

# Branch off main for your personal config
git checkout -b <your-username>/main
git push -u origin <your-username>/main

./setup.sh
```

Add your content under `dotclaude/` and commit it to your branch. When the template evolves on `main`, pull the updates into your branch:

```bash
git checkout <your-username>/main
git merge main
```

Because your personal content was added **after** branching from `main`, it's a branch-exclusive change — future `main → <your-username>/main` merges will never try to remove it. (This is also why `code-reviewer.md` lives on `povaz/main` rather than `main`: it was removed from `main` *before* `povaz/main` branched, so `povaz/main` re-introduces it as its own commit.)

## What's currently on `povaz/main`

A snapshot for anyone browsing this branch as a working example:

- **Agents** (`dotclaude/agents/`)
  - `code-reviewer` — multi-language reviewer (Python 3.14, Vue 3 TS/JS, MySQL) with an expanded code-smells / clean-code rule body.
  - `code-atlas` — produces high-level Markdown architectural documentation aimed at onboarding new developers.
- **Skills** (`dotclaude/skills/`)
  - `user-stories` — Apprendere agile-practices skill for drafting and reviewing Connextra-format stories with INVEST checks.
  - `acceptance-criteria` — Apprendere skill for producing Gherkin Happy/Sad paths plus a FURPS+ NFR checklist.
  - Each skill ships with an `evals/evals.json` and a companion `<name>-workspace/` — see [`CLAUDE.md`](CLAUDE.md) for why workspaces live inside `dotclaude/`.
- **Commands** (`dotclaude/commands/`) — none yet.
- **Statusline** (`dotclaude/statusline.sh`) — color-coded cost/context thresholds and current project + branch display.
