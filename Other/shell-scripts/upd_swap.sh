#!/bin/sh

blkid | grep swap | awk ' { print $2 }' | sed -e 's/UUID=//g' -e 's/\"//g' | 
xargs -n 1 -i echo /dev/disk/by-uuid/{} none swap sw 0 0 >> /etc/fstab
