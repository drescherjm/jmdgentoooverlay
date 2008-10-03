#!/bin/sh
# Copyright 2006, Kees Cook <kees@outflux.net>
# License: GNU GPL v2

MEDIA=""

function update_database {
   echo "update recorded set hostname='jmd1' where basename='${BASENAME}.mpg' AND hostname = 'jmd0' ;" | mysql -h jmd0 -u mythtv mythconverg
}

function init_vars {
  MEDIA="$1"

  ID=`echo "$MEDIA" | perl -ne 'print "$1 $2" if /(\d+)_(\d+)[^\d]+$/'`;
  CHAN=`echo "$ID" | awk '{print $1}'`
  CHAN=$(( CHAN + 0 ))
  START=`echo "$ID" | awk '{print $2}'`
  START=$(( START + 0 ))   

  BASENAME=${CHAN}_${START}

}

init_vars $@

update_database
