#!/bin/env bash

# yadm add ~/.gitignore;
yadm add ~/README.md;
yadm add ~/.config/alacritty;
yadm add ~/.config/btop;
yadm add ~/.config/fish;
yadm add ~/.config/helix;
yadm add ~/.config/hypr;
yadm add ~/.config/kitty;
yadm add ~/.config/lvim;
yadm add ~/.config/mpv;
yadm add ~/.config/neofetch;
yadm add ~/.config/nvim;
yadm add ~/.config/rofi;
yadm add ~/.config/shellfetch;
yadm add ~/.config/sway;
yadm add ~/.config/tmux;
yadm add ~/.config/vim;
yadm add ~/.config/waybar;
yadm add ~/.config/wezterm;
yadm add ~/.config/wofi;
yadm add ~/.config/zsh;
yadm add ~/.config/wpaperd;
yadm add ~/.config/yadm;
yadm add ~/other-configs/*;

yadm commit -a -m "update";
yadm push
