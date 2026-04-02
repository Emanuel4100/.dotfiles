
# Emanuel's Fedora Dotfiles

My custom dotfiles and automated setup script tailored for **Fedora Linux**. This setup provides a complete, beautifully configured **Hyprland** environment alongside carefully selected GNOME tweaks, terminal utilities, and daily-driver applications.

## 🚀 Installation

You can install everything (or pick and choose components) using a single command. The interactive installer will guide you through the process.

```bash
git clone [https://github.com/emanuel4100/.dotfiles.git](https://github.com/emanuel4100/.dotfiles.git) ~/.dotfiles && cd ~/.dotfiles && bash scripts/install.sh
```

### Installer Features:
* **Interactive Mode:** Choose between a "Full Install" or a "Custom Install" to select specific components.
* **Idempotent & Safe:** Can be run multiple times safely. It handles prerequisites, symlinking, and updates automatically.
* **Auto-Stowing:** Automatically links configuration files using `GNU Stow` to your home directory.

---

## 📦 Components & Packages

### System & CLI
* **Shell:** Fish (with custom aliases)
* **Terminal:** Kitty
* **Utilities:** Fastfetch, GNU Stow, wl-clipboard, Neovim, Git, GitHub CLI (gh)
* **Fonts:** JetBrainsMono Nerd Font (Auto-installed and cached)

### Desktop Environment (Hyprland & GNOME)
* **Window Manager:** Hyprland
* **Launcher:** Rofi (Spotlight theme)
* **Shell/Bar:** Quickshell & Waybar
* **Lock & Idle:** Hyprlock & Hypridle
* **Theming:** Custom GRUB theme, GNOME Extensions, and GNOME Tweaks

### Applications
* **Browser:** Brave
* **Development:** Visual Studio Code
* **Flatpaks:** Obsidian, Resources, ZapZap, Flatseal, Extension Manager
* **Snaps:** Spotify

---

## ⌨️ Shortcuts & Keybinds

These are the global custom keybindings configured via the setup script (GNOME/Hyprland):

| Keybind | Action |
| :--- | :--- |
| `SUPER` + `T` | Open Terminal (Kitty) |
| `SUPER` + `B` | Open Browser (Brave) |
| `SUPER` + `E` | Open File Manager (Nautilus) |
| `SUPER` + `V` | Open Visual Studio Code |
| `SUPER` + `C` | Open Calculator |
| `SUPER` + `Q` | Close Window / Quit App |
| `SUPER` + `F` | Open Rofi / Spotlight Launcher |
| `SUPER` + `Shift` + `O` | Open Settings / Control Center |
| `ALT` + `Shift` + `S` | Open Spotify |
| `CTRL` + `Shift` + `\`` | Open System Resources |
| `SUPER` + `F4` | Shutdown Prompt |

---

## 🛠️ Directory Structure
* `assets/` - Fonts, Wallpapers, and GRUB themes.
* `scripts/` - Modular installation scripts (`install.sh`, `install_hypr.sh`, `setup_rofi.sh`, etc.).
* `fish/`, `kitty/`, `rofi/`, `hypr/`, `quickshell/` - Configuration directories ready to be stowed.

> **Note:** After running the installation script, it is highly recommended to **reboot** your system for all changes, shell overrides, and keybindings to take full effect.