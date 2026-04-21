#!/usr/bin/env python3
"""
launch.py
Prepares a git worktree for a Claude Code agent.

Accepts an agent number and branch name as CLI arguments, ensures the
worktree exists (creating it on-demand if needed), checks out the
requested branch, and prints the worktree path to stdout on success.

Called by launch.sh — not intended to be run directly.

Usage:
    python .scripts/launch.py <agent_number> <branch_name>
"""

import logging
import os
import subprocess
import sys

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
PROJECT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PROJECT_NAME = os.path.basename(PROJECT_DIR)
PARENT_DIR = os.path.dirname(PROJECT_DIR)
BASE_BRANCH = "dev"

# ---------------------------------------------------------------------------
# Logging — all output goes to stderr so stdout stays clean for the
# worktree path that launch.sh captures.
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(message)s",
    datefmt="%H:%M:%S",
    stream=sys.stderr,
)
log = logging.getLogger("launch")


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


def get_existing_worktrees() -> dict[str, str]:
    """Return a mapping of worktree path -> checked-out branch for all worktrees."""
    result = run(["git", "worktree", "list", "--porcelain"], cwd=PROJECT_DIR, context="Listing worktrees")
    worktrees: dict[str, str] = {}
    current_path = None
    for line in result.stdout.splitlines():
        if line.startswith("worktree "):
            current_path = line.split(" ", 1)[1]
        elif line.startswith("branch ") and current_path:
            # branch refs/heads/feature/x -> feature/x
            branch = line.split(" ", 1)[1].removeprefix("refs/heads/")
            worktrees[current_path] = branch
    return worktrees


def branch_exists(branch: str) -> bool:
    """Check whether a branch name exists in the local repo."""
    result = run(
        ["git", "rev-parse", "--verify", f"refs/heads/{branch}"],
        cwd=PROJECT_DIR,
        context=f"Checking if branch '{branch}' exists",
    )
    return result.returncode == 0


def branch_checked_out_in(branch: str, worktrees: dict[str, str]) -> str | None:
    """Return the worktree path where *branch* is checked out, or None."""
    for path, checked_out in worktrees.items():
        if checked_out == branch:
            return path
    return None


# ---------------------------------------------------------------------------
# Core steps
# ---------------------------------------------------------------------------
def ensure_worktree(agent_num: int, worktrees: dict[str, str]) -> str:
    """
    Ensure a worktree directory exists for the given agent number.

    If the worktree already exists it is reused; otherwise a new one is
    created on a placeholder branch ``wt/agent-{N}``.

    Returns
    -------
    str
        Absolute path to the worktree directory.
    """
    worktree_path = os.path.join(PARENT_DIR, f"{PROJECT_NAME}-agent-{agent_num}")

    if worktree_path in worktrees:
        log.info("Worktree already exists: %s  (on branch '%s')", worktree_path, worktrees[worktree_path])
        return worktree_path

    placeholder = f"wt/agent-{agent_num}"
    # Try creating with a new placeholder branch
    result = run(
        ["git", "worktree", "add", worktree_path, "-b", placeholder],
        cwd=PROJECT_DIR,
        context=f"Creating worktree at {worktree_path} on new branch '{placeholder}'",
    )
    if result.returncode != 0:
        # Placeholder branch already exists in git — attach worktree to it
        result = run(
            ["git", "worktree", "add", worktree_path, placeholder],
            cwd=PROJECT_DIR,
            context=f"Branch '{placeholder}' already exists, attaching worktree to it",
        )
        if result.returncode != 0:
            log.error("Failed to create worktree: %s", result.stderr.strip())
            sys.exit(1)

    log.info("Worktree created successfully")
    return worktree_path


def checkout_branch(branch: str, worktree_path: str, worktrees: dict[str, str]) -> None:
    """
    Check out the requested branch inside the worktree.

    If the branch already exists and is not checked out elsewhere, it is
    switched to directly. If it does not exist, it is created from the
    base branch (``dev``). If it is already checked out in another
    worktree, the script exits with a clear error.
    """
    # Check if the worktree is already on the requested branch
    current = worktrees.get(worktree_path)
    if current == branch:
        log.info("Worktree is already on branch '%s' — nothing to do", branch)
        return

    if branch_exists(branch):
        # Branch exists — check it's not checked out elsewhere
        occupied = branch_checked_out_in(branch, worktrees)
        if occupied and occupied != worktree_path:
            log.error(
                "Branch '%s' is already checked out in: %s\n"
                "       Git does not allow the same branch in two worktrees.\n"
                "       Switch that worktree to a different branch first.",
                branch,
                occupied,
            )
            sys.exit(1)

        result = run(
            ["git", "checkout", branch],
            cwd=worktree_path,
            context=f"Switching to existing branch '{branch}'",
        )
    else:
        result = run(
            ["git", "checkout", "-b", branch, BASE_BRANCH],
            cwd=worktree_path,
            context=f"Creating new branch '{branch}' from '{BASE_BRANCH}'",
        )

    if result.returncode != 0:
        log.error("Checkout failed: %s", result.stderr.strip())
        sys.exit(1)

    log.info("Now on branch '%s'", branch)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    if len(sys.argv) != 3:
        print(f"Usage: python {sys.argv[0]} <agent_number> <branch_name>", file=sys.stderr)
        sys.exit(1)

    # --- Agent number ---
    agent_input = sys.argv[1]
    if not agent_input.isdigit() or int(agent_input) < 1:
        log.error("Invalid agent number. Please enter a positive integer.")
        sys.exit(1)
    agent_num = int(agent_input)

    # --- Branch name ---
    branch = sys.argv[2]

    # --- Resolve worktree ---
    worktrees = get_existing_worktrees()
    worktree_path = ensure_worktree(agent_num, worktrees)

    # Refresh worktree map after possible creation
    worktrees = get_existing_worktrees()

    # --- Checkout branch ---
    checkout_branch(branch, worktree_path, worktrees)

    # Print the worktree path to stdout for the shell wrapper to capture
    log.info("Ready: %s", worktree_path)
    print(worktree_path)


if __name__ == "__main__":
    main()
