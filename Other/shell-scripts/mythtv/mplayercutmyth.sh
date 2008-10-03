#!/bin/bash
# Copyright 2006, Kees Cook <kees@outflux.net>
# License: GNU GPL v2

set -e

#EDL=`mktemp -t edl-XXXXXX`

#echo using "$EDL"

MEDIA="$1"
shift
if [ ! -f "$MEDIA" ]; then
    echo "Play what mythtv recording?" >&2
    exit 1
fi

ID=`echo "$MEDIA" | perl -ne 'print "$1 $2" if /(\d+)_(\d+)[^\d]+$/'`;
CHAN=`echo "$ID" | awk '{print $1}'`
CHAN=$(( CHAN + 0 ))
START=`echo "$ID" | awk '{print $2}'`
START=$(( START + 0 ))

echo "SELECT mark/29.97 FROM recordedmarkup WHERE chanid = $CHAN AND starttime = $START AND (type = 0 OR type = 1) ORDER BY mark;" | mysql -h jmd0 -u mythtv mythconverg -B --skip-column-names | xargs -n2 | awk '{print $0 " 0" }' > cutlist.txt

#"echo 'SELECT mark/29.97 FROM recordedmarkup WHERE chanid = $CHAN AND starttime = $START AND (type = 0 OR type = 1) ORDER BY mark;' | mysql -B --skip-column-names --password=\`grep ^DBPassword= /etc/mythtv/mysql.txt | awk -F= '{print \$2}'\` mythconverg | xargs -l2" 2>/dev/null | awk '{print $0 " 0" }' > "$EDL"

mv  "$MEDIA" "$MEDIA".old

mencoder -of mpeg -idx -oac copy -ovc copy -edl cutlist.txt -o "$MEDIA" "$MEDIA".old

#rm -f "$EDL"
