#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# setup.sh — Symlink dotclaude/ contents into ~/.claude/
#
# Creates symlinks from ~/.claude/<item> → <repo>/dotclaude/<item> for every
# entry under dotclaude/. Anything outside dotclaude/ is repo plumbing and is
# never synced — no ignore list to maintain.
# Backs up any pre-existing items before overwriting.
# Safe to re-run — skips items already correctly linked.
# =============================================================================

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTCLAUDE_DIR="${REPO_DIR}/dotclaude"
TARGET_DIR="${HOME}/.claude"
BACKUP_BASE="${TARGET_DIR}/backups"

# ---------------------------------------------------------------------------
# Colored output helpers
# ---------------------------------------------------------------------------
info() { printf '\033[0;34m[INFO]\033[0m %s\n' "$1"; }
ok()   { printf '\033[0;32m[OK]\033[0m %s\n' "$1"; }
warn() { printf '\033[0;33m[WARN]\033[0m %s\n' "$1"; }
die()  { printf '\033[0;31m[ERROR]\033[0m %s\n' "$1" >&2; exit 1; }  # fatal: prints to stderr and exits

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
echo "  │  Claude Code Dotfiles — Setup               │"
echo "  └─────────────────────────────────────────────┘"
echo ""
info "Repo:      ${REPO_DIR}"
info "Dotclaude: ${DOTCLAUDE_DIR}"
info "Target:    ${TARGET_DIR}"
info "Backup:    ${BACKUP_BASE}"
echo ""

# ---------------------------------------------------------------------------
# Manual confirmation — let the user verify paths before touching anything
# ---------------------------------------------------------------------------
read -r -p "  Proceed with these paths? [y/N] " _confirm
case "$_confirm" in
    [yY][eE][sS]|[yY]) ;;
    *) die "Aborted." ;;
esac
echo ""

# ---------------------------------------------------------------------------
# Ensure source and target directories are usable
# ---------------------------------------------------------------------------
if [ ! -d "$DOTCLAUDE_DIR" ]; then
    die "Source directory not found: ${DOTCLAUDE_DIR} (expected dotclaude/ in repo root)"
fi

mkdir -p "$TARGET_DIR"
# Fail early if we can't write to TARGET_DIR — avoids partial state from a mid-run
# permission error (e.g. directory owned by another user or chmod 555).
if [ ! -w "$TARGET_DIR" ]; then
    die "Target directory is not writable: ${TARGET_DIR}"
fi

# ---------------------------------------------------------------------------
# Discover items to manage — every top-level entry under dotclaude/.
# No ignore list: if you don't want it synced, don't put it in dotclaude/.
# ---------------------------------------------------------------------------
items=()
while IFS= read -r -d '' entry; do
    items+=("$(basename "$entry")")
done < <(find "$DOTCLAUDE_DIR" -maxdepth 1 -mindepth 1 -print0)

if [ ${#items[@]} -eq 0 ]; then
    warn "No items found under ${DOTCLAUDE_DIR} to symlink."
    exit 0
fi

# Sort for deterministic output — find(1) returns filesystem order, which varies across runs.
IFS=$'\n' items=($(printf '%s\n' "${items[@]}" | sort))

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
    source="${DOTCLAUDE_DIR}/${name}"
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
        # set -e would abort on mv failure, but || die gives a formatted [ERROR] message
        # instead of a raw shell error — consistent with the rest of the output style.
        mv "${TARGET_DIR}/${name}" "${backup_dir}/${name}" || die "Failed to back up: ${name}"
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
    source="${DOTCLAUDE_DIR}/${name}"
    if is_correctly_linked "$target" "$source"; then
        ok "Already linked: ${name}"
        skipped=$((skipped + 1))
    else
        # Guard against broken symlinks: source could disappear between discovery
        # and this pass (race condition). Warn and skip rather than die so the
        # rest of the items still get linked.
        if [ ! -e "$source" ]; then
            warn "Source no longer exists, skipping: ${name}"
            continue
        fi
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
