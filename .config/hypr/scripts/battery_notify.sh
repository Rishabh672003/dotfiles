#!/usr/bin/env bash

SLEEP_TIME=30
full_flag=0
low_flag=0
crit_flag=0
vcrit_flag=0
while true; do
    capc=$(cat /sys/class/power_supply/BAT0/capacity)
    if [[ $(cat /sys/class/power_supply/BAT0/status) != "Discharging" ]]; then # -- charging state
        shutdown -c                                                               # -- closing the pending shutdowns from critical shutdown action
        low_flag=0
        crit_flag=0
        vcrit_flag=0
        if (("$capc" == 100)); then
            if ((full_flag != 1)); then
                notify-send "    Battery FULL" "are you planning to blast me!!\ndetach that fuckin charger man.."
                full_flag=1
            fi
        fi
        SLEEP_TIME=30

    else # -- discharging state

        full_flag=0
        if (("$capc" >= 60)); then
            SLEEP_TIME=40
        else
            SLEEP_TIME=30
            if (("$capc" <= 50)); then
                SLEEP_TIME=20
                if ((low_flag != 1)); then
                    notify-send "    Battery LOW" "\nFind the charger , already.." -u low -t 6000
                    low_flag=1
                fi

            fi
            if (("$capc" <= 5)); then
                SLEEP_TIME=15
                if ((crit_flag != 1)); then
                    notify-send "    CRITICAL level reached" "Plug-in that fuckin charger\ni'm gonna die...." -u critical -t 8000
                    crit_flag=1
                fi
            fi
            if (("$capc" <= 3)); then
                SLEEP_TIME=10
                if ((vcrit_flag != 1)); then
                    notify-send "    Out Of Juice" "SHUTDOWN in 1 minute..\nta da!!" -u critical -t 10000
                    shutdown
                    vcrit_flag=1
                fi

            fi
        fi

    fi
    #echo ""$capc" sl_time = $SLEEP_TIME"
    sleep $SLEEP_TIME
done
