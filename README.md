# claude-code-dotfiles

Portable Claude Code configuration — sync agents, commands, settings & skills across machines.

```bash
./setup.sh                                # install symlinks into ~/.claude/
./status.sh                               # check symlink state
./teardown.sh                             # uninstall, leaving local copies
~/.claude/scripts/spawn-agent/launch.sh   # spawn a Claude agent in a git worktree
~/.claude/scripts/spawn-agent/cleanup.py  # prune agent worktrees
```

## Contents

- [How It Works](#how-it-works)
- [Repo Structure](#repo-structure)
- [Branches: clean template vs. personal configs](#branches-clean-template-vs-personal-configs)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
  - [Backups](#backups)
  - [Syncing Between Machines](#syncing-between-machines)
  - [Uninstalling](#uninstalling)
  - [What Gets Synced](#what-gets-synced)
- [Spawning agents in worktrees](#spawning-agents-in-worktrees)
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
    ├── skills/        # Custom skills
    └── scripts/       # Helper scripts synced into ~/.claude/scripts/
        └── spawn-agent/   # Interactive agent-in-worktree launcher
            ├── launch.py
            ├── launch.sh
            └── cleanup.py
```

`dotclaude/` **is** the sync manifest. `setup.sh` doesn't maintain an ignore list — it links every entry under `dotclaude/` and nothing else. Anything outside `dotclaude/` is repo plumbing (scripts, docs, the project-level `CLAUDE.md` / `.claude/` used when Claude Code runs inside this repo) and is never synced. Add a new file or directory under `dotclaude/`, re-run `setup.sh`, and it gets linked automatically.

## Branches: clean template vs. personal configs

This repo is published in two states:

- **`main`** — the **clean template**. Setup scripts plus empty `dotclaude/` placeholders (`.gitkeep` files under `agents/`, `commands/`, `skills/`, a minimal `CLAUDE.md`, and default `settings.json` / `statusline.sh`). No personal agents, commands, or skills. This is the intended starting point for anyone adopting these dotfiles.
- **`povaz/main`** — the **author's personal config**, layered on top of the template. Adds personal agents, commands, and skills.
- If you want your own version [fork the repo](#setting-up-your-own-fork) instead and branch from main.

The naming convention `<username>/main` is a hint, not a requirement — any branch name works.

## Prerequisites

- **bash** — the setup/teardown/status scripts and the [worktree launcher](#spawning-agents-in-worktrees) under `dotclaude/scripts/` declare `#!/usr/bin/env bash`. Run them as `./script.sh` so the shebang is honored; don't invoke them through `zsh` or `sh`.
- **Python 3.14** — required by the [worktree launcher](#spawning-agents-in-worktrees) scripts under `dotclaude/scripts/spawn-agent/`.

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

## Spawning agents in worktrees

`dotclaude/scripts/spawn-agent/` lets you launch a Claude Code session in a dedicated git worktree, so multiple agents can work the same repo on different branches in parallel without fighting over `HEAD`. The scripts are synced globally through the same `dotclaude/` pipeline — they live at `~/.claude/scripts/spawn-agent/` after `setup.sh` and operate on whichever repo you invoke them from (discovered via `git rev-parse --show-toplevel` in the caller's cwd).

### Setup

- **Already installed by `setup.sh`** — no extra step. The scripts are symlinked into `~/.claude/scripts/spawn-agent/`.
- **Shell invocation** — from any project root:

  ```bash
  ~/.claude/scripts/spawn-agent/launch.sh
  ```

  Prompts for agent name, branch name, and base branch, then `cd`s into the worktree and `exec`s `claude`. Agent names are any string matching `^[A-Za-z0-9][A-Za-z0-9._-]*$` — digits alone are fine if you prefer the integer convention.
- **Optional: cleanup Run Configuration** for `cleanup.py`. Type: Python; interpreter: system `python3` (3.14+); Working directory: `$ProjectFileDir$`.

For internals — the worktree/agent model, argument handling, and cleanup flow — see [`dotclaude/scripts/README.md`](dotclaude/scripts/README.md).

## Setting up your own fork

`main` is intentionally clean so anyone can use it as a fresh starting point. The recommended way to layer your own agents, commands, and skills on top is to **fork the repo** — that way your personal config lives in your own GitHub account, decoupled from this upstream.

1. Fork [`Povaz/claude-code-dotfiles`](https://github.com/Povaz/claude-code-dotfiles) on GitHub into your own account.
2. Clone your fork and register this repo as an `upstream` remote so you can pull template updates later:

```bash
git clone https://github.com/<your-username>/claude-code-dotfiles.git
cd claude-code-dotfiles
git remote add upstream https://github.com/Povaz/claude-code-dotfiles.git

./setup.sh
```

Add your content under `dotclaude/` and commit it to your fork's `main` (or any branch you prefer — per-machine or per-context branches still work inside your fork).

When the template evolves upstream, pull the updates in:

```bash
git fetch upstream
git merge upstream/main
```

Because your personal content lives in **your fork**, not the upstream repo, future `upstream/main → main` merges will never try to remove it.
