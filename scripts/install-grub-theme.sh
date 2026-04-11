#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
THEME_SOURCE="$DOTFILES_ROOT/assets/grub-themes/fedora"
THEME_DEST="/boot/grub2/themes/fedora"
GRUB_DEFAULT="/etc/default/grub"

echo "Checking if source theme exists at $THEME_SOURCE..."
if [ ! -d "$THEME_SOURCE" ]; then
    echo "Error: Theme directory not found. Please check your dotfiles path."
    exit 1
fi

echo "Creating the GRUB themes folder if it doesn't exist..."
sudo mkdir -p /boot/grub2/themes

echo "Copying the Fedora theme to the GRUB boot folder..."
# We remove the existing folder first just in case you are updating the theme
sudo rm -rf "$THEME_DEST"
sudo cp -r "$THEME_SOURCE" /boot/grub2/themes/

echo "Configuring /etc/default/grub..."

# Update the terminal output to gfxterm
if grep -q "^GRUB_TERMINAL_OUTPUT=" "$GRUB_DEFAULT"; then
    sudo sed -i 's/^GRUB_TERMINAL_OUTPUT=.*/GRUB_TERMINAL_OUTPUT="gfxterm"/' "$GRUB_DEFAULT"
else
    echo 'GRUB_TERMINAL_OUTPUT="gfxterm"' | sudo tee -a "$GRUB_DEFAULT" > /dev/null
fi

# Set GRUB_DISABLE_SUBMENU to false to clean up the menu
echo "Grouping older kernels into a submenu..."
if grep -q "^GRUB_DISABLE_SUBMENU=" "$GRUB_DEFAULT"; then
    sudo sed -i 's/^GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=false/' "$GRUB_DEFAULT"
else
    echo 'GRUB_DISABLE_SUBMENU=false' | sudo tee -a "$GRUB_DEFAULT" > /dev/null
fi

# Remove any existing GRUB_THEME lines to avoid duplicates
sudo sed -i '/^GRUB_THEME=/d' "$GRUB_DEFAULT"

# Append the new GRUB_THEME line
echo 'GRUB_THEME="/boot/grub2/themes/fedora/theme.txt"' | sudo tee -a "$GRUB_DEFAULT" > /dev/null

echo "Generating new GRUB config file..."
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

echo "Done! Your GRUB theme is installed and the menu is cleaned up."
