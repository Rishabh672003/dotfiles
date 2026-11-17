#!/usr/bin/env bash
set -euo pipefail

dnd="$(wayle notify is-dnd)"

if [[ "$dnd" == true ]]; then
    wayle notify dnd >/dev/null
    notify-send -t 2000 'Do Not Disturb off'
else
    notify-send -t 2000 'Do Not Disturb on'
    wayle notify dnd >/dev/null
fi
