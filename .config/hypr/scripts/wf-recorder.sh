#!/bin/sh

export pid
pid=$(pgrep wf-recorder)
status=$?

if [ $status != 0 ]
then
    timeout 600 wf-recorder -g "$(slurp)" -F fps=30 -f ~/Screencasts/"$(date +'recording_%Y-%m-%d-%H%M%S.mp4')" || exit
else
    pkill --signal SIGINT wf-recorder
fi;
