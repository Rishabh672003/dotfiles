#!/bin/bash
# Backs up and restores material-shell's settings
#command structure - ./material-shell-backup.sh (backup, restore)
set -e

if [[ $1 == 'backup' ]]; then
    dconf dump '/org/gnome/shell/extensions/materialshell/' > material-shell-settings.dconf
    echo "backup done"
    exit 0
fi
if [[ $1 == 'restore' ]]; then
    dconf load '/org/gnome/shell/extensions/materialshell/' < material-shell-settings.dconf
    echo "restore done"
    exit 0
fi

echo "parameter 0: [backup|restore]"
