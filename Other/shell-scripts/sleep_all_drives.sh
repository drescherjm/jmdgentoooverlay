#!/bin/bash

for device in /dev/sd?; 
do         
	hdparm -y ${device}; 
done
