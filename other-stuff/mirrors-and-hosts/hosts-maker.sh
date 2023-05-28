#!/bin/sh

#script that applies the energized ultimate hosts
cd /home/rishabh/projects/hosts/ &&
rm -f /home/rishabh/projects/hosts/hosts&&
curl -C - --output hosts https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/pro.txt &&
sudo cp hosts /etc/hosts
