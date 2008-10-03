#!/bin/sh

DATE=`date '+%e'`


if [ "$#" -gt "0" ]; then
        emerge $@ >> /var/log/world-update-${DATE}.log
else
        emerge -uDv system >> /var/log/world-update-${DATE}.log
fi


sh resume-build.sh
