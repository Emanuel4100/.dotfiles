#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Hyprland component installation for Fedora...${NC}"

# 1. Update the system
echo -e "${GREEN}Updating system packages...${NC}"
sudo dnf update -y

# 2. Install main components from official repos
# waybar, hyprpaper, hypridle, and hyprlock are in official Fedora repos
echo -e "${GREEN}Installing Waybar, Hyprpaper, Hypridle, and Hyprlock...${NC}"
sudo dnf install -y waybar hyprpaper hypridle hyprlock wlogout

# 3. Install Hyprshot dependencies and Hyprshot
# Hyprshot is a shell script wrapper for grim and slurp
echo -e "${GREEN}Installing Hyprshot and dependencies (grim, slurp, jq)...${NC}"
sudo dnf install -y grim slurp jq libnotify

# Since Hyprshot isn't always in the main dnf repo, 
# we'll fetch the latest script directly from the source to /usr/local/bin
sudo curl -L https://raw.githubusercontent.com/Gustash/Hyprshot/main/hyprshot -o /usr/local/bin/hyprshot
sudo chmod +x /usr/local/bin/hyprshot

# 4. Verification
echo -e "${BLUE}Checking installations:${NC}"
for pkg in waybar hyprpaper hypridle hyprlock hyprshot; do
    if command -v $pkg &> /dev/null; then
        echo -e "  [✅] $pkg is installed"
    else
        echo -e "  [❌] $pkg installation failed"
    fi
done

echo -e "${BLUE}Installation complete! Restart your Hyprland session to begin using your new tools.${NC}"
