#!/bin/bash

# List of extensions to install
EXTENSIONS=(
    "appindicatorsupport@rgcjonas.gmail.com"
    "gsconnect@andyholmes.github.io"
    "dash-to-dock@micxgx.gmail.com"
    "simple-weather@romanlefler.com"
    "Bluetooth-Battery-Meter@maniacx.github.com"
    "mediacontrols@cliffniff.github.com"
    "search-light@icedman.github.com"
    "hidetopbar@mathieu.bidon.ca"
    "disable-unredirect@exeos"
    "blur-my-shell@aunetx"
    "Battery-Health-Charging@maniacx.github.com"
    "tailscale-status@maxgallup.github.com"
    "background-logo@fedorahosted.org"
    "pomodoro@arun.codito.in"
    "quick-lang-switch@ankostis.gmail.com"
)

# Ensure required commands are available
for cmd in curl jq gnome-extensions; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: '$cmd' is not installed. Please install it and try again."
        exit 1
    fi
done

# Detect GNOME Shell version (Handles both 3.x and 40+ versioning)
GS_VERSION=$(gnome-shell --version | awk '{print $3}')
if [[ "$GS_VERSION" == 3.* ]]; then
    GNOME_VERSION=$(echo "$GS_VERSION" | cut -d. -f1,2)
else
    GNOME_VERSION=$(echo "$GS_VERSION" | cut -d. -f1)
fi

echo "Detected GNOME Shell version: $GNOME_VERSION"

# Create a temporary directory for downloading the zip files
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Loop through and install each extension
for UUID in "${EXTENSIONS[@]}"; do
    echo "------------------------------------------------"
    echo "Processing: $UUID"
    
    # Query the GNOME Extensions API for the extension info
    RESPONSE=$(curl -s "https://extensions.gnome.org/extension-info/?uuid=${UUID}")
    
    # Extract the specific version tag (pk) matching the user's GNOME version
    # 2>/dev/null suppresses jq errors if the UUID is invalid or curling fails
    VERSION_TAG=$(echo "$RESPONSE" | jq -r ".shell_version_map[\"${GNOME_VERSION}\"].pk // empty" 2>/dev/null)
    
    if [ -z "$VERSION_TAG" ]; then
        echo "  -> Error: Could not find a compatible version of this extension for GNOME $GNOME_VERSION."
        continue
    fi
    
    # Construct the correct download URL
    DOWNLOAD_URL="/download-extension/${UUID}.shell-extension.zip?version_tag=${VERSION_TAG}"
    
    # Download the extension zip
    echo "  -> Downloading..."
    curl -sL "https://extensions.gnome.org${DOWNLOAD_URL}" -o "$TMP_DIR/${UUID}.zip"
    
    # Install the extension
    echo "  -> Installing..."
    gnome-extensions install "$TMP_DIR/${UUID}.zip" --force
    
    # Enable the extension
    echo "  -> Enabling..."
    gnome-extensions enable "$UUID"
    
    echo "  -> Successfully installed and enabled!"
done

echo "------------------------------------------------"
echo "All done! Note: You may need to log out and log back in (or press Alt+F2, type 'r', and hit Enter on X11) for all changes to properly take effect."
