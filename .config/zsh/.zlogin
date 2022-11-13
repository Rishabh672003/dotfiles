
# <https://github.com/zimfw/zimfw/blob/master/login_init.zsh>
setopt LOCAL_OPTIONS EXTENDED_GLOB
autoload -U zrecompile
# local ZSHCONFIG=~/.zsh-config

# Compile zcompdump, if modified, to increase startup speed.
zcompdump="${XDG_CACHE_HOME/zsh}/.zcompdump"
if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zrecompile -pq "$zcompdump"
fi
zcompile .zshrc
zrecompile -pq ${XDG_CACHE_HOME/zsh}/.zshrc
zrecompile -pq ${XDG_CACHE_HOME/zsh}/.zprofile
zrecompile -pq ${XDG_CACHE_HOME/zsh}.zshenv
# recompile all zsh or sh
# for f in $ZSHCONFIG/**/*.*sh
# do
#     zrecompile -pq $f
# done
