# dotclaude/scripts

Helper scripts synced into `~/.claude/scripts/` by the repo-root `setup.sh`. They ride on the same `dotclaude/` → `~/.claude/` symlink pipeline as Claude Code's config but serve adjacent workflows.

For what's in here and how to use it, see the top-level [README: Spawning agents in worktrees](../../README.md#spawning-agents-in-worktrees). This file is the deep-dive reference — internals, not setup.

## spawn-agent — how it works

**The worktree/agent model.** Each "agent" is identified by a name — any string matching `^[A-Za-z0-9][A-Za-z0-9._-]*$` (letters, digits, and `.`, `-`, `_`; must start with a letter or digit). For agent `<name>`, the worktree lives at `../<project-name>-agent-<name>` (sibling of the main checkout). The worktree is the durable seat; the branch on it is what you swap. Digits alone are a valid name, so if you prefer the old integer convention, `1`, `2`, `42` all still work.

**`launch.sh`.** Thin interactive wrapper. Prompts for the three inputs (agent name, branch name, base branch), delegates to `launch.py`, captures the resulting worktree path from stdout, `cd`s there, and `exec claude`.

**`launch.py`.** The real work:

- Discovers the project via `git rev-parse --show-toplevel` from cwd — that's how one global script serves every repo.
- Validates the agent name against the regex above.
- If the worktree doesn't yet exist, creates it at `../<project>-agent-<name>` on a placeholder branch `wt/agent-<name>` (so `git worktree add` has a branch to attach to).
- Checks out the requested branch inside the worktree:
  - If the branch exists and isn't checked out elsewhere → switch to it.
  - If it exists but is checked out in another worktree → aborts with a clear error (git forbids dual checkout of the same branch).
  - If it doesn't exist → creates it from `<base_branch>`.
- All logs go to stderr; only the final worktree path goes to stdout, so `launch.sh` can capture it with `$(...)`.

**`cleanup.py`.** Interactive worktree pruning:

- Lists all non-main worktrees in a numbered table.
- You pick comma-separated indices to remove.
- For each: removes the worktree, deletes the `wt/agent-<name>` placeholder branch if that was its branch, then `git worktree prune` at the end to clear any stale metadata.

## Design notes

- Agent name is stable across branch swaps — `cleanup.py` is how you free a seat; pointing the same agent at a new branch is how you reuse it.
- `wt/agent-<name>` placeholder branches are scaffolding only; they never need to be pushed.
- The scripts assume the invocation cwd is inside the target repo (`git rev-parse` from cwd). In PyCharm, `$ProjectFileDir$` gives you exactly that.
