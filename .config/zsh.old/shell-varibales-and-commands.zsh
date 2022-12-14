# my commands
# neofetch
# fastfetch
# clear
pfetch

#evals needed for apps
eval "$(zoxide init zsh)"

#shell variables
export XDG_CURRENT_DESKTOP="Wayland"
export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH
export ZDOTDIR="$HOME"/.config/zsh
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache
export _Z_DATA="$XDG_DATA_HOME/z"
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GOPATH="$XDG_DATA_HOME"/go
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo
export HISTFILE="${XDG_STATE_HOME}"/zsh/history
export HISTCONTROL=ignoredups:erasedups
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export XDG_SESSION_TYPE=wayland
export GDK_BACKEND=wayland
export XDG_PICTURES_DIR="$HOME"/Pictures
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export ANDROID_HOME="$XDG_DATA_HOME"/android
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export XCURSOR_PATH=/usr/share/icons:${XDG_DATA_HOME}/icons
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
