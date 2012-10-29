#!/bin/bash

function process_device()
{
   echo -n $1 " "
   sgdisk -p $1 | grep GUID
}

for a in /dev/sd?;
do
	process_device ${a}
done

