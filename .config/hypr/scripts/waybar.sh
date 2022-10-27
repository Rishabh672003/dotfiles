#!/bin/bash

CONFIG_FILES1="$HOME/.config/waybar/config.jsonc"
CONFIG_FILES2="$HOME/.config/waybar/style.css"

trap "killall waybar" EXIT

while true; do
    waybar &
    inotifywait -e modify "$CONFIG_FILES1"
    inotifywait -e create,modify "$CONFIG_FILES2"
    killall waybar
done
