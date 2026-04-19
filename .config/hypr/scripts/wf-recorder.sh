#!/usr/bin/env bash

RECORDER="wf-recorder"
PID_FILE="/tmp/wf-recorder.pid"

# Check if wf-recorder is already running from our PID file
if [[ -f "$PID_FILE" ]]; then
    read -r pid <"$PID_FILE"
    if kill -0 "$pid" 2>/dev/null; then
        notify-send "Screen Recorder" "Stopping recording..." -t 3000
        pkill --signal SIGINT "$RECORDER"
        rm "$PID_FILE"
        exit 0
    else
        notify-send "Screen Recorder" "Removing stale PID file" -t 2000
        rm "$PID_FILE"
    fi
fi

notify-send "Screen Recorder" "Select area to record" -t 300
GEOMETRY=$(slurp -f "%x,%y %wx%h")

if [[ -z "$GEOMETRY" ]]; then
    notify-send "Screen Recorder" "Selection cancelled" -t 2000
    exit 1
fi

OUTPUT_FILE="$HOME/Screencasts/recording_$(date +'%Y-%m-%d-%H%M%S').mp4"
mkdir -p "$HOME/Screencasts"

timeout 600 "$RECORDER" -g "$GEOMETRY" -f "$OUTPUT_FILE" &
pid=$!

# Save the PID to the file and wait for the process to finish
echo "$pid" >"$PID_FILE"
wait "$pid"
exit_code=$?

# Cleanup PID file after recording finishes
rm -f "$PID_FILE"

# Notify user about the result
if [[ $exit_code -eq 0 ]]; then
    notify-send "Screen Recorder" "Recording saved to:\n$(basename "$OUTPUT_FILE")" -t 5000
elif [[ $exit_code -eq 124 ]]; then
    notify-send "Screen Recorder" "Recording stopped: 10 minute timeout reached" -t 5000
else
    notify-send "Screen Recorder" "Recording stopped unexpectedly" -t 4000
fi
