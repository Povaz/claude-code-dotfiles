# Git Worktree with PyCharm: A Comprehensive Guide for Parallel Claude Code Agents

---

## Part 1: Understanding the Problem

When you run multiple Claude Code instances inside PyCharm's terminal tabs, each agent shares the same working directory and, crucially, the same `.git` folder. A Git repository has a single `HEAD` file that points to the currently checked-out branch. When one agent runs `git checkout feature/task-A`, it moves that `HEAD` for everyone. The other agents are now silently operating on the wrong branch.

This isn't a Claude Code problem — it would happen with any tool that switches branches in a shared directory.

---

## Part 2: How Git Worktree Works (The Theory)

### The mental model

Think of a standard Git repo like a single office desk. All your work lives there. If two people (agents) want to work simultaneously, they'd be fighting over the same desk, the same open files, the same branch.

`git worktree` lets you open **additional desks** — each in their own room — that all share the **same filing cabinet** (the `.git` directory). Each desk has:

- Its own working directory (the files you see and edit)
- Its own `HEAD` (its own current branch)
- Its own index (staging area)

But they all share:

- The same commit history
- The same objects (files, trees, commits)
- The same remote configuration

This means a commit made at desk 2 is immediately visible from desk 1, without any push or fetch. It's all local, just on separate branches.

### What `.git` actually contains

Understanding this helps you manage worktrees confidently:

```
.git/
  HEAD              ← points to your current branch (main worktree only)
  config            ← remote URLs, settings
  objects/          ← all file contents and commits, shared by all worktrees
  refs/             ← branch and tag pointers, shared by all worktrees
  worktrees/        ← metadata for each additional worktree
    agent1/
      HEAD          ← this worktree's current branch
      gitdir        ← pointer back to the main .git
      locked        ← (optional) prevents accidental removal
```

Each worktree has its own `HEAD` stored inside `.git/worktrees/<name>/HEAD`. That's the key insight: no more single-point-of-failure for the current branch.

---

## Part 3: Setting Up From Your Current State

You currently have a single project folder. Let's call it `myproject/`. Here's your starting point:

```
~/dev/
  myproject/        ← your PyCharm project, contains .git
```

### Step 1: Decide on a naming convention

Pick a scheme before creating worktrees — it's hard to rename them later without removing and recreating. Two common approaches:

**By agent slot** (reusable, generic):
```
myproject-agent1/
myproject-agent2/
```

**By task** (descriptive, disposable):
```
myproject-feature-login/
myproject-bugfix-api/
```

For parallel Claude Code agents, the agent-slot approach is more practical. You reuse the slot for new tasks by switching the branch inside the worktree.

### Step 2: Create the worktrees with placeholder branches

When you're just setting up the infrastructure — no real task yet — you still need to give each worktree *some* branch to check out. Git requires it. The clean solution is to create lightweight placeholder branches that simply sit at the current `main` commit and cost you nothing: no meaningful commits, nothing worth pushing.

Open any terminal tab in PyCharm and navigate to your project root. Then run:

```bash
# Make sure you're in the project root
cd ~/dev/myproject

# Create worktree for agent 1 on a placeholder branch
git worktree add ../myproject-agent1 -b wt/agent1

# Create worktree for agent 2 on a placeholder branch
git worktree add ../myproject-agent2 -b wt/agent2
```

The `wt/` prefix is a personal convention to mark these as worktree infrastructure branches — not real feature branches. They never get pushed to GitHub. They exist only as parking spots until a real task comes in.

Your directory structure is now:

```
~/dev/
  myproject/          ← main worktree (your PyCharm project root)
  myproject-agent1/   ← agent 1's worktree, parked on wt/agent1
  myproject-agent2/   ← agent 2's worktree, parked on wt/agent2
```

**What happened under the hood:** Git created the two new sibling directories, checked out the placeholder branches into them, and registered their metadata under `myproject/.git/worktrees/`.

### Step 3: Verify everything looks right

```bash
git worktree list
```

Output will look like:

```
/home/you/dev/myproject         abc1234 [main]
/home/you/dev/myproject-agent1  abc1234 [wt/agent1]
/home/you/dev/myproject-agent2  abc1234 [wt/agent2]
```

All three point to the same commit (`abc1234`), which is correct — the agent slots are fresh and ready.

### Step 4: Assign a real branch and launch the agent

When a task is ready, go into the worktree, create a branch from `main`, and start Claude:

```bash
cd ~/dev/myproject-agent1
git checkout -b feature/task-1 main
claude
```

Optionally, clean up the placeholder branch you no longer need:

```bash
git branch -d wt/agent1
```



---

## Part 4: Day-to-Day Workflow

### Viewing agent commits from your main folder

Since all worktrees share the same `.git`, commits made by any agent are immediately visible in the Git log — no push required. In PyCharm:

- Open **Git → Log** (Alt+9 or ⌘9 on Mac)
- Use the branch filter to show all branches
- You'll see commits from `feature/agent-1-task` and `feature/agent-2-task` appear in real time as agents work

From the terminal:
```bash
# From your main project folder, see all branches
git log --oneline --all --graph

# Check what agent 1 has committed
git log --oneline feature/agent-1-task
```

### Checking what files an agent changed

```bash
# Diff between agent 1's branch and main
git diff main..feature/agent-1-task

# Just the filenames
git diff --name-only main..feature/agent-1-task
```

### Merging agent work back to main

Once an agent finishes its task, merge normally from your main worktree:

```bash
cd ~/dev/myproject
git checkout main
git merge feature/agent-1-task

# Or create a pull request if using GitHub:
git push origin feature/agent-1-task
# then open PR on GitHub
```

---

## Part 5: Managing Worktrees Over Time

### Reusing a worktree slot for a new task

When agent 1 finishes its task and you want to assign it a new one, don't remove and recreate the worktree. Just switch the branch inside it:

```bash
cd ~/dev/myproject-agent1

# Create a new branch from main and switch to it
git checkout -b feature/agent-1-new-task main
```

The worktree folder stays the same. The agent just starts working on a fresh branch tomorrow.

### Locking a worktree

If a worktree is doing important work and you want to prevent accidental removal:

```bash
git worktree lock ../myproject-agent1 --reason "Agent 1 mid-task"
```

To unlock:
```bash
git worktree unlock ../myproject-agent1
```

### Removing a worktree when truly done

When the task is merged and you no longer need the worktree:

```bash
# This removes the directory AND deregisters the worktree from .git
git worktree remove ../myproject-agent1

# If the worktree has uncommitted changes, force-remove
git worktree remove --force ../myproject-agent1
```

If you manually deleted the folder without using `git worktree remove`, clean up the stale reference:

```bash
git worktree prune
```

### The full lifecycle in one view

```
git worktree add    →  create slot + branch
    ↓
agent works, commits accumulate
    ↓
git merge / PR      →  integrate the work
    ↓
git checkout -b     →  reassign slot to new task  (reuse)
  OR
git worktree remove →  delete slot when done      (cleanup)
```

---

## Part 6: PyCharm Integration Tips

### Attaching worktree folders to your project

PyCharm's project view is anchored to `myproject/`. The agent worktrees are siblings outside it. To browse them without opening a new window:

1. Go to **File → Open**
2. Select `myproject-agent1/`
3. Choose **Attach** (not "New Window" or "This Window")

This adds a second content root to your existing project. You keep all your Docker, Database, and Run configurations intact, and you can browse agent files alongside your main code.

### PyCharm's Git Log shows all worktrees

The Git Log panel (Alt+9) reads from the shared `.git/objects`. All branches and all commits from all worktrees appear here automatically. Use the branch selector in the top-left of the Git Log to filter by branch.

### Terminal tab naming

PyCharm lets you rename terminal tabs. Right-click a tab → **Rename**. Use names like `agent-1`, `agent-2`, `main` to avoid confusion over time.

### Launching agents with the launch scripts

Two scripts in `.scripts/` handle agent setup and launch:

```
myproject/
  .scripts/
    launch.sh    ← interactive shell wrapper (entry point)
    launch.py    ← worktree + branch logic
```

`launch.sh` is the entry point — it prompts for input, delegates the git setup to `launch.py`, then launches Claude with a proper interactive terminal. Add `.scripts/` to `.gitignore` if your worktree paths are machine-specific, or commit it if the team shares the same setup.

Run the launcher from any terminal tab:

```bash
.scripts/launch.sh
```

It prompts for two inputs:

```
Agent number: 3
Branch name: feature/task-1
```

The script then:

1. **Checks if a worktree exists** for that agent number (e.g. `myproject-agent-3/`). If not, it creates one automatically with a placeholder branch.
2. **Checks the branch**: if it already exists and is free, switches to it. If it doesn't exist, creates it from `dev`. If it's already checked out in another worktree, exits with a clear error message.
3. **Launches Claude** inside the worktree with an interactive terminal.

All setup steps are logged with timestamps to stderr so you can see exactly what happened:

```
14:32:01  Worktree already exists: /home/you/dev/myproject-agent-3  (on branch 'wt/agent-3')
14:32:01  Creating new branch 'feature/task-1' from 'dev'
14:32:01  Now on branch 'feature/task-1'
14:32:01  Ready: /home/you/dev/myproject-agent-3
```

Any agent number works — the script creates new worktrees on-demand, so there is no fixed limit.

#### PyCharm Run Configuration

In PyCharm:

1. Go to **Run → Edit Configurations**
2. Click **+** and choose **Shell Script**
3. Switch to **Script file** and point it to `.scripts/launch.sh`
4. Check **Execute in terminal** — this opens a PyCharm terminal tab with a real TTY
5. Name it `Launch Agent` and save

Each time you trigger it, a terminal tab opens and prompts for the agent number and branch. Because it uses `exec claude`, the terminal tab becomes the Claude session.

### Cleaning up worktrees

A companion script removes worktrees you no longer need:

```bash
python .scripts/cleanup.py
```

It lists all agent worktrees with numbered indices, then asks which to remove:

```
Agent worktrees:

  #    Path                                                    Branch
  ———  —————————————————————————————————————————————————————    ————————————————————
  1    /home/you/dev/myproject-agent-1                         feature/task-1
  2    /home/you/dev/myproject-agent-2                         wt/agent-2
  3    /home/you/dev/myproject-agent-3                         feature/task-3

Worktrees to remove (comma-separated numbers, or 'q' to quit): 2,3
```

For each selected worktree the script:

1. Runs `git worktree remove <path>` and logs the command
2. If the worktree has uncommitted changes, it reports the error and suggests the `--force` flag
3. If the branch was a `wt/` placeholder, it deletes the branch with `git branch -d`
4. Runs `git worktree prune` at the end to clean up stale metadata

All operations are logged with the underlying git commands, just like the launch script.

### Run configurations still work from the main project

Your Docker Compose, database connections, and run configurations are attached to `myproject/` — the main worktree. They don't need to change. Agents work in their own folders, but if they need to run the app for testing, they can do so from within their worktree (it has all the same source files on their branch).

---

## Part 7: Important Constraints to Know

### You cannot check out the same branch in two worktrees

Git enforces this strictly. Each branch can only be active in one worktree at a time. If you try:

```bash
git worktree add ../agent1 -b main   # ERROR if main is already checked out in myproject/
```

You'll get: `fatal: 'main' is already checked out`. This is a safety feature, not a limitation to work around.

### Worktrees are local-machine only

Worktrees are metadata stored in your local `.git/worktrees/` folder. They don't push to GitHub, don't appear in CI, and don't affect your teammates. If you clone the repo on another machine, the worktrees don't come with it.

### Submodules and worktrees

If your project uses Git submodules, worktrees have limited support for them. Each worktree would need its own submodule initialization. This is an edge case, but worth knowing if your project is structured that way.

---

## Part 8: Quick Reference Card

```bash
# --- INITIAL SETUP (one time, no task needed) ---
git worktree add ../myproject-agent1 -b wt/agent1   # create slot with placeholder branch
git worktree add ../myproject-agent2 -b wt/agent2

# --- ASSIGN A REAL TASK TO A SLOT ---
cd ../myproject-agent1
git checkout -b feature/task-name main              # create real branch from main
git branch -d wt/agent1                             # optional: delete the placeholder

# --- INSPECT ---
git worktree list                     # show all worktrees and their branches
git log --oneline --all --graph       # see all branches and commits

# --- DAILY USE ---
cd ../myproject-agent1 && claude      # launch agent in its worktree

# --- REASSIGN SLOT TO NEW TASK ---
cd ../myproject-agent1
git checkout -b feature/next-task main

# --- CLEANUP ---
python .scripts/cleanup.py                 # interactive: list, select, remove worktrees
git worktree remove ../myproject-agent1    # manual: remove worktree + deregister
git worktree prune                         # clean up stale entries after manual deletion
git worktree lock ../myproject-agent1      # protect from accidental removal
git worktree unlock ../myproject-agent1    # undo lock
```

---

## Summary

The core insight is simple: `git worktree` lets you have multiple working directories, each on its own branch, all backed by the same `.git` history. For PyCharm users, the entire workflow stays inside the IDE — terminal tabs point to different worktree folders, the Git Log panel shows all branches together, and Docker/DB/run configurations remain untouched in the main project folder. Worktrees are persistent and reusable, so the practical day-to-day pattern is to maintain two or three named agent slots and simply reassign them to new branches as tasks come and go.