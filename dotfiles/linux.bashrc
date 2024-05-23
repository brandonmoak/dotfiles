case $- in
    *i*) ;;
      *) return;;
esac


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# If not running interactively, don't do anything
# get the functions to setup bashrc
if [ -f $SCRIPT_DIR/.rcfunctions ]; then
  source $SCRIPT_DIR/.rcfunctions
fi

# aliases
if [ -f $SCRIPT_DIR/.aliases ]; then
  source $SCRIPT_DIR/.aliases
fi

# configure history (defined in ~/.rcfucntions)
setup_history

# configure window (defined in ~/.rcfucntions)
setup_window

# setup prompt (defined in ~/.rcfucntions)
setup_prompt

# load ros (defined in ~/.rcfucntions)
# load_ros

# load utilities for dropbox bag uploading (defined in ~/.rcfunctions)
load_dropbox_bag_utils ~/.dropbox-ln

# load encfs + dropbox utilities (defined in ~/.rcfucntions)
load_encfs_utils ~/.unlockrc

# git auto completion
source /usr/share/bash-completion/completions/git

# python 2.7.12
alias python2.7.12="/usr/local/lib/python2.7.12/bin/python"

# Remote jupyter on port 8889
alias jupyterhost="jupyter notebook --NotebookApp.token= --no-browser --port 8889"
alias jupytersbox="ssh -N -f -L localhost:8899:localhost:8889 brandon@$SBOXIP; google-chrome http://localhost:8899"

