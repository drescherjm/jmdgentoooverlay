#! /bin/bash

BASENAME=`echo $1 | sed -e 's#.*/##g' -e's/\..*//'`

update_database() {
FILESIZE=`du -b $1 | cut -f 1`
echo "update recorded set filesize=${FILESIZE} where basename='${BASENAME}.mpg';" | mysql -h jmd0 -u mythtv mythconverg
}

update_database $@
