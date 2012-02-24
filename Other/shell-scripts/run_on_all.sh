#!/bin/sh
#

if [ -z "$1" ];
then
echo $0 "<commands>"
else
COMMAND="$@"
stty -echo;
read -p "Input password:" A;
stty echo;
echo;

if [ -z ${SERVERS} ]; then
   SERVERS="datastore0 datastore1 datastore2 datastore3 fileserver dev6 sysserv0 tempdata0"
fi

for HOST in ${SERVERS} 
do

echo "Connecting to $HOST"
expect -c "set timeout -1;\
spawn ssh $HOST -l root ${COMMAND}
match_max 100000;\
expect *assword:*;\
send -- $A\r;\
interact;"
echo "Finished job on $HOST"

done
fi
