#!/bin/bash

# ==========================================
# PRE-FLIGHT CHECK
# ==========================================
if [[ $EUID -eq 0 ]]; then
    echo "❌ Please run this script as your NORMAL user."
    exit 1
fi

SUDO="sudo"
HYPR_PATH="" # Fixed syntax: removed spaces

# ==========================================
# INSTALLATION MODE SELECTION
# ==========================================
echo "------------------------------------------"
echo "  Fedora Setup Script - Choose Mode"
echo "------------------------------------------"
echo "1) Full Install (Everything)"
echo "2) Custom Install (Choose sections)"
read -p "Select [1-2]: " INSTALL_MODE

# Function to ask permission for a section
ask_install() {
    if [[ "$INSTALL_MODE" == "1" ]]; then
        return 0 # Always install in Full mode
    fi
    read -p "Install $1? (y/n): " choice
    [[ "$choice" == "y" || "$choice" == "Y" ]] && return 0 || return 1
}

# ==========================================
# CORE REPOS & UPDATES (Required)
# ==========================================
echo "Adding RPM Fusion & Updating..."
$SUDO dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
$SUDO dnf update -y --refresh

# ==========================================
# DNF PACKAGES
# ==========================================
if ask_install "DNF General Packages (git, kitty, nvim, etc)"; then
    PACKAGES=(git gh kitty fastfetch stow fish gnome-tweaks gnome-pomodoro wl-clipboard neovim)
    $SUDO dnf install -y "${PACKAGES[@]}"
fi

# ==========================================
# BRAVE BROWSER
# ==========================================
if ask_install "Brave Browser"; then
    curl -fsS https://dl.brave.com/install.sh | sh
fi

# ==========================================
# VISUAL STUDIO CODE
# ==========================================
if ask_install "Visual Studio Code"; then
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
fi

# ==========================================
# FLATPAK & FLATHUB
# ==========================================
if ask_install "Flatpak Apps (Obsidian, Resources, etc)"; then
    $SUDO dnf install -y flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    FLATPAK_APPS=(
        "com.github.tchx84.Flatseal"
        "io.github.giantpinkrobots.flathub.ExtensionManager"
        "md.obsidian.Obsidian"
        "com.rtosta.zapzap"
        "net.nokyan.Resources"
    )
    flatpak install -y flathub "${FLATPAK_APPS[@]}"
fi

# ==========================================
# SNAP & SPOTIFY
# ==========================================
if ask_install "Snap Apps (Spotify)"; then
    echo "Installing snapd..."
    $SUDO dnf install -y snapd
    $SUDO systemctl enable --now snapd.socket
    
    # Fedora requires this symlink for classic snap support
    if [ ! -L /snap ]; then
        $SUDO ln -s /var/lib/snapd/snap /snap
    fi
    
    # Wait briefly for snapd socket to fully initialize
    echo "Waiting for snapd to initialize..."
    sleep 5
    
    echo "Installing Spotify (Revision 89)..."
    $SUDO snap install spotify --revision=89
fi

# ==========================================
# HYPRLAND
# ==========================================
if [[ -n "$HYPR_PATH" ]] && ask_install "Hyprland"; then
    $SUDO bash "$HYPR_PATH"
fi

# ==========================================
# GNOME KEYBINDS
# ==========================================
if ask_install "Custom GNOME Keybindings"; then
    # System Defaults
    gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Super>b']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys calculator "['<Super>c']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys control-center "['<Super><Shift>o']"
    gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"

    # Define Paths
    P0="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    P1="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
    P2="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
    P3="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
    P4="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"

    # Spotify (Updated for Snap)
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P0 name 'Spotify'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P0 command 'snap run spotify'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P0 binding '<Alt><Shift>s'

    # Terminal
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P1 name 'Terminal'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P1 command 'kitty'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P1 binding '<Super>t'

    # Shutdown
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P2 name 'Shutdown Prompt'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P2 command 'gnome-session-quit --power-off'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P2 binding '<Super>F4'
    
    # VS Code
    # Fix: Clear the default Super+V binding so VS Code can use it
    gsettings set org.gnome.shell.keybindings toggle-message-tray "[]"
    
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P4 name 'VS Code'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P4 command 'code'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P4 binding '<Super>v'
    
    # Resources 
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P3 name 'Resources'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P3 command 'flatpak run net.nokyan.Resources'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P3 binding '<Control><Shift>grave'

    # Register all
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$P0', '$P1', '$P2', '$P3', '$P4']"
    echo "Setup custom GNOME Keybindings"
fi

# ==========================================
# FINAL STEPS
# ==========================================
if ask_install "Shell customization (Fish & Aliases)"; then
    echo "Changing default shell to fish..."
    chsh -s /usr/bin/fish

    echo "Adding custom aliases to fish config..."
    mkdir -p ~/.config/fish
    # Adding via echo is safer than 'alias --save' inside a bash script
    echo "alias files='nautilus .'" >> ~/.config/fish/config.fish
fi

if ask_install "GRUB Theme"; then
    $SUDO mkdir -p /boot/grub2/themes
    $SUDO cp -r ~/.dotfiles/assets/grub-themes/fedora /boot/grub2/themes/
fi

echo "✅ Installation script finished successfully!"
