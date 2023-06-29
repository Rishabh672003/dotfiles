#!/bin/env bash

export pid
pid=$(pgrep waybar)
status=$?

if [ $status != 0 ]; then
    exec waybar;
else
    killall -9 waybar && waybar
fi
