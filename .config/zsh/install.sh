#!/bin/bash

echo "export ZDOTDIR=$HOME/.config/zsh" | sudo tee -a /etc/zsh/zshenv;
sh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.sh) &&
git clone https://github.com/Rishabh672003/zsh-configs ~/.config/zsh &&
sudo pacman -S exa zoxide fzf --noconfirm; yay -S pfetch;
exec zsh
