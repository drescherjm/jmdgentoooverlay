#!/bin/sh
 
# === ARGUMENTS PARSING ===
 
# We don't want to define a default period
PERIOD=
 
while echo $1 | grep ^- > /dev/null; do
 
    if [ "$1" = "--daily" ]; then
        PERIOD=daily
    fi
 
    if [ "$1" = "--monthly" ]; then
        PERIOD=monthly
    fi
 
    if [ "$1" = "--period" ]; then
        PERIOD=$2
        shift
    fi
 
    shift
done
 
if [ "${PERIOD}" = "" ]; then
        echo "You have to define a period  with the --period arg !" >&2
        exit 1
fi
 
# === END OF ARGUMENTS PARSING ===
 
# === PARAMETERS ===
 
# * Device we will use
DISK=/auto/btrfs-root
 
# * Subvolume used for the backup
SUBVOLUME=${DISK}/gentoo-root
 
# * Current date (you could limit the date to +%Y-%m-%d)
DATE=`/bin/date +%Y-%m-%d_%H-%M-%S`
 
# * snapshot directory that will be used
SNAPDIR=${DISK}/snapshots/gentoo-root
 
# * snapshot volume that will be used
SNAPVOL=${SNAPDIR}/${PERIOD}-${DATE}
 
# * max days to keep daily backups
MAX_DAYLY=60
 
# * max days to keep monthly backups
MAX_MONTHLY=365
 
# * Alert limit
LIMIT_ALERT=95
 
# * High limit
LIMIT_HIGH=90
 
# * Low limit
LIMIT_LOW=85
 
# === END OF PARAMETERS ===
 
# We get the space used over the total allocated space and the total percentage use.
# This is NOT the device total size but it's a lot more reliable than "df -h"
DISK_USED=`/sbin/btrfs filesystem df ${DISK}|grep Data|grep -Po "used=([0-9]*)"|cut -d= -f2`
DISK_TOTAL=`/sbin/btrfs filesystem df ${DISK}|grep Data|grep -Po "total=([0-9]*)"|cut -d= -f2`
DISK_PERC=`echo 100*${DISK_USED}/${DISK_TOTAL}|bc`
 
# We create the snapshot dir if it doesn't exist
if [ ! -d ${SNAPDIR} ]; then
        mkdir -p ${SNAPDIR}
fi
 
cd ${SNAPDIR}
 
# If we are over the low free space limit,
# we delete two days of daily backup.
if [ $DISK_PERC -gt $LIMIT_LOW ]; then
        echo "LOW LIMIT reached: $DISK_PERC > $LIMIT_LOW : Deleting 2 days" >&2
 
        OLDEST_FILES=`ls --sort=time -r|grep "daily-.*"|head -2`
        for file in $OLDEST_FILES; do
                /sbin/btrfs subvolume delete $file;
        done
 
fi
 
# If we are over the high free space limit,
# we delete a month of monthly backup
if [ $DISK_PERC -gt $LIMIT_HIGH ]; then
        echo "HIGH LIMIT reached: $DISK_PERC > $LIMIT_HIGH : Deleting 1 month" >&2
 
        OLDEST_FILES=`ls --sort=time -r|grep "monthly-.*"|head -1`
        for file in $OLDEST_FILES; do
                /sbin/btrfs subvolume delete $file;
        done
 
fi
 
# If we are over the alert free space limit,
# we delete the first two oldest files we can find
if [ $DISK_PERC -gt $LIMIT_ALERT ]; then
        echo "ALERT LIMIT reached: $DISK_PERC > $LIMIT_ALERT : Deleting the 2 oldest" >&2
 
        OLDEST_FILES=`ls --sort=time -r|head -2`
        for file in $OLDEST_FILES; do
                /sbin/btrfs subvolume delete $file;
        done
fi
 
 
# We touch the subvolume to change the modification date
touch ${SUBVOLUME}
 
# We do a snapshot of the subvolume
if [ ! -d "${SNAPVOL}" ]; then
        /sbin/btrfs subvolume snapshot ${SUBVOLUME} ${SNAPVOL}
fi
 
# We delete the backups older than MAX_DAYLY
find ${SNAPDIR} -mindepth 1 -maxdepth 1 -mtime +${MAX_DAYLY} -name "daily-*" -exec /sbin/btrfs subvolume delete {} \;
 
# We delete the backups older than MAX_MONTHLY
find ${SNAPDIR} -mindepth 1 -maxdepth 1 -mtime +${MAX_MONTHLY} -name "monthly-*" -exec /sbin/btrfs subvolume delete {} \;
 
 
# This is the actual backup code
# You need to save your data into the ${SUBVOLUME} directory
 
# We will only do the actual backup for the daily task
if [ "${PERIOD}" = "daily" ]; then
 
rsync -auv /usr/local/bin ${SUBVOLUME}/localhost/usr/local
 
fi

