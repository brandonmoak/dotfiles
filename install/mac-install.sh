#! /bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cp -i $SCRIPT_DIR/../dotfiles/.vimrc $HOME/.vimrc
cp -i $SCRIPT_DIR/../dotfiles/.tmux.conf $HOME/.tmux.conf

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "source $SCRIPT_DIR/../dotfiles/mac.bashrc" >> ~/.bashrc

# load the rcfunctions
ls $SCRIPT_DIR/../dotfiles/.rcfunctions
source $SCRIPT_DIR/../dotfiles/.rcfunctions

# add an include in the gitconfig
add_gitconfig_include $SCRIPT_DIR/../dotfiles/.gitconfig


