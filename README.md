# claude-code-dotfiles

Portable Claude Code configuration — sync agents, commands, settings & skills across machines and subscriptions.

## How It Works

Claude Code stores its configuration in `~/.claude/`. This repo turns that directory into a Git-managed set of **symlinks**: each top-level file or folder in this repo gets linked into `~/.claude/`, so changes you commit here are instantly picked up by Claude Code on any machine where you've run `setup.sh`.

No files are copied — the symlinks point directly into your clone. Edit in the repo, commit, push, and every linked machine sees the update on the next `git pull`.

## Repo Structure

```
claude-code-dotfiles/
├── setup.sh           # Creates symlinks from ~/.claude/ → this repo
├── teardown.sh        # Removes symlinks, leaves standalone local copies
├── README.md
├── LICENSE
├── .gitignore
├── CLAUDE.md          # Global instructions Claude reads every session
├── settings.json      # Claude Code settings
├── commands/          # Custom slash commands
├── agents/            # Custom agent definitions
└── skills/            # Custom skills
```

The repo structure **is** the config. `setup.sh` doesn't maintain a hardcoded list — it scans the repo root and symlinks everything it finds (minus a small ignore list). Add a new file or directory to the repo, re-run `setup.sh`, and it gets linked automatically.

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
2. Create symlinks from `~/.claude/<item>` → `<repo>/<item>`.
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

| Synced | NOT Synced (private/local) |
|---|---|
| `CLAUDE.md` | `.credentials.json` |
| `settings.json` | `settings.local.json` |
| `commands/` | `projects/` |
| `agents/` | `statsig/` |
| `skills/` | `backups/` |
| Any file/dir you add to the repo | Cache, sessions, telemetry, etc. |

Credentials and machine-local state are never touched by `setup.sh` or `teardown.sh`.

## Multiple Configurations

### Git branches

Keep different configs on different branches:

```bash
# Personal machine
git checkout personal
./setup.sh

# Work machine
git checkout company
./setup.sh
```

### Separate clones

Alternatively, maintain two clones (e.g. `claude-code-dotfiles-personal` and `claude-code-dotfiles-work`) and run the appropriate `setup.sh`.

## Auto-Ignored Files

`setup.sh` skips the following items and will never symlink them:

| Ignored item | Reason |
|---|---|
| `setup.sh` | The setup script itself |
| `teardown.sh` | The teardown script itself |
| `README.md` | Repo documentation |
| `LICENSE` | Repo license |
| `.git` | Git metadata |
| `.gitignore` | Git ignore rules |
| `.DS_Store` | macOS Finder metadata |

To add more items to the ignore list, edit the `is_ignored()` function in `setup.sh` — it's a simple `case` statement.

## Notes

- **Re-run safe.** Running `setup.sh` multiple times is harmless — it skips items already correctly linked and only backs up items that would be overwritten.
- **Credentials are never touched.** `setup.sh` only symlinks items that exist in this repo. Files like `.credentials.json` live outside the repo and are left alone.
- **Teardown copies latest, not old backups.** `teardown.sh` copies the current repo version of each file into `~/.claude/`, so you always get the most recent config as a standalone local copy.
- **Backups are timestamped.** If `setup.sh` needs to back up existing files, they go into `~/.claude/backups/YYYYMMDD_HHMMSS/`. Old backups are never overwritten.

## Suggested GitHub Topics

After creating the repo, add these topics for discoverability:

`claude-code` `dotfiles` `claude` `ai-agents` `anthropic` `claude-code-agents`
