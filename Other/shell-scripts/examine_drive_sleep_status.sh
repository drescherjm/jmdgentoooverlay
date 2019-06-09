#!/bin/bash

for device in /dev/sd?; 
do         
	hdparm -C ${device}; 
done
