#!/bin/sh

cd /home/rishabh/other-stuff/mirrors-and-hosts/ &&
rm -f /home/rishabh/other-stuff/mirrors-and-hosts/hosts &&
curl -C - --output hosts https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/pro.txt &&
sudo cp hosts /etc/hosts && sudo chmod 644 /etc/hosts &&
rm -f /home/rishabh/other-stuff/mirrors-and-hosts/hosts
