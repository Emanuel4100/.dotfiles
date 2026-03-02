#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
INSTALL='sudo dnf install -y'

echo -e "${BLUE}Starting Hyprland component installation for Fedora...${NC}"

# 1. Update the system
echo -e "${GREEN}Updating system packages...${NC}"
sudo dnf update -y

# 2. Install Core Hyprland Components
CORE_PACKAGES=(
    waybar
    hyprpaper
    hypridle
    hyprlock
    wlogout
    rofi-wayland
    xdg-desktop-portal-hyprland
)
echo -e "${GREEN}Installing Core Hyprland Components...${NC}"
$INSTALL "${CORE_PACKAGES[@]}"

# 3. Install Hyprshot and dependencies
HYPRSHOT_PACKAGES=(
    hyprshot
    grim
    slurp
    jq
    libnotify
)
echo -e "${GREEN}Installing Hyprshot and dependencies...${NC}"
$INSTALL "${HYPRSHOT_PACKAGES[@]}"

# 4. Install Applets, Launcher, Terminal, and Utils
EXTRA_PACKAGES=(
    kitty
    wl-clipboard
    network-manager-applet
    pavucontrol
    brightnessctl
    playerctl
    SwayNotificationCenter
)
echo -e "${GREEN}Installing Terminal, Applets, Clipboard, and Audio/Media Controls...${NC}"
$INSTALL "${EXTRA_PACKAGES[@]}"

# 5. Fix XDG Desktop Portal Conflict for Dual DE (GNOME + Hyprland)
echo -e "${YELLOW}Applying XDG-Portal fix for dual GNOME/Hyprland setup...${NC}"
mkdir -p ~/.config/xdg-desktop-portal
cat <<EOF > ~/.config/xdg-desktop-portal/hyprland-portals.conf
[preferred]
default=hyprland;gtk
EOF
echo -e "  [✅] hyprland-portals.conf created"

# 6. Verification
# 6. Verification
echo -e "${BLUE}Checking primary installations:${NC}"

# We check the actual commands they provide to the system, not the package names!
COMMANDS_TO_CHECK=(
    waybar
    hyprpaper
    hypridle
    hyprlock
    wlogout
    rofi        # Provided by rofi-wayland
    hyprshot
    kitty
    wl-copy     # Provided by wl-clipboard
    nm-applet   # Provided by network-manager-applet
    swaync      # Provided by SwayNotificationCenter
)

for cmd in "${COMMANDS_TO_CHECK[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        echo -e "  [✅] $cmd is ready to use"
    else
        echo -e "  [❌] $cmd is missing or failed to install"
    fi
done

echo -e "${BLUE}Installation complete! Restart your Hyprland session to begin using your new tools.${NC}"
