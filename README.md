<center>

# Dotfiles

![image](https://user-images.githubusercontent.com/53911515/235317064-720dd2e0-cfa3-43b8-b773-34350b4dd357.png)

</center>

All of my dotfiles, these are managed by [yadm](https://github.com/TheLocehiliosan/yadm) At first this repo contained my wallpapers also but that would just make it very big in size so now they are in a different repo and they are at https://github.com/Rishabh672003/Wallpapers

# Apply the configs

### install yadm

```sh
sudo pacman -Sy yadm
```

#### I would say fork this repo and then install it using yadm here the way you do it so just change the github link to your fork

```
yadm clone https://github.com/Rishabh672003/dotfiles
```

#### Explanation of yadm

let me explain how yadm works because i couldn't figure it out for the first few

days that I used it
what yadm does is use your home directory as a git repo but doesnt adds anything to the git repo where the .git directory stays is in `~/.local/share/yadm/repo.git/`

#### Get started

Easiest way to get started is make a bare git repo in github or gitlab and do a
`yadm clone "link of your repo"`
that will clone the repo in the repo. git that I mentioned above
aftet that using yadm is just like using git you can do any git command with yadm like `yadm add` or `yadm clone` and all
so just add the dotfiles you need to save by doing `yadm add "path of file"`
than commit by using `yadm commit -am "your message"` and push by using `yadm push`
one extra yadm command which i recommend you learn is `yadm enter` using that will put you in a shell where you can just manipulate the yadm repo by just using git commands and you can also use apps like lazygit for the dotfiles repo which you can't do by default
