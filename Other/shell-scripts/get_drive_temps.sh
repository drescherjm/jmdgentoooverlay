#!/bin/bash

get_drive_info()
{
  if [ -e $1 ]; then
    drv=$1
    drv_serial=$(hdparm -I $1 | grep "erial N" | sed 's#Serial\ Number:##g')
    drv_temp=$(hddtemp --numeric -u C $1 2>/dev/null)
    echo ${drv} ${drv_serial} ${drv_temp}
  fi
}

for drive in /dev/sd?
do
  get_drive_info ${drive}
done


