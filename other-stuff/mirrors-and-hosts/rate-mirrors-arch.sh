#!/bin/env sh

TMPFILE="$(mktemp)"
export TMPFILE

rate-mirrors --disable-comments-in-file --save="$TMPFILE" arch &&
    sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup &&
    sudo mv "$TMPFILE" /etc/pacman.d/mirrorlist &&
    sudo chmod 644 /etc/pacman.d/mirrorlist &&
    sudo chown root /etc/pacman.d/mirrorlist &&
    rate-mirrors --disable-comments chaotic-aur |
    sudo tee /etc/pacman.d/chaotic-mirrorlist &&
    bash /home/rishabh/other-stuff/mirrors-and-hosts/hosts-maker.sh &&
    sudo journalctl --vacuum-time=2d
