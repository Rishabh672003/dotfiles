# dotfiles
all of my dotfiles,
these are managed by a software called [yadm](https://github.com/TheLocehiliosan/yadm) and my wallpapers are in ~/.config/hypr/wallpaper

# Showcase
![showcase](https://i.imgur.com/tqBKBnn.png) 

# Apply the configs

### install yadm 

```sh
sudo pacman -Sy yadm
```

#### clone the repo with yadm

```
yadm clone https://github.com/Rishabh672003/dotfiles
```
and remove packer_compiled binaries
```
rm -rf ~/.config/nvim/plugin/packer_compiled.lua ~/.config/lvim/plugin/packer_compiled.lua
```

