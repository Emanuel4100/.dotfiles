#!/bin/bash

# ==========================================
# PRE-FLIGHT CHECK
# ==========================================
# Prevent running directly as root so user-specific configs apply correctly.
if [[ $EUID -eq 0 ]]; then
    echo "❌ Please run this script as your NORMAL user (do not use 'sudo ./script.sh')."
    echo "The script will automatically use sudo for installation commands."
    exit 1
fi

SUDO="sudo"
HYPR_PATH = ""

# ==========================================
# RPM FUSION (Done first to combine updates)
# ==========================================
echo "Adding RPM Fusion repositories..."
$SUDO dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

echo "Updating system..."
$SUDO dnf update -y --refresh

# ==========================================
# DNF PACKAGES
# ==========================================
PACKAGES=(
    git
    gh
    kitty
    fastfetch
    stow
    fish
    gnome-tweaks
    gnome-pomodoro
    wl-clipboard
    neovim
)

echo "Installing general packages..."
$SUDO dnf install -y "${PACKAGES[@]}"


# ==========================================
# BRAVE BROWSER
# ==========================================
echo "Installing Brave Browser..."
curl -fsS https://dl.brave.com/install.sh | sh


# ==========================================
# VISUAL STUDIO CODE
# ==========================================
echo "Installing Visual Studio Code..."
$SUDO rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat <<EOF | $SUDO tee /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
$SUDO dnf install -y code

# ==========================================
# FLATPAK & FLATHUB
# ==========================================
echo "Setting up Flatpak and Flathub..."
$SUDO dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

FLATPAK_APPS="com.spotify.Client com.github.tchx84.Flatseal mattjakeman.ExtensionManager md.obsidian.Obsidian com.rtosta.zapzap"

echo "Installing Flatpak apps: $FLATPAK_APPS"
$SUDO flatpak install -y flathub $FLATPAK_APPS

# ==========================================
# HYPRLAND
# ==========================================
echo "Installing Hyprland..."
$SUDO bash HYPR_PATH

# ==========================================
# GNOME KEYBINDS
# ==========================================
# Note: These bindings will only work when logged into GNOME, not Hyprland.
echo "Adding custom GNOME keybinds..."

# --- System Defaults ---
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Super>b']"
gsettings set org.gnome.settings-daemon.plugins.media-keys calculator "['<Super>c']"
gsettings set org.gnome.settings-daemon.plugins.media-keys power "['<Super>F4']"
gsettings set org.gnome.settings-daemon.plugins.media-keys control-center "['<Super><Shift>o']"
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"

# --- Custom App Shortcuts (Terminal & Spotify) ---
PATH_SPOTIFY="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
PATH_TERMINAL="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"

# 1. Spotify
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$PATH_SPOTIFY name 'Spotify'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$PATH_SPOTIFY command 'flatpak run com.spotify.Client'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$PATH_SPOTIFY binding '<Alt><Shift>s'

# 2. Terminal (Kitty)
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$PATH_TERMINAL name 'Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$PATH_TERMINAL command 'kitty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$PATH_TERMINAL binding '<Super>t'

# Register custom bindings so GNOME activates them
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$PATH_SPOTIFY', '$PATH_TERMINAL']"

# ==========================================
# FINAL STEPS
# ==========================================
echo "Changing default shell to fish..."
# This might prompt you for your user password
chsh -s /usr/bin/fish

echo "✅ Installation script finished successfully!"
