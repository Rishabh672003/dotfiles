alias :q='exit'
alias :wq='exit'
alias adb='HOME="$XDG_DATA_HOME"/android adb'
alias c='clear'
alias cali='nvim ~/.config/zsh/aliases.zsh'
alias cat='bat -p'
alias cd='z'
alias cdd='zi'
alias cdp='cd ..'
alias cdpp='cd ../../'
alias cf='clear;fastfetch'
alias cn='c && n'
alias cnp='c;n;p'
alias cny='c;n;y'
alias cpc='clear;pfetch'
alias cz='nvim ~/.config/zsh/.zshrc'
alias e='exit'
alias f='fastfetch'
alias gmi='go mod init $(printf '%s\n' "${PWD##*/}")'
alias grep='grep -n --color'
alias hosts='sh ~/projects/hosts/hosts-maker.sh'
alias hx='helix'
alias install-grub='sudo grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=GRUB'
alias jn="jupyter notebook --no-browser ."
alias lg='lazygit'
alias ll='exa --color always --icons -1albh -s name --git --sort date --group-directories-first'
alias lll='exa --color always --icons -1albhT -L 2 -s name -I .git --git --group-directories-first'
alias llll='exa --color always --icons -1albhT -L 3 -s name -I .git --git --group-directories-first'
alias ls='exa --color always --icons -a'
alias lv='lvim'
alias m='mocp'
alias mkdir='mkdir -p'
alias mpv='mpv --screenshot-directory=/home/rishabh/Pictures/mpv-ss'
alias n='neofetch'
alias nbi='NVIM_APPNAME=nvim-basic-ide nvim'
alias ngt='git clone https://github.com/rishabh672003/neovim ~/.config/nvim'
alias nnv='~/Applications/nvim-linux64/bin/nvim'
alias nr='sudo systemctl restart NetworkManager'
alias nrandom='tr -dc "A-Za-z 0-9" < /dev/urandom | fold -w100 | head -n 1000000 > bigfile.txt'
alias nro='NVIM_APPNAME=nvim-rocks nvim'
alias nv='nvim'
alias nvc='nvim --clean'
alias one='onefetch'
alias p='paru'
alias pf='pfetch'
alias q='exit'
alias rest='reboot'
alias rm='trash'
alias rmbin="rm -rf *.out; rm -rf */*.out; rm -rf */*/*.out; rm -rf */*/*/*.out"
alias rs='sudo systemctl start rate-mirrors'
alias rss='systemctl status rate-mirrors'
alias rsss='sh ~/other-stuff/mirrors-and-hosts/rate-mirrors-arch.sh'
alias sdp='sudo docker system prune -a'
alias sdr='sudo docker run -it archlinux:base-devel'
alias shut='shutdown now'
alias shut='shutdown now'
alias sp='speedtest'
alias sus='systemctl suspend'
alias sys='system-monitoring-center'
alias ta='tmux attach'
alias td='tmux detach'
alias tpg='topgrade'
alias tree='exa --tree'
alias uneo='bob install nightly'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias v='nvim'
alias vs='sudoedit'
alias we='waydroid session stop'
alias wf='we && sudo systemctl stop docker && sudo systemctl restart iptables && wr'
alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'
alias wl='sudo waydroid log'
alias wr='sudo systemctl restart waydroid-container'
alias ws='waydroid show-full-ui'
alias wss='XDG_SESSION_TYPE=wayland waydroid show-full-ui'
alias wtr='curl -4 https://wttr.in/virar'
alias xo='xdg-open'
alias y='yay'
alias yel='yadm enter lazygit'
alias yl='sh ~/.config/yadm/yadm.sh'
alias ys='yay -Syu --noconfirm --devel'
alias yss='yay -S --noconfirm --needed'
alias yt="yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'"

alias ua-drop-caches='yay -Sc --aur --noconfirm'
alias ua-update-all='export TMPFILE="$(mktemp)"; \
    sudo true; \
    rate-mirrors --save=$TMPFILE arch --max-delay=21600 && \
    sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup && \
    sudo mv $TMPFILE /etc/pacman.d/mirrorlist && \
    ua-drop-caches && \
    yay -Syyu --noconfirm'
alias sep="pacman -Slq | fzf --multi --preview 'pacman -Si {1}' \
    | xargs -ro sudo pacman -S"
alias srp="pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' \
    | xargs -ro sudo pacman -Rns"


function convert_video(){
    local input_file="$1"
    local output_file="wa-${input_file}"
    ffmpeg -i "$input_file" -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p "$output_file"
}

function gpgkey() {
    gpg --output "$1.sig" \
        --default-key 86D63A086746385BAE60E505421FFABA41F36DA5 \
        --detach-sign \
        --sign "$1"
}

function makesign(){
    ./cleanup.sh && makepkg -s && gpgkey *.tar.zst
}

function ssep (){
    pacman -Slq | fzf --multi --preview 'cat <(pacman -Si {1}) <(pacman -Fl {1} | awk "{print \$2}")' | xargs -ro sudo pacman -S
}
