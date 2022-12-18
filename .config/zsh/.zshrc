# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ⚡zap
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"
autoload -Uz plug

# all the good stuff
plug ~/.config/zsh/aliases.zsh
plug ~/.config/zsh/supercharge.zsh

# evals needed for apps
eval "$(zoxide init zsh)"

# Installing and sourcing all the plugins
# The order is important so dont change it if you dont know what you are doing
plug "zsh-users/zsh-autosuggestions"
plug "hlissner/zsh-autopair"
plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-history-substring-search"
plug "Aloxaf/fzf-tab"
plug "Freed-Wu/fzf-tab-source"
plug "zap-zsh/vim"
plug "Rishabh672003/zsh-autoswitch-virtualenv"

# theme
plug "romkatv/powerlevel10k"

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# get pfetch every time you open the terminal
pfetch

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/rishabh/.local/share/sdkman"
[[ -s "/home/rishabh/.local/share/sdkman/bin/sdkman-init.sh" ]]
