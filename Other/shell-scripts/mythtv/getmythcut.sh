#!/bin/sh
# Copyright 2006, Kees Cook <kees@outflux.net>
# License: GNU GPL v2

set -e

MEDIA="$1"
EDL=`mktemp -t edl-XXXXXX`

cat "$EDL"

if [ ! -f "$MEDIA" ]; then
    echo "Play what mythtv recording?" >&2
    exit 1
fi

ID=`echo "$MEDIA" | perl -ne 'print "$1 $2" if /(\d+)_(\d+)[^\d]+$/'`;
CHAN=`echo "$ID" | awk '{print $1}'`
CHAN=$(( CHAN + 0 ))
START=`echo "$ID" | awk '{print $2}'`
START=$(( START + 0 ))

echo "SELECT mark/29.97 FROM recordedmarkup WHERE chanid = $CHAN AND starttime = $START AND (type = 0 OR type = 1) ORDER BY mark;" | mysql -h jmd0 -u mythtv mythconverg -B --skip-column-names | xargs -n2 | awk '{print $0 " 0" }' > "$EDL"

VAL=`wc  "$EDL" | awk '{ print $1 }'`

if [ $VAL -gt 2 ]; then
    mv  "$MEDIA" "$MEDIA".old
    mencoder -of mpeg -idx -oac copy -ovc copy -edl "$EDL" -o "$MEDIA" "$MEDIA".old
    if [ $? -eq 0 ]; then
       mv "$MEDIA".old "$MEDIA".bak
    fi
fi


