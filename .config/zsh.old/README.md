# zsh-configs

my zsh configs

I use zsh4humans so to install it run this command

```bash
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
fi
```

and to apply the configs run this command

```bash
git clone https://github.com/Rishabh672003/zsh-configs && cd zsh-configs && mkdir -p $HOME/.config/zsh ; cp * $HOME/.config/zsh/
```
