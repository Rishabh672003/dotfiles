# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

autoload -U +X compinit && compinit
autoload -Uz zmv

#zap source
zapsource ~/.config/zsh/aliases.zsh
zapsource ~/.config/zsh/shell-varibales-and-commands.zsh
zapsource ~/.config/zsh/git.plugin.zsh
zapsource ~/projects/zsh-autoswitch-virtualenv/autoswitch_virtualenv.plugin.zsh
zapsource ~/.config/zsh/fzf-tab.zsh

# Example install plugins
zapplug "zap-zsh/supercharge"
zapplug "zsh-users/zsh-autosuggestions"
zapplug "zsh-users/zsh-syntax-highlighting"
zapplug "hlissner/zsh-autopair"
zapplug "zap-zsh/vim"
zapplug "Aloxaf/fzf-tab"
zapplug "zsh-users/zsh-completions"
zapplug "zsh-users/zsh-history-substring-search"

# Example theme
# zapplug "zap-zsh/zap-prompt"
zapplug "romkatv/powerlevel10k"

# Example install completion
zapcmp "esc/conda-zsh-completion" false

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
