#!/bin/bash

while true; do
	hour=$(date +%H)
	minute=$(date +%M)

	# Convert the current time to minutes past midnight
	currentminutes=$((hour * 60 + minute))

	if [[ $currentminutes -ge 390 ]] && [[ $currentminutes -lt 1440 ]]; then
		# During morning hours (06:30 to 23:00)
		if ! pgrep -x "wpaperd" >/dev/null; then
			wpaperd &
		fi
		if pgrep -x "swaybg" >/dev/null; then
			killall -9 swaybg
		fi
	else
		# During night hours (23:00 to 06:30)
		if ! pgrep -x "swaybg" >/dev/null; then
			swaybg -i ~/Pictures/Wallpapers/wallpapers/Milky_Way.jpg &
		fi
		if pgrep -x "wpaperd" >/dev/null; then
			killall -9 wpaperd
		fi
	fi

	# Wait for a minute before checking again
	sleep 60
done
