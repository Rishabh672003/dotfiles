#!/bin/env sh

TMPFILE="$(mktemp)"
export TMPFILE

rate-mirrors --disable-comments --allow-root --save="$TMPFILE" arch --max-delay=21600 \
    && sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup \
    && sudo mv "$TMPFILE" /etc/pacman.d/mirrorlist \
    && sudo chmod 644 /etc/pacman.d/mirrorlist \
    && sudo chown root /etc/pacman.d/mirrorlist \
    && bash /home/rishabh/other-stuff/mirrors-and-hosts/hosts-maker.sh \
    && journalctl --vacuum-time=2d \
