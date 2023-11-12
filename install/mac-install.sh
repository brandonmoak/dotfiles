#! /bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cp -i $SCRIPT_DIR/../dotfiles/.vimrc $HOME/.vimrc
cp -i $SCRIPT_DIR/../dotfiles/.tmux.conf $HOME/.tmux.conf

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "source $SCRIPT_DIR/../dotfiles/mac.bashrc" >> ~/.bashrc


