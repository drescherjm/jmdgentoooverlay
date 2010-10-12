#!/bin/sh

for drive in sda sdb sdc sdd sde sdf sdg
do
  echo -n $drive " "
  [ -e /dev/$drive ] && hdparm -I /dev/$drive | grep "erial N"
  #blkid | grep /dev/$drive
  ls -al /dev/disk/by-id/ | grep $drive
done

