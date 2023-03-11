#my aliases
alias c='clear'
alias e='exit'
alias :q='exit'
alias :wq='exit'
alias f='fastfetch'
alias m='mocp'
alias n='neofetch'
alias p='paru'
alias q='exit'
alias y='yay'
alias cd='z'
alias cf='clear;fastfetch'
alias cn='c && n'
alias cz='nvim ~/.config/zsh/.zshrc'
alias cat='bat -p'
alias cdd='zi'
alias cdp='cd ..'
alias cpc='clear;pfetch'
alias pf='pfetch'
alias cnp='c;n;p'
alias cny='c;n;y'
alias cdpp='cd ../../'
alias py='python'
alias cali='nvim ~/.config/zsh/aliases.zsh'
alias nr='sudo systemctl restart NetworkManager'
alias sp='speedtest'
alias yss='yay -S --noconfirm --needed'
alias ys='yay -Syu --noconfirm --devel'
alias pss='paru -Syu --noconfirm --devel'
alias tpg='topgrade'
alias one='onefetch'
alias rm='rm -v'
alias vs='sudoedit'
alias lg='lazygit'
alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'
alias nv='nvim'
alias nbi="NVIM_APPNAME=nvim-basic-ide nvim"
alias nvc='nvim --clean'
alias hx='helix'
alias lv='lvim'
alias shut='shutdown now'
alias rest='reboot'
alias rs='sudo systemctl start rate-mirrors'
alias rss='systemctl status rate-mirrors'
alias rsss='sh ~/projects/configs/mirrors-and-hosts/rate-mirrors-arch.sh'
alias hosts='sh ~/projects/hosts/hosts-maker.sh'
alias rest='reboot'
alias sys='system-monitoring-center'
alias shut='shutdown now'
alias sus='systemctl suspend'
alias ls='exa --color always --icons -a'
alias ll='exa --color always --icons -1albh -s name --git --sort date --group-directories-first'
alias lll='exa --color always --icons -1albhT -L 2 -s name -I .git --git --group-directories-first'
alias ws='waydroid show-full-ui'
alias wss='XDG_SESSION_TYPE=wayland waydroid show-full-ui'
alias we='waydroid session stop'
alias wr='sudo systemctl restart waydroid-container'
alias wl='sudo waydroid log'
alias install-grub='sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB'
alias update-grub=' sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias wtr='curl -4 https://wttr.in/virar'
alias gtnv='cd ~/Applications/ && \
    rm -rf ~/Applications/nvim-linux64 ~/Applications/nvim-linux64.tar.gz > /dev/null 2>&1 ; \
    curl --output-dir ~/Applications/ \
    -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz && \
    tar -xvf ~/Applications/nvim-linux64.tar.gz > /dev/null 2>&1'
alias nnv='~/Applications/nvim-linux64/bin/nvim'
alias ua-drop-caches='yay -Sc --aur --noconfirm'
alias ua-update-all='export TMPFILE="$(mktemp)"; \
    sudo true; \
    rate-mirrors --save=$TMPFILE arch --max-delay=21600 && \
    sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup && \
    sudo mv $TMPFILE /etc/pacman.d/mirrorlist && \
    ua-drop-caches && \
    yay -Syyu --noconfirm'
alias ngit='cp -r /home/rishabh/.config/nvim/* ~/projects/Neovim/ && \
    cd ~/projects/Neovim'
alias zshc='cp ~/.config/zsh/* ~/projects/zsh-configs/ ; \
    cd ~/projects/zsh-configs
# git add * && \
    # sh ~/git-repos/gc.sh && \
    # git push'
alias pgit='cp ~/python-study/* ~/projects/python-studies/ ; cd ~/projects/python-studies/'
alias sdr='sudo docker run -it archlinux:base-devel'
alias sdp='sudo docker system prune -a'
alias uneo='bob install nightly'
alias ngt='git clone https://github.com/rishabh672003/neovim ~/.config/nvim'
alias hyp='cp -r ~/.config/hypr ~/projects/hyprland-configs/ \
    cp -r ~/.config/waybar ~/projects/hyprland-configs/ \
    cd ~/projects/hyprland-configs/'
alias nrandom='tr -dc "A-Za-z 0-9" < /dev/urandom | fold -w100 | head -n 1000000 > bigfile.txt'
alias yl='sh ~/.config/yadm/yadm.sh'
alias yel='yadm enter lazygit'
alias yt="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'"
alias sep="pacman -Slq | fzf --multi --preview 'pacman -Si {1}' \
    | xargs -ro sudo pacman -S"
alias srp="pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' \
    | xargs -ro sudo pacman -Rns"
export ssep (){
    pacman -Slq | fzf --multi --preview 'cat <(pacman -Si {1}) <(pacman -Fl {1} | awk "{print \$2}")' | xargs -ro sudo pacman -S
}
alias ssep=ssep
