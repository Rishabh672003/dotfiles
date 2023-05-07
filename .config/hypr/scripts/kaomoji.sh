#!/usr/bin/env sh

ROFI_PATH=$(which rofi 2>/dev/null)
WOFI_PATH=$(which wofi 2>/dev/null)
if [ -x "$ROFI_PATH" ]; then
    ROFI_COMMAND="$ROFI_PATH -dmenu -i"
elif [ -x "$WOFI_PATH" ]; then
    ROFI_COMMAND="$WOFI_PATH --dmenu -i"
else
    notify-send "Neither rofi or wofi is found, exit."
    exit 1
fi


if [ -z $WAYLAND_DISPLAY ]; then
    current_wid=$(xdo id)
    selection=$($ROFI_COMMAND $@ < $(dirname $0)/kaomoji.txt)
    kaomoji=$(echo $selection | sed "s|$(echo -e "\ufeff").*||")
    echo -n "$kaomoji" | xclip -selection clipboard
    xdotool key --window $current_wid --clearmodifiers ctrl+v
else
    kaomoji=$($ROFI_COMMAND -p kaomoji $@ < $(dirname $0)/kaomoji.txt | sed "s|$(echo -e "\ufeff").*||")
    wtype "$kaomoji"
fi
