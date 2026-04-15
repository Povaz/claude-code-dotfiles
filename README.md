# claude-code-dotfiles

Portable Claude Code configuration — sync agents, commands, settings & skills across machines and subscriptions.

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
# Clone the repo
git clone https://github.com/<your-username>/claude-code-dotfiles.git
cd claude-code-dotfiles

# Create symlinks into ~/.claude/
./setup.sh
```

`setup.sh` will:
1. Back up any existing files in `~/.claude/` that would be overwritten (into `~/.claude/backups/<timestamp>/`).
2. Create symlinks from `~/.claude/<item>` → `<repo>/dotclaude/<item>` for every entry under `dotclaude/`.
3. Skip items that are already correctly linked.

## Syncing Between Machines

```bash
# On machine A — push your changes
git add -A && git commit -m "Update settings" && git push

# On machine B — pull the latest
cd ~/claude-code-dotfiles
git pull
# That's it — symlinks already point here, so changes are live immediately.
```

No need to re-run `setup.sh` after pulling. The symlinks point into the repo, so any file changes from `git pull` are picked up instantly.

## Uninstalling

```bash
./teardown.sh
```

This removes every symlink in `~/.claude/` that points into this repo and replaces each one with a **copy of the current repo version**. After teardown, `~/.claude/` contains standalone local files — not old backups, not dangling links. You can safely delete the repo afterward.

## What Gets Synced

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

## Setting up your own personal branch

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

### Multiple personal branches

You can keep several per-context branches off `main` — e.g., `<username>/personal` and `<username>/work` — and `git checkout` between them when switching machines.

### Separate clones (alternative)

If you prefer physically separate checkouts — e.g., one per machine — maintain multiple clones of the repo and run `setup.sh` in each.

## Migrating From the Old Layout

Earlier versions of this repo symlinked each top-level file/directory directly. If you have an existing install with those old-style symlinks in `~/.claude/`, migrate with:

```bash
cd ~/claude-code-dotfiles             # wherever your clone lives
git fetch
git checkout <last-old-commit-sha>    # a commit before the dotclaude/ refactor
./teardown.sh                         # converts old symlinks → real files in ~/.claude/
git checkout main && git pull         # pull the new layout
./setup.sh                            # creates symlinks into dotclaude/
```

The intermediate `teardown.sh` step leaves `~/.claude/` with standalone real files, so Claude Code stays functional between the two steps even if something goes wrong.

## Notes

- **Re-run safe.** Running `setup.sh` multiple times is harmless — it skips items already correctly linked and only backs up items that would be overwritten.
- **Credentials are never touched.** `setup.sh` only symlinks items that exist in this repo. Files like `.credentials.json` live outside the repo and are left alone.
- **Teardown copies latest, not old backups.** `teardown.sh` copies the current repo version of each file into `~/.claude/`, so you always get the most recent config as a standalone local copy.
- **Backups are timestamped.** If `setup.sh` needs to back up existing files, they go into `~/.claude/backups/YYYYMMDD_HHMMSS/`. Old backups are never overwritten.

## Suggested GitHub Topics

After creating the repo, add these topics for discoverability:

`claude-code` `dotfiles` `claude` `ai-agents` `anthropic` `claude-code-agents`
