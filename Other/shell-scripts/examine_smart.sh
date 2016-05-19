#!/bin/bash

function process_device()
{
        echo -n ${device}
        hdparm -I /dev/${device} | grep "al Number"
        smartctl --all /dev/${device} | grep -e "Reallocated_Sector_Ct" -e "Current_Pending_Sector" -e "Offline_Uncorrectable" -e "UDMA_CRC_Error_Count" -e "Hardware_ECC_Recovered" -e "Command_Timeout" -e "Power_On_Hours"

	smartctl --all /dev/${device} | grep FIRMWARE -C 10
        echo
}

date

for a in /dev/sd?;
do
        device=${a/\/dev\//}
        process_device
done

