#!/bin/bash

sleep 5
hyprctl keyword windowrule "workspace unset,firefox"
hyprctl keyword windowrule "workspace unset,ghostty"
hyprctl keyword windowrule "workspace unset,kitty"
hyprctl keyword windowrule "workspace unset,evince"
sleep 3
