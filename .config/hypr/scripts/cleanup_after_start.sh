#!/bin/bash

sleep 5
hyprctl keyword windowrule "workspace unset,title:firefox"
hyprctl keyword windowrule "workspace unset,title:foot"
hyprctl keyword windowrule "workspace unset,title:kitty"
hyprctl keyword windowrule "workspace unset,title:evince"
sleep 3
