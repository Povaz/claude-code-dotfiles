# CLAUDE.md

A dotfiles repo for Claude Code. Entries under `dotclaude/` are symlinked into the user's `~/.claude/` directory by `setup.sh`. This `CLAUDE.md` and the repo-root `.claude/` are **project-level** config for working on the dotfiles repo itself — they are deliberately **not** under `dotclaude/` and never get synced.

## The dotclaude/ invariant

**`dotclaude/` is the complete, authoritative sync manifest.** Everything inside it is symlinked into `~/.claude/`; everything outside is repo plumbing and never synced.

Practical consequences:

- Adding a new slash command, agent, skill, or setting: put it under `dotclaude/` (e.g., `dotclaude/commands/foo.md`). Anywhere else and `setup.sh` won't link it.
- **Never move `CLAUDE.md`, `.claude/`, `setup.sh`, `teardown.sh`, `status.sh`, `README.md`, or `LICENSE` into `dotclaude/`.** They are repo tooling, not user config.
- There is no ignore list. Prior versions had a hardcoded `is_ignored()` function; the `dotclaude/` boundary replaced it. Don't reintroduce it.

## Script architecture

Three scripts at the repo root. All share the same conventions — `#!/usr/bin/env bash`, `set -euo pipefail`, `info`/`ok`/`warn`/`die` color helpers, null-separated `find -print0` + `read -r -d ''` for path safety.

- **`setup.sh`** and **`status.sh`** discover items by iterating `dotclaude/` top-level entries. Their discovery logic is identical by design — **when you change one, mirror the change in the other.**
- **`teardown.sh`** resolves each symlink's source via `readlink "$path"` rather than computing `${REPO_DIR}/${name}`. This is intentional — it stays correct across future layout changes. Don't hardcode paths back in.
- `is_correctly_linked()` is the canonical "is this our symlink?" check. Reuse it; don't reinvent.

## Testing scripts

No test framework — verification is manual end-to-end against the live `~/.claude/`.

Syntax-check after any edit:

```bash
bash -n setup.sh && bash -n teardown.sh && bash -n status.sh
```

Full round-trip (destructive to live `~/.claude/` but fully reversible):

```bash
printf 'y\n' | ./setup.sh         # setup.sh has an interactive confirm prompt
./status.sh                        # expect: N linked, 0 not linked, 0 missing
printf 'y\n' | ./setup.sh         # idempotency: 0 linked, N already correct
./teardown.sh                      # restores real files into ~/.claude/
diff ~/.claude/CLAUDE.md dotclaude/CLAUDE.md    # expect: empty
printf 'y\n' | ./setup.sh         # cycle back to symlinks
```

Backups accumulate at `~/.claude/backups/YYYYMMDD_HHMMSS/` — never delete or "clean up" them; the README promises they are preserved.

## Things to avoid

- Don't un-ignore `.claude/settings.local.json` in `.gitignore` — it's per-machine state.
- Don't touch `~/.claude/` beyond what the scripts already manage. That directory also holds unrelated Claude Code state (`sessions/`, `projects/`, `statsig/`, `todos/`, `shell-snapshots/`, …) — never "tidy" it.