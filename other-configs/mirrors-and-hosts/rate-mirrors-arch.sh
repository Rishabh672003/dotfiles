#!/bin/env sh

TMPFILE="$(mktemp)"
export TMPFILE
sudo true; \
    rate-mirrors --disable-comments --allow-root --save="$TMPFILE" arch --max-delay=21600 \
    && sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup \
    && sudo mv "$TMPFILE" /etc/pacman.d/mirrorlist \
    && sudo chmod 777 /etc/pacman.d/mirrorlist  \
    && sudo bash /home/rishabh/projects/hosts/hosts-maker.sh \
    && sudo journalctl --vacuum-time=2d \
