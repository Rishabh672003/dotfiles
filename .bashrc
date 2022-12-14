#!/bin/bash
eval "$(zoxide init bash)"

# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias m='mocp'
alias cpc='clear;pfetch'
alias py='python'
alias cali='nvim ~/.config/zsh/aliases.zsh'
alias nr='sudo systemctl restart NetworkManager'
alias sp='speedtest'
alias y='yay'
alias yss='yay -S --noconfirm --needed'
alias ys='yay -Syu --noconfirm --devel'
alias pss='paru -Syu --noconfirm --devel'
alias p='paru'
alias tpg='topgrade'
alias n='neofetch'
alias f='fastfetch'
alias one='onefetch'
alias c='clear'
alias cd='z'
alias cdd='zi'
alias cdp='cd ..'
alias cdpp='cd ../../'
alias cz='nvim ~/.config/zsh/.zshrc'
alias e='exit'
alias q='exit'
alias vs='sudoedit'
alias lg='lazygit'
alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'
alias nv='nvim'
alias nvc='nvim --clean'
alias nnvim='~/Applications/nvim.appimage'
alias hx='helix'
alias lv='lvim'
alias cat='bat -p'
alias cn='c && n'
alias cnp='c;n;p'
alias cny='c;n;y'
alias cf='clear;fastfetch'
alias shut='shutdown now'
alias rest='reboot'
alias log='gnome-session-quit'
alias rs='sudo systemctl start rate-mirrors'
alias rss='systemctl status rate-mirrors'
alias rsss='sh ~/projects/configs/mirrors-and-hosts/rate-mirrors-arch.sh'
alias hosts='sh ~/projects/hosts/hosts-maker.sh'
alias rest='reboot'
alias sys='system-monitoring-center'
alias shut='shutdown now'
alias sus='systemctl suspend'
alias ls='exa --color always --icons -a'
alias ll='exa --color always --icons -1albh -s name --git'
alias lll='exa --color always --icons -1albhT -L 2 -s name -I .git --git'
alias ws='waydroid show-full-ui'
alias wss='XDG_SESSION_TYPE=wayland waydroid show-full-ui'
alias we='waydroid session stop'
alias wr='sudo systemctl restart waydroid-container'
alias wl='sudo waydroid log'
alias grub-update=' sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias wtr='curl -4 https://wttr.in/virar'
alias gtnv='curl --output-dir ~/Applications/ \
    -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage'
alias ua-drop-caches='yay -Sc --aur --noconfirm'
alias ua-update-all='export TMPFILE="$(mktemp)"; \
    sudo true; \
    rate-mirrors --save=$TMPFILE arch --max-delay=21600 && \
    sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup && \
    sudo mv $TMPFILE /etc/pacman.d/mirrorlist && \
    ua-drop-caches && \
    yay -Syyu --noconfirm'
alias ngit='cp -r /home/rishabh/.config/nvim/* ~/projects/Neovim/ && \
    cp ~/projects/init.lua ~/projects/Neovim/init.lua && \
    cd ~/projects/Neovim'
alias zshc='cp ~/.config/zsh/* ~/projects/zsh-configs/ ; \
    cd ~/projects/zsh-configs'
alias pgit='cp ~/python-study/* ~/projects/python-studies/ ; cd ~/projects/python-studies/'
alias sdr='sudo docker run -it archlinux:base-devel'
alias sdp='sudo docker system prune -a'
alias uneo='sudo true && cd /home/rishabh/projects/random-repos/neovim/ && git pull && sudo make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install'
alias ngt='git clone https://github.com/rishabh672003/neovim ~/.config/nvim'
alias hyp='cp -r ~/.config/hypr ~/projects/hyprland-configs/ \
    cp -r ~/.config/waybar ~/projects/hyprland-configs/ \
    cd ~/projects/hyprland-configs/'
alias nrandom='tr -dc "A-Za-z 0-9" < /dev/urandom | fold -w100 | head -n 19999 > bigfile.txt'
alias yl='sh ~/.config/yadm/yadm.sh'
alias yel='yadm enter lazygit' 

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
