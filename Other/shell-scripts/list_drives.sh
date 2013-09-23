#!/bin/sh

for drive in /dev/sd?
do
  echo -n ${drive} " "
  [ -e ${drive} ] && hdparm -I ${drive} | grep "erial N"
  #blkid | grep $drive
  ls -al /dev/disk/by-id/ | grep ${drive}
done

