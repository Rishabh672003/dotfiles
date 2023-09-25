#!/bin/bash

# Set the ZSH configuration directory variable.
ZSH_CONFIG_DIR=$HOME/.config/zsh

# Set the ZSH configs repository URL variable.
ZSH_CONFIGS_REPO=https://github.com/Rishabh672003/zsh-configs

# Install the required dependencies.
install_dependencies() {
    sudo pacman -S exa zoxide fzf --noconfirm --needed ||
    yay -S pfetch-rs-bin --noconfirm --needed;
}
install_dependencies

# Check for errors.
if ! install_dependencies; then
    echo "Failed to install dependencies."
    exit 1
fi

# Export the ZSH configuration directory variable.
echo "export ZDOTDIR=$ZSH_CONFIG_DIR" | sudo tee -a /etc/zsh/zshenv

# Install the Zap Zsh plugin and clone the repo
sh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.sh) &&
git clone $ZSH_CONFIGS_REPO "$ZSH_CONFIG_DIR"

# Start Zsh.
exec zsh
