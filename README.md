# claude-code-dotfiles

Portable Claude Code configuration — sync agents, commands, settings & skills across machines.

```bash
./setup.sh    # install symlinks into ~/.claude/
./status.sh   # check symlink state
./teardown.sh # uninstall, leaving local copies
```

## Contents

- [How It Works](#how-it-works)
- [Repo Structure](#repo-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
  - [Backups](#backups)
  - [Syncing Between Machines](#syncing-between-machines)
  - [Uninstalling](#uninstalling)
  - [What Gets Synced](#what-gets-synced)
- [Setting up your own fork](#setting-up-your-own-fork)

## How It Works

Claude Code stores its configuration in `~/.claude/`. This repo turns that directory into a Git-managed set of **symlinks**: each entry under `dotclaude/` gets linked into `~/.claude/`, so changes you commit here are instantly picked up by Claude Code on any machine where you've run `setup.sh`.

No files are copied — the symlinks point directly into your clone. Edit in the repo, commit, push, and every linked machine sees the update on the next `git pull`.

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

## Prerequisites

- **bash** — the setup/teardown/status scripts declare `#!/usr/bin/env bash`. Run them as `./script.sh` so the shebang is honored; don't invoke them through `zsh` or `sh`.

## Quick Start

```bash
git clone https://github.com/<your-username>/claude-code-dotfiles.git
cd claude-code-dotfiles
./setup.sh
```

`setup.sh` symlinks every entry under `dotclaude/` into `~/.claude/`, backing up any conflicting files into `~/.claude/backups/<timestamp>/` and skipping already-correct links. It's idempotent, so re-running it is safe.

### Backups

Whenever `setup.sh` would overwrite something in `~/.claude/`, it moves the pre-existing file into `~/.claude/backups/YYYYMMDD_HHMMSS/` first. One directory per run, timestamped to the second — so repeated runs never clobber earlier backups.

Backups are a one-way safety net, not a restore mechanism: nothing in this repo reads them back. If you want an old config, pull it out manually. Prune the `backups/` directory yourself whenever it gets noisy — the scripts will never touch it.

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

## Setting up your own fork

To run your own personal Claude Code configuration on top of this repo, **fork it** on GitHub and edit `dotclaude/` in your fork.

1. Fork [`Povaz/claude-code-dotfiles`](https://github.com/Povaz/claude-code-dotfiles) on GitHub into your own account.
2. Clone your fork and register this repo as an `upstream` remote so you can pull infrastructure updates later:

```bash
git clone https://github.com/<your-username>/claude-code-dotfiles.git
cd claude-code-dotfiles
git remote add upstream https://github.com/Povaz/claude-code-dotfiles.git

./setup.sh
```

Edit `dotclaude/` to taste — replace or extend the maintainer's agents, commands, skills, and `CLAUDE.md` — and commit to your fork.

When the upstream lifecycle scripts or shared infrastructure evolve, pull the updates in:

```bash
git fetch upstream
git merge upstream/main
```
