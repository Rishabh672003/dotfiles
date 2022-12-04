#!/bin/bash

sleep 1;
killall xdg-desktop-portal-wlr &&
killall xdg-desktop-portal &&
/usr/lib/xdg-desktop-portal-wlr &
sleep 1
/usr/lib/xdg-desktop-portal &
