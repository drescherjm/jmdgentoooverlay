#!/bin/bash

verify_drive_temps()
{
   local serial_number=$1
   local warn_temp=${DEFAULT_WARN_TEMP}
   local crit_temp=${DEFAULT_CRIT_TEMP}

   if [ -f ${DRIVE_SETTINGS_FILE} ]; then
     local line=$(grep ${serial_number} ${DRIVE_SETTINGS_FILE})
     #echo ${line}

     local warn_temp_override=$(echo ${line} | awk '{ print $2 }')
     local crit_temp_override=$(echo ${line} | awk '{ print $3 }')

     echo ${warn_temp_override} ${crit_temp_override}
   fi

}

verify_drive_temps_old()
{
   local serial_number=$1
   local warn_temp=${DEFAULT_WARN_TEMP}
   local crit_temp=${DEFAULT_CRIT_TEMP}

   name=$(echo $(echo DRIVE_${serial_number}_CRIT_TEMP))
  
   echo ${!name}

   eval "echo DRIVE_${!serial_number}_CRIT_TEMP"

   echo $DRIVE_${!serial_number}_CRIT_TEMP


#   local warn_override=$(eval ${DRIVE_${!serial_number}_CRIT_TEMP})


 #  if [! -z "${warn_override}" ]; then
 #    echo ${warn_override}
 #  fi
}


get_drive_info()
{
  if [ -e $1 ]; then
    drv=$1
    drv_serial=$(hdparm -I $1 | grep "erial N" | sed 's#Serial\ Number:##g')
    drv_temp=$(hddtemp --numeric -u C $1 2>/dev/null)
    echo ${drv} ${drv_serial} ${drv_temp}
    verify_drive_temps ${drv_serial}
  fi
}

DEFAULT_WARN_TEMP=30
DEFAULT_CRIT_TEMP=35
DRIVE_SETTINGS_FILE="/root/shell-scripts/data/drive_temp_limits.txt"

#if [ -f ${DRIVE_SETTINGS_FILE} ]; then
#   source ${DRIVE_SETTINGS_FILE}
#fi


for drive in /dev/sd?
do
  get_drive_info ${drive}
done

