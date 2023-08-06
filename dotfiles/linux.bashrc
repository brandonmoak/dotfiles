case $- in
    *i*) ;;
      *) return;;
esac

# EMBITE
source /home/brandon/.embite/source.sh
# EMBITE
source /home/brandon/.embite/source.sh

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
if [ -f ~/.rcfunctions ]; then
  source ~/.rcfunctions
fi

# aliases
if [ -f ~/.aliases ]; then
  source ~/.aliases
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

# random work related stuff
SUBNET="10.140"
export GBOXIP=$SUBNET".20.20"
export SBOXIP=$SUBNET".20.10"
export TBOXIP=$SUBNET".40.11"
export PACIFICIP=$SUBNET".40.205"

REMOTE_TRUCKS="trucks.lte.embark"
export TBOXREMOTEIP="101."$REMOTE_TRUCKS
export PACIFICREMOTEIP="201."$REMOTE_TRUCKS

alias sshsbox="ssh brandon@"$SBOXIP
alias sshtbox="ssh jar@"$TBOXIP
alias sshtboxremote="ssh jar@"$TBOXREMOTEIP
alias sshpacific="ssh embark@$PACIFICIP"
alias sshpacificremote="ssh jar@"$PACIFICREMOTEIP
alias sshgbox="ssh brandon@"$GBOXIP
alias mountsbox="sudo mount -t nfs $SBOXIP:/sbox /sbox"

alias ssh201="ssh jar@10.0.201.2"
alias ssh204="ssh jar@10.0.204.2"

# Remote jupyter on port 8889
alias jupyterhost="jupyter notebook --NotebookApp.token= --no-browser --port 8889"
alias jupytersbox="ssh -N -f -L localhost:8899:localhost:8889 brandon@$SBOXIP; google-chrome http://localhost:8899"
alias cdbrain="cd $HOME/workspace/catkin_ws/src/brain"
alias gboxuri="seturi $GBOXIP:11916"

source '/home/brandon/.embite/source.sh'

#export DQI_BASE_DIR="/sbox/data"
#export SBOXIP="10.142.20.10"
#alias mountsbox="sudo mount -t nfs $SBOXIP:/ /sbox"

export PATH="$PATH:$HOME/workspace/catkin_ws/src/brain/brain/scripts"
alias es="embite shell"
