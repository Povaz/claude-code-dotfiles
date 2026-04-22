#!/usr/bin/env python3
"""
cleanup.py
Interactive cleanup of git worktrees.

Discovers the current project by running ``git rev-parse --show-toplevel``
in the invocation's working directory, so the script can live in one place
and serve every project.

Lists all non-main worktrees, lets you pick which ones to remove, and
cleans up stale entries. Every git command is logged with a contextual
explanation so you can learn the underlying operations.

Usage:
    python cleanup.py
"""

import logging
import os
import subprocess
import sys

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("cleanup")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def run(cmd: list[str], cwd: str | None = None, context: str | None = None) -> subprocess.CompletedProcess:
    """Run a command and return the CompletedProcess (never raises on failure).

    Parameters
    ----------
    cmd
        The command to execute.
    cwd
        Working directory for the command.
    context
        If provided, a human-readable explanation logged alongside the command.
    """
    if context:
        log.info("%s  →  $ %s", context, " ".join(cmd))
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)


def discover_project_dir() -> str:
    """Resolve the enclosing git repo root from the invocation's cwd.

    Exits with a clear error if cwd is not inside a git working tree.
    """
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        log.error(
            "Not inside a git repository (cwd=%s). Run this from a project root.",
            os.getcwd(),
        )
        sys.exit(1)
    return result.stdout.strip()


def get_worktrees(project_dir: str) -> list[dict[str, str]]:
    """Return a list of worktree dicts with 'path' and 'branch' keys.

    The main worktree (the one containing .git) is excluded.
    """
    result = run(
        ["git", "worktree", "list", "--porcelain"],
        cwd=project_dir,
        context="Listing worktrees",
    )

    worktrees: list[dict[str, str]] = []
    current: dict[str, str] = {}
    for line in result.stdout.splitlines():
        if line.startswith("worktree "):
            current = {"path": line.split(" ", 1)[1]}
        elif line.startswith("branch "):
            current["branch"] = line.split(" ", 1)[1].removeprefix("refs/heads/")
        elif line == "":
            if current:
                worktrees.append(current)
                current = {}
    # Catch the last entry if no trailing blank line
    if current:
        worktrees.append(current)

    # The first worktree is always the main one — skip it
    return worktrees[1:]


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    project_dir = discover_project_dir()
    log.info("Project: %s", project_dir)

    worktrees = get_worktrees(project_dir)

    if not worktrees:
        log.info("No agent worktrees found. Nothing to clean up.")
        return

    # --- Display table ---
    print("\nAgent worktrees:\n")
    print(f"  {'#':<4} {'Path':<55} {'Branch'}")
    print(f"  {'—'*3:<4} {'—'*53:<55} {'—'*20}")
    for i, wt in enumerate(worktrees, 1):
        print(f"  {i:<4} {wt['path']:<55} {wt.get('branch', '(detached)')}")
    print()

    # --- Prompt for selection ---
    selection = input("Worktrees to remove (comma-separated numbers, or 'q' to quit): ").strip()
    if not selection or selection.lower() == "q":
        log.info("Nothing selected. Exiting.")
        return

    # Parse selected indices
    try:
        indices = [int(s.strip()) for s in selection.split(",")]
    except ValueError:
        log.error("Invalid input. Please enter comma-separated numbers.")
        sys.exit(1)

    selected = []
    for idx in indices:
        if idx < 1 or idx > len(worktrees):
            log.error("Number %d is out of range (1–%d).", idx, len(worktrees))
            sys.exit(1)
        selected.append(worktrees[idx - 1])

    # --- Remove selected worktrees ---
    for wt in selected:
        path = wt["path"]
        branch = wt.get("branch", "")

        result = run(
            ["git", "worktree", "remove", path],
            cwd=project_dir,
            context=f"Removing worktree at {path}",
        )

        if result.returncode != 0:
            stderr = result.stderr.strip()
            log.error("Failed: %s", stderr)
            if "contains modified or untracked files" in stderr:
                log.info("Hint: use 'git worktree remove --force %s' to remove anyway.", path)
            continue

        log.info("Worktree removed: %s", path)

        # Clean up placeholder branches (wt/...) that are no longer needed
        if branch.startswith("wt/"):
            result = run(
                ["git", "branch", "-d", branch],
                cwd=project_dir,
                context=f"Deleting placeholder branch '{branch}'",
            )
            if result.returncode == 0:
                log.info("Branch deleted: %s", branch)
            else:
                log.warning("Could not delete branch '%s': %s", branch, result.stderr.strip())

    # --- Prune stale worktree metadata ---
    run(
        ["git", "worktree", "prune"],
        cwd=project_dir,
        context="Pruning stale worktree metadata",
    )

    log.info("Cleanup complete.")


if __name__ == "__main__":
    main()
