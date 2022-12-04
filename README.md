# dotfiles

all of my dotfiles,
these are managed by a software called [yadm](https://github.com/TheLocehiliosan/yadm) and my wallpapers are in ~/.config/hypr/wallpaper

# Showcase

![image](https://user-images.githubusercontent.com/53911515/205472813-86d27f48-65fa-4381-a77e-fedb7ec1ee1c.png)

# Apply the configs

### install yadm

```sh
sudo pacman -Sy yadm
```

#### i would say fork this repo and then install it using yadm here the way you do it so just change the github link to your fork

```
yadm clone https://github.com/Rishabh672003/dotfiles
```

#### Explaination of yadm

let me explain how yadm works because i couldnt figure it out for the first few
days that i used it
what yadm does is use your home directory as a git repo but doesnt adds anything to the git repo where the .git directory stays is in `~/.local/share/yadm/repo.git/`
#### Get started

easiest way to get started is make a bare git repo in github or gitlab and do a
`yadm clone "link of your repo"`
that will clone the repo in the repo.git that i mentioned above
aftet that using yadm is just like using git you can do any git command with yadm like `yadm add` or `yadm clone` and all 
so just add the dotfiles you need to save by doing `yadm add "path of file"`
than commit by using `yadm commit -am "your message"` and push by using `yadm push`
one extra yadm command which i recommend you learn is `yadm enter` using that will put you in a shell where you can just manipulate the yadm repo by just using git commands and you can also use apps like lazygit for the dotfiles repo which you cant do by default
