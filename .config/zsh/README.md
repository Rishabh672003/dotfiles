# my zsh-configs

made with ⚡[zap](https://github.com/zap-zsh-zap) very minimal and has all the stuff you would require for a great shell.

## showcase

![image](https://user-images.githubusercontent.com/53911515/201460548-1957f0e5-bede-4f97-b72b-6ddd64c287cb.png)
![image](https://user-images.githubusercontent.com/53911515/201460573-e4bbc0ce-566b-4225-abd7-9aad08ebd266.png)
![image](https://user-images.githubusercontent.com/53911515/202460011-d781dcf9-5fb9-4ddc-b2ec-733d2cddc5e0.png)

## startup-time

i have tried to worked on the startup time and it varies around 200ms to 400ms. If you know how to reduce it please open a pr, i would very much appreciate it

![image](https://user-images.githubusercontent.com/53911515/202460120-4e80a636-6e1e-45ac-a094-7d6deb910ccc.png)

## Installation

```bash
sh <(curl -s https://raw.githubusercontent.com/Rishabh672003/zsh-configs/main/install.sh)
```

### Dependencies
```bash
sudo pacman -S zsh fzf exa zoxide zsh-completions bat chafa exiftool --needed --noconfirm 
```

## Uninstallation

```bash
rm -rf $HOME/.local/share/zap $HOME/.config/zsh $HOME/.cache/zsh
```
