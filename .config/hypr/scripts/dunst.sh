#!/bin/bash

# Function to send a notification
function send_notification {
	local message=$1
	dunstify "Dunst Status" "$message"
}

# Get the current paused state of Dunst
current_state=$(dunstctl is-paused | awk '{print $NF}')

# Compare the current and new paused states
if [[ "$current_state" == "false" ]]; then
	# The paused state has changed, send a notification
	send_notification "Dunst is now paused."
    sleep 2
else
	send_notification "Dunst is now unpaused."
fi

dunstctl set-paused toggle
