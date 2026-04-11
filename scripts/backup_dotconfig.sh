#!/bin/bash
# Copy ~/.config trees that this repo stows, before removing them for a clean stow.
# Usage: bash ~/.dotfiles/scripts/backup_dotconfig.sh
# Override destination parent: DOTFILES_BACKUP_PARENT=/path bash ...

set -euo pipefail

BACKUP_PARENT="${DOTFILES_BACKUP_PARENT:-$HOME/dotfiles-config-backups}"
STAMP=$(date +%Y%m%d-%H%M%S)
DEST="$BACKUP_PARENT/$STAMP"

mkdir -p "$DEST"

paths=(fastfetch fish kitty rofi)
backed=0
for p in "${paths[@]}"; do
    src="$HOME/.config/$p"
    if [[ -e "$src" ]]; then
        echo "  -> $src"
        cp -a "$src" "$DEST/"
        backed=1
    fi
done

if [[ "$backed" -eq 0 ]]; then
    echo "Nothing to back up under ~/.config/{fastfetch,fish,kitty,rofi} (paths missing)."
    rmdir "$DEST" 2>/dev/null || true
    exit 0
fi

echo ""
echo "Backup written to: $DEST"
echo "Restore example: cp -a \"$DEST/fish\"/* \"$HOME/.config/fish/\"   (adjust as needed)"
