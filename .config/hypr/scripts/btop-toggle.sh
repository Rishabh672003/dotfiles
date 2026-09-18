#!/bin/sh
# Toggle a floating btop terminal (matched by foot app-id).
pkill -f 'app-id=btop-float' || exec foot --app-id=btop-float btop
