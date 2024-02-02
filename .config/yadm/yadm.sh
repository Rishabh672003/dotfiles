#!/bin/env bash

yadm add ~/README.md \
	~/.config/alacritty \
	~/.config/bat \
	~/.config/btop \
	~/.config/contour \
	~/.config/dunst \
	~/.config/fish \
	~/.config/helix \
	~/.config/hypr \
	~/.config/kitty \
	~/.config/lvim \
	~/.config/mpv \
	~/.config/neofetch \
	~/.config/rofi \
	~/.config/shellfetch \
	~/.config/spicetify \
	~/.config/sway \
	~/.config/tmux \
	~/.config/vim \
	~/.config/waybar \
	~/.config/wezterm \
	~/.config/wofi \
	~/.config/wpaperd \
	~/.config/yadm \
	~/.config/zsh \
	~/other-stuff # ~/.config/nvim \

yadm commit -a -m "update" && yadm push
