#!/bin/bash
# Remove blocking ~/.config paths and run stow (same packages as install.sh).
# Run backup_dotconfig.sh first, or pass --backup-first.
#
# Usage:
#   bash ~/.dotfiles/scripts/apply_stow.sh --backup-first
#   bash ~/.dotfiles/scripts/apply_stow.sh -y              # skip confirmation (after you backed up)
#   bash ~/.dotfiles/scripts/apply_stow.sh --backup-first -y

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STOW_DIR="$DOTFILES_ROOT/stow"

backup_first=false
assume_yes=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --backup-first) backup_first=true; shift ;;
        -y|--yes) assume_yes=true; shift ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--backup-first] [-y|--yes]" >&2
            exit 1
            ;;
    esac
done

if [[ $EUID -eq 0 ]]; then
    echo "Run as your normal user, not root." >&2
    exit 1
fi

if [[ ! -d "$STOW_DIR" ]]; then
    echo "Missing stow dir: $STOW_DIR" >&2
    exit 1
fi

if $backup_first; then
    echo "=== Running backup ==="
    bash "$SCRIPT_DIR/backup_dotconfig.sh"
    echo ""
fi

echo "This will remove the following if they exist (so stow can create symlinks):"
echo "  - $HOME/.config/fastfetch (entire dir — stow links the folder)"
echo "  - $HOME/.config/fish/config.fish and functions/fish_prompt.fish only"
echo "  - $HOME/.config/kitty (entire dir)"
echo "  - $HOME/.config/rofi (entire dir)"
echo ""
echo "Not removed: $HOME/.config/fish/fish_variables (Fish universal variables)"
echo ""

if ! $assume_yes; then
    read -r -p "Proceed with removal and stow? [y/N] " ans
    case "$ans" in
        y|Y|yes|YES) ;;
        *) echo "Aborted."; exit 1 ;;
    esac
fi

rm -rf "$HOME/.config/fastfetch"
rm -f "$HOME/.config/fish/config.fish"
rm -f "$HOME/.config/fish/functions/fish_prompt.fish"
if [[ -d "$HOME/.config/fish/functions" ]] && [[ -z "$(find "$HOME/.config/fish/functions" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
    rmdir "$HOME/.config/fish/functions" 2>/dev/null || true
fi
rm -rf "$HOME/.config/kitty"
rm -rf "$HOME/.config/rofi"

cd "$STOW_DIR"
for pkg in fastfetch fish kitty rofi; do
    if [[ -d "$pkg" ]]; then
        echo "  -> stow -R -t \"\$HOME\" $pkg"
        stow -R -t "$HOME" "$pkg"
    fi
done

echo ""
echo "Done. Verify with: bash \"$DOTFILES_ROOT/scripts/verify_stow.sh\""
