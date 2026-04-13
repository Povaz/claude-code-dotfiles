#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# status.sh — Show current symlink and backup state for this dotfiles repo
#
# Read-only: makes no changes to the filesystem.
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
# Items the setup script never symlinks (must match setup.sh)
# ---------------------------------------------------------------------------
is_ignored() {
    case "$1" in
        setup.sh|teardown.sh|status.sh|README.md|LICENSE|.git|.gitignore|.DS_Store|.idea|.claude)
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
# Header
# ---------------------------------------------------------------------------
echo ""
echo "  ┌─────────────────────────────────────────────┐"
echo "  │  Claude Code Dotfiles — Status              │"
echo "  └─────────────────────────────────────────────┘"
echo ""
info "Repo:   ${REPO_DIR}"
info "Target: ${TARGET_DIR}"
info "Backup: ${BACKUP_BASE}"
echo ""

# ---------------------------------------------------------------------------
# Discover managed items (top-level repo contents, minus ignore list)
# ---------------------------------------------------------------------------
items=()
while IFS= read -r -d '' entry; do
    name="$(basename "$entry")"
    if ! is_ignored "$name"; then
        items+=("$name")
    fi
done < <(find "$REPO_DIR" -maxdepth 1 -mindepth 1 -print0)

if [ ${#items[@]} -eq 0 ]; then
    info "No managed items found in repo."
else
    IFS=$'\n' items=($(printf '%s\n' "${items[@]}" | sort))

    # -----------------------------------------------------------------------
    # Section 1 — Symlink status for each managed item
    # -----------------------------------------------------------------------
    echo "  Managed items:"
    echo ""

    linked=0
    not_linked=0
    missing=0

    for name in "${items[@]}"; do
        target="${TARGET_DIR}/${name}"
        source="${REPO_DIR}/${name}"
        if is_correctly_linked "$target" "$source"; then
            ok "  Linked:     ${name}  →  ${target}"
            linked=$((linked + 1))
        elif [ -e "$target" ] || [ -L "$target" ]; then
            warn "  Not linked: ${name}  (exists at target but is not our symlink)"
            not_linked=$((not_linked + 1))
        else
            warn "  Missing:    ${name}  (not present in target)"
            missing=$((missing + 1))
        fi
    done

    echo ""
    info "Summary: ${linked} linked, ${not_linked} not linked, ${missing} missing."
fi

# ---------------------------------------------------------------------------
# Section 2 — Backup snapshots
# ---------------------------------------------------------------------------
echo ""
echo "  Backups:"
echo ""

if [ ! -d "$BACKUP_BASE" ] || [ -z "$(ls -A "$BACKUP_BASE" 2>/dev/null)" ]; then
    info "  No backups found."
else
    while IFS= read -r -d '' snap; do
        snap_name="$(basename "$snap")"
        info "  Backup: ${snap_name}"
        while IFS= read -r -d '' entry; do
            printf '          %s\n' "$(basename "$entry")"
        done < <(find "$snap" -maxdepth 1 -mindepth 1 -print0 | sort -z)
    done < <(find "$BACKUP_BASE" -maxdepth 1 -mindepth 1 -type d -print0 | sort -z)
fi

echo ""
