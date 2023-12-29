# Function to select or use a given Neovim profile
nvims() {
    local profile=$1

    # Check if the provided profile exists
    if [[ -n "$profile" && -d ~/.config/nvim-profiles/"$profile" ]]; then
        local args=("${@:2}")
    else
        # Use fzf to allow the user to select a profile
        profile=$(\ls ~/.config/nvim-profiles/ | fzf --prompt=" Neovim Profile: " --height=~50% --layout=reverse --exit-0)
        if [[ -z "$profile" ]]; then
            return 1
        fi
    fi

    local appname=nvim-profiles/$profile
    if [[ ! -d ~/.config/"$appname" ]]; then
        echo "Profile $profile does not exist."
        echo "Use nvims_install to install a new profile."
        return 1
    fi

    export NVIM_APPNAME=$appname
    nvim $args
}

nvims_tmp() {
    if [[ -L ~/.config/nvim-profiles/tmp ]]; then
        rm ~/.config/nvim-profiles/tmp
    fi
    ln -s $(realpath .) ~/.config/nvim-profiles/tmp
    nvims tmp
}

# Autocomplete profiles for the nvims function
compctl -g '~/.config/nvim-profiles/*(:t)' nvims

# Function to install a new Neovim profile from a given Git URL
nvims_install() {
    local url=$1
    local profile=$2
    if [[ -z "$profile" || -z "$url" ]]; then
        echo "Usage: nvim_profile_install <url> <profile>"
        return 1
    fi

    local dest=~/.config/nvim-profiles/$profile
    if [[ -d $dest ]]; then
        echo "Profile $profile already exists"
        return 1
    fi

    git clone $url.git $dest
    nvims $profile
}
