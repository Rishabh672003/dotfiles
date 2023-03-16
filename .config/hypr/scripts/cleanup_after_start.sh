#!/bin/bash

sleep 2
hyprctl keyword windowrule "workspace unset,firefox"
hyprctl keyword windowrule "workspace unset,alacritty"
hyprctl keyword windowrule "workspace unset,kitty"
hyprctl keyword windowrule "workspace unset,wezterm"
hyprctl keyword windowrule "workspace unset,evince"
