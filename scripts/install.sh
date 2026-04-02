#!/bin/bash

# ==========================================
# COLORS & FORMATTING
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[*] $1${NC}"; }
success() { echo -e "${GREEN}[+] $1${NC}"; }
warning() { echo -e "${YELLOW}[!] $1${NC}"; }
error() { echo -e "${RED}[x] $1${NC}"; }

# ==========================================
# PRE-FLIGHT CHECK
# ==========================================
if [[ $EUID -eq 0 ]]; then
    error "Please run this script as your NORMAL user, not as root."
    exit 1
fi

SUDO="sudo"
# Automatically point to the hyprland install script in your dotfiles
HYPR_PATH="$HOME/.dotfiles/scripts/install_hypr.sh"

# ==========================================
# INSTALLATION MODE SELECTION
# ==========================================
echo "------------------------------------------"
echo -e "${BLUE}  Fedora Setup Script - Choose Mode${NC}"
echo "------------------------------------------"
echo "1) Full Install (Everything)"
echo "2) Custom Install (Choose sections)"

# Loop until valid input
while true; do
    read -p "Select [1-2]: " INSTALL_MODE
    if [[ "$INSTALL_MODE" == "1" || "$INSTALL_MODE" == "2" ]]; then
        break
    else
        warning "Invalid input. Please enter 1 or 2."
    fi
done

# Function to ask permission for a section
ask_install() {
    if [[ "$INSTALL_MODE" == "1" ]]; then
        return 0 # Always install in Full mode
    fi
    # Default to 'y' if user just presses Enter
    read -p "Install $1? (Y/n): " choice
    [[ -z "$choice" || "$choice" == "y" || "$choice" == "Y" ]] && return 0 || return 1
}

# ==========================================
# CORE REPOS & UPDATES (Required)
# ==========================================
info "Adding RPM Fusion & Updating system..."
$SUDO dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
$SUDO dnf update -y --refresh
success "System is up to date."

# ==========================================
# DNF PACKAGES
# ==========================================
if ask_install "DNF General Packages (git, kitty, nvim, etc)"; then
    info "Installing DNF packages..."
    PACKAGES=(git gh kitty fastfetch stow fish gnome-tweaks gnome-pomodoro wl-clipboard neovim openssl fontconfig)
    $SUDO dnf install -y "${PACKAGES[@]}"
    success "DNF packages installed."
fi

# ==========================================
# STOW DOTFILES
# ==========================================
if ask_install "Stow Dotfiles (Link config files)"; then
    info "Stowing dotfiles..."
    
    cd ~/.dotfiles || { error "Could not find ~/.dotfiles"; exit 1; }
    
    STOW_FOLDERS=(fastfetch fish hypr kitty quickshell rofi)
    
    for folder in "${STOW_FOLDERS[@]}"; do
        if [ -d "$folder" ]; then
            echo "  -> Linking $folder..."
            stow -R "$folder"
        else
            warning "Directory $folder not found, skipping."
        fi
    done
    
    success "Dotfiles linked successfully!"
    cd - > /dev/null
fi

# ==========================================
# INSTALL CUSTOM FONTS
# ==========================================
if ask_install "Custom Fonts (JetBrainsMono Nerd Font)"; then
    info "Installing Custom Fonts..."
    FONT_DIR="$HOME/.local/share/fonts"
    SOURCE_FONTS="$HOME/.dotfiles/assets/fonts"
    
    if [ -d "$SOURCE_FONTS" ]; then
        mkdir -p "$FONT_DIR"
        cp -r "$SOURCE_FONTS"/* "$FONT_DIR/"
        
        info "Rebuilding font cache..."
        fc-cache -fv >/dev/null 2>&1
        success "Fonts installed and cache updated."
    else
        warning "Could not find fonts directory at $SOURCE_FONTS. Skipping..."
    fi
fi

# ==========================================
# BRAVE BROWSER
# ==========================================
if ask_install "Brave Browser"; then
    info "Installing Brave Browser..."
    curl -fsS https://dl.brave.com/install.sh | sh
    success "Brave installed."
fi

# ==========================================
# VISUAL STUDIO CODE
# ==========================================
if ask_install "Visual Studio Code"; then
    info "Installing VS Code..."
    $SUDO rpm --import https://packages.microsoft.com/keys/microsoft.asc
    
    $SUDO tee /etc/yum.repos.d/vscode.repo > /dev/null << 'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

    $SUDO dnf install -y code
    success "VS Code installed."
fi

# ==========================================
# FLATPAK & FLATHUB
# ==========================================
if ask_install "Flatpak Apps (Obsidian, Resources, etc)"; then
    info "Setting up Flatpak and Flathub..."
    $SUDO dnf install -y flatpak
    $SUDO flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    
    FLATPAK_APPS=(
        "com.github.tchx84.Flatseal"
        "com.mattjakeman.ExtensionManager"
        "md.obsidian.Obsidian"
        "com.rtosta.zapzap"
        "net.nokyan.Resources"
    )
    
    info "Installing Flatpak apps..."
    for app in "${FLATPAK_APPS[@]}"; do
        echo "  -> Installing $app..."
        $SUDO flatpak install -y flathub "$app"
    done
    success "Flatpak apps installed."
fi

# ==========================================
# SNAP & SPOTIFY
# ==========================================
if ask_install "Snap Apps (Spotify)"; then
    info "Installing snapd..."
    $SUDO dnf install -y snapd
    
    # Enable both the socket and the actual service
    $SUDO systemctl enable --now snapd.socket
    $SUDO systemctl enable --now snapd.service
    
    if [ ! -L /snap ]; then
        $SUDO ln -s /var/lib/snapd/snap /snap
    fi
    
    info "Waiting for snapd to fully initialize (this may take a minute)..."
    
    # 1. Loop until the snap command becomes responsive
    until $SUDO snap version >/dev/null 2>&1; do
        sleep 2
    done
    
    # 2. Wait for snapd to finish its internal background setup (seeding)
    $SUDO snap wait system seed
    
    info "Installing Spotify (Revision 89)..."
    if $SUDO snap install spotify --revision=89; then
	sudo snap refresh --hold=forever spotify
        success "Spotify installed successfully."
    else
        error "Failed to install Spotify. You might need to restart your PC and run: sudo snap install spotify"
    fi
fi

# ==========================================
# HYPRLAND
# ==========================================
if ask_install "Hyprland Component"; then
    if [ -f "$HYPR_PATH" ]; then
        info "Running Hyprland install script..."
        bash "$HYPR_PATH"
        success "Hyprland setup complete."
    else
        warning "Hyprland install script not found at $HYPR_PATH"
    fi
fi

# ==========================================
# GNOME KEYBINDS
# ==========================================
if ask_install "Custom GNOME Keybindings"; then
    info "Applying GNOME Custom Keybindings..."
    
    gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Super>b']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys calculator "['<Super>c']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys control-center "['<Super><Shift>o']"
    gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"

    P0="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    P1="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
    P2="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
    P3="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
    P4="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P0 name 'Spotify'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P0 command 'snap run spotify'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P0 binding '<Alt><Shift>s'

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P1 name 'Terminal'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P1 command 'kitty'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P1 binding '<Super>t'

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P2 name 'Shutdown Prompt'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P2 command 'gnome-session-quit --power-off'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P2 binding '<Super>F4'
    
    gsettings set org.gnome.shell.keybindings toggle-message-tray "[]"
    
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P4 name 'VS Code'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P4 command 'code'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P4 binding '<Super>v'
    
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P3 name 'Resources'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P3 command 'flatpak run net.nokyan.Resources'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P3 binding '<Control><Shift>grave'

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$P0', '$P1', '$P2', '$P3', '$P4']"
    
    success "GNOME Keybindings configured."
fi

# ==========================================
# GNOME EXTENSIONS
# ==========================================
if ask_install "GNOME Extensions"; then
    info "Installing GNOME Extensions..."
    EXTENSIONS_SCRIPT="$HOME/.dotfiles/scripts/install_gnome_extensions.sh"
    
    if [ -f "$EXTENSIONS_SCRIPT" ]; then
        bash "$EXTENSIONS_SCRIPT"
        success "GNOME Extensions script executed."
    else
        warning "Could not find $EXTENSIONS_SCRIPT. Skipping..."
    fi
fi

# ==========================================
# FINAL STEPS
# ==========================================
if ask_install "Shell customization (Fish & Aliases)"; then
    info "Changing default shell to fish..."
    chsh -s /usr/bin/fish

    info "Adding custom aliases to fish config..."
    mkdir -p ~/.config/fish
    
    # Safe append: Checks if the alias already exists before adding it
    if ! grep -q "alias files='nautilus .'" ~/.config/fish/config.fish 2>/dev/null; then
        echo "alias files='nautilus .'" >> ~/.config/fish/config.fish
    fi
    success "Shell customized."
fi

if ask_install "GRUB Theme"; then
    info "Setting up GRUB Theme..."
    GRUB_SCRIPT="$HOME/.dotfiles/scripts/install-grub-theme.sh"
    if [ -f "$GRUB_SCRIPT" ]; then
        bash "$GRUB_SCRIPT"
        success "GRUB Theme applied."
    else
        # Fallback if the script isn't found
        $SUDO mkdir -p /boot/grub2/themes
        $SUDO cp -r ~/.dotfiles/assets/grub-themes/fedora /boot/grub2/themes/
        success "GRUB Theme files copied (Update grub manually)."
    fi
fi

echo "------------------------------------------"
success "🎉 Installation script finished successfully! Please reboot your system for all changes to take effect."
