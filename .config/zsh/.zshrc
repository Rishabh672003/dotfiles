# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

#evals needed for apps
eval "$(zoxide init zsh)"
pfetch
autoload -U +X compinit && compinit
autoload -Uz zmv
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
SAVEHIST=1000000000

# Example install plugins
zapplug "zap-zsh/supercharge"
zapplug "zsh-users/zsh-autosuggestions"
zapplug "zsh-users/zsh-syntax-highlighting"
zapplug "hlissner/zsh-autopair"
zapplug "zap-zsh/vim"
zapplug "Aloxaf/fzf-tab"
zapplug "zsh-users/zsh-completions"
zapplug "zsh-users/zsh-history-substring-search"

#zap source
zapsource ~/.config/zsh/aliases.zsh
zapsource ~/.config/zsh/shell-varibales-and-commands.zsh
zapsource ~/.config/zsh/git.plugin.zsh
zapsource ~/projects/zsh-autoswitch-virtualenv/autoswitch_virtualenv.plugin.zsh
zapsource ~/.config/zsh/fzf-tab.zsh
zapsource ~/.local/share/zap/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

fpath=(~/.local/share/zap/plugins/zsh-completions/src $fpath)

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Example theme
# zapplug "zap-zsh/zap-prompt"
zapplug "romkatv/powerlevel10k"

# Example install completion
# zapcmp "esc/conda-zsh-completion" false

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
