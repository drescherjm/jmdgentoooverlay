#!/bin/bash

function process_device()
{
        echo Reading from mdraid device ${device}
	dd if=/dev/${device} of=/dev/null bs=16M count=50 > /dev/null
        echo
}

for a in /dev/sd?;
do
        device=${a/\/dev\//}
        grep ${device} /proc/mdstat >> /dev/null
        if [ $? == 0 ];
        then
                process_device
        fi
done

