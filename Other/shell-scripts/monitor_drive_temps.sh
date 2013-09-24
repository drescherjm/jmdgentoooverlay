#!/bin/bash

# Escape code
esc=`echo -en "\033"`

# Set colors
cc_red="${esc}[0;31m"
cc_green="${esc}[0;32m"
cc_yellow="${esc}[0;33m"
cc_blue="${esc}[0;34m"
cc_normal=`echo -en "${esc}[m\017"`

trim() {
    local var=$@
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

debug_echo()
{
  if [ ! -z "${DEBUG_TEMPS}" ]; then
    echo $@
  fi
}

verbose_echo()
{
  if [ ! -z "${VERBOSE_OUTPUT}" ]; then
    echo $@
  fi
}


log_echo()
{
  if [ -e "${LOGGER}" ]; then
    ${LOGGER} -s $@
  fi
}

verify_drive_temps()
{
   local drive_temp=$2

   if [[ ${drive_temp} =~ ^[0-9]+$ ]]; then
     local serial_number=$(trim $1)
     local warn_temp=${DEFAULT_WARN_TEMP}
     local crit_temp=${DEFAULT_CRIT_TEMP}

     if [ -f ${DRIVE_SETTINGS_FILE} ]; then
       local line=$(grep ${serial_number} ${DRIVE_SETTINGS_FILE})
       debug_echo ${line}

       local warn_temp_override=$(echo ${line} | awk '{ print $2 }')
       local crit_temp_override=$(echo ${line} | awk '{ print $3 }')

       #echo ${warn_temp_override} ${crit_temp_override}

       if [[ ${warn_temp_override} =~ ^[0-9]+$ ]]; then
         warn_temp=${warn_temp_override}
       fi 

       if [[ ${crit_temp_override} =~ ^[0-9]+$ ]]; then
         crit_temp=${crit_temp_override}
       fi 
     fi

     if [ ${drive_temp} -ge ${warn_temp} ]; then
       let warn++

       
       if [ -z "${VERBOSE_OUTPUT}" ]; then
         echo -n "${drive} ${serial_number} "
       fi

       echo -n "Temp=${drive_temp} "
 
       if [ ${drive_temp} -ge ${crit_temp} ]; then
         let crit++
         echo "${cc_red} WARN=${warn_temp} CRIT=${crit_temp} ${cc_normal}"
         log_echo "CRITICAL: ${drive} ${serial_number} Temp=${drive_temp} WARN=${warn_temp} CRIT=${crit_temp}"

       else
         echo "${cc_red} WARN=${warn_temp} ${cc_normal} CRIT=${crit_temp}"
         log_echo "WARNING: ${drive} ${serial_number} Temp=${drive_temp} WARN=${warn_temp} CRIT=${crit_temp}"
       fi
     else
       let okay++
     fi
 
   else
	log_echo "WARNING: The temperature could not be parsed for drive ${drive} ${serial_number} from the following: ${drive_temp}"
   fi  

}

get_drive_info()
{
  if [ -e $1 ]; then
    drv=$1
    drv_serial=$(hdparm -I $1 | grep "erial N" | sed 's#Serial\ Number:##g')
    drv_temp=$(hddtemp --numeric -u C $1 2>/dev/null)
    verbose_echo ${drv} ${drv_serial} ${drv_temp}
    verify_drive_temps "${drv_serial}" "${drv_temp}"
  fi
}

# This function will check the temperatures on all drives in the system and keep a count of how many drives are okay or in a warning or critical state
check_temps()
{
  warn=0 
  crit=0
  okay=0

  for drive in /dev/sd?
  do
    get_drive_info ${drive}
  done
}


MON_RETRY_DELAY=60
DEFAULT_WARN_TEMP=32
DEFAULT_CRIT_TEMP=35
DRIVE_SETTINGS_FILE="/root/shell-scripts/data/drive_temp_limits.txt"
LOGGER="/usr/bin/logger"
SHUTDOWN=/sbin/shutdown

check_temps

if [ ${warn} -gt 0 ] || [ ${crit} -gt 0 ]; then
  echo "OKAY=${okay} WARN=${warn} CRIT=${crit}"

  if [ ${crit} -gt ${okay} ]; then
    log_echo "CRITICAL: There are ${crit} drives are are over their threshold temperatures."

    if [ -z "${DISABLE_SHUTDOWN}" ] && [ -e ${SHUTDOWN} ]; then

      # Wait a few minutes and test again
      sleep ${MON_RETRY_DELAY}
      check_temps

      if [ ${crit} -gt ${okay} ]; then

	# The test failed again. We will now issue a shutdown

        log_echo "CRITICAL: There are ${crit} drives are are over their threshold temperatures on the second try. The system will shutdown to reduce the chance of damage to the drives."
        sync;sync
        ${SHUTDOWN} -h 0
      fi
    fi
  fi 
fi

