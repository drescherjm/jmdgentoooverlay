#!/bin/sh

DATE=`date '+%e'`
#echo "************************emerge sync*******************************" > /var/log/world-update-${DATE}.log
emerge --sync >> /var/log/world-update-${DATE}.log

echo "************************emerge -uev world*************************" >> /var/log/world-update-${DATE}.log
emerge -uDv --newuse world >> /var/log/world-update-${DATE}.log
echo "************************emerge --resume --skipfirst*************************" >> /var/log/world-update-${DATE}.log

emerge --resume --skipfirst >> /var/log/world-update-${DATE}.log
emerge --resume --skipfirst >> /var/log/world-update-${DATE}.log
emerge --resume --skipfirst >> /var/log/world-update-${DATE}.log
emerge --resume --skipfirst >> /var/log/world-update-${DATE}.log
emerge --resume --skipfirst >> /var/log/world-update-${DATE}.log
emerge --resume --skipfirst >> /var/log/world-update-${DATE}.log
emerge --resume --skipfirst >> /var/log/world-update-${DATE}.log
emerge --resume --skipfirst >> /var/log/world-update-${DATE}.log
emerge --resume --skipfirst >> /var/log/world-update-${DATE}.log
emerge --resume --skipfirst >> /var/log/world-update-${DATE}.log
emerge --resume --skipfirst >> /var/log/world-update-${DATE}.log
