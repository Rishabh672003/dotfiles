#!/bin/bash

max_volume=100 # in percent

pactl subscribe |
	grep --line-buffered 'sink ' |
	stdbuf -o0 cut -d# -f2 |
	while read -r index; do
		volume=$(pactl get-sink-volume "$index" | head -n1 | cut -d/ -f2 | tr -d ' %')
		if [[ $volume -ge max_volume ]]; then
			pactl set-sink-volume "$index" $max_volume%
		fi
	done
