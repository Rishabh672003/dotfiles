#!/bin/bash

sleep 3
killall xdg-desktop-portal-hyprland
killall xdg-desktop-portal-wlr
killall xdg-desktop-portal

/usr/libexec/xdg-desktop-portal-hyprland &
sleep 3

/usr/lib/xdg-desktop-portal &
