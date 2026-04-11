#!/bin/bash
# Dry-run stow and spot-check symlinks into DOTFILES_ROOT/stow/.
# Run as your normal user:  bash ~/.dotfiles/scripts/verify_stow.sh
# Optional: VERIFY_HYPR=1 bash ...  — include hypr + quickshell checks

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STOW_DIR="$DOTFILES_ROOT/stow"
TARGET="${STOW_TARGET:-$HOME}"

DEFAULT_PKGS=(fastfetch fish kitty rofi)
HYPR_PKGS=(hypr quickshell)

echo -e "${BLUE}Dotfiles root:${NC} $DOTFILES_ROOT"
echo -e "${BLUE}Stow dir:${NC}     $STOW_DIR"
echo -e "${BLUE}Target:${NC}        $TARGET"
echo ""

if [[ ! -d "$STOW_DIR" ]]; then
    echo -e "${RED}[x] Stow directory missing: $STOW_DIR${NC}" >&2
    exit 1
fi

dry_run_failed=0
echo -e "${BLUE}=== stow dry-run (-n) per package ===${NC}"
pkgs=("${DEFAULT_PKGS[@]}")
if [[ "${VERIFY_HYPR:-0}" == "1" ]]; then
    pkgs+=("${HYPR_PKGS[@]}")
fi

for pkg in "${pkgs[@]}"; do
    if [[ ! -d "$STOW_DIR/$pkg" ]]; then
        echo -e "${YELLOW}[!] skip $pkg (no directory)${NC}"
        continue
    fi
    echo -n "  $pkg ... "
    if out=$(cd "$STOW_DIR" && stow -n -R -t "$TARGET" "$pkg" 2>&1); then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}CONFLICTS${NC}"
        echo "$out" | sed 's/^/    /'
        dry_run_failed=1
    fi
done

echo ""
echo -e "${BLUE}=== symlink spot-checks (default GNOME stack) ===${NC}"
# fish: single-file links under ~/.config/fish/
# fastfetch, kitty, rofi: stow links the whole ~/.config/<name> directory

link_failed=0
check_link() {
    local path=$1 pkg=$2 label=$3
    if [[ ! -e "$path" ]] && [[ ! -L "$path" ]]; then
        echo -e "  ${YELLOW}!${NC} $label — missing"
        link_failed=1
        return
    fi
    if [[ ! -L "$path" ]]; then
        echo -e "  ${RED}!!${NC} $label — not a symlink (plain file/dir blocks stow)"
        link_failed=1
        return
    fi
    local real
    real=$(readlink -f "$path" 2>/dev/null || true)
    if [[ "$real" == "$STOW_DIR/$pkg"/* ]] || [[ "$real" == */stow/$pkg/* ]]; then
        echo -e "  ${GREEN}OK${NC} $label -> $real"
    else
        echo -e "  ${RED}!!${NC} $label -> $real (expected under stow/$pkg/)"
        link_failed=1
    fi
}

check_link "$TARGET/.config/fish/config.fish" fish "~/.config/fish/config.fish"
check_link "$TARGET/.config/kitty" kitty "~/.config/kitty (dir)"
check_link "$TARGET/.config/fastfetch" fastfetch "~/.config/fastfetch (dir)"
check_link "$TARGET/.config/rofi" rofi "~/.config/rofi (dir)"

echo ""
if [[ "$dry_run_failed" -eq 0 ]]; then
    echo -e "${GREEN}[+] All dry-runs passed.${NC}"
else
    echo -e "${YELLOW}[!] Fix conflicts above, then from $STOW_DIR run:${NC}"
    echo "    stow -R -t \"\$HOME\" <package>"
    echo -e "${YELLOW}    If you moved from an old layout, unstow from the old repo path first.${NC}"
    echo -e "${YELLOW}    fish: ~/.config/fish/fish_variables is often a real file — remove it from the${NC}"
    echo -e "${YELLOW}    stow package in git or delete the target file after backing up universals.${NC}"
fi

if [[ "$link_failed" -eq 1 ]] && [[ "$dry_run_failed" -eq 0 ]]; then
    echo -e "${YELLOW}[!] Some paths are not stow symlinks yet; run the installer stow step or stow manually.${NC}"
fi

exit $((dry_run_failed | link_failed))
