#!/bin/sh
# Author: John M. Drescher
# License: GNU GPL v2

MEDIA=""
HOSTNAME=`uname -n`
DBSERVER='jmd1'
DBUSER='mythtv'

function update_filesize {
   FILESIZE=`du -b "${MEDIA}" | cut -f 1`
   if [ "${FILESIZE}" -gt 1000000 ]; then
      echo "update recorded set filesize=${FILESIZE} where basename='${BASENAME}.mpg';" | mysql -h ${DBSERVER} -u ${DBUSER} mythconverg
      mythcommflag -f "${MEDIA}" --clearcutlist
   fi
}

function update_database {
   update_filesize
   echo "update recorded set hostname='${HOSTNAME}' where basename='${BASENAME}.mpg';" | mysql -h ${DBSERVER} -u ${DBUSER} mythconverg
}

function init_vars {
  MEDIA="$1"

  if [ ! -f "$MEDIA" ]; then
    echo "Fix what mythtv recording?" >&2
    exit 1
  fi

  ID=`echo "$MEDIA" | perl -ne 'print "$1 $2" if /(\d+)_(\d+)[^\d]+$/'`;
  CHAN=`echo "$ID" | awk '{print $1}'`
  CHAN=$(( CHAN + 0 ))
  START=`echo "$ID" | awk '{print $2}'`
  START=$(( START + 0 ))   

  BASENAME=${CHAN}_${START}

}

init_vars $@

update_database
