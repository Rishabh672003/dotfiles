#!/bin/sh

#script that applies the energized ultimate hosts
cd /home/rishabh/projects/hosts/ &&
rm -f /home/rishabh/projects/hosts/hosts&&
curl -C - --output hosts https://block.energized.pro/ultimate/formats/hosts&&
sudo cp hosts /etc/hosts
