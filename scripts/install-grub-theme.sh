#!/bin/bash

# Define the source and destination paths
THEME_SOURCE="$HOME/.dotfiles/assets/grub-themes/fedora"
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
sudo sed -i 's/^GRUB_TERMINAL_OUTPUT=.*/GRUB_TERMINAL_OUTPUT="gfxterm"/' "$GRUB_DEFAULT"

# Remove any existing GRUB_THEME lines to avoid duplicates
sudo sed -i '/^GRUB_THEME=/d' "$GRUB_DEFAULT"

# Append the new GRUB_THEME line
echo 'GRUB_THEME="/boot/grub2/themes/fedora/theme.txt"' | sudo tee -a "$GRUB_DEFAULT" > /dev/null

echo "Generating new GRUB config file..."
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

echo "Done! Your GRUB theme has been successfully installed."
