case $- in
    *i*) ;;
      *) return;;
esac

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

# aliases
if [ -f ~/.aws-aliases ]; then
  source ~/.aws-aliases
fi

# configure history (defined in ~/.rcfucntions)
setup_history

# configure window (defined in ~/.rcfucntions)
setup_window

# setup prompt (defined in ~/.rcfucntions)
setup_prompt

# git auto completion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# python 2.7.12
alias python2.7.12="/usr/local/lib/python2.7.12/bin/python"

# Remote jupyter on port 8889
alias jupyterhost="jupyter notebook --NotebookApp.token= --no-browser --port 8889"
alias jupytersbox="ssh -N -f -L localhost:8899:localhost:8889 brandon@$SBOXIP; google-chrome http://localhost:8899"

