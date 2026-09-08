#!/usr/bin/env bash
# Lock the session before the system sleeps (lid close / suspend).
# hypridle on this system can only exec a single bare path with no args,
# so any multi-step logic must live in a script like this one.

# Don't stack a second locker if one is already up.
if ! pidof hyprlock >/dev/null 2>&1; then
    "$HOME/.config/hypr/scripts/lock.sh" &
fi

# Give hyprlock a moment to grab the session lock before we actually sleep.
sleep 1
