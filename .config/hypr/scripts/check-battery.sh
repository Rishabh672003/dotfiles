#!/bin/env bash

bat_loc=/sys/class/power_supply/BAT0
bat_status=$(cat "$bat_loc"/status)
bat_cap=$(cat "$bat_loc"/capacity)

checkBatteryInfo(){
    echo "charge"
    if [ "$bat_cap" = 15 ] && [ "$bat_status" == Discharging ]; then
        notify-send "Battery Low";

    elif [ "$bat_cap" == 8 ] && [ "$bat_status" == Discharging ] ; then
        notify-send "Battery Insanely Low"
    fi
}

while true
do
    checkBatteryInfo
    sleep 60s
done
