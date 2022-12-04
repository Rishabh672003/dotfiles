#!/bin/bash

sleep 3
killall xdg-desktop-portal-wlr
killall xdg-desktop-portal
/usr/lib/xdg-desktop-portal-wlr &
sleep 3
/usr/lib/xdg-desktop-portal &
