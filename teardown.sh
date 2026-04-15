#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# teardown.sh — Remove symlinks and restore standalone local copies
#
# Scans ~/.claude/ for symlinks pointing into THIS repo. For each one, removes
# the symlink and copies the current repo version back as a real file or
# directory. After running this, ~/.claude/ contains standalone copies of the
# latest config — no old backups, no dangling links.
# Safe to re-run — reports "nothing to do" if no matching symlinks exist.
# =============================================================================

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${HOME}/.claude"

# ---------------------------------------------------------------------------
# Colored output helpers
# ---------------------------------------------------------------------------
info() { printf '\033[0;34m[INFO]\033[0m %s\n' "$1"; }
ok()   { printf '\033[0;32m[OK]\033[0m %s\n' "$1"; }
warn() { printf '\033[0;33m[WARN]\033[0m %s\n' "$1"; }

# ---------------------------------------------------------------------------
# Header
# ---------------------------------------------------------------------------
echo ""
echo "  ┌─────────────────────────────────────────────┐"
echo "  │  Claude Code Dotfiles — Teardown             │"
echo "  └─────────────────────────────────────────────┘"
echo ""
info "Repo:   ${REPO_DIR}"
info "Target: ${TARGET_DIR}"
echo ""

# ---------------------------------------------------------------------------
# Early exit if target directory does not exist
# ---------------------------------------------------------------------------
if [ ! -d "$TARGET_DIR" ]; then
    warn "Target directory does not exist: ${TARGET_DIR}"
    info "Nothing to do."
    exit 0
fi

# ---------------------------------------------------------------------------
# Find symlinks in ~/.claude/ that point into this repo
# ---------------------------------------------------------------------------
symlinks=()
while IFS= read -r -d '' entry; do
    if [ -L "$entry" ]; then
        link_target="$(readlink "$entry")"
        case "$link_target" in
            "${REPO_DIR}"/*)
                symlinks+=("$entry")
                ;;
        esac
    fi
done < <(find "$TARGET_DIR" -maxdepth 1 -mindepth 1 -print0)

if [ ${#symlinks[@]} -eq 0 ]; then
    info "No symlinks pointing to this repo found in ${TARGET_DIR}."
    info "Nothing to do."
    exit 0
fi

info "Found ${#symlinks[@]} symlink(s) to restore."
echo ""

# ---------------------------------------------------------------------------
# Replace each symlink with a real copy of whatever it pointed at.
# We resolve the source from the symlink itself (readlink) rather than assuming
# a fixed layout — this stays correct across repo reorganizations (e.g., files
# living under dotclaude/ vs. at the repo root).
# ---------------------------------------------------------------------------
restored=0
for path in "${symlinks[@]}"; do
    name="$(basename "$path")"
    source="$(readlink "$path")"

    # Remove the symlink
    rm "$path"

    # Copy whatever the symlink was pointing at as a real file or directory
    if [ -d "$source" ]; then
        cp -R "$source" "$path"
        ok "Restored directory: ${name}"
    elif [ -f "$source" ]; then
        cp "$source" "$path"
        ok "Restored file: ${name}"
    else
        warn "Source no longer exists in repo: ${name} (symlink removed, nothing to copy back)"
    fi

    restored=$((restored + 1))
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
info "Done! Restored ${restored} item(s) as standalone local copies."
echo ""
