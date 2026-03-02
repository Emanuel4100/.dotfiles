
#!/bin/bash

# Define source and destination paths
SOURCE_FILE=".dotfiles/assets/rofi/themes"
DEST_DIR="/usr/share/rofi/themes"

# Copy the files
cp "$SOURCE_FILE"/*  "$DEST_DIR"/

echo "Files copied successfully!"
