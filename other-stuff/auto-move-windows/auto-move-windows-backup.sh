#!/usr/bin/env bash

# Backs up and restores auto-move-windows settings 
#command structure - ./auto-move-windows-backup.sh (backup, restore)
set -e

if [[ $1 == 'backup' ]]; then
  dconf dump '/org/gnome/shell/extensions/auto-move-windows/' > auto-move-windows-settings.dconf
  echo "backup done"
  exit 0
fi
if [[ $1 == 'restore' ]]; then
  dconf load '/org/gnome/shell/extensions/auto-move-windows/' < auto-move-windows-settings.dconf
  echo "restore done"
  exit 0
fi

echo "parameter 0: [backup|restore]"



