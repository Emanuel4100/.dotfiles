#!/bin/bash

# Ensure zscroll and playerctl are installed
zscroll -l 30 \
        --delay 0.1 \
        --scroll-padding "   " \
        --match-command "playerctl -p spotify status" \
        --match-text "Playing" "--scroll 1" \
        --match-text "Paused" "--scroll 0" \
        --update-check true "playerctl -p spotify metadata --format '{{ artist }} - {{ title }}'" &

wait
