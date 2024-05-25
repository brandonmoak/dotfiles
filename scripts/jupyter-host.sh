#!/bin/bash

# Directory containing virtual environments
VENV_DIR="$HOME/src/virtualenvs"

# Find potential virtual environments in the specified directory
venvs=($(find "$VENV_DIR" -mindepth 1 -maxdepth 1 -type d))

# Check if any environments were found
if [ ${#venvs[@]} -eq 0 ]; then
    echo "No virtual environments found in $VENV_DIR."
    exit 1
fi

# Function to select and activate a virtual environment
select_venv() {
    echo "Available virtual environments:"
    PS3="Select a virtual environment to activate: " # Custom prompt for select
    select venv in "${venvs[@]}"; do
        if [ -n "$venv" ]; then
            echo "Activating virtual environment in $venv"
            source "$venv/bin/activate"
            venv_base=$(basename "$venv")
            echo "vevb: $venv_base"
            python -m ipykernel install --user --name $venv_base --display-name "Python ($venv_base)"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

# Prompt for the port
read -p "Enter the port for Jupyter notebook: " port
# Check if the port is a valid number
if ! [[ "$port" =~ ^[0-9]+$ ]]; then
  echo "Error: Port must be a number."
  exit 1
fi

# Call the function to select and activate the virtual environment
select_venv

# Start a new detached tmux session to run the Jupyter notebook, including the port in the session name
session_name="jupyter_notebook_$port"
tmux new-session -d -s "$session_name"

# Send commands to the tmux session to start Jupyter
tmux send-keys -t "$session_name" "which python"
tmux send-keys -t "$session_name" "echo 'Starting Jupyter notebook on port ${port}...'" C-m
tmux send-keys -t "$session_name" "jupyter notebook --port=${port} --no-browser" C-m

echo "Jupyter notebook server started in tmux session '$session_name'."
echo "You can attach to the session with 'tmux attach -t $session_name'."
echo "To detach again, press 'Ctrl-b d'."
