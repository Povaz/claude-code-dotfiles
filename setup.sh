#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# setup.sh — Symlink repo contents into ~/.claude/
#
# Auto-discovers top-level files and directories in this repo (minus an IGNORE
# list) and creates symlinks from ~/.claude/<item> → <repo>/<item>.
# Backs up any pre-existing items before overwriting.
# Safe to re-run — skips items already correctly linked.
# =============================================================================

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${HOME}/.claude"
BACKUP_BASE="${TARGET_DIR}/backups"

# ---------------------------------------------------------------------------
# Colored output helpers
# ---------------------------------------------------------------------------
info() { printf '\033[0;34m[INFO]\033[0m %s\n' "$1"; }
ok()   { printf '\033[0;32m[OK]\033[0m %s\n' "$1"; }
warn() { printf '\033[0;33m[WARN]\033[0m %s\n' "$1"; }

# ---------------------------------------------------------------------------
# Items the setup script should never symlink
# ---------------------------------------------------------------------------
is_ignored() {
    case "$1" in
        setup.sh|teardown.sh|README.md|LICENSE|.git|.gitignore|.DS_Store|.idea|.claude)
            return 0 ;;
        *)
            return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# Check if a target path is already a symlink pointing to the expected source
# ---------------------------------------------------------------------------
is_correctly_linked() {
    local target="$1"
    local source="$2"
    [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]
}

# ---------------------------------------------------------------------------
# Summary box
# ---------------------------------------------------------------------------
echo ""
echo "  ┌─────────────────────────────────────────────┐"
echo "  │  Claude Code Dotfiles — Setup                │"
echo "  └─────────────────────────────────────────────┘"
echo ""
info "Repo:   ${REPO_DIR}"
info "Target: ${TARGET_DIR}"
echo ""

# ---------------------------------------------------------------------------
# Ensure target directory exists
# ---------------------------------------------------------------------------
mkdir -p "$TARGET_DIR"

# ---------------------------------------------------------------------------
# Discover items to manage (top-level files and dirs, minus IGNORE list)
# ---------------------------------------------------------------------------
items=()
while IFS= read -r -d '' entry; do
    name="$(basename "$entry")"
    if ! is_ignored "$name"; then
        items+=("$name")
    fi
done < <(find "$REPO_DIR" -maxdepth 1 -mindepth 1 -print0)

if [ ${#items[@]} -eq 0 ]; then
    warn "No items found in repo to symlink."
    exit 0
fi

info "Found ${#items[@]} item(s) to manage: ${items[*]}"
echo ""

# ---------------------------------------------------------------------------
# First pass — identify items that need backing up
# An item needs backup if something exists at the target path and it is NOT
# already our symlink.
# ---------------------------------------------------------------------------
needs_backup=()
for name in "${items[@]}"; do
    target="${TARGET_DIR}/${name}"
    source="${REPO_DIR}/${name}"
    if is_correctly_linked "$target" "$source"; then
        continue
    elif [ -e "$target" ] || [ -L "$target" ]; then
        needs_backup+=("$name")
    fi
done

# ---------------------------------------------------------------------------
# Back up items (only creates the backup dir if at least one item needs it)
# ---------------------------------------------------------------------------
backup_dir=""
if [ ${#needs_backup[@]} -gt 0 ]; then
    backup_dir="${BACKUP_BASE}/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    info "Backing up ${#needs_backup[@]} existing item(s) to ${backup_dir}"
    for name in "${needs_backup[@]}"; do
        mv "${TARGET_DIR}/${name}" "${backup_dir}/${name}"
        ok "Backed up: ${name}"
    done
    echo ""
fi

# ---------------------------------------------------------------------------
# Second pass — create symlinks
# ---------------------------------------------------------------------------
linked=0
skipped=0
for name in "${items[@]}"; do
    target="${TARGET_DIR}/${name}"
    source="${REPO_DIR}/${name}"
    if is_correctly_linked "$target" "$source"; then
        ok "Already linked: ${name}"
        skipped=$((skipped + 1))
    else
        ln -sfn "$source" "$target"
        ok "Linked: ${name}"
        linked=$((linked + 1))
    fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
info "Done! ${linked} linked, ${skipped} already correct."
if [ -n "$backup_dir" ]; then
    info "Backups saved to: ${backup_dir}"
fi
echo ""
info "To undo, run: ./teardown.sh"
echo ""
