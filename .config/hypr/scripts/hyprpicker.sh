#!/bin/bash

COLOR=$(hyprpicker --format hex)
notify-send "Color copied" "$COLOR"
# then put it on your clipboard with your clipboard manager idk I don't daily drive wayland
wl-copy "$COLOR"

