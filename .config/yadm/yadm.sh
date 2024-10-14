#!/bin/env bash

yadm add ~/README.md \
	~/.config/alacritty \
	~/.config/bat \
	~/.config/btop \
	~/.config/contour \
	~/.config/dunst \
	~/.config/fish \
	~/.config/hypr \
	~/.config/kitty \
	~/.config/lvim \
	~/.config/mpv \
	~/.config/neofetch \
	~/.config/rofi \
	~/.config/shellfetch \
	~/.config/sway \
	~/.config/tmux \
	~/.config/vim \
	~/.config/waybar \
	~/.config/wezterm \
	~/.config/wofi \
	~/.config/wpaperd \
	~/.config/yadm \
	~/.config/zsh \
	~/.config/ghostty \
	~/other-stuff # ~/.config/nvim \

yadm commit -a -m "update" && yadm push
