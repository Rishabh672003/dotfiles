#!/bin/bash

sleep 5

hyprctl eval 'hl.config({ windowrule = { "workspace unset,title:firefox", "workspace unset,title:foot", "workspace unset,title:kitty", "workspace unset,title:evince" } })'

sleep 3
