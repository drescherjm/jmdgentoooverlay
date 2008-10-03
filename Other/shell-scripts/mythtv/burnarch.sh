#!/bin/sh
ulimit -l unlimited
/usr/bin/growisofs -Z /dev/dvd=/tmp/work/mythburn.iso -use-the-force-luke=notray -use-the-force-luke=tty -dvd-compat -speed=4
eject /dev/dvd

