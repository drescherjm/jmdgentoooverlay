#!/bin/sh
#

if [ -z "$1" ];
then
echo $0 "<commands>"
else
COMMAND="$@"

if [ -z "${SERVERS}" ]; then
   source /root/servers.sh 2> /dev/null
fi

if [ -z "${SERVERS}" ]; then
   SERVERS="datastore0 datastore1 datastore2 datastore3 datastore4 fileserver dev6 sysserv0 tempdata0"
fi

for HOST in ${SERVERS} ${SERVERS_EXTRA}
do

echo "Connecting to $HOST"
ssh -o PasswordAuthentication=no $HOST -l root ${COMMAND}
echo "Finished job on $HOST"

done
fi
