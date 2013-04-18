#!/bin/bash

function process_device()
{
    echo Reading from mdraid device ${device}
	dd if=/dev/${device} of=/dev/null bs=16M count=100 &> ${device}.txt &
    echo
}


if [ ! -z "$1" ]; then

	for a in /dev/sd?;
	do
			device=${a/\/dev\//}
			grep ${device} /proc/mdstat | grep $1 >> /dev/null
			if [ $? == 0 ];
			then
					process_device
			fi
	done

else
  echo "USAGE: $0 <mdraidarray>"
fi
