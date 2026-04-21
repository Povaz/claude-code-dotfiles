#!/bin/bash
# launch.sh — Interactive wrapper for launch.py.
# Run as a PyCharm Shell Script configuration with "Execute in terminal".

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

read -p "Agent number: " agent_num
read -p "Branch name: " branch

if [ -z "$agent_num" ] || [ -z "$branch" ]; then
  echo "Both agent number and branch name are required. Aborting."
  exit 1
fi

worktree=$(python "$SCRIPT_DIR/launch.py" "$agent_num" "$branch")
if [ $? -ne 0 ]; then
  exit 1
fi

cd "$worktree" && exec claude
