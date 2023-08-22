#! /bin/bash

#  * * * * * /$HOME/src/dotfiles/aws/aws-stats-cron.sh
export PATH="/usr/local/bin/:$PATH"

#source "$HOME/.aws-aliases"
source "$HOME/src/dotfiles/aws/.aws-aliases"

instances=$(aws-instance-count-running)
workspaces=$(aws-workspace-count-running)

echo -e "instances $instances\nworkspaces $workspaces" > $HOME/.aws-stats
