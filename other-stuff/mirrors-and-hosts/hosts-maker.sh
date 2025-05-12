#!/bin/sh

cd /home/rishabh/other-stuff/mirrors-and-hosts/ &&
    rm -f /home/rishabh/other-stuff/mirrors-and-hosts/hosts &&
    curl -C - --output pro https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/pro.txt &&
    curl -C - --output corn https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts &&
    cat pro corn | uniq >hosts &&
    rm -f pro corn &&
    sudo cp hosts /etc/hosts && sudo chmod 644 /etc/hosts &&
    rm -f /home/rishabh/other-stuff/mirrors-and-hosts/hosts
