#!/bin/zsh
#
# Ubuntu 14.04 LTS server base install script
# 
# Version: 1.0
# Author: Lukacs Zoltan
# Date: 2016.04.01
# 
# Descritpion: Install and configure base system with tools I use often
# Tmux 2.1, tmux.conf, vim, vimrc, mc, git, powerlinecolor,
#
# ----------------------------------------------------------------------

#
# --- Variables
# 
APT=$(which apt-get)
ZSH=$(which zsh)
GIT=$(which git)
WGET=$(which wget)
TAR=$(which tar)
PIP=$(which pip)
LN=$(which ln)
# -----------------------------------------------------------------------

#
# --- Functions
#

# Check if we are root
function check_root(){
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi
}

# check if ZSH is installed
function check_zsh(){
    IS_ZSH=$(echo $ZSH_NAME)
    echo 'Check if we are in ZSH shell'
    if [ $IS_ZSH != "zsh" ]; then
        echo 'Not in ZSH shell! Please switch to ZSH shell or install it!'
        exit 1
    fi
}

# Download fresh repository
function apt_fresh(){
    echo "Downloading fresh repository"
    $APT update || { echo 'Update Failed!' ; exit 1; }
    $APT upgrade || { echo 'Upgrade Failed!' ; exit 1; }
    }

# Install basic tools
function install_basic(){
    $APT install -y build-essential libevent-dev libncurses5-dev mc zsh git vim || { echo 'Install Failed!' ; exit 1; }
}

# Install Zprezto ZSH Framework
function install_zprezto(){
   # Clone Zprezto repo
    $GIT clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

    # Create a new Zsh configuration by copying the Zsh configuration files provided:
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
        ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done
    mv $HOME/.zpreztorc $HOME/.zpreztorc_original
    $LN -sf $HOME/.dotfiles/zpreztorc $HOME/.zpreztorc || exit 1;
    #    $CHSH -s "$ZSH"
}

# Install tmux 2.1 from source
function install_tmux21(){
    cd /opt || exit
    $WGET https://github.com/tmux/tmux/releases/download/2.1/tmux-2.1.tar.gz
    $TAR -xvf tmux-2.1.tar.gz
    cd /opt/tmux-2.1 || exit
    ./configure || { echo 'Configure failed! Check requirements!' ; exit 1; }
    make || { echo 'Make Failed!' ; exit 1; }
    make install || exit
}

# Install powerline status
function install_powerline(){
    $APT install python-pip || exit 1;
    $PIP install powerline-status || exit 1;
}

# Clone tmux.conf from gitlab repo
function install_tmux_conf(){
    cd $HOME || exit 1;
    $GIT clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    $LN -s .dotfiles/tmux.conf $HOME/.tmux.conf || exit 1;
}

# Clone .vimrc file and plugins
function install_vimrc_conf(){
    cd $HOME/.dotfiles || exit 1;
    make install
    $LN -s .dotfiles/vimrc $HOME/.vimrc || exit 1;
}

# ---------------------------------------------------------------------------------------

#
# --- Main program execution
#
check_root
set -e
check_zsh
set +e
apt_fresh
install_basic
install_zprezto
install_tmux21
install_powerline
install_tmux_conf
install_vimrc_conf

echo 'Installation finished!'
echo 'For tmux, start tmux then C-a + I to install tmux plugins!'
echo 'You should logout/login'
