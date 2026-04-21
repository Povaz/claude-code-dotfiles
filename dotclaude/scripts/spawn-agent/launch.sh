#!/bin/bash
# launch.sh — Interactive wrapper for launch.py.
# Run as a PyCharm Shell Script configuration with "Execute in terminal"
# and Working Directory set to the project root.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

read -p "Agent number: " agent_num
read -p "Branch name: " branch
read -p "Base branch: " base_branch

if [ -z "$agent_num" ] || [ -z "$branch" ] || [ -z "$base_branch" ]; then
  echo "Agent number, branch name, and base branch are all required. Aborting."
  exit 1
fi

worktree=$(python "$SCRIPT_DIR/launch.py" "$agent_num" "$branch" "$base_branch")
if [ $? -ne 0 ]; then
  exit 1
fi

cd "$worktree" && exec claude
