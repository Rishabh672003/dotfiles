#!/bin/env sh

TMPFILE="$(mktemp)"
export TMPFILE

rate-mirrors --disable-comments --allow-root --save="$TMPFILE" arch --max-delay=21600 \
    && mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup \
    && mv "$TMPFILE" /etc/pacman.d/mirrorlist \
    && chmod 777 /etc/pacman.d/mirrorlist  \
    && bash /home/rishabh/projects/hosts/hosts-maker.sh \
    && journalctl --vacuum-time=2d \
