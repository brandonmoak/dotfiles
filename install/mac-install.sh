#! /bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cp -i $SCRIPT_DIR/../dotfiles/.vimrc $HOME/.vimrc
cp -i $SCRIPT_DIR/../dotfiles/.tmux.conf $HOME/.tmux.conf
cp -i $SCRIPT_DIR/../dotfiles/mac.bashrc  $HOME/.bashrc
cp -i $SCRIPT_DIR/../dotfiles/.rcfunctions $HOME/.rcfunctions
cp -i $SCRIPT_DIR/../dotfiles/.aliases $HOME/.aliases


