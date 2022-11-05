#!/usr/bin/env bash

choice=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown" | wofi -dmenu)
if [[ $choice == "Lock" ]];then
    bash ~/.config/hypr/scripts/lock.sh
    elif [[ $choice == "Logout" ]];then
    pkill -KILL -u "$USER"
    elif [[ $choice == "Suspend" ]];then
    systemctl suspend
    elif [[ $choice == "Reboot" ]];then
    systemctl reboot
    elif [[ $choice == "Shutdown" ]];then
    systemctl poweroff
fi
