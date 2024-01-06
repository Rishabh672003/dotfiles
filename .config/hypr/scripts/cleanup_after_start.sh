#!/bin/bash

sleep 5
hyprctl keyword windowrule "workspace unset,floorp"
hyprctl keyword windowrule "workspace unset,alacritty"
hyprctl keyword windowrule "workspace unset,kitty"
hyprctl keyword windowrule "workspace unset,wezterm"
hyprctl keyword windowrule "workspace unset,evince"
sleep 3
