#!/bin/bash

function process_device()
{
        echo -n ${device}
        hdparm -I /dev/${device} | grep "al Number"
        smartctl --all /dev/${device} | grep -e "Reallocated_Sector_Ct" -e "Current_Pending_Sector" -e "Offline_Uncorrectable" -e "UDMA_CRC_Error_Count" -e "Hardware_ECC_Recovered"

	smartctl --all /dev/${device} | grep FIRMWARE -C 10
        echo
}

for a in /dev/sd?;
do
        device=${a/\/dev\//}
        process_device
done

