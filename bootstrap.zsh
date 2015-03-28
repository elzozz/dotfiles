#!/usr/bin/env zsh

# Script for installing or updating the dotfiles
# Requirements: zsh, wget, git, vim, rsync


# Get the path of the script, usually: ~/.dotfiles/bootstrap.zsh
pushd $(dirname $0) >/dev/null
script_path=$(pwd -P)
popd >/dev/null

# Path of the Oh-my-zsh repo
if [ ! -n "${ZSH}" ]; then
    ZSH="${ZDOTDIR:-$HOME}/.zprezto"
fi


function installPrezto() {

    echo -n "Installing Prezto... "

    # Clone the Prezto git repo
    local prezto_repo="https://github.com/sorin-ionescu/prezto.git"
    hash git >/dev/null && /usr/bin/env git clone --recursive "${prezto_repo}" "${ZSH}" || {
        echo "✗"
        echo "Git not installed"
        exit 1
    }
    echo "✔"
   
    # Setup Prezto
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
       ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done
   
    chsh -s /bin/zsh
       
    if [[ ! $? -eq 0 ]]; then echo "✗"
    else echo "✔"
    fi
}

function doIt() {
    cd "${script_path}"

    echo -n "Updating dotfiles... "

    # Get the latest version of the repository
    git pull origin master

    if [[ ! $? -eq 0 ]]; then echo "✗"
    else echo "✔"
    fi
    
    # Install Oh-my-zsh, if not installed already
    if [ ! -d "${ZSH}" ]; then
        installPrezto
    fi
    
    # Copy all files to the home directory
    echo -n "Syncing files... "

    rsync --exclude ".git/" --exclude "fonts/" --exclude ".DS_Store" --exclude ".gitmodules" \
        --exclude "bootstrap.zsh" --exclude "README.md" --exclude "brew.sh" --exclude ".osx" --exclude "brew-cask.sh" \
        --exclude "setup-new-mac.sh" -avq --no-perms . ${ZDOTDIR:-$HOME}

    if [[ ! $? -eq 0 ]]; then echo "✗"
    else echo "✔"
    fi

   
}


# Show a warning message, before the installation
if [[ "$1" == "--force" || "$1" == "-f" ]]; then
    doIt
else
    echo -n "This may overwrite existing files in your home directory." \
        "Are you sure? (y/N) "

    read -q
    local answer=$?

    echo

    if [[ ${answer} -eq 0 ]]; then
        doIt
    fi
fi
unset script_path
