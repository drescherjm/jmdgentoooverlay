#!/bin/sh
ulimit -l unlimited
/usr/bin/growisofs -Z /dev/cdrom=/mnt/dvd/tmp/mythburndvd.iso -use-the-force-luke=notray -use-the-force-luke=tty -dvd-compat -speed=8
eject /mnt/cdrom

