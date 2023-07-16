#!/bin/env bash

sudo reflector --country "France, Germany, Norway, Australia, Sweden,United States" \
    --verbose \
    --sort rate \
    --protocol https,http \
    --save /etc/pacman.d/mirrorlist
