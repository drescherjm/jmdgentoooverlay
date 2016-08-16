#!/bin/bash

get_drive_info()
{
  if [ -e $1 ]; then
    drv=$1
    drv_serial=$(hdparm -I $1 2>/dev/null | grep "erial N" | sed 's#Serial\ Number:##g')
    drv_temp=$(hddtemp --numeric -u C $1 2>/dev/null)
    if [ ! -z "${drv_temp}" ]; then
    	echo Installing on drive: ${drv} ${drv_serial} ${drv_temp}
	grub-install ${drv}
    fi
  fi
}

for drive in /dev/sd?
do
  get_drive_info ${drive}
done


