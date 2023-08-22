#!/bin/bash

# Define your unique identifier and cron job line
CRON_IDENTIFIER="#AWSSTATS"
CRON_JOB="* * * * * $HOME/src/dotfiles/aws/aws-stats-cron.sh $CRON_IDENTIFIER"

# Remove the old instance of the cron job, if it exists
(sudo crontab -u $USER -l 2>/dev/null | grep -v "$CRON_IDENTIFIER"; echo "$CRON_JOB" ) | sudo crontab -u $USER -

