#!/bin/bash
KEY="tunaws.pem"
CLOUDHOST="13.50.210.14"
USER="ubuntu"
#KEY=tunaws.pem
#CLOUDHOST="34.118.38.72"
#USER="tunkey"
REMOTE_PORT="14550"
LOCPORT="14550"
SSH_COMMAND="ssh -N -i ~/.ssh/$KEY -o ServerAliveCountMax=2 -o ServerAliveInterval=15 -R $REMOTE_PORT:localhost:$LOCPORT $USER@$CLOUDHOST"







function ssh_remote_connect {
    while true; do
	current_time=$(date +"%T")
	echo "$current_time"
        # Check if the port is open on the remote server
        #nc -z -w 1 $CLOUDHOST $REMOTE_PORT
        ncat --sh-exec "echo >/dev/null" -w 1 $CLOUDHOST $REMOTE_PORT
        local exit_status=$?
	echo "status [$exit_status]"
        #if [ $exit_status -eq 0 ] || [ $exit_status -eq 1 ]; then
        if [ $exit_status -eq 0 ]; then
            echo "Port $CLOUDHOST:$REMOTE_PORT is open. SSH tunnel is active."
        else
            echo "Port $CLOUDHOST:$REMOTE_PORT is closed. Reconnecting...$SSH_COMMAND"
            $SSH_COMMAND &
        fi

        # Sleep for a few seconds before the next check
        sleep 10
    done
}

# Function to handle SSH errors
function handle_ssh_error {
    echo "SSH connection failed. Reconnecting..."
    # Attempt to re-establish the SSH connection in the background
	$SSH_COMMAND &
}

# Set up a trap to handle SSH errors
trap handle_ssh_error ERR

ssh_remote_connect

