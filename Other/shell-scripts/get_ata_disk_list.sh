#!/bin/sh

find /dev/disk/by-id/ -iname '*ata*' -and -not -iname '*part*' -and -not -iname '*md-name*' -and -not -iname '*dm-name*' -ls | gawk ' { print $13 } ' | cut -f3 -d/ | sed -e 's/\(.*\)/\/dev\/\1/'|sort -u
