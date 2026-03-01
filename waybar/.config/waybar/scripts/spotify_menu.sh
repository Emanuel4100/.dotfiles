#!/bin/bash

options="Next\nPrevious\nPlay/Pause\nShuffle Toggle\nRepeat Toggle"

# Uses Rofi in dmenu mode for Wayland
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Spotify Controls")

case $chosen in
    "Next") playerctl -p spotify next ;;
    "Previous") playerctl -p spotify previous ;;
    "Play/Pause") playerctl -p spotify play-pause ;;
    "Shuffle Toggle") playerctl -p spotify shuffle Toggle ;;
    "Repeat Toggle") playerctl -p spotify repeat Toggle ;;
esac
