#!/bin/sh
if [ $# = 0 ]
then
  echo "Usage: `basename $0` device" >&2
  exit 1
fi
ADDR=`/sbin/ifconfig $1 | grep 'inet addr' | awk '{print $2}' | sed -e s/.*://`
HOST=`hostname`.radimg.pitt.edu
echo "update delete $HOST A" > /tmp/nsupdate.txt
echo "update add $HOST 86400 A $ADDR" >> /tmp/nsupdate.txt
echo "send" >> /tmp/nsupdate.txt
nsupdate /tmp/nsupdate.txt
