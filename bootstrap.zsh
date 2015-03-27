#!/usr/bin/env zsh

# Script for installing or updating the dotfiles
# Requirements: zsh, wget, git, vim, rsync


# Get the path of the script, usually: ~/.dotfiles/bootstrap.zsh
pushd $(dirname $0) >/dev/null
script_path=$(pwd -P)
popd >/dev/null


function installVimSettings() {
    echo "Installing vim settings\n"

    echo -n "Installing vim plugins... "

    # Install vundle plugin manager (if not installed already)
    local vundle_dir="${HOME}/.vim/bundle/vundle"
    if [ ! -d "${vundle_dir}" ]; then
        local vundle_repository="https://github.com/gmarik/vundle.git"
        git clone -q "${vundle_repository}" "${vundle_dir}"
    fi

    # Install the plugins
    vim -c "BundleInstall" -c "qa"

    echo "✔"
}

function doIt() {
    cd "${script_path}"

    echo -n "Updating dotfiles... "

    # Get the latest version of the repository
    git pull origin master

    if [[ ! $? -eq 0 ]]; then echo "✗"
    else echo "✔"
    fi

    # Copy all files to the home directory
    echo -n "Syncing files... "

    rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.zsh" \
        --exclude "README.md" -avq --no-perms . ${HOME}

    if [[ ! $? -eq 0 ]]; then echo "✗"
    else echo "✔"
    fi

    # Install vundle and vim plugins, if not installed already
    local vim_plugins_count=$(ls -1 "${HOME}/.vim/bundle" | wc -l | tr -d " ")
    if [[ ${vim_plugins_count} == "0" ]]; then
        installVimSettings
    fi
    
    # Setup Prezto
    setopt EXTENDED_GLOB
    for rcfile in "${$HOME}"/.zprezto/runcoms/^README.md(.N); do
      ln -s "$rcfile" "${$HOME}/.${rcfile:t}"
    done
    
    chsh -s /bin/zsh
    
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
