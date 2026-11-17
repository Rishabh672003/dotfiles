#!/usr/bin/env bash
# grimblast computes window rects once before slurp starts, so they go stale if
# you switch workspace mid-selection. Restart the selection on workspace change.
flag="${XDG_RUNTIME_DIR:-/tmp}/grimblast-area.restart"

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" |
  while read -r ev; do
    case $ev in workspace\>\>* | focusedmon\>\>* | activespecial\>\>*)
      pgrep -x slurp >/dev/null && : >"$flag" && pkill -x slurp ;;
    esac
  done &
watcher=$!
trap 'pkill -P $watcher; kill $watcher 2>/dev/null; rm -f "$flag"' EXIT

while :; do
  rm -f "$flag"
  "$HOME/.local/bin/grimblast" "$@" && break
  [[ -e $flag ]] || exit 1 # real cancel (Esc), not our restart
done
