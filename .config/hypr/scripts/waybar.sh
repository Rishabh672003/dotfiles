#!/bin/env bash

if ! pgrep -x waybar >/dev/null; then status=$?; fi

if [ "$status" -eq 0 ]; then
	exec waybar
else
	killall -9 waybar && exec waybar
fi
