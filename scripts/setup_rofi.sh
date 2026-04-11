#!/bin/bash
# Copy bundled Rofi themes to the user theme directory (no sudo).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$DOTFILES_ROOT/assets/rofi/themes"
DEST_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/rofi/themes"

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: theme source not found at $SOURCE_DIR" >&2
    exit 1
fi

mkdir -p "$DEST_DIR"
shopt -s nullglob
rasi_files=("$SOURCE_DIR"/*.rasi)
if ((${#rasi_files[@]} == 0)); then
    echo "Error: no .rasi files in $SOURCE_DIR" >&2
    exit 1
fi
cp -f "${rasi_files[@]}" "$DEST_DIR"/
echo "Rofi themes installed to $DEST_DIR"
