#!/bin/env bash

if ! pgrep -x wayle >/dev/null; then status=$?; fi

if [ "$status" -eq 0 ]; then
	exec wayle panel start
else
	killall -9 wayle && exec wayle panel start
fi
